//
//  TSUserNetworkingManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户相关网络请求

import UIKit

import RealmSwift
import ObjectMapper
import Alamofire

enum TSUserRelationType {
    /// 关注
    case follow
    /// 粉丝
    case fans
}

enum TSUserIsCancelFollow {
    /// 关注
    case follow
    /// 取消关注
    case cancel
}

enum TSUserManagerAuthority: String {
    /// 删除动态权限
    case deleteFeed = "[feed] Delete Feed"
    /// 删除问题
    case deleteQuestion = "[Q&A] Manage Questions"
    /// 删除回答
    case deleteAnswer = "[Q&A] Manage Answers"
    /// 删除资讯
    case deleteNew = "[News] Delete News Post"
}

class TSUserNetworkingManager: NSObject {

    /// 上传用户/企业认证
    ///
    /// - Parameters:
    ///   - type: 认证类型，必须是 personal 或者 enterprise
    ///   - files: 认证材料文件。必须是数组或者对象，value 为 文件ID
    ///   - name: 如果 type 是 enterprise 那么就是负责人名字，如果 type 是 personal 则为用户真实姓名
    ///   - phone: 如果 type 是 enterprise 则为负责人联系方式，如果 type 是 personal 则为用户联系方式
    ///   - number: 如果 type 是 enterprise 则为营业执照注册号，如果 type 是 personal 则为用户身份证号码
    ///   - desc: 认证描述
    ///   - org_name: type 为 enterprise 则必须，企业或机构名称
    ///   - org_address: type 为 enterprise 则必须，企业或机构地址
    func certificate(type: String, files: [Int], name: String, phone: String, number: String, desc: String, orgName: String?, orgAddress: String?, complete: @escaping (Bool, String) -> Void) {
        // TODO: 暂时屏蔽掉未登录用户调用该接口导致的验证错误
        if TSCurrentUserInfo.share.isLogin == false {
            complete(false, "网络请求错误")
            return
        }
        // 1.配置路径
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.certificate.rawValue
        // 2.配置参数
        var parameters: [String: Any] = ["type": type, "files": files, "name": name, "phone": phone, "number": number, "desc": desc]
        if let orgAddress = orgAddress, let orgName = orgName {
            parameters.updateValue(orgName, forKey: "org_name")
            parameters.updateValue(orgAddress, forKey: "org_address")
        }
        // 3.发起请求
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters, complete: { (response: NetworkResponse?, status: Bool) in
            var message: String
            if status {
                message = "上传成功"
            } else {
                message = "上传失败"
                if let serverMsg = TSCommonNetworkManager.getNetworkErrorMessage(with: response) {
                    message += serverMsg
                }
            }
            complete(status, message)
        })
    }

    /// 更新用户/企业认证
    ///
    /// - Parameters:
    ///   - type: 认证类型，必须是 personal 或者 enterprise
    ///   - files: 认证材料文件。必须是数组或者对象，value 为 文件ID
    ///   - name: 如果 type 是 enterprise 那么就是负责人名字，如果 type 是 personal 则为用户真实姓名
    ///   - phone: 如果 type 是 enterprise 则为负责人联系方式，如果 type 是 personal 则为用户联系方式
    ///   - number: 如果 type 是 enterprise 则为营业执照注册号，如果 type 是 personal 则为用户身份证号码
    ///   - desc: 认证描述
    ///   - org_name: type 为 enterprise 则必须，企业或机构名称
    ///   - org_address: type 为 enterprise 则必须，企业或机构地址
    func updateCertificate(type: String, files: [Int], name: String, phone: String, number: String, desc: String, orgName: String?, orgAddress: String?, complete: @escaping (Bool, String) -> Void) {
        // TODO: 暂时屏蔽掉未登录用户调用该接口导致的验证错误
        if TSCurrentUserInfo.share.isLogin == false {
            complete(false, "网络请求错误")
            return
        }
        // 1.配置路径
        var request = UserNetworkRequest.updateVerified
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["type": type, "files": files, "name": name, "phone": phone, "number": number, "desc": desc]
        if let orgAddress = orgAddress, let orgName = orgName {
            parameters.updateValue(orgName, forKey: "org_name")
            parameters.updateValue(orgAddress, forKey: "org_address")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(false, "网络请求错误")
            case .failure(let failure):
                complete(false, failure.message ?? "上传失败")
            case .success(let data):
                complete(true, data.message ?? "上传成功")
            }
        }
    }

    /// 获取用户认证信息
    func getUserCertificate(complete: @escaping (TSUserCertificateObject?) -> Void) {
        // TODO: 暂时屏蔽掉未登录用户调用该接口导致的验证错误
        if TSCurrentUserInfo.share.isLogin == false {
            complete(nil)
            return
        }
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.certificate.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (response: NetworkResponse?, status: Bool) in
            if status {
                let object = Mapper<TSCertificateModel>().map(JSONObject: response)?.object()
                complete(object)
                return
            }
            complete(nil)
        })
    }

    /// 获取用户的粉丝或者关注列表
    ///
    /// - Parameters:
    ///   - identity: 被查询者的用户标识
    ///   - fansOrFollowList: 粉丝或者关注
    ///   - maxID: 最大的ID，查询更多时使用
    ///   - isAuth: 查询者是否是认证（登录）用户
    ///   - complete: 查询到的用户信息组；网络错误；当两个值都未空表示服务器响应错误
    func user(identity: Int?, fansOrFollowList: TSUserRelationType, offset: Int?, isAuth: Bool = false, complete: @escaping ((_ users: [TSUserInfoModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        if isAuth {
            if fansOrFollowList == .follow {
                requestMethod = TSNetworkRequest().authFollowingsList
            } else {
                requestMethod = TSNetworkRequest().authFollowersList
            }
            fullPath = requestMethod.fullPath()
        } else {
            if fansOrFollowList == .follow {
                requestMethod = TSNetworkRequest().followingsList
            } else {
                requestMethod = TSNetworkRequest().followersList
            }
            fullPath = requestMethod.fullPathWith(replace: "\(identity!)")
        }
        var parameter = ["limit": TSAppConfig.share.localInfo.limit]
        if let offset = offset {
            parameter["offset"] = offset
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<TSUserInfoModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 获取用户搜索好友列表
    ///
    /// - Parameters:
    ///   - identity: 被查询者的用户标识
    ///   - offset: 分页
    ///   - keyWordString: 搜索关键字
    ///   - complete: 查询到的用户信息组；网络错误；当两个值都未空表示服务器响应错误
    func friendList(offset: Int?, keyWordString: String?, complete: @escaping ((_ users: [TSUserInfoModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSNetworkRequest().searchMyFriend
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["offset": 0]
        parameter["keyword"] = keyWordString
        if let offset = offset {
            parameter["offset"] = offset
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<TSUserInfoModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 获取话题列表(联想)
    ///
    /// - Parameters:
    ///  - index:
    ///  - keyWordString: 关键词
    ///  - limit: 每页多少条数据
    ///  - direction: 排序
    ///  - only: 热门，当有only的时候其他参数全部失效，只会返回热门数据
    func getTopicListThink(index: Int?, keyWordString: String?, limit: Int?, direction: String?, only: String?, complete: @escaping ((_ topicList: [TopicListModel]?, _ error: NetworkError?) -> Void)) -> DataRequest {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().topicList
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["direction": "desc"]
        if let index = index {
            parameter["index"] = index
        }
        if let keyWordString = keyWordString {
            parameter["q"] = keyWordString
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        if let direction = direction {
            parameter["direction"] = direction
        }
        if let only = only {
            parameter.removeAll()
            parameter["only"] = only
        }
        return try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<TopicListModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 获取话题列表
    ///
    /// - Parameters:
    ///  - index:
    ///  - keyWordString: 关键词
    ///  - limit: 每页多少条数据
    ///  - direction: 排序
    ///  - only: 热门，当有only的时候其他参数全部失效，只会返回热门数据
    func getTopicList(index: Int?, keyWordString: String?, limit: Int?, direction: String?, only: String?, complete: @escaping ((_ topicList: [TopicListModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().topicList
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["direction": "desc"]
        if let index = index {
            parameter["index"] = index
        }
        if let keyWordString = keyWordString {
            parameter["q"] = keyWordString
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        if let direction = direction {
            parameter["direction"] = direction
        }
        if let only = only {
            parameter.removeAll()
            parameter["only"] = only
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<TopicListModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 话题详情信息
    func getTopicInfo(groupId: Int, complete: @escaping (TopicModel?, String?, Bool) -> Void) {
        // 1.请求 url
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().detailTopic
        fullPath = requestMethod.fullPathWith(replace: "\(groupId)")
        // 3.发起请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, nil, result)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, nil, result)
                }
                return
            }
            let model = Mapper<TopicModel>().map(JSONObject: networkResponse)
            var userIds: [Int] = (model?.menberID)!
            userIds.insert((model?.userId)!, at: 0)
            // 2.发起网络请求
            TSUserNetworkingManager().getUserInfo(userIds) { (_, models, _) in
                guard var models = models else {
                    // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                    // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                    // 就先写一个假的数据，等这 API 更新后再替换
                    complete(nil, "获取信息失败，请检查网络设置", false)
                    return
                }
                // 3.将用户信息和动态信息匹配
                for (index, item) in models.enumerated() {
                    if item.userIdentity == model?.userId {
                        model?.setUserInfo(user: item)
                        /// 排序 将发布者的用户信息排在最前面
                        models.remove(at: index)
                        models.insert((model?.userInfo)!, at: 0)
                        break
                    }
                }
                model?.setMenber(menber: models)
                complete(model, nil, true)
            }
        })
    }

    /// 话题参与者列表(返回的是用户id数组)
    func getTopicMenberList(groupId: Int, limit: Int?, offset: Int?, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().topicMenberList
        fullPath = requestMethod.fullPathWith(replace: "\(groupId)")
        var parameter = ["limit": 15]
        if let offset = offset {
            parameter["offset"] = offset
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        // 3.发起请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, nil, result)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, nil, result)
                }
                return
            }
            let userIds: [Int] = networkResponse as! [Int]
            // 2.发起网络请求
            TSUserNetworkingManager().getUserInfo(userIds) { (_, models, _) in
                guard let models = models else {
                    // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                    // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                    // 就先写一个假的数据，等这 API 更新后再替换
                    complete(nil, "获取信息失败，请检查网络设置", false)
                    return
                }
                complete(models, nil, true)
            }
        })
    }

    /// 上传话题封面图
    func uploadTopicFace(_ bgData: Data, complete: @escaping ((_ faceNode: String?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSGlobalNetManager.uploadImage(data: bgData) { (node, msg, status) in
            complete(node, msg, status)
        }
    }

    /// 话题下的动态列表
    func getTopicMomentList(topicID: Int, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int?, complete: @escaping ([FeedListModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = TSTopicNetworkRequest().topicMomentList
        request.urlPath = request.fullPathWith(replacers: ["\(topicID)"] )
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let offset = offset {
            parameters.updateValue(offset, forKey: "index")
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
                    let feeds = data.models
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
                        })
                        group.leave()
                    }
                    /// 帖子
                    if repostGroupPostsListModelIDs.count > 0 {
                        group.enter()
                        FeedListNetworkManager.requestPostInfo(IDs: repostGroupPostsListModelIDs, complete: { (Infos, messgae) in
                            if messgae == nil {
                                if let Infos = Infos {
                                    for dataDic in Infos {
                                        let repostModel = TSRepostModel()
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
                                        repostModelDic.updateValue(repostModel, forKey: "group-posts" + String(repostModel.id))
                                    }
                                }
                            } else {
                                comleteErrorInfo = messgae!
                            }
                            group.leave()
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
                        complete(feedModels, nil, true)
                        }
                    }
            }
        }
}
    ///创建话题
    func createTopic(faceNode: String?, topicTitle: String, topicIntro: String?, complete: @escaping ((_ topicId: Int?, _ msg: String?, _ status: Bool, _ needReview: Bool) -> Void)) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().createTopic
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["name": topicTitle]
        if let faceNode = faceNode {
            parameter["logo"] = faceNode
        }
        if let topicIntro = topicIntro {
            parameter["desc"] = topicIntro
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, message, false, false)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(nil, message, false, false)
                }
                return
            }
            let resultDict = networkResponse as! Dictionary<String, Any>
            let topicOfId = resultDict["id"] as! Int
            if let needView = resultDict["need_review"] {
                // 请求成功处理
                complete(topicOfId, "创建成功，待审核", true, needView as! Bool)
            } else {
                complete(topicOfId, "创建成功，待审核", true, false)
            }
        })
    }

    ///编辑一个话题
    func editTopic(faceNode: String?, topicIntro: String?, topicId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().editTopic
        fullPath = requestMethod.fullPathWith(replace: "\(topicId)")
        var parameter: [String: Any] = ["desc": ""]
        if let faceNode = faceNode {
            parameter["logo"] = faceNode
        }
        if let topicIntro = topicIntro {
            parameter["desc"] = topicIntro
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete("恭喜你！成功保存话题！", true)
        })
    }

    /// 举报一个话题
    func reportATopic(topicId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void )) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().reportTopic
        fullPath = requestMethod.fullPathWith(replace: "\(topicId)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete("举报成功!", true)
        })
    }

    /// 关注、取消关注话题
    func followOrUnfollowTopic(topicId: Int, follow: Bool, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void )) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        if follow {
            requestMethod = TSTopicNetworkRequest().followTopic
        } else {
            requestMethod = TSTopicNetworkRequest().unFollowTopic
        }
        fullPath = requestMethod.fullPathWith(replace: "\(topicId)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String:
                    TSLogCenter.log.debug(responseInfo)
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete(follow ? "关注成功!" : "取消关注成功!", true)
        })
    }

    /// 操作用户关系
    ///
    /// - Parameters:
    ///   - type: 将当前登录用户和指定用户的关系修改为该类型
    ///   - userID: 操作的用户标识
    /// - Note: 该操作无任何响应
    func operate(_ type: FollowStatus, userID: Int) {
        assert(type != .oneself || type != .eachOther, "操作用户关系时，不能切换为自己活着相互关注")
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        if type == .follow {
            requestMethod = TSNetworkRequest().followUser
        } else {
            requestMethod = TSNetworkRequest().unfollowUser
        }
        fullPath = requestMethod.fullPath().replacingOccurrences(of: requestMethod.replace!, with: "\(userID)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { _, _ in
        })
    }

}

// MARK: - V2部分的请求

// MARK: - 获取用户信息

extension TSUserNetworkingManager {
    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userIdentities: 用户标识数组
    ///   - complete: 结果
    func getUserInfo(_ userIdentities: [Int], complete: @escaping ((_ info: Any?, _ userInfoModels: [TSUserInfoModel]?, _ error: NSError?) -> Void)) {
        //assert(!userIdentities.isEmpty, "查询用户信息数组为空")
        if userIdentities.isEmpty {
            complete(nil, nil, NSError(domain: "查询用户信息数组为空", code: -1, userInfo: nil))
            return
        }
        var path = TSURLPathV2.path.rawValue
        path = path + TSURLPathV2.User.users.rawValue + "?id=" + userIdentities.convertToString()! + "&limit=50"
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (networkResponse, result) in
            guard result == true else {
                switch networkResponse {
                case _ as NetworkError:
                    let error = TSErrorCenter.create(With: .networkError)
                    complete(nil, nil, error)
                case let responseInfo as String:
                    complete(responseInfo, nil, nil)
                case let responseDic as Dictionary<String, Array<String>>:
                    complete(responseDic, nil, nil)
                default:
                    assert(false, "服务器响应了无法解析的数据")
                }
                return
            }
            var tempUserInfoModels = [TSUserInfoModel]()
            if let datas = networkResponse as? [Any] {
                if let modelList = Mapper<TSUserInfoModel>().mapArray(JSONObject: datas) {
                    tempUserInfoModels.append(contentsOf: modelList)
                }
            }

            if let data = networkResponse as? [String: Any] {
                if let userModel = Mapper<TSUserInfoModel>().map(JSON: data) {
                    tempUserInfoModels.append(userModel)
                }
            }
            complete(networkResponse, tempUserInfoModels, nil)
        })
    }

    // 获取当前用户信息
    func getCurrentUserInfo(complete: @escaping ((_ userModel: TSCurrentUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let userModel = Mapper<TSCurrentUserInfoModel>().map(JSONObject: data)
                complete(userModel, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }

    // 获取指定的单个用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户标识数组
    ///   - complete: 请求回调
    func getUserInfo(userId: Int, complete: @escaping ((_ userModel: TSUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?id=\(userId)"
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let userModel = Mapper<TSUserInfoModel>().map(JSONObject: data)
                complete(userModel, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }

    // 获取指定的多个用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户标识数组
    ///   - complete: 请求回调
    func getUsersInfo(usersId: [Int], userNames: [String] = [], complete: @escaping ((_ usersModel: [TSUserInfoModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        if usersId.isEmpty && userNames.isEmpty {
            complete(nil, nil, false)
            return
        }
        // 应对usersId进行判断处理
        var path = ""
        if usersId.count > 0 {
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?id=" + (usersId.convertToString() ?? "")
        } else if userNames.count > 0 {
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?name=" + (userNames.convertToString() ?? "") + "&fetch_by=username"
            path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let userList = Mapper<TSUserInfoModel>().mapArray(JSONObject: data)
                complete(userList, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    // MARK: - 检查当前电话号码是否已经注册
    func phoneDidRegister(number: String, complete: @escaping ((_ didRegister: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "/" + number
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            /// 如果注册了 就返回用户信息，否者404
            complete(status)
        })
    }
}

// MARK: - 修改用户信息

extension TSUserNetworkingManager {

    /// 修改用户的基本信息
    func updateUserBaseInfo(name: String, sex: String, bio: String, location: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
        var sexParam = 0
        if sex == "男" {
            sexParam = 1
        } else if sex == "女" {
            sexParam = 2
        }
        let params: [String: Any] = ["name": name, "sex": "\(sexParam)", "bio": bio, "location": location]
        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 修改用户头像
    func updateUserAvatar(_ avatar: Data, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSGlobalNetManager.uploadImage(data: avatar) { (node, message, status) in
            if status == true {
                let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
                let params: [String: Any] = ["avatar": node!]
                try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: params, complete: { (data, status) in
                    var message: String?
                    if !status {
                        message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                    }
                    complete(message, status)
                })
            }
        }
    }

    /// 修改用户背景
    func updateUserBgImage(_ bgData: Data, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSGlobalNetManager.uploadImage(data: bgData) { (node, message, status) in
            if status == true {
                let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
                let params: [String: Any] = ["bg": node!]
                try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: params, complete: { (data, status) in
                    var message: String?
                    if !status {
                        message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                    }
                    complete(message, status)
                })
            }
        }
    }

}

// MARK: - 用户打赏

extension TSUserNetworkingManager {

    /// 打赏指定用户
    /// userId - 打赏的用户Id
    /// amount - 打赏金额
    func reward(userId: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求url
        let requestMethod = TSUserRewardNetworkMethod().reward
        // 2.请求参数
        var params: [String: Any] = ["amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                params.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        // 3.请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(userId)"), parameter: params, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 指定用户的打赏列表
    /// 指定用户的打赏统计信息

}

// MARK: - 其他用户相关

extension TSUserNetworkingManager {

    // 用户关注/取消关注的请求
    class func followOperate(_ followOperate: TSFollowOperate, userId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var  request: Request<Empty>
        switch followOperate {
        case .follow:
            request = UserNetworkRequest.follow
        case .unfollow:
            request = UserNetworkRequest.unfollow
        }
        request.urlPath = request.fullPathWith(replacers: ["\(userId)"])
        // 2. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(_):
                complete(nil, true)
            }
        }
    }

}

// MARK: - 获取管理员权限信息

extension TSUserNetworkingManager {

    /// 获取当前用户管理权限
    class func currentUserManagerInfo(complete: @escaping ((_ magagerModel: [TSCurrentUserManagerAuthority]?, _ status: Bool) -> Void)) -> Void {
        if TSCurrentUserInfo.share.isLogin == false {
            complete(nil, false)
            return
        }
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.managerInfgo.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (response: NetworkResponse?, status: Bool) in
            if status {
                let users = Mapper<TSCurrentUserManagerAuthority>().mapArray(JSONObject: response)
                var delete = false
                var deleteQuestion = false
                var deleteAnswer = false
                var deleteNew = false
                for (_, item) in (users?.enumerated())! {
                    if item.name == TSUserManagerAuthority.deleteFeed.rawValue {
                        delete = true
                    }
                    if item.name == TSUserManagerAuthority.deleteQuestion.rawValue {
                        deleteQuestion = true
                    }
                    if item.name == TSUserManagerAuthority.deleteAnswer.rawValue {
                        deleteAnswer = true
                    }
                    if item.name == TSUserManagerAuthority.deleteAnswer.rawValue {
                        deleteNew = true
                    }
                }
                let accountInfo = TSCurrentUserInfoSave()
                accountInfo.deleteFeed = delete
                accountInfo.deleteQuestion = deleteQuestion
                accountInfo.deleteAnswer = deleteAnswer
                accountInfo.deleteNew = deleteNew
                TSCurrentUserInfo.share.accountManagerInfo = accountInfo
                TSCurrentUserInfo.share.accountManagerInfo?.save()
                complete(users, true)
                return
            }
            complete(nil, false)
        })
    }

}
