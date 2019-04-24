//
//  TSCommentNetWorkManager.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  评论相关请求
//  Remark: - TODO 该页面有很多需要移除，待之后完成

import UIKit
import RealmSwift

import ObjectMapper

class TSCommentNetWorkManager: NSObject {

    /// 设置评论置顶
    ///
    /// - Parameters:
    ///   - feedId: 动态 id
    ///   - days: 置顶天数
    ///   - amount: 置顶金额
    ///   - complete: 结果
    func set(comment commentId: Int, ofFeed feedId: Int, toTopDuring days: Int, withMoney amount: Int, complete: @escaping((Bool, String?) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)" + TSURLPathV2.Feed.comments.rawValue + "/\(commentId)" + TSURLPathV2.Feed.pinneds.rawValue
        var parametars: [String : Any] = ["day": days, "amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parametars, complete: { (datas: NetworkResponse?, status: Bool) in
            let message: String? = TSCommonNetworkManager.getNetworkErrorMessage(with: datas)
            complete(status, message)
        })
    }

    /// 获取评论数据
    ///
    /// - Parameters:
    ///   - feedId: feedId
    ///   - complete: 返回评论列表的数组
    func getCommetList(feedId: Int, maxId after: Int?, complete: @escaping((_ isSuccess: Bool, _ commnetModels: [TSMomentCommnetModel]?, _ error: String?) -> Void)) {
        // 配置 path
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)" + TSURLPathV2.Feed.comments.rawValue + "?limit=" + "\(TSAppConfig.share.localInfo.limit)"
        if let after = after {
            path = path + "&after=\(after)"
        }

        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data: NetworkResponse?, status: Bool) in
            // 1. 网络请求失败
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(false, nil, message) // 返回后台信息
                return
            }
            // 2. 数据格式错误
            guard let datas = data as? [String: Any] else {
                complete(status, nil, "服务器返回数据错误")
                return
            }
            // 3. 正常解析数据
            var commentDatas: [[String: Any]] = []
            var tops: [[String: Any]] = []
            var normals: [[String: Any]] = []
            // 3.1.获取置顶数据
            if let topDatas = datas["pinneds"] as? [Dictionary<String, Any>] {
                tops = topDatas
            }
            // 3.2.获取普通数据
            if let normalDatas = datas["comments"] as? [Dictionary<String, Any>] {
                normals = normalDatas
            }
            // 置顶去重(普通的评论列表中也还有置顶评论)
            var normalTopFlags: [(isTop: Bool, index: Int)] = [(isTop: Bool, index: Int)]()
            for (index, _) in normals.enumerated() {
                normalTopFlags.append((isTop: false, index: index))
            }
            for topComment in tops {
                for (index, normalComment) in normals.enumerated() {
                    if let topCommentId = topComment["id"] as? Int, let normalCommentId = normalComment["id"] as? Int, topCommentId == normalCommentId {
                        normalTopFlags[index].isTop = true
                    }
                }
            }
            for normalTopFlag in normalTopFlags.reversed() {
                if normalTopFlag.isTop {
                    normals.remove(at: normalTopFlag.index)
                }
            }
            commentDatas = normals + tops
            // 3.3.解析数据
            var commentObject: [TSMomentCommnetModel] = []
            for index in 0..<commentDatas.count {
                let comment = commentDatas[index]
                var commentModel = TSMomentCommnetModel(comment)
                if index >= normals.count {
                    commentModel.painned = 1
                }
                var isHave = false
                let deleteCommentsTask = TSDatabaseManager().comment.getDeleteTask()
                if let deleteDatas = deleteCommentsTask {
                    for delete in deleteDatas {
                        if delete.commentMark.value == commentModel.commentMark {
                            isHave = true
                        }
                    }

                    if isHave {
                        continue
                    }
                }
                commentObject.append(commentModel)
            }
            complete(status, commentObject, nil)
        })
    }

    /// 发送评论
    ///
    /// - Parameters:
    ///   - commentContent: 评论内容
    ///   - replyToUserId: 被回复人的ID
    ///   - feedId: 动态的唯一Id
    ///   - complete: 返回的参数
    func send(commentContent: String, replyToUserId: Int?, feedId: Int, type: ReceiveInfoSourceType, complete: @escaping((_ message: String?, _ id: Int?, _ error: NSError?) -> Void)) {
        let sourceId = feedId
        let commentType: TSCommentType = TSCommentType(type: type)
        TSCommentNetWorkManager.submitComment(for: commentType, content: commentContent, sourceId: sourceId, replyUserId: replyToUserId) { (comment, msg, status) in
            // 发送失败
            guard status, let comment = comment else {
                complete(msg, nil, TSErrorCenter.create(With: .networkError))
                return
            }
            // 发送成功
            complete(msg, comment.id, nil)
        }
    }

    func sendMoment(commentContent: String, replyToUserId: Int?, feedId: Int, type: ReceiveInfoSourceType, complete: @escaping((_ message: String?, _ id: Int?, _ error: NSError?) -> Void)) {
        // 配置路径
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)" + TSURLPathV2.Feed.comments.rawValue
        // 配置参数
        var parameters: [String: Any] = ["body": commentContent]
        if let replyToUserId = replyToUserId {
            parameters.updateValue(replyToUserId, forKey: "reply_user")
        }

        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters, complete: { (data: NetworkResponse?, status) in
            // 1. 网络请求失败处理
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, nil, nil) // 返回后台信息
                return
            }
            // 2. 返回数据异常
            guard let commentDatas = data as? [String: Any], let comment = commentDatas["comment"] as? [String: Any] else {
                complete("服务器返回数据解析错误", nil, nil)
                return
            }
            // 3. 正常数据解析
            let id = comment["id"] as? Int
            complete(nil, id, nil)
        })
    }

    /// 删除评论
    ///
    /// - Parameters:
    ///   - feedId: 动态唯一Id
    ///   - commentId: 排序用的Id
    ///   - complete: 完成后的参数
    func delete(feedId: Int, commentId: Int, complete: @escaping((Bool) -> Void)) {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue + "/\(feedId)" + TSURLPathV2.Feed.comments.rawValue + "/\(commentId)"

        try! RequestNetworkData.share.textRequest(method: .delete, path: path, parameter: nil) { (data: NetworkResponse?, _) in
            if data is NetworkError {
                complete(false)
            } else {
                complete(true)
            }
        }
    }

    // MARK: - 圈子相关

    // [长期注释] 时间有限，复制动态的代码，后期有时间请优化
    /// 获取帖子评论

    /// 获取评论数据
    func getPostCommetList(groupId: Int, postId: Int, after: Int?, complete: @escaping((_ isSuccess: Bool, _ commnetModels: [TSMomentCommnetModel]?, _ error: String?) -> Void)) {
        // 配置路径
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Group.comments.rawValue + "?limit=" + "\(TSAppConfig.share.localInfo.limit)"
        path = path.replacingOccurrences(of: "{group}", with: "\(groupId)")
        path = path.replacingOccurrences(of: "{post}", with: "\(postId)")
        if let after = after {
            path = path + "&after=\(after)"
        }

        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data: NetworkResponse?, status: Bool) in
            // 1. 请求失败处理
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(false, nil, message) // 返回后台信息
                return
            }
            // 2. 服务器数据异常
            guard let datas = data as? [[String: Any]] else {
                complete(false, nil, "服务器数据异常")
                return
            }
            // 3. 正常数据解析
            var commentObject: [TSMomentCommnetModel] = []
            for comment in datas {
                let commentModel = TSMomentCommnetModel(postComment: comment)
                var isHave = false
                let deleteCommentsTask = TSDatabaseManager().comment.getDeleteTask()
                if let deleteDatas = deleteCommentsTask {
                    for delete in deleteDatas {
                        if delete.commentMark.value == commentModel.commentMark {
                            isHave = true
                        }
                    }
                    if isHave {
                        continue
                    }
                }
                commentObject.append(commentModel)
            }
            complete(status, commentObject, nil)
        })
    }

    /// 发送评论
    func sendPostComment(commentContent content: String, replyToUserId: Int?, groupId: Int, postId: Int, commentMark: Int64, complete: @escaping((_ message: String?, _ id: Int?, _ error: NSError?) -> Void)) {
        // 配置路径
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Group.comments.rawValue
        path = path.replacingOccurrences(of: "{group}", with: "\(groupId)")
        path = path.replacingOccurrences(of: "{post}", with: "\(postId)")
        // 配置参数
        var parameters: [String: Any] = ["body": content, "group_post_comment_mark": commentMark]
        if let replyToUserId = replyToUserId {
            parameters.updateValue(replyToUserId, forKey: "reply_user")
        }

        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters, complete: { (data: NetworkResponse?, status) in
            // 1.1 请求失败处理
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, nil, nil) // 返回后台信息
                return
            }
            // 1.2 返回数据异常处理
            guard let commentDatas = data as? [String: Any], let comment = commentDatas["comment"] as? [String: Any] else {
                complete("服务器返回数据解析错误", nil, nil)
                return
            }
            // 1.3 正常数据解析
            let id = comment["id"] as? Int
            complete(nil, id, nil)
        })
    }

}

// MARK: - 评论相关的请求统一: 评论加载和评论操作(发布评论、删除评论、申请置顶)
//  评论重构完成后，上面部分除了评论置顶外，其余部分皆应删除。

extension TSCommentNetWorkManager {
    /// 获取评论列表
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景
    ///   - sourceId: 评论的对象的id
    ///   - afterId: Int?, 评论列表的起始id，默认为nil表示最头开始
    ///   - limit: Int, 评论限制条数，(默认为20，外界传入)
    ///   - complete: 请求回调
    /// - Note: 评论列表的数据返回有2种包装方式：资讯和动态采用字段包装以区分置顶(pinneds + comments)，其余部分直接采用列表不用字段包装
    class func getCommentList(type: TSCommentType, sourceId: Int, afterId: Int?, limit: Int, complete: @escaping((_ commentList: [TSCommentModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<TSCommentModel>
        switch type {
        case .momment:
            request = CommentNetworkRequest.Moment.commentList
        case .news:
            request = CommentNetworkRequest.News.commentList
        case .album:
            request = CommentNetworkRequest.Album.commentList
        case .song:
            request = CommentNetworkRequest.Song.commentList
        case .question:
            request = CommentNetworkRequest.Question.commentList
        case .answer:
            request = CommentNetworkRequest.Answer.commentList
        case .post:
            request = CommentNetworkRequest.Post.commentList
        }
        request.urlPath = request.fullPathWith(replacers: ["\(sourceId)"])
        // 2. params
        var params: [String: Any] = [String: Any]()
        params.updateValue(limit, forKey: "limit")
        if let afterId = afterId {
            if type == .album || type == .song {
                params.updateValue(afterId, forKey: "max_id")
            } else {
                params.updateValue(afterId, forKey: "after")
            }
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
                var comments: [TSCommentModel] = response.models
                // 资讯、动态、帖子的评论进行特殊处理
                if type == .momment || type == .news || type == .post {
                    var commentList: [TSCommentModel] = [TSCommentModel]()
                    guard let dataDic = response.sourceData as? [String: Any] else {
                        complete(nil, "服务器返回数据错误", false)
                        return
                    }
                    if let topCommentList = Mapper<TSCommentModel>().mapArray(JSONObject: dataDic["pinneds"]) {
                        // 将topCommentList中的置顶标识修正
                        for topComment in topCommentList {
                            topComment.isTop = true
                        }
                        commentList += topCommentList
                    }
                    if var normalCommentList = Mapper<TSCommentModel>().mapArray(JSONObject: dataDic["comments"]) {
                        let topComment = commentList
                        if topComment.isEmpty {
                            commentList += normalCommentList
                        } else {
                            var indexArray = [Int]()
                            for (index, comment) in normalCommentList.enumerated() {
                                for top in topComment {
                                    if comment.id == top.id {
                                        indexArray.append(index)
                                    }
                                }
                            }
                            for index in indexArray {
                                normalCommentList.remove(at: index)
                            }
                            commentList += normalCommentList
                        }
                    }
                    comments = commentList
                }
                complete(comments, response.message, true)
            }
        }
    }

    /// 提交评论
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - content: 评论内容(必填)
    ///   - sourceId: 评论的对象的id(必填)
    ///   - replyUserId: 若该评论是回复别人，则需传入被回复的用户的id(选填)
    ///   - complete: 请求回调，请求成功则通过comment字段返回服务器上关于该评论的数据
    class func submitComment(for type: TSCommentType, content: String, sourceId: Int, replyUserId: Int?, complete: @escaping ((_ comment: TSCommentModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<TSCommentModel>
        switch type {
        case .momment:
            request = CommentNetworkRequest.Moment.sendComment
        case .news:
            request = CommentNetworkRequest.News.sendComment
        case .album:
            request = CommentNetworkRequest.Album.sendComment
        case .song:
            request = CommentNetworkRequest.Song.sendComment
        case .question:
            request = CommentNetworkRequest.Question.sendComment
        case .answer:
            request = CommentNetworkRequest.Answer.sendComment
        case .post:
            request = CommentNetworkRequest.Post.sendComment
        }
        request.urlPath = request.fullPathWith(replacers: ["\(sourceId)"])
        // 2. params
        var params: [String: Any] = [String: Any]()
        params.updateValue(content, forKey: "body")
        if let replyUserId = replyUserId {
            params.updateValue(replyUserId, forKey: "reply_user")
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
                guard let dataDic = response.sourceData as? [String: Any] else {
                    complete(nil, "服务器返回数据错误", false)
                    return
                }
                let comment = Mapper<TSCommentModel>().map(JSONObject: dataDic["comment"])
                complete(comment, response.message, true)
            }
        }
    }
    /// 删除评论
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - commentId: 评论的id(必填)
    ///   - sourceId: 评论的对象的id(必填)
    ///   - complete: 请求回调
    class func deleteComment(for type: TSCommentType, commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch type {
        case .momment:
            request = CommentNetworkRequest.Moment.deleteComment
        case .news:
            request = CommentNetworkRequest.News.deleteComment
        case .album:
            request = CommentNetworkRequest.Album.deleteComment
        case .song:
            request = CommentNetworkRequest.Song.deleteComment
        case .question:
            request = CommentNetworkRequest.Question.deleteComment
        case .answer:
            request = CommentNetworkRequest.Answer.deleteComment
        case .post:
            request = CommentNetworkRequest.Post.deleteComment
        }
        request.urlPath = request.fullPathWith(replacers: ["\(sourceId)", "\(commentId)"])
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
