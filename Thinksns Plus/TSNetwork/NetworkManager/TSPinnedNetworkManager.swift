//
//  TSPinnedNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  收到的待操作通知的网络请求
//  请使用和完善下面新版的接口
/**
类型：动态置顶、评论置顶、
相关的操作：审核通过、拒绝、删除、 因无法统一且后续会修改,暂时使用了不同版本的网络请求
备注：当前的部分动态操作没有位于这里，位于别的地方
 */

import Foundation

import ObjectMapper

/// 置顶对象的类型
enum TSTopTargetType {
    /// 动态
    case moment
    /// 帖子
    case post

    /// 评论置顶
    enum Comment: Int {
        /// 动态评论置顶
        case moment = 0
        /// 资讯评论置顶
        case news
        /// 帖子评论置顶
        case post
    }
}

/// 评论置顶的审核相关消息
/// 收到的待操作的通知
///
/// - newsCommentToTop: 资讯评论置顶
/// - feedCommentToTop: 动态评论置顶
//enum ReceivePendingNoticeType: Int {
//    case feedCommentToTop = 0
//    case newsCommentToTop
//}
//typealias ReceivePendingNoticeType = TSTopTargetType.Comment

class TSPinnedNetworkManager {

//    class func getPendingNotice(_ type: ReceivePendingNoticeType, limit: Int = 20, after: Int?, complete: @escaping ((_ pendingConfigs: [ReceivePendingCommentTopModel]?, _ info: String?) -> Void)) {
//        switch type {
//        case .feedCommentToTop:
//            getFeedCommentPendingNotice(limit: limit, after: after, complete: complete)
//        case .newsCommentToTop:
//            getNewsCommentPendingNotice(limit: limit, after: after, complete: complete)
//        }
//    }

    class func getPendingNotice(_ type: TSTopTargetType.Comment, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping ((_ pendingConfigs: [ReceivePendingCommentTopModel]?, _ info: String?) -> Void)) {
        switch type {
        case .moment:
            getFeedCommentPendingNotice(limit: limit, after: after, complete: complete)
        case .news:
            getNewsCommentPendingNotice(limit: limit, after: after, complete: complete)
        case .post:
            break
        }
    }

    class func getNewsCommentPendingNotice(limit: Int, after: Int?, complete: @escaping ((_ pendingConfigs: [ReceivePendingCommentTopModel]?, _ info: String?) -> Void)) {
        var models: [ReceivePendingCommentTopModel]?
        var errorInfo: String?
        let requestGroup = DispatchGroup()
        var request = ReceivePendingNetworkRequest().newsCommentList
        request.urlPath = request.fullPathWith(replacers: [])
        var parameter: [String: Any] = ["limit": limit]
        if let after = after {
            parameter["after"] = after
        }
        request.parameter = parameter
        requestGroup.enter()
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(let error):
                if error == NetworkError.networkErrorFailing {
                    errorInfo = "提示信息_网络错误".localized
                } else {
                    errorInfo = "网络请求超时"
                }
            case .failure(let response):
                if let message = response.message {
                    errorInfo = message
                } else {
                    errorInfo = "提示信息_网络错误".localized
                }
            case .success(let response):
                models = response.models
            }
            requestGroup.leave()
        }

        requestGroup.notify(queue: DispatchQueue.main) {
            guard let receiveModels = models else {
                complete(nil, errorInfo)
                return
            }
            guard receiveModels.isEmpty == false else {
                complete([], nil)
                return
            }
            let userIds = receiveModels.map({ (temp) -> Int in
                return temp.userId
            })

            let filterIds = Array(Set(userIds))
            TSUserNetworkingManager().getUserInfo(filterIds, complete: { (_, userInfoModels, _) in
                guard let userInfoModels = userInfoModels else {
                    complete(nil, "提示信息_网络错误".localized)
                    return
                }
                let results = receiveModels.map({ (model) -> ReceivePendingCommentTopModel in
                    for user in userInfoModels {
                        if model.userId == user.userIdentity {
                            model.userInfo = user
                        }
                    }
                    return model
                }).map { model -> ReceivePendingCommentTopModel in
                    // 如果未查询到用户信息 且用户ID不等于0 的 就设置一个 未知用户
                    if model.userInfo == nil && model.userId != 0 {
                        model.userInfo = TSUnknownUserInfoModel()
                    }
                    return model
                }

                complete(results, nil)
            })
        }
    }

    class func getFeedCommentPendingNotice(limit: Int, after: Int?, complete: @escaping ((_ pendingConfigs: [ReceivePendingCommentTopModel]?, _ info: String?) -> Void)) {
        var models: [ReceivePendingCommentTopModel]?
        var errorInfo: String?
        let requestGroup = DispatchGroup()
        var request = ReceivePendingNetworkRequest().feedCommentList
        request.urlPath = request.fullPathWith(replacers: [])
        var parameter: [String: Any] = ["limit": limit]
        if let after = after {
            parameter["after"] = after
        }
        request.parameter = parameter
        requestGroup.enter()
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(let error):
                if error == NetworkError.networkErrorFailing {
                    errorInfo = "提示信息_网络错误".localized
                } else {
                    errorInfo = "网络请求超时"
                }
            case .failure(let response):
                if let message = response.message {
                    errorInfo = message
                } else {
                    errorInfo = "提示信息_网络错误".localized
                }
            case .success(let response):
                models = response.models
            }
            requestGroup.leave()
        }

        requestGroup.notify(queue: DispatchQueue.main) {
            guard let receiveModels = models else {
                complete(nil, errorInfo)
                return
            }
            guard receiveModels.isEmpty == false else {
                complete([], nil)
                return
            }
            let userIds = receiveModels.map({ (temp) -> Int in
                return temp.userId
            })

            let filterIds = Array(Set(userIds))
            TSUserNetworkingManager().getUserInfo(filterIds, complete: { (_, userInfoModels, _) in
                guard let userInfoModels = userInfoModels else {
                    complete(nil, "提示信息_网络错误".localized)
                    return
                }
                let results = receiveModels.map({ (model) -> ReceivePendingCommentTopModel in
                    for user in userInfoModels {
                        if model.userId == user.userIdentity {
                            model.userInfo = user
                        }
                    }
                    return model
                }).map { model -> ReceivePendingCommentTopModel in
                    // 如果未查询到用户信息 且用户ID不等于0 的 就设置一个 未知用户
                    if model.userInfo == nil && model.userId != 0 {
                        model.userInfo = TSUnknownUserInfoModel()
                    }
                    return model
                }

                complete(results, nil)
            })
        }
    }

    class func getPostCommentPendingNotice(limit: Int, after: Int?, complete: @escaping ((_ pendingConfigs: [ReceivePendingCommentTopModel]?, _ info: String?) -> Void)) {
        var models: [ReceivePendingCommentTopModel]?
        var errorInfo: String?
        let requestGroup = DispatchGroup()
        var request = ReceivePendingNetworkRequest().feedCommentList
        request.urlPath = request.fullPathWith(replacers: [])
        var parameter: [String: Any] = ["limit": limit]
        if let after = after {
            parameter["after"] = after
        }
        request.parameter = parameter
        requestGroup.enter()
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(let error):
                if error == NetworkError.networkErrorFailing {
                    errorInfo = "提示信息_网络错误".localized
                } else {
                    errorInfo = "网络请求超时"
                }
            case .failure(let response):
                if let message = response.message {
                    errorInfo = message
                } else {
                    errorInfo = "提示信息_网络错误".localized
                }
            case .success(let response):
                models = response.models
            }
            requestGroup.leave()
        }

        requestGroup.notify(queue: DispatchQueue.main) {
            guard let receiveModels = models else {
                complete(nil, errorInfo)
                return
            }
            guard receiveModels.isEmpty == false else {
                complete([], nil)
                return
            }
            let userIds = receiveModels.map({ (temp) -> Int in
                return temp.userId
            })

            let filterIds = Array(Set(userIds))
            TSUserNetworkingManager().getUserInfo(filterIds, complete: { (_, userInfoModels, _) in
                guard let userInfoModels = userInfoModels else {
                    complete(nil, "提示信息_网络错误".localized)
                    return
                }
                let results = receiveModels.map({ (model) -> ReceivePendingCommentTopModel in
                    for user in userInfoModels {
                        if model.userId == user.userIdentity {
                            model.userInfo = user
                        }
                    }
                    return model
                }).map { model -> ReceivePendingCommentTopModel in
                    // 如果未查询到用户信息 且用户ID不等于0 的 就设置一个 未知用户
                    if model.userInfo == nil && model.userId != 0 {
                        model.userInfo = TSUnknownUserInfoModel()
                    }
                    return model
                }

                complete(results, nil)
            })
        }
    }

}

// MARK: - 使用新版的接口

// MARK: - 其他置顶相关(非评论置顶的)

extension TSPinnedNetworkManager {
    /// 申请置顶
    /// 取消置顶

    // MARK: - 注：非评论的指定中，目前只圈子的帖子可以前端处理(置顶列表、同意置顶、拒绝置顶)

    /// 帖子申请置顶列表
    /// 同意帖子置顶
    /// 拒绝帖子置顶
}

// MARK: - 评论置顶相关

extension TSPinnedNetworkManager {

    /// 评论置顶审核消息列表
    ///
    /// - Parameters:
    ///   - commentTargetType: 评论对象的类型
    ///   - limit: 本次请求列表的限制条数
    ///   - after: 分页请求标记(注：帖子的评论置顶通知中是offset，其余情况下是afterId)
    ///   - complete: 请求结果回调
    ///
    ///   - Note: after在帖子的评论置顶通知中是offset，其余情况下是afterId
    class func pinnedList(commentTargetType: TSTopTargetType.Comment, limit: Int, after: Int, complete: @escaping ((_ modelList: [ReceivePendingCommentTopModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        switch commentTargetType {
        case .moment:
            TSPinnedNetworkManager.momentCommentPinnedList(limit: limit, after: after, complete: complete)
        case .news:
            TSPinnedNetworkManager.newsCommentPinnedList(limit: limit, after: after, complete: complete)
        case .post:
            TSPinnedNetworkManager.postCommentPinnedList(limit: limit, after: after, complete: complete)
        }
    }

    class func momentCommentPinnedList(limit: Int, after: Int, complete: @escaping ((_ modelList: [ReceivePendingCommentTopModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = TSPinnedNetworkRequest.Comment.Moment.pinnedList
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        let params: [String: Any] = ["limit": limit, "after": after]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                if response.models.isEmpty {
                    complete([], response.message, true)
                } else {
                    TSPinnedNetworkManager.getPinnedListUserInfo(pinnedList: response.models, complete: complete)
                }
            }
        }
    }
    class func newsCommentPinnedList(limit: Int, after: Int, complete: @escaping ((_ modelList: [ReceivePendingCommentTopModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = TSPinnedNetworkRequest.Comment.News.pinnedList
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        let params: [String: Any] = ["limit": limit, "after": after]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                if response.models.isEmpty {
                    complete([], response.message, true)
                } else {
                    TSPinnedNetworkManager.getPinnedListUserInfo(pinnedList: response.models, complete: complete)
                }
            }
        }
    }
    class func postCommentPinnedList(limit: Int, after: Int, complete: @escaping ((_ modelList: [ReceivePendingCommentTopModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = TSPinnedNetworkRequest.Comment.Post.pinnedList
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        let params: [String: Any] = ["limit": limit, "after": after]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                if response.models.isEmpty {
                    complete([], response.message, true)
                } else {
                    TSPinnedNetworkManager.getPinnedListUserInfo(pinnedList: response.models, complete: complete)
                }
            }
        }
    }

    /// 获取评论置顶列表下的用户
    class func getPinnedListUserInfo(pinnedList: [ReceivePendingCommentTopModel], complete: @escaping (_ modelList: [ReceivePendingCommentTopModel]?, _ msg: String?, _ status: Bool) -> Void) -> Void {
        if pinnedList.isEmpty {
            complete([], nil, false)
            return
        }
        let userIds = pinnedList.map({ (temp) -> Int in
            return temp.userId
        })
        let filterIds = Array(Set(userIds))
        TSUserNetworkingManager().getUsersInfo(usersId: filterIds, complete: { (userList, msg, status) in
            guard status, let userList = userList else {
                complete(nil, msg, false)
                return
            }
            let results = pinnedList.map({ (model) -> ReceivePendingCommentTopModel in
                for user in userList {
                    if model.userId == user.userIdentity {
                        model.userInfo = user
                    }
                }
                return model
            }).map { model -> ReceivePendingCommentTopModel in
                // 如果未查询到用户信息 且用户ID不等于0 的 就设置一个 未知用户
                if model.userInfo == nil && model.userId != 0 {
                    model.userInfo = TSUnknownUserInfoModel()
                }
                return model
            }
            complete(results, msg, true)
        })
    }

    /// 申请评论置顶
    ///
    /// - Parameters:
    ///   - commentId: 评论id
    ///   - commentTargetId: 评论对象的id
    ///   - commentTargetType: 评论对象的类型
    ///   - day: 置顶天数
    ///   - amount: 置顶总价格，单位分。
    ///   - complete: 请求结果回调
    class func applyCommentPinned(commentId: Int, commentTargetId: Int, commentTargetType: TSTopTargetType.Comment, day: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch commentTargetType {
        case .moment:
            request = TSPinnedNetworkRequest.Comment.Moment.applyPinned
        case .news:
            request = TSPinnedNetworkRequest.Comment.News.applyPinned
        case .post:
            request = TSPinnedNetworkRequest.Comment.Post.applyPinned
        }
        if commentTargetType == .post {
            request.urlPath = request.fullPathWith(replacers: ["\(commentId)"])
        } else {
            request.urlPath = request.fullPathWith(replacers: ["\(commentTargetId)", "\(commentId)"])
        }
        // 2. params
        let params: [String: Any] = ["amount": amount, "day": day]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete( "网络请求错误", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 取消评论置顶 - 暂时仅资讯评论开放该接口

    /// 同意评论置顶
    ///
    /// - Parameters:
    ///   - commentId: 评论id
    ///   - pinnedId: 评论置顶申请的id
    ///   - commentTargetId: 评论对象的id
    ///   - commentTargetType: 评论对象的类型
    ///   - complete: 请求结果回调
    class func agreeCommentPinned(commentId: Int, pinnedId: Int, commentTargetId: Int, commentTargetType: TSTopTargetType.Comment, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch commentTargetType {
        case .moment:
            request = TSPinnedNetworkRequest.Comment.Moment.agreePinned
        case .news:
            request = TSPinnedNetworkRequest.Comment.News.agreePinned
        case .post:
            request = TSPinnedNetworkRequest.Comment.Post.agreePinned
        }
        if commentTargetType == .post {
            request.urlPath = request.fullPathWith(replacers: ["\(commentId)"])
        } else {
            request.urlPath = request.fullPathWith(replacers: ["\(commentTargetId)", "\(commentId)", "\(pinnedId)"])
        }
        // 2. params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete( "网络请求错误", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 拒绝评论置顶
    ///
    /// - Parameters:
    ///   - commentId: 评论id
    ///   - pinnedId: 评论置顶申请的id
    ///   - commentTargetId: 评论对象的id
    ///   - commentTargetType: 评论对象的类型
    ///   - complete: 请求结果回调
    class func denyCommentPinned(commentId: Int, pinnedId: Int, commentTargetId: Int, commentTargetType: TSTopTargetType.Comment, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch commentTargetType {
        case .moment:
            request = TSPinnedNetworkRequest.Comment.Moment.rejectPinned
            request.urlPath = request.fullPathWith(replacers: ["\(pinnedId)"])
        case .news:
            request = TSPinnedNetworkRequest.Comment.News.rejectPinned
            request.urlPath = request.fullPathWith(replacers: ["\(commentTargetId)", "\(commentId)", "\(pinnedId)"])
        case .post:
            request = TSPinnedNetworkRequest.Comment.Post.rejectPinned
            request.urlPath = request.fullPathWith(replacers: ["\(commentId)"])
        }
        // 2. params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete( "网络请求错误", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

}

// MARK: - 帖子置顶审核相关

extension TSPinnedNetworkManager {
    /// 帖子申请置顶列表
    ///
    /// - Parameters:
    ///   - groupId: 圈子id  默认(nil) 全部，某个圈子置顶帖子需传圈子id
    ///   - after: 默认 0 ，数据偏移id
    ///   - limit: 默认 15 ，数据返回条数 默认为15
    ///   - complete: 请求结果回调
    class func getPostTopList(groupId: Int?, after: Int, limit: Int, complete: @escaping (_ modelList: [ReceivePendingPostTopModel]?, _ msg: String?, _ status: Bool) -> Void) -> Void {
        // 1. url
        var request = TSPinnedNetworkRequest.Post.pinnedList
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        var params: [String: Any] = ["after": after, "limit": limit]
        if let groupId = groupId {
            params.updateValue(groupId, forKey: "group")
        }
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                complete(response.models, response.message, true)
            }
        }
    }

    /// 申请帖子置顶
    ///
    /// - Parameters:
    ///   - postId: 帖子id
    ///   - day: 置顶天数
    ///   - amount: 置顶总价格，单位分。
    ///   - complete: 请求结果回调
    class func applyPostPinned(postId: Int, day: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = TSPinnedNetworkRequest.Post.applyPinned
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2. params
        let params: [String: Any] = ["day": day, "amount": amount]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 帖子置顶审核
    enum PostTopAudit {
        case agree
        case reject
    }

    /// 帖子置顶处理：同意置顶、拒绝置顶
    ///
    /// - Parameters:
    ///   - postId: 帖子id
    ///   - process: 帖子置顶处理：同意置顶、拒绝置顶
    ///   - complete: 请求结果回调
    class func postTopPinnedAudit(postId: Int, audit: PostTopAudit, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch audit {
        case .agree:
            request = TSPinnedNetworkRequest.Post.agreePinned
        case .reject:
            request = TSPinnedNetworkRequest.Post.rejectPinned
        }
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2. params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

}
