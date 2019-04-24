//
//  TSCommentTaskQueue.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  评论队列

import UIKit
import RealmSwift

class TSCommentTaskQueue: NSObject {

    enum CommentType {
        case send
        case delete
    }
    /// 最大错误请求次数
    let maxErrorRequest = 2
    /// 错误请求次数
    var errorCount = 0

    /// 获取评论详情
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - momentUserId: 动态的用户id
    ///   - maxId: 请求下一页的id
    /// - Returns: 返回评论模型
    func getCommentDatas(momentListObject: TSMomentListObject, maxId: Int?, complete: @escaping ([TSSimpleCommentModel]?) -> Void) {
        let momentId = momentListObject.feedIdentity
        TSCommentTaskQueue.getCommentList(type: .momment, sourceId:momentId, afterId: maxId, limit: TSAppConfig.share.localInfo.limit) { (commentList, msg, status) in
            complete(commentList)
        }
    }

    /// 发送评论
    ///
    /// - Parameters:
    ///   - CellModel: 动态cell的模型数据
    ///   - commentModel: 评论的模型数据
    ///   - message: 评论内容
    func send(cellModel: TSMomentListCellModel, commentModel: TSSimpleCommentModel?, message: String, type: SendCommentType, complete: @escaping (TSMomentListCellModel) -> Void) -> TSMomentListCellModel {
        let commentMark = Int64(TSCurrentUserInfo.share.createResourceID())
        let replayId = commentModel?.userInfo?.userIdentity
        let object: TSSendCommentObject!

        switch type {
        case .send, .replySend:
            /// 保存新建的任务的
            object = setTSSendCommentObject(message: message, replyToUserId: replayId ?? 0, create: NSDate(), feedId: (cellModel.data?.feedIdentity)!, userIdentity: (TSCurrentUserInfo.share.userInfo?.userIdentity)!, commentMark: commentMark, commentId: Int(commentMark), status: 0)
            TSDatabaseManager().comment.save(comment:object)
        case .reSend:
            /// 把没有发送成功的设置成发送成功的状态(为了避免用户在请求的时候下拉刷新，又刷新出没有发送成功的任务，而反复发送)
            object = setTSSendCommentObject(message: (commentModel?.content)!, replyToUserId: commentModel?.replyUserInfo?.userIdentity, create: (commentModel?.createdAt)!, feedId: (cellModel.data?.feedIdentity)!, userIdentity: (commentModel?.userInfo?.userIdentity)!, commentMark: (commentModel?.commentMark)!, commentId: (commentModel?.id)!, status: 0)
            TSDatabaseManager().comment.save(comment:object)
        default:
            object = TSSendCommentObject()
            assert(false, "不应该走这里")
        }

        var rcommentModel = TSSimpleCommentModel()
        rcommentModel.commentMark = commentMark
        rcommentModel.content = message
        rcommentModel.createdAt = NSDate()
        rcommentModel.id = Int(commentMark)
        rcommentModel.userInfo = TSCurrentUserInfo.share.userInfo?.convert().object()

        let momentObject = setMomentObject(moment: cellModel.data!, comments: Array((cellModel.data?.comments)!), type: type, rcommentModel: rcommentModel)

        var mommentModel = TSMomentListCellModel()
        mommentModel.userInfo = cellModel.userInfo
        mommentModel.data = momentObject
        var cellModel = cellModel

        switch type {
        case .send :
            rcommentModel.replyUserInfo = nil
            cellModel.comments?.insert(rcommentModel, at: 0)
        case .replySend:
            rcommentModel.replyUserInfo = commentModel?.userInfo
            cellModel.comments?.insert(rcommentModel, at: 0)
        default:
            rcommentModel.replyUserInfo = commentModel?.replyUserInfo
            /// 修改重发的状态，让它假装成功
            for (index, item) in cellModel.comments!.enumerated() {
                if item.commentMark == commentModel?.commentMark {
                    var comment = item
                    comment.status = 0
                    cellModel.comments?[index] = comment
                }
            }
            break
        }

        mommentModel.comments = cellModel.comments
        mommentModel.height = cellModel.height

        /// 发送请求
        switch type {
        case .send, .replySend:
            requestSend(commentContent: message, replyToUserId: replayId, feedId: (cellModel.data?.feedIdentity)!, object: object, commentMark: commentMark, momentObject: mommentModel, complete: { model in
                complete(model)
            })
        default:
            requestSend(commentContent: message, replyToUserId: commentModel?.replyUserInfo?.userIdentity, feedId: (cellModel.data?.feedIdentity)!, object: object, commentMark: (commentModel?.commentMark)!, momentObject: mommentModel, complete: { model in
                complete(model)
            })
        }
        TSDatabaseManager().moment.save(userMoments: momentObject.userIdentity, objects: [momentObject])
        return mommentModel
    }

    /// 设置发送任务的对象
    private func setTSSendCommentObject(message: String, replyToUserId: Int?, create: NSDate, feedId: Int, userIdentity: Int, commentMark: Int64, commentId: Int, status: Int ) -> TSSendCommentObject {
        let object = TSSendCommentObject()
        object.commentIdentity = commentId
        object.commentMark = commentMark
        object.content = message
        object.create = create
        object.feedId = feedId
        object.replayToUserIdentity = replyToUserId ?? 0
        object.userIdentity = userIdentity
        object.status = status
        return object
    }

    /// 发送评论请求队列
    ///
    /// - Parameters:
    ///   - commentContent: 评论内容
    ///   - replyToUserId: 被回复人的Id
    ///   - feedId: 动态的唯一Id
    ///   - object: 评论数据模型
    ///   - commentMark: 评论的唯一Id
    private func requestSend(commentContent: String, replyToUserId: Int?, feedId: Int, object: TSSendCommentObject, commentMark: Int64, momentObject: TSMomentListCellModel, complete: @escaping (TSMomentListCellModel) -> Void) {
        TSCommentNetWorkManager().send(commentContent: commentContent, replyToUserId: replyToUserId, feedId: feedId, type: .feed) { (_, commentId, _) in
            if let commentId = commentId {
                let failSendComments = TSDatabaseManager().comment.getSendTask()
                guard let comments = failSendComments else {
                    return
                }
                for item in comments {
                    if item.commentMark == commentMark {
                        TSDatabaseManager().comment.delete(commentMark: commentMark)
                        var momentObject = momentObject
                        for (index, item) in momentObject.comments!.enumerated() {
                            if item.commentMark == commentMark {
                                momentObject.comments?[index].id = commentId
                                let commentObject = momentObject.data?.comments.filter("commentMark == \(commentMark)")
                                if !(commentObject?.isEmpty)! {
                                    let realm = try! Realm()
                                    realm.beginWrite()
                                    commentObject?.first?.commentIdentity = commentId
                                    try! realm.commitWrite()
                                }
                            }
                        }
                        complete(momentObject)
                    }
                }
                return
            }

            if self.errorCount == self.maxErrorRequest {
                if object.isInvalidated {
                    self.errorCount = 0
                    return
                }
                let SendComment = TSSendCommentObject()
                SendComment.commentIdentity = 0
                SendComment.content = object.content
                SendComment.feedId = object.feedId
                SendComment.create = object.create
                SendComment.userIdentity = object.userIdentity
                SendComment.replayToUserIdentity = object.replayToUserIdentity
                SendComment.commentMark = object.commentMark
                SendComment.status = 1
                TSDatabaseManager().comment.save(comment:SendComment)
                self.errorCount = 0
                return
            }

            if self.errorCount <= self.maxErrorRequest {
                self.errorCount += 1
                let waitTime: Int = self.errorCount * 2
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(waitTime), execute: {
                    DispatchQueue.main.async {
                        self.requestSend(commentContent: commentContent, replyToUserId: replyToUserId, feedId: feedId, object: object, commentMark: commentMark, momentObject: momentObject, complete: { _ in
                        })
                    }
                })
            }
        }
    }

    /// 删除评论
    ///
    /// - Parameters:
    ///   - CellModel: 动态cell的模型数据
    ///   - commentModel: 评论的模型数据
    func deleteComment(cellModel: TSMomentListCellModel, commentModel: TSSimpleCommentModel) -> TSMomentListCellModel {

        // 目的为了修改评论模型的评论数量，应该一致
        var finalComments: [TSSimpleCommentModel] = Array()
        for item in cellModel.comments! {
            if item.commentMark != commentModel.commentMark {
                finalComments.append(item)
            }
        }

        // 再检查有没有发送中的消息并删除（不然在网络不好的时候可能会把删除任务添加到Moments数据库里）
        let feedId = cellModel.data?.feedIdentity
        let errComments = TSDatabaseManager().comment.get(feedId: feedId!)
        if let commsents = errComments {
            for comment in commsents {
                if commentModel.commentMark == comment.commentMark {
                    TSDatabaseManager().comment.delete(commentMark: commentModel.commentMark)
                    var cellM = cellModel
                    cellM.comments = finalComments
                    // 能走到这个里证明因为网络问题之前这条评论还没有发送出去，索性直接从数据库里删除，等待发送成功后再让用户删除一次，或者根本就没有发送成功，用户也不用删除了，同时避免了给后台发送没有comment_id的删除评论请求，所以才return，这是一种极端情况(其实很容易遇到：比如🚇里？)
                    let realm = try! Realm()
                    realm.beginWrite()
                    cellM.data?.commentCount -= 1
                    try! realm.commitWrite()
                     TSDatabaseManager().comment.delete(mommentCommentMark: commentModel.commentMark)
                    return cellM
                }
            }
        }

//        // 储存需要删除的评论任务
        let deleteObjce = TSDeleteCommentObject()
        deleteObjce.feedId.value = feedId!
        deleteObjce.commentIdentity.value = commentModel.id
        deleteObjce.commentMark.value = commentModel.commentMark
        TSDatabaseManager().comment.save(delete: deleteObjce)

        let realm = try! Realm()
        realm.beginWrite()
        cellModel.data?.commentCount -= 1
        try! realm.commitWrite()
        TSDatabaseManager().comment.delete(mommentCommentMark: commentModel.commentMark)

        /// 这里才是修改当前的模型（评论数，评论内容）
        var mommentModel = TSMomentListCellModel()
        mommentModel.userInfo = cellModel.userInfo
        mommentModel.data = cellModel.data
        mommentModel.comments = finalComments
        mommentModel.height = cellModel.height

        // 好了终于可以正式请求删除了
        deleteRequest(deleteObjce: deleteObjce, complete: {_ in
        })
        return mommentModel
    }

    /// 删除评论请求
    ///
    /// - Parameters:
    ///   - feedId: 动态的唯一Id
    ///   - commentId: 评论的索引Id
    func deleteRequest(deleteObjce: TSDeleteCommentObject, complete: @escaping (Bool) -> Void) {
        TSCommentNetWorkManager().delete(feedId: deleteObjce.feedId.value!, commentId: deleteObjce.commentIdentity.value!) { (isSuccess) in
            if isSuccess {
                let deleteTask = TSDatabaseManager().comment.getDeleteTask()
                guard let deletes = deleteTask else {
                    complete(isSuccess)
                    return
                }

                for item in deletes {
                    if !item.isInvalidated && !deleteObjce.isInvalidated {
                        if item.commentMark.value == deleteObjce.commentMark.value {
                            TSDatabaseManager().comment.delete(deleteCommentMark: deleteObjce.commentMark.value!)
                        }
                    }
                }
                // 删除要删除的评论
                complete(isSuccess)
                return
            }

            if self.errorCount == self.maxErrorRequest {
                complete(isSuccess)
                return
            }

            if self.errorCount <= self.maxErrorRequest {
                self.errorCount += 1
                let waitTime: Int = self.errorCount * 2
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(waitTime), execute: {
                    DispatchQueue.main.async {
                        self.deleteRequest(deleteObjce: deleteObjce, complete: {_ in
                        })
                    }
                })
            }
        }
    }

    /// 合成新的cell对象
    ///
    /// - Parameters:
    ///   - moment: cell的原始数据
    ///   - comments: 评论些
    ///   - type: 删除或发送
    /// - Returns: cell模型对象
    private func setMomentObject(moment: TSMomentListObject, comments: [TSMomentCommnetObject], type: SendCommentType, rcommentModel: TSSimpleCommentModel? ) -> TSMomentListObject {
        let object = TSMomentListObject()

        for item in comments {
            object.comments.append(item)
        }

        if let rcommentModel = rcommentModel {
            let realm = try! Realm()
            realm.beginWrite()
            let commentObject = TSMomentCommnetObject()
            commentObject.feedId = moment.feedIdentity
            commentObject.commentIdentity = Int(rcommentModel.commentMark)
            commentObject.content = rcommentModel.content
            commentObject.create = rcommentModel.createdAt
            commentObject.replayToUserIdentity = rcommentModel.replyUserInfo?.userIdentity ?? 0
            commentObject.toUserIdentity = moment.userIdentity
            commentObject.userIdentity = rcommentModel.userInfo!.userIdentity
            commentObject.commentMark = rcommentModel.commentMark
            realm.add(commentObject, update: true)
            object.comments.append(commentObject)
            try! realm.commitWrite()
        }

        var count = 0
        switch type {
        case .delete:
            count = moment.commentCount - 1
        case .replySend, .send:
            count = moment.commentCount + 1
        case .getList, .reSend:
            count = moment.commentCount
        case .top:
            break
        }

        object.commentCount = count
        object.isCollect = moment.isCollect
        object.userIdentity = moment.userIdentity
        object.content = moment.content
        object.create = moment.create
        object.digg = moment.digg
        object.feedIdentity = moment.feedIdentity
        object.primaryKey = moment.feedIdentity
        object.follow = moment.follow
        object.from = moment.from
        object.hot = moment.hot
        object.isDigg = moment.isDigg
        object.latitude = moment.latitude
        object.longtitude = moment.longtitude
        object.localCreate = moment.localCreate
        object.now = moment.now
        object.paid = moment.paid
        for item in moment.pictures {
            object.pictures.append(item)
        }

        object.sendState = moment.sendState
        object.view = moment.view
        object.sendState = moment.sendState
        object.title = moment.title
        return (object)
    }

    /// 启动时检查是否有失败的的评论任务，有则转成失败状态 / 检查是否有未删除成功的评论
    func checkFailCommentsTask(isOpenApp: Bool) {
        if isOpenApp {
            let failSendComments = TSDatabaseManager().comment.getSendTask()
            guard let comments = failSendComments else {
                return
            }
            TSDatabaseManager().comment.replace(failComments: comments)

            // 请求删除的评论
            let deleteCommentsTask = TSDatabaseManager().comment.getDeleteTask()
            if let deleteComments = deleteCommentsTask {
                for item in deleteComments {
                    TSCommentTaskQueue().deleteRequest(deleteObjce: item, complete: { (_) in
                    })
                }
            }
        }
    }

}

// MARK: - New API
// Note：评论重构完成时，应删除上面所有代码

extension TSCommentTaskQueue {

    /// 获取评论列表的封装
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景
    ///   - sourceId: 评论的对象的id
    ///   - afterId: Int?, 评论列表的起始id，默认为nil表示最头开始
    ///   - limit: Int, 评论限制条数，(默认为20，由外界传入)
    ///   - complete: 请求回调
    class func getCommentList(type: TSCommentType, sourceId: Int, afterId: Int?, limit: Int, complete: @escaping((_ commentList: [TSSimpleCommentModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSCommentNetWorkManager.getCommentList(type: type, sourceId: sourceId, afterId: afterId, limit: limit) { (commentList, msg, status) in
            // 请求成功失败与否的判断
            guard status, let commentList = commentList else {
                complete(nil, msg, false)
                return
            }
            /***
             这里暂时先使用之前的方式，之后再确认这里是否能解析到用户，而直接使用下面的方式。
            // 如果是帖子的评论，无需请求用户(帖子评论中已返回用户列表，但之前的评论部分还没有返回用户)
            if type == .post {
                // 将评论列表模型更换
                var simpleList = [TSSimpleCommentModel]()
                for commentModel in commentList {
                    simpleList.append(commentModel.simpleModel())
                }
                complete(simpleList, msg, status)
                return
            }
             **/

            if commentList.isEmpty {
                complete([TSSimpleCommentModel](), msg, status)
                return
            }
            // 构造用户id列表用于请求用户信息
            var userIds = [Int]()
            for comment in commentList {
                if !userIds.contains(comment.userId) {
                    userIds.append(comment.userId)
                }
                if !userIds.contains(comment.targetUserId) {
                    userIds.append(comment.targetUserId)
                }
                if nil != comment.replyUserId && !userIds.contains(comment.replyUserId!) {
                    userIds.append(comment.replyUserId!)
                }
            }
            let commentMsg = msg
            TSUserNetworkingManager().getUsersInfo(usersId: userIds, complete: { (userList, msg, status) in
                guard status, let userList = userList else {
                    complete(nil, msg, false)
                    return
                }
                // 本地保存用户列表信息
                TSDatabaseManager().user.saveUsersInfo(userList)
                // 对当前的评论列表匹配用户信息
                for commentModel in commentList {
                    let users = userList.filter({ (userModel) -> Bool in
                        return userModel.userIdentity == commentModel.userId
                    })
                    commentModel.user = users.first
                    let replyUsers = userList.filter({ (userModel) -> Bool in
                        return userModel.userIdentity == commentModel.replyUserId
                    })
                    commentModel.replyUser = replyUsers.first
                    let targetUsers = userList.filter({ (userModel) -> Bool in
                        return userModel.userIdentity == commentModel.targetUserId
                    })
                    commentModel.targetUser = targetUsers.first
                }
                // 将评论列表模型更换
                var simpleList = [TSSimpleCommentModel]()
                for commentModel in commentList {
                    simpleList.append(commentModel.simpleModel())
                }
                complete(simpleList, commentMsg, status)
            })
        }
    }

    /// 发送评论的封装
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - content: 评论内容(必填)
    ///   - sourceId: 评论的对象的id(必填)
    ///   - replyUserId: 若该评论是回复别人，则需传入被回复的用户的id(选填)
    ///   - complete: 请求回调
    class func submitComment(for type: TSCommentType, content: String, sourceId: Int, replyUserId: Int?, complete: @escaping ((_ successModel: TSCommentModel?, _ failModel: TSFailedCommentModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSCommentNetWorkManager.submitComment(for: type, content: content, sourceId: sourceId, replyUserId: replyUserId) { (commentModel, msg, status) in
            // 发送失败处理
            guard status, let model = commentModel else {
                // 构建failedModel，存储并回调
                let failedModel = TSFailedCommentModel(type: type, sourceId: sourceId, content: content, targetUserId: 0, replyUserId: replyUserId)
                failedModel.user = TSDatabaseManager().user.getUserInfo(userId: failedModel.userId)
                failedModel.targetUser = TSDatabaseManager().user.getUserInfo(userId: failedModel.targetUserId)
                if let replyUserId = replyUserId {
                    failedModel.replyUser = TSDatabaseManager().user.getUserInfo(userId: replyUserId)
                }
                TSDatabaseManager().commentManager.save(failedModel)
                complete(nil, failedModel, msg, status)
                return
            }
            // 发送成功处理
            model.user = TSDatabaseManager().user.getUserInfo(userId: model.userId)
            model.targetUser = TSDatabaseManager().user.getUserInfo(userId: model.targetUserId)
            if let replyUserId = model.replyUserId {
                model.replyUser = TSDatabaseManager().user.getUserInfo(userId: replyUserId)
            }
            complete(model, nil, msg, status)
        }
    }

    /// 删除评论的封装
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - commentId: 评论内容(必填)
    ///   - sourceId: 评论的对象的id(必填)
    ///   - complete: 请求回调
    class func deleteComment(for type: TSCommentType, commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSCommentNetWorkManager.deleteComment(for: type, commentId: commentId, sourceId: sourceId, complete: complete)
    }

}
