//
//  TSMomentNetworkManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态相关网络请求

import UIKit
import ObjectMapper

class TSMomentNetworkManager: NSObject {

    // MARK: - 打赏
    // 打赏某条动态
    func reward(price: Int, momentId: Int, complete: @escaping((_ message: String?, _ result: Bool) -> Void)) {
        guard price > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSMomentNetworkRequest().reward
        var parameter: [String : Any] = ["amount": price]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parameter.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(momentId)"), parameter: parameter, complete: { (networkResponse, result) in
            var message: String?
            // 请求失败处理
            guard result else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse) ?? "提示信息_网络错误".localized
                complete(message, false)
                return
            }
            // 请求成功处理
            message = TSCommonNetworkManager.getNetworkSuccessMessage(with: networkResponse) ?? "打赏成功"
            complete(message, true)
        })
    }

    // 打赏列表
    func rewardList(momentID: Int, maxID: Int?, complete: @escaping((_ data: [TSNewsRewardModel]?, _ result: Bool) -> Void)) {
        guard momentID > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSMomentNetworkRequest().rewardList
        var parameter: Dictionary<String, Any> = ["limit": TSAppConfig.share.localInfo.limit]
        if let maxID = maxID {
            parameter["since"] = maxID
        }
        parameter["order"] = "desc"
        parameter["order_type"] = "date"
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(momentID)"), parameter: parameter, complete: { (networkResponse, result) in
            guard result == true else {
                complete(nil, false)
                return
            }
            let data = Mapper<TSNewsRewardModel>().mapArray(JSONObject: networkResponse)
            complete(data, true)
        })
    }

    /// 设置动态置顶
    ///
    /// - Parameters:
    ///   - feedId: 动态 id
    ///   - days: 置顶天数
    ///   - amount: 置顶金额
    ///   - complete: 结果
    func set(feed feedId: Int, toTopDuring days: Int, withMoney amount: Int, complete: @escaping((Bool, String?) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)" + TSURLPathV2.Feed.pinneds.rawValue
        var parametars: [String : Any] = ["day": days, "amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parametars, complete: { (datas: NetworkResponse?, status: Bool) in
            var message: String?
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: datas)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: datas)
            }
            complete(status, message)
        })
    }

    /// 删除动态
    func deleteMoment(_ feedIdentity: Int, complete: @escaping ((_ success: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedIdentity)/currency"

        try! RequestNetworkData.share.textRequest(method: .delete, path: path, parameter: nil) { (data: NetworkResponse?, _) in
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
            }
        }
    }

    /// 收藏/取消收藏某条动态
    func colloction(_ newState: Int, feedIdentity: Int, _ complete: @escaping((Bool) -> Void)) {

        let collectPath = newState == 1 ? TSURLPathV2.Feed.collection.rawValue : TSURLPathV2.Feed.uncollect.rawValue
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedIdentity)" + collectPath

        try! RequestNetworkData.share.textRequest(method: newState == 1 ? .post : .delete, path: path, parameter: nil) { (data: NetworkResponse?, _) in
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
            }
        }
    }

    /// 点赞 / 取消点赞
    ///
    /// - Parameters:
    ///   - isDigg: 状态，1 表示点赞，0 表示取消点赞
    ///   - feedIdentity: 动态标识
    ///   - complete: 结果
    func digg(_ newDigg: Int, to feedIdentity: Int, _ complete: @escaping((Bool) -> Void)) {
        let diggPath = newDigg == 1 ? TSURLPathV2.Feed.like.rawValue : TSURLPathV2.Feed.unlike.rawValue
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedIdentity)" + diggPath
        try! RequestNetworkData.share.textRequest(method: newDigg == 1 ? .post : .delete, path: path, parameter: nil) { (data: NetworkResponse?, _) in
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
            }
        }
    }

    func postShortVideo(momentListObject: TSMomentListObject, shortVideoID: Int, coverImageID: Int, feedContent: String?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String : Any] = Dictionary()
        if let content = feedContent {
            param["feed_content"] = content
        }
        param["feed_from"] = 3
        param["video"] = ["video_id": shortVideoID, "cover_id": coverImageID]
        param["feed_mark"] = momentListObject.feedIdentity
        if !momentListObject.topics.isEmpty {
            let topicArr = NSMutableArray()
            for item in momentListObject.topics {
                topicArr.append(item.topicId)
            }
            param["topics"] = topicArr
        }

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ?? "发送失败"]))
                return
            }
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            let feedId = responseDic["id"] as? Int
            complete(feedId, nil)
        })
    }

    /// 发布动态
    ///
    /// - Parameters:
    ///   - feed_content: 动态内容
    ///   - feed_title: 动态标题
    ///   - coordinate: 坐标
    ///   - storageTaskIds: 图片id(服务器返回)
    ///   - feedMark: 用户Id 拼接 时间戳
    ///   - complete: 返回是否成功
    func release(momentListObject: TSMomentListObject, storageTaskIds: Array<Int>?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String : Any] = Dictionary()
        param["feed_content"] = momentListObject.content
        param["feed_mark"] = momentListObject.feedIdentity
        // [长期注释] 暂时没有发布动态时候，发布位置的需求
//        if let coordinate = coordinate {
//            param["latitude"] = coordinate.latitude
//            param["longtitude"] = coordinate.longtitude
//            param["geohash"] = Geohash.encode(latitude: Double(coordinate.latitude)!, longitude: Double(coordinate.longtitude)!)
//        }

        if momentListObject.textPrice > 0 {
            // 价格 单位积分
            param["amount"] = momentListObject.textPrice
        }

//        结构：{ id: <id>, amount: <amount>, type: <read|download> }，amount 为可选，id 必须存在，amount 为收费金额，单位分, type 为收费方式
        var images: Array<Dictionary<String, Any>> = []
        if storageTaskIds != nil {
            for id in storageTaskIds! {
                var dic: Dictionary<String, Any> = [:]
                dic["id"] = id
                images.append(dic)
            }
        }
        // 图片是否付费
        var isImagePay = false
        for picture in momentListObject.pictures {
            if picture.payType != 0 {
                isImagePay = true
                continue
            }
        }
        if isImagePay == true {
            for (index, picture) in momentListObject.pictures.enumerated() {
                if picture.price != 0 {
                    var image = images[index]
                    image["type"] = (picture.payType == 1) ? "download" : "read"

                    // 图片价格，由之前的金额更正为积分
                    image["amount"] = picture.price
                    images[index] = image
                }
            }
        }

        if !images.isEmpty {
            param["images"] = images
        }

        param["feed_from"] = 3

        if !momentListObject.topics.isEmpty {
            let topicArr = NSMutableArray()
            for item in momentListObject.topics {
                topicArr.append(item.topicId)
            }
            param["topics"] = topicArr
        }
        /// 转发
        if let repostType = momentListObject.repostType, momentListObject.repostID > 0 {
            param["repostable_type"] = repostType
            param["repostable_id"] = momentListObject.repostID
        }
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: param, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                    complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                complete(nil, NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ?? "发送失败"]))
                return
            }
            // 服务器数据异常处理
            guard let responseDic = networkResponse as? Dictionary<String, Any> else {
                complete(nil, TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            let feedId = responseDic["id"] as? Int
            complete(feedId, nil)
        })
    }

    /// 获取动态点赞数据,服务器根据时间排序
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - after: 动态id, 获取该值之后的动态
    ///   - limit: 获取动态条数
    ///   - complete:
    ///     - data: 点赞用户数据
    ///     - error: 网络请求相关错误信息
    func getLikeList(feedId: Int, after: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping((_ data: [TSLikeUserModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod = TSFeedsNetworkRequest().likesList
        var parameter = [String: Any]()
        parameter["limit"] = limit
        parameter["after"] = after

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(feedId)"), parameter: parameter) { (datas: NetworkResponse?, status: Bool) in
            guard status == true else {
                complete(nil, .networkErrorFailing)
                return
            }

            guard let likeList = datas as? [Dictionary<String, Any>] else {
                complete(nil, .networkErrorFailing)
                return
            }
            let users = Mapper<TSLikeUserModel>().mapArray(JSONArray: likeList)
            complete(users, nil)
        }
    }

    /// 获取一条动态
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - complete: 完成后的回调
    class func getOneMoment(feedId: Int, complete: @escaping((_ momentObject: TSMomentListObject?, _ error: NSError?, _ resposeInfo: Any?, _ statusCode: Int?) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)"
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status, code) in
            // 1.网络请求失败处理
            guard status else {
                complete(nil, NSError(), data, code)
                return
            }
            // 2.服务器数据异常处理
            guard let moment = data as? Dictionary<String, Any> else {
                complete(nil, NSError(), data, code)
                return
            }
            // 3.正常数据解析
            var model = TSMomentListModel(dataV2: moment)
            /// 需要根据返回的转发ID和type去单独获取转发资源
            if model.moment.repostType == "feeds" {
                // 动态
                let requestPath = TSURLPathV2.path.rawValue + "feeds"
                let parameter: [String: Any] = ["id": model.moment.repostId]
                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (data, status, code) in
                    // 1.网络请求失败处理
                    guard status else {
                        /// 这个地方需要判断一下是否是已经被删除
                        /// 由于是批量获取的动态内容，所以如果被删除的原文，也会请求成功，但是data里边是两个空数组
                        complete(nil, NSError(), data, code)
                        return
                    }
                    // 2.服务器数据异常处理
                    guard let moment = data as? Dictionary<String, Any>, let originalFeeds = moment["feeds"] as? Array<Dictionary<String, Any>> else {
                        /// 说明原文不存在了
                        /// 转发的动态的model
                        let repostModel = TSRepostModel()
                        repostModel.id = 0
                        repostModel.type = .delete
                        repostModel.typeStr = repostModel.type.rawValue
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, 200)
                        return
                    }
                    // 3.正常数据解析
                    let resourceModel = TSMomentListModel(dataV2: originalFeeds[0])
                    // 请求原作者的信息
                    TSTaskQueueTool.getAndSave(userIds: [resourceModel.userIdentity]) { (users, msg, status) in
                        guard let users = users, users.isEmpty == false else {
                            /// 已经删除的原文
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                            return
                        }
                        // TSUserInfoModel
                        let repostModel = TSRepostModel()
                        repostModel.id = resourceModel.moment.feedIdentity
                        repostModel.title = users[0].name
                        repostModel.content = resourceModel.moment.content
                        if let videoID = resourceModel.videoID, videoID > 0 {
                            repostModel.type = .postVideo
                        } else if resourceModel.moment.pictures.count > 0 {
                            repostModel.type = .postImage
                        } else {
                            repostModel.type = .postWord
                        }
                        repostModel.typeStr = repostModel.type.rawValue
                        /// 转发的动态的model
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, code)
                    }
                })
            } else if model.moment.repostType == "news" {
                let requestPath = TSURLPathV2.path.rawValue + "news"
                var parameter: [String: Any] = [:]
                parameter["id"] = model.moment.repostId
                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
                    // 请求失败
                    guard result else {
                        /// 这个地方需要判断一下是否是已经被删除
                        if let code = code, code == 404 {
                            /// 转发的动态的model
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                        } else {
                            complete(nil, NSError(), data, code)
                        }
                        return
                    }
                    // 服务器数据异常
                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
                        /// 已经删除的原文
                        let repostModel = TSRepostModel()
                        repostModel.id = 0
                        repostModel.type = .delete
                        repostModel.typeStr = repostModel.type.rawValue
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, 200)
                        return
                    }
                    let info = datas[0]
                    let repostModel = TSRepostModel()
                    repostModel.id = info["id"] as! Int
                    repostModel.title = info["title"] as? String
                    repostModel.content = info["subject"] as? String
                    repostModel.type = .news
                    repostModel.typeStr = repostModel.type.rawValue
                    if info["image"] != nil {
                        let images = info["image"] as? Dictionary<String, Any>
                        if images != nil {
                            let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: images?["id"] as? Int, compressionRatio: 20, cgSize: nil)
                            repostModel.coverImage = imgUrl?.absoluteString
                        }
                    }
                    /// 转发的动态的model
                    model.moment.repostModel = repostModel
                    let objcet = model.converToObject()
                    TSDatabaseManager().moment.save(moments: [objcet])
                    complete(objcet, nil, data, code)
                })
            } else if model.moment.repostType == "questions" {
                let requestPath = TSURLPathV2.path.rawValue + "questions"
                var parameter: [String: Any] = [:]
                parameter["id"] = model.moment.repostId
                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
                    // 请求失败
                    guard result else {
                        /// 这个地方需要判断一下是否是已经被删除
                        if let code = code, code == 404 {
                            /// 转发的动态的model
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                        } else {
                            complete(nil, NSError(), data, code)
                        }
                        return
                    }
                    // 服务器数据异常
                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
                        /// 已经删除的原文
                        let repostModel = TSRepostModel()
                        repostModel.id = 0
                        repostModel.type = .delete
                        repostModel.typeStr = repostModel.type.rawValue
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, 200)
                        return
                    }
                    let dataDic = datas[0]
                    let repostModel = TSRepostModel()
                    repostModel.id = dataDic["id"] as! Int
                    repostModel.title = dataDic["subject"] as? String
                    repostModel.content = dataDic["body"] as? String
                    repostModel.type = .question
                    repostModel.typeStr = repostModel.type.rawValue
                    /// 转发的动态的model
                    model.moment.repostModel = repostModel
                    let objcet = model.converToObject()
                    TSDatabaseManager().moment.save(moments: [objcet])
                    complete(objcet, nil, data, code)
                })
            } else if model.moment.repostType == "question-answers" {
                let requestPath = TSURLPathV2.path.rawValue + "qa/reposted-answers"
                var parameter: [String: Any] = [:]
                parameter["id"] = model.moment.repostId
                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
                    // 请求失败
                    guard result else {
                        /// 这个地方需要判断一下是否是已经被删除
                        if let code = code, code == 404 {
                            /// 转发的动态的model
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                        } else {
                            complete(nil, NSError(), data, code)
                        }
                        return
                    }
                    // 服务器数据异常
                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
                        /// 已经删除的原文
                        let repostModel = TSRepostModel()
                        repostModel.id = 0
                        repostModel.type = .delete
                        repostModel.typeStr = repostModel.type.rawValue
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, 200)
                        return
                    }
                    let dataDic = datas[0]
                    let repostModel = TSRepostModel()
                    repostModel.id = dataDic["id"] as! Int
                    let questionDic = dataDic["question"] as? Dictionary<String, Any>
                    repostModel.title = questionDic!["subject"] as? String
                    repostModel.content = dataDic["body"] as? String
                    repostModel.type = .questionAnswer
                    repostModel.typeStr = repostModel.type.rawValue
                    /// 转发的动态的model
                    model.moment.repostModel = repostModel
                    let objcet = model.converToObject()
                    TSDatabaseManager().moment.save(moments: [objcet])
                    complete(objcet, nil, data, code)
                })
            } else if model.moment.repostType == "groups" {
                let requestPath = TSURLPathV2.path.rawValue + "plus-group/groups"
                var parameter: [String: Any] = [:]
                parameter["id"] = model.moment.repostId
                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
                    // 请求失败
                    guard result else {
                        /// 这个地方需要判断一下是否是已经被删除
                        if let code = code, code == 404 {
                            /// 转发的动态的model
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                        } else {
                            complete(nil, NSError(), data, code)
                        }
                        return
                    }
                    // 服务器数据异常
                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
                        /// 已经删除的原文
                        let repostModel = TSRepostModel()
                        repostModel.id = 0
                        repostModel.type = .delete
                        repostModel.typeStr = repostModel.type.rawValue
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, 200)
                        return
                    }
                    let dataDic = datas[0]
                    let repostModel = TSRepostModel()
                    repostModel.id = dataDic["id"] as! Int
                    repostModel.title = dataDic["name"] as? String
                    repostModel.content = dataDic["summary"] as? String
                    repostModel.type = .group
                    var avatarObject: TSNetFileModel?
                    if let avatarDic = dataDic["avatar"] as? [String: Any] {
                         avatarObject = TSNetFileModel(JSON: avatarDic)!
                    }
                    repostModel.coverImage = TSUtil.praseTSNetFileUrl(netFile: avatarObject)
                    repostModel.typeStr = repostModel.type.rawValue
                    /// 需要判断是否可以进入圈子详情
                    if let joinedDic = dataDic["joined"] as? Dictionary<String, Any>, joinedDic.count > 0 {
                        // 只要加入了的就可以进入详情
                    } else if let mode = dataDic["mode"] as? String, mode != "public" {
                        repostModel.couldShowDetail = false
                    }
                    /// 转发的动态的model
                    model.moment.repostModel = repostModel
                    let objcet = model.converToObject()
                    TSDatabaseManager().moment.save(moments: [objcet])
                    complete(objcet, nil, data, code)
                })
            } else if model.moment.repostType == "group-posts" {
                let requestPath = TSURLPathV2.path.rawValue + "group/simple-posts"
                var parameter: [String: Any] = [:]
                parameter["id"] = model.moment.repostId
                try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
                    // 请求失败
                    guard result else {
                        /// 这个地方需要判断一下是否是已经被删除
                        if let code = code, code == 404 {
                            /// 转发的动态的model
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                        } else {
                            complete(nil, NSError(), data, code)
                        }
                        return
                    }
                    // 服务器数据异常
                    guard let datas = networkResponse as? [[String : Any]], datas.isEmpty == false else {
                        /// 已经删除的原文
                        let repostModel = TSRepostModel()
                        repostModel.id = 0
                        repostModel.type = .delete
                        repostModel.typeStr = repostModel.type.rawValue
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, 200)
                        return
                    }
                    let dataDic = datas[0]
                    /// 需要去单独请求圈子信息，用来判断当前帖子是否属于私密圈子
                    /// 如果当前帖子是转发至私密圈子，并且当前用户未加入该圈子
                    /// 直接进入圈子预览页面
                    /// 否则直接进入帖子详情
                    let requestDetailPath = TSURLPathV2.path.rawValue + "plus-group/groups"
                    let detailParameter: [String: Any] = ["id": dataDic["group_id"] as! Int]
                    try! RequestNetworkData.share.textRequest(method: .get, path: requestDetailPath, parameter: detailParameter, complete: { (networkResponse, result) in
                        // 请求失败
                        guard result else {
                            /// 这个地方需要判断一下是否是已经被删除
                            if let code = code, code == 404 {
                                /// 转发的动态的model
                                let repostModel = TSRepostModel()
                                repostModel.id = 0
                                repostModel.type = .delete
                                repostModel.typeStr = repostModel.type.rawValue
                                model.moment.repostModel = repostModel
                                let objcet = model.converToObject()
                                TSDatabaseManager().moment.save(moments: [objcet])
                                complete(objcet, nil, data, 200)
                            } else {
                                complete(nil, NSError(), data, code)
                            }
                            return
                        }
                        // 服务器数据异常
                        guard let detailDatas = networkResponse as? [[String : Any]], detailDatas.isEmpty == false else {
                            /// 已经删除的原文
                            let repostModel = TSRepostModel()
                            repostModel.id = 0
                            repostModel.type = .delete
                            repostModel.typeStr = repostModel.type.rawValue
                            model.moment.repostModel = repostModel
                            let objcet = model.converToObject()
                            TSDatabaseManager().moment.save(moments: [objcet])
                            complete(objcet, nil, data, 200)
                            return
                        }
                        let detailDataDic = detailDatas[0]
                        let repostModel = TSRepostModel()
                        /// 需要判断是否可以进入圈子详情
                        if let joinedDic = detailDataDic["joined"] as? Dictionary<String, Any>, joinedDic.count > 0 {
                            // 只要加入了的就可以进入详情
                        } else if let mode = detailDataDic["mode"] as? String, mode != "public" {
                            repostModel.couldShowDetail = false
                        }
                        repostModel.id = dataDic["id"] as! Int
                        repostModel.subId = dataDic["group_id"] as! Int
                        repostModel.title = dataDic["title"] as? String
                        var content = dataDic["summary"] as? String
                        content = content?.ts_standardMarkdownToClearString()
                        repostModel.content = content
                        repostModel.type = .groupPost
                        let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: dataDic["image"] as? Int, compressionRatio: 20, cgSize: nil)
                        repostModel.coverImage = imgUrl?.absoluteString
                        repostModel.typeStr = repostModel.type.rawValue
                        /// 转发的动态的model
                        model.moment.repostModel = repostModel
                        let objcet = model.converToObject()
                        TSDatabaseManager().moment.save(moments: [objcet])
                        complete(objcet, nil, data, code)
                    })
                })
            } else {
                let objcet = model.converToObject()
                TSDatabaseManager().moment.save(moments: [objcet])
                complete(objcet, nil, data, code)
            }
        })
    }
}
