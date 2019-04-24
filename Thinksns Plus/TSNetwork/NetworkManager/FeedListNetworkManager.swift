//
//  FeedListNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表网络请求方法

import UIKit

// MARK: - 对外 API
class FeedListNetworkManager {

    /// 获取某个用户的动态列表
    ///
    /// - Parameters:
    ///   - userId: 用户 id
    ///   - screen: paid-付费动态 pinned - 置顶动态
    ///   - limit: Integer	可选，默认值 20 ，获取条数
    ///   - after: 上次获取到数据最后一条 ID，用于获取该 ID 之后的数据
    ///   - complete: 结果
    class func getUserFeed(userId: Int, screen: String?, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: "users", search: nil, user: userId, screen: screen, complete: complete)
    }

    /// 获取首页动态列表
    ///
    /// - Parameters:
    ///   - type: String	可选，默认值 new，可选值 new 、hot 、 follow
    ///   - limit: Integer	可选，默认值 20 ，获取条数
    ///   - after: 上次获取到数据最后一条 ID，用于获取该 ID 之后的数据
    ///   - hot: 可选，仅 type=hot 时有效，用于热门数据翻页标记！上次获取数据最后一条的 hot 值
    ///   - complete: 结果
    class func getTypeFeeds(type: String, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: type, search: nil, user: nil, screen: nil, complete: complete)
    }

    /// 关键字搜索获取动态列表
    ///
    /// - Parameters:
    ///   - type: String    可选，默认值 new，可选值 new 、hot 、 follow
    ///   - limit: Integer    可选，默认值 20 ，获取条数
    ///   - after: 上次获取到数据最后一条 ID，用于获取该 ID 之后的数据
    ///   - complete: 结果
    class func getSearchFeeds(keyword: String, type: String, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeedsAndRequestUserInfos(limit: limit, after: after, type: type, search: keyword, user: nil, screen: nil, complete: complete)
    }

    /// 获取动态详情
    /// 
    /// - Note: 这个方法只是临时使用的
    class func getFeed(id: Int, complete: @escaping(Bool, TSMomentListModel?) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(id)"
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (datas: NetworkResponse?, _) in
            if let data = datas as? [String: Any] {
                let model = TSMomentListModel(dataV2: data)
                complete(true, model)
                return
            }
            complete(false, nil)
        })
    }

    /// 获取用户收藏的动态
    class func getCollectFeeds(limit: Int = TSAppConfig.share.localInfo.limit, after: Int, complete: @escaping (Bool, String?, [FeedListModel]?) -> Void) {
        // 1.请求 url
        var request = FeedNetworkRequest().collection
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["limit": limit]
        if after >= 0 {
            request.parameter!["offset"] = after
        }
        var models: [FeedListModel]?
        var errorInfo: String?
        // 2.发起请求
        let requestGroup = DispatchGroup()
        requestGroup.enter()
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                errorInfo = "网络请求失败"
            case .failure(let faild):
                errorInfo = faild.message
            case .success(let success):
                models = success.models
            }
            requestGroup.leave()
        }
        requestGroup.notify(queue: DispatchQueue.main) {
            guard errorInfo == nil else {
                complete(false, errorInfo, nil)
                return
            }
            guard let models = models else {
                complete(true, nil, [])
                return
            }
            guard models.isEmpty == false else {
                complete(true, nil, [])
                return
            }

            let userIds = models.map({ (temp) -> Int in
                return temp.userId
            })
            let filterIds = Array(Set(userIds))
            TSUserNetworkingManager().getUserInfo(filterIds, complete: { (_, userInfoModels, _) in
                guard let userInfoModels = userInfoModels else {
                    complete(false, "提示信息_网络错误".localized, [])
                    return
                }
                let results = models.map({ (model) -> FeedListModel in
                    for user in userInfoModels {
                        if model.userId == user.userIdentity {
                            model.userInfo = user
                        }
                    }
                    return model
                })
                complete(true, nil, results)
            })
        }
    }
}

// MARK: - 基于服务器提供的原始接口，增加了获取用户信息逻辑，而封装的 API
extension FeedListNetworkManager {

    /// 批量获取动态，及动态中相关用户信息    
    fileprivate class func getFeedsAndRequestUserInfos(limit: Int = TSAppConfig.share.localInfo.limit, after: Int? = nil, type: String = "new", search: String?, user: Int?, screen: String?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        getFeeds(limit: limit, after: after, type: type, search: search, user: user, screen: screen) { (data: FeedListResultsModel?, message: String?, status: Bool) in
            guard let data = data else {
                complete(nil, message, status)
                return
            }
            let allFeeds = data.pinned + data.feeds
            if allFeeds.isEmpty {
                complete(data, message, status)
                return
            }
            // 请求用户信息
            requestUserInfo(to: allFeeds, complete: { (datas, message, status) in
                guard let datas = datas else {
                    complete(nil, message, false)
                    return
                }
                let model = FeedListResultsModel()
                model.pinned = Array(datas[0..<data.pinned.count])
                model.feeds = Array(datas[data.pinned.count..<datas.count])
                complete(model, message, status)
            })
        }
    }

    /// 根据 [FeedListModel] 中的 userId，请求用户信息，并返回带有用户信息的 [FeedListModel]
    fileprivate class func requestUserInfo(to feeds: [FeedListModel], complete: @escaping ([FeedListModel]?, String?, Bool) -> Void) {
        // 1.取出所有用户信息，过滤重复信息
        let userIds = Array(Set(feeds.flatMap { $0.userIds() }))
        // 2.发起网络请求
        TSUserNetworkingManager().getUserInfo(userIds) { (_, models, _) in
            guard let models = models else {
                // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                // 就先写一个假的数据，等这 API 更新后再替换
                complete(nil, "获取信息失败，请检查网络设置", false)
                return
            }
            // 3.将用户信息和动态信息匹配
            let userDic = models.toDictionary { $0.userIdentity }
            for feed in feeds {
                feed.set(userInfos: userDic)
            }
            complete(feeds, nil, true)
        }
    }
}

// MARK: - 服务器提供的原始接口
extension FeedListNetworkManager {

    /// 服务器提供方法 批量获取动态
    ///
    /// - Parameters:
    ///   - limit: Integer	可选，默认值 20 ，获取条数
    ///   - after: Integer	可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    ///   - type: String	可选，默认值 new，可选值 new 、hot 、 follow 、users
    ///   - search: String	type = new时可选，搜索关键字
    ///   - user: Integer	type = users 时可选，默认值为当前用户id
    ///   - screen: string	type = users 时可选，paid-付费动态 pinned - 置顶动态
    ///   - complete: 结果
    fileprivate class func getFeeds(limit: Int = TSAppConfig.share.localInfo.limit, after: Int? = nil, type: String = "new", search: String?, user: Int?, screen: String?, complete: @escaping (FeedListResultsModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = FeedNetworkRequest().feeds
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["type": type, "limit": limit]
        if let after = after, type != "hot" {
            parameters.updateValue(after, forKey: "after")
        }
        // 热门的分页分页标示不一样服务器要求的
        if let after = after, type == "hot" {
            parameters.updateValue(after, forKey: "hot")
        }
        if let search = search {
            parameters.updateValue(search, forKey: "search")
        }
        if let user = user {
            parameters.updateValue(user, forKey: "user")
        }
        if let screen = screen {
            parameters.updateValue(screen, forKey: "screen")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                // 需要组装转发的数据
                // 分类整理
                let originalModel = data.model
                // 乱序
                var repostModelDic: [String : TSRepostModel] = [:]
                var repostFeedsListModels: [FeedListModel] = []
                var repostFeedsListModelIDs: [Int] = []
                var repostGroupsListModels: [FeedListModel] = []
                var repostGroupsListModelIDs: [Int] = []
                var repostGroupPostsListModels: [FeedListModel] = []
                var repostGroupPostsListModelIDs: [Int] = []
                var repostQuestionsListModels: [FeedListModel] = []
                var repostQuestionsListModelIDs: [Int] = []
                var repostQuestionAnswersListModels: [FeedListModel] = []
                var repostQuestionAnswersListModelIDs: [Int] = []
                var repostNewsListModels: [FeedListModel] = []
                var repostNewsListModelIDs: [Int] = []
                if let pinned = originalModel?.pinned {
                    for listModel in pinned {
                        if listModel.repostType == "feeds" {
                            repostFeedsListModels.append(listModel)
                            repostFeedsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "groups" {
                            repostGroupsListModels.append(listModel)
                            repostGroupsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "group-posts" {
                            repostGroupPostsListModels.append(listModel)
                            repostGroupPostsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "questions" {
                            repostQuestionsListModels.append(listModel)
                            repostQuestionsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "question-answers" {
                            repostQuestionAnswersListModels.append(listModel)
                            repostQuestionAnswersListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "news" {
                            repostNewsListModels.append(listModel)
                            repostNewsListModelIDs.append(listModel.repostId)
                        }
                    }
                }
                if let feeds = originalModel?.feeds {
                    for listModel in feeds {
                        if listModel.repostType == "feeds" {
                            repostFeedsListModels.append(listModel)
                            repostFeedsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "groups" {
                            repostGroupsListModels.append(listModel)
                            repostGroupsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "group-posts" {
                            repostGroupPostsListModels.append(listModel)
                            repostGroupPostsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "questions" {
                            repostQuestionsListModels.append(listModel)
                            repostQuestionsListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "question-answers" {
                            repostQuestionAnswersListModels.append(listModel)
                            repostQuestionAnswersListModelIDs.append(listModel.repostId)
                        } else if listModel.repostType == "news" {
                            repostNewsListModels.append(listModel)
                            repostNewsListModelIDs.append(listModel.repostId)
                        }
                    }
                }
                /// 通过模块逐个去请求转发的信息，动态需要的原作者的用户信息也返回了的开森
                let group = DispatchGroup()
                // 失败的信息，只有有接口报错就把错误信息付值给他
                var comleteErrorInfo: String = ""
                if repostFeedsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestFeedInfo(feedIDs: repostFeedsListModelIDs, complete: { (Infos, messgae) in
                        if messgae == nil {
                            if let Infos = Infos {
                                for dataDic in Infos {
                                    let repostModel = TSRepostModel()
                                    repostModel.id = dataDic["id"] as! Int
                                    let userDic = dataDic["user"] as! Dictionary<String, Any>
                                    repostModel.title = userDic["name"] as? String
                                    if let videoDic = dataDic["video"] as? Dictionary<String, Any>, videoDic.count > 0 {
                                        repostModel.type = .postVideo
                                    } else if let imageArr = dataDic["images"] as? Array<Dictionary<String, Any>>, imageArr.count > 0 {
                                        repostModel.type = .postImage
                                    } else {
                                        repostModel.type = .postWord
                                        repostModel.content = dataDic["feed_content"] as? String
                                    }
                                    repostModelDic.updateValue(repostModel, forKey: "feeds" + String(repostModel.id))
                                }
                            }
                        } else {
                            comleteErrorInfo = messgae!
                        }
                        group.leave()
                    })
                }
                /// 圈子
                if repostGroupsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestGroupInfo(IDs: repostGroupsListModelIDs, complete: { (Infos, messgae) in
                        if messgae == nil {
                            if let Infos = Infos {
                                for dataDic in Infos {
                                    let repostModel = TSRepostModel()
                                    repostModel.id = dataDic["id"] as! Int
                                    repostModel.title = dataDic["name"] as? String
                                    repostModel.content = dataDic["summary"] as? String
                                    repostModel.type = .group
                                    /// 需要判断是否可以进入圈子详情
                                    if let joinedDic = dataDic["joined"] as? Dictionary<String, Any>, joinedDic.count > 0 {
                                        // 只要加入了的就可以进入详情
                                    } else if let mode = dataDic["mode"] as? String, mode != "public" {
                                        repostModel.couldShowDetail = false
                                    }
                                    var avatarObject: TSNetFileModel?
                                    if let avatarDic = dataDic["avatar"] as? [String: Any] {
                                        avatarObject = TSNetFileModel(JSON: avatarDic)!
                                    }
                                    repostModel.coverImage = TSUtil.praseTSNetFileUrl(netFile: avatarObject)
                                    repostModel.typeStr = repostModel.type.rawValue
                                    repostModelDic.updateValue(repostModel, forKey: "groups" + String(repostModel.id))
                                }
                            }
                        } else {
                            comleteErrorInfo = messgae!
                        }
                        group.leave()
                    })
                }
                /// 帖子
                if repostGroupPostsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestPostInfo(IDs: repostGroupPostsListModelIDs, complete: { (Infos, messgae) in
                        if messgae == nil {
                            if let Infos = Infos {
                                var requestGroupIDs: [Int] = []
                                var tempRepostModels: [TSRepostModel] = []
                                for dataDic in Infos {
                                    let repostModel = TSRepostModel()
                                    repostModel.id = dataDic["id"] as! Int
                                    repostModel.subId = dataDic["group_id"] as! Int
                                    repostModel.title = dataDic["title"] as? String
                                    var content = dataDic["summary"] as? String
                                    requestGroupIDs.append(repostModel.subId)
                                    content = content?.ts_standardMarkdownToClearString()
                                    repostModel.content = content
                                    repostModel.type = .groupPost
                                    let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: dataDic["image"] as? Int, compressionRatio: 20, cgSize: nil)
                                    repostModel.coverImage = imgUrl?.absoluteString
                                    repostModel.typeStr = repostModel.type.rawValue
                                    tempRepostModels.append(repostModel)
                                }
                                if requestGroupIDs.isEmpty == false {
                                    /// 需要请求帖子所对应的圈子的信息，用来更新能否直接进入帖子的权限
                                    FeedListNetworkManager.requestGroupInfo(IDs: requestGroupIDs, complete: { (Infos, messgae) in
                                        if messgae == nil {
                                            if let Infos = Infos {
                                                var groupsAccess: [Int: Bool] = [ : ]
                                                for dataDic in Infos {
                                                    var could = true
                                                    let groupId = dataDic["id"] as! Int
                                                    /// 需要判断是否可以进入圈子详情
                                                    if let joinedDic = dataDic["joined"] as? Dictionary<String, Any>, joinedDic.count > 0 {
                                                        // 只要加入了的就可以进入详情
                                                        could = true
                                                    } else if let mode = dataDic["mode"] as? String, mode != "public" {
                                                        could = false
                                                    }
                                                    groupsAccess.updateValue(could, forKey: groupId)
                                                }
                                                for aRepostModel in tempRepostModels {
                                                    if let couldShowDetail = groupsAccess[aRepostModel.subId] {
                                                        aRepostModel.couldShowDetail = couldShowDetail
                                                        repostModelDic.updateValue(aRepostModel, forKey: "group-posts" + String(aRepostModel.id))
                                                    } else {
                                                        /// 说明这个帖子的圈子信息没有查到，就不要这条帖子
                                                    }
                                                }
                                            }
                                        } else {
                                            comleteErrorInfo = messgae!
                                        }
                                        group.leave()
                                    })
                                }
                            } else {
                            comleteErrorInfo = messgae!
                        }
                        }
                    })
                }
                /// 问题
                if repostQuestionsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestQuestionInfo(IDs: repostQuestionsListModelIDs, complete: { (Infos, messgae) in
                        if messgae == nil {
                            if let Infos = Infos {
                                for dataDic in Infos {
                                    let repostModel = TSRepostModel()
                                    repostModel.id = dataDic["id"] as! Int
                                    repostModel.title = dataDic["subject"] as? String
                                    repostModel.content = dataDic["body"] as? String
                                    repostModel.type = .question
                                    repostModel.typeStr = repostModel.type.rawValue
                                    repostModelDic.updateValue(repostModel, forKey: "questions" + String(repostModel.id))
                                }
                            }
                        } else {
                            comleteErrorInfo = messgae!
                        }
                        group.leave()
                    })
                }
                /// 回答
                if repostQuestionAnswersListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestAnswerInfo(IDs: repostQuestionAnswersListModelIDs, complete: { (Infos, messgae) in
                        if messgae == nil {
                            if let Infos = Infos {
                                for dataDic in Infos {
                                    let repostModel = TSRepostModel()
                                    repostModel.id = dataDic["id"] as! Int
                                    let questionDic = dataDic["question"] as? Dictionary<String, Any>
                                    repostModel.title = questionDic!["subject"] as? String
                                    repostModel.content = dataDic["body"] as? String
                                    repostModel.type = .questionAnswer
                                    repostModel.typeStr = repostModel.type.rawValue
                                    repostModelDic.updateValue(repostModel, forKey: "question-answers" + String(repostModel.id))
                                }
                            }
                        } else {
                            comleteErrorInfo = messgae!
                        }
                        group.leave()
                    })
                }
                /// 资讯
                if repostNewsListModelIDs.count > 0 {
                    group.enter()
                    FeedListNetworkManager.requestNewsInfo(IDs: repostNewsListModelIDs, complete: { (Infos, messgae) in
                        if messgae == nil {
                            if let Infos = Infos {
                                for dataDic in Infos {
                                    let repostModel = TSRepostModel()
                                    repostModel.id = dataDic["id"] as! Int
                                    repostModel.title = dataDic["title"] as? String
                                    repostModel.content = dataDic["subject"] as? String
                                    repostModel.type = .news
                                    repostModel.typeStr = repostModel.type.rawValue
                                    if dataDic["image"] != nil {
                                        let images = dataDic["image"] as? Dictionary<String, Any>
                                        if images != nil {
                                            let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: images?["id"] as? Int, compressionRatio: 20, cgSize: nil)
                                            repostModel.coverImage = imgUrl?.absoluteString
                                        }
                                    }
                                    repostModelDic.updateValue(repostModel, forKey: "news" + String(repostModel.id))
                                }
                            }
                        } else {
                            comleteErrorInfo = messgae!
                        }
                        group.leave()
                    })
                }
                /// 全部请求完毕
                group.notify(queue: .main) { _ in
                    if comleteErrorInfo.isEmpty {
                        var pinneds: [FeedListModel] = []
                        if let pinned = originalModel?.pinned {
                            for listModel in pinned {
                                if listModel.repostId > 0 {
                                    if let reostModel = repostModelDic[listModel.repostType! + String(listModel.repostId)] {
                                        listModel.repostModel = reostModel
                                        pinneds.append(listModel)
                                    } else {
                                        /// 已经删除的内容，需要显示"该内容已被删除"
                                        let repostModel = TSRepostModel()
                                        repostModel.id = 0
                                        repostModel.type = .delete
                                        repostModel.typeStr = repostModel.type.rawValue
                                        listModel.repostModel = repostModel
                                        pinneds.append(listModel)
                                    }
                                } else {
                                    // 非转发类型
                                    pinneds.append(listModel)
                                }
                            }
                            originalModel?.pinned = pinneds
                        }
                    } else {
                        complete(nil, comleteErrorInfo, false)
                    }
                    if let feeds = originalModel?.feeds {
                        var feedModels: [FeedListModel] = []
                        for listModel in feeds {
                            if listModel.repostId > 0 {
                                if let reostModel = repostModelDic[listModel.repostType! + String(listModel.repostId)] {
                                    listModel.repostModel = reostModel
                                    feedModels.append(listModel)
                                } else {
                                    /// 已经删除的内容，需要显示"该内容已被删除"
                                    let repostModel = TSRepostModel()
                                    repostModel.id = 0
                                    repostModel.type = .delete
                                    repostModel.typeStr = repostModel.type.rawValue
                                    listModel.repostModel = repostModel
                                    feedModels.append(listModel)
                                }
                            } else {
                                // 非转发类型
                                feedModels.append(listModel)
                            }
                        }
                        originalModel?.feeds = feedModels
                        complete(originalModel!, nil, true)
                    } else {
                        complete(nil, nil, false)
                    }
                }
            }
        }
    }
}
extension FeedListNetworkManager {
    /// 获取动态信息
     class func requestFeedInfo(feedIDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "feeds"
        var parameter: [String: Any] = [:]
        var feedIdStr = ""
        for feedIs in feedIDs {
            feedIdStr = feedIdStr.isEmpty ? String(feedIs) : feedIdStr + "," +  String(feedIs)
        }
        parameter["id"] = feedIdStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [String: Any] else {
                complete([], nil)
                return
            }
            complete(datas["feeds"] as? [[String : Any]], nil)
        })
    }
    /// 圈子信息
     class func requestGroupInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "plus-group/groups"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 帖子详情
     class func requestPostInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "group/simple-posts"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 资讯信息
     class func requestNewsInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "news"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 问题信息
     class func requestQuestionInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "questions"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 回答信息
     class func requestAnswerInfo(IDs: [Int], complete: @escaping ([[String: Any]]?, _ errorInfo: String?) -> Void) {
        let requestPath = TSURLPathV2.path.rawValue + "qa/reposted-answers"
        var parameter: [String: Any] = [:]
        var idStr = ""
        for idInt in IDs {
            idStr = idStr.isEmpty ? String(idInt) : idStr + "," +  String(idInt)
        }
        parameter["id"] = idStr
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                complete([], nil)
                return
            }
            // 服务器数据异常
            guard let datas = networkResponse as? [[String : Any]] else {
                complete([], nil)
                return
            }
            complete(datas, nil)
        })
    }
    /// 请求用户信息
     class func requestUserInfo(userIds: [Int], complete: @escaping ([TSUserInfoModel]?, _ errorInfo: String?) -> Void) {
        TSTaskQueueTool.getAndSave(userIds: userIds) { (users, msg, status) in
            guard let users = users else {
                complete(nil, msg)
                return
            }
            complete(users, nil)
        }
    }
}
extension Sequence {

    func toDictionary<Key: Hashable>(_ key: (Iterator.Element) -> Key) -> [Key: Iterator.Element] {
        var dict: [Key: Iterator.Element] = [:]
        for element in self {
            dict[key(element)] = element
        }
        return dict
    }
}
