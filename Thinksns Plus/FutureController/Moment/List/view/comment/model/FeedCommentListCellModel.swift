//
//  FeedCommentListCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class FeedCommentLabelModel {

    /// 评论 id 的类型
    enum IdType {
        case feed(feedId: Int, commentId: Int)
        case post(groupId: Int, postId: Int, commentId: Int)

        subscript(index: String) -> Int? {
            switch self {
            case .feed(let feedId, let commentId):
                if index == "feedId" {
                    return feedId
                }
                if index == "commentId" {
                    return commentId
                }
            case .post(let groupId, let postId, let commentId):
                if index == "postId" {
                    return postId
                }
                if index == "groupId" {
                    return groupId
                }
                if index == "commentId" {
                    return commentId
                }
            }
            return nil
        }
    }

    /// 评论类型
    enum CommentType {
        /// 评论了文章
        case text
        /// 评论了用户的评论（replyName: 被评论的用户信息）
        case user(replyName: String, replyUserId: Int)
    }

    /// id
    var id = IdType.feed(feedId: 0, commentId: 0)
    /// 评论者的用户名
    var name = ""
    /// 评论者的用户 id
    var userId = 0
    /// 评论类型
    var type = CommentType.text
    /// 评论内容
    var content = ""
    /// 是否显示置顶标签
    var showTopIcon = false

    // MARK: Object

    func object() -> FeedListCommentObject {
        let object = FeedListCommentObject()
        object.commentId = id["commentId"] ?? 0
        object.name = name
        object.userId = userId
        switch type {
        case .user(let replyName, let replyUserId):
            object.replyName = replyName
            object.replyUserId.value = replyUserId
        default:
            break
        }
        object.content = content
        object.showTopIcon = showTopIcon
        return object
    }
}

class FeedCommentListCellModel: FeedCommentLabelModel {

    /// 评论发送状态
    var sendStatus = SendStatus.success

    /// 控件距上左下右的距离
    var contentInset = UIEdgeInsets(top: 0, left: 58, bottom: 3, right: 13)
    /// cell 高度
    var cellHeight: CGFloat = 0

    override init() {
    }

    /// 初始化动态评论
    init(feedListCommentModel model: FeedListCommentModel) {
        super.init()
        id = .feed(feedId: model.feedid, commentId: model.id)
        name = model.userInfo.name
        userId = model.userId
        if model.replyId > 0 {
            type = .user(replyName: model.replyInfo.name, replyUserId: model.replyId)
        }
        content = model.body
        showTopIcon = model.pinned
    }

    /// 初始化帖子评论
    init(postListCommentModel model: PostListCommentModel, postId: Int, groupId: Int) {
        super.init()
        id = .post(groupId: groupId, postId: postId, commentId: model.id)
        name = model.userInfo.name
        userId = model.userId
        if model.replyId > 0 {
            type = .user(replyName: model.replyInfo.name, replyUserId: model.replyId)
        }
        content = model.body
        showTopIcon = model.pinned
    }

    /// 初始化帖子评论
    init(topicPostListCommentModel model: TopicPostListCommentModel, postId: Int, groupId: Int) {
        super.init()
        id = .post(groupId: groupId, postId: postId, commentId: model.id)
        name = model.userInfo.name
        userId = model.userId
        if model.replyId > 0 {
            type = .user(replyName: model.replyInfo.name, replyUserId: model.replyId)
        }
        content = model.body
        showTopIcon = model.pinned
    }

    /// 自定义动态列表评论
    ///
    /// - Note: 用于动态列表新建评论 model
    init(feedId: Int, content: String, replyId: Int? = nil, replyName: String? = nil) {
        super.init()
        // 1.本地新建的评论没有 commentId，先设置为 0，待创建评论的任务方法返回后更新 commentId 的值
        id = .feed(feedId: feedId, commentId: 0)
        // 2.本地新建的评论，评论者自然是当前用户啦~
        guard let userInfo = TSCurrentUserInfo.share.userInfo else {
            return
        }
        name = userInfo.name
        userId = userInfo.userIdentity
        // 3.如果有 replyId 和 replyName，说明评论对象是用户的评论
        if let replyId = replyId, let replyName = replyName {
            type = .user(replyName: replyName, replyUserId: replyId)
        }
        // 4.其他
        self.content = content
        showTopIcon = false
        sendStatus = .sending // 发送状态为“正在发送中”
    }

    /// 自定义帖子列表评论
    ///
    /// - Note: 用于动态列表新建评论 model
    init(groupId: Int, postId: Int, content: String, replyId: Int? = nil, replyName: String? = nil) {
        super.init()
        // 1.本地新建的评论没有 commentId，先设置为 0，待创建评论的任务方法返回后更新 commentId 的值
        id = .post(groupId: groupId, postId: postId, commentId: 0)
        // 2.本地新建的评论，评论者自然是当前用户啦~
        guard let userInfo = TSCurrentUserInfo.share.userInfo else {
            return
        }
        name = userInfo.name
        userId = userInfo.userIdentity
        // 3.如果有 replyId 和 replyName，说明评论对象是用户的评论
        if let replyId = replyId, let replyName = replyName {
            type = .user(replyName: replyName, replyUserId: replyId)
        }
        // 4.其他
        self.content = content
        showTopIcon = false
        sendStatus = .sending // 发送状态为“正在发送中”
    }

    init(object: FeedListCommentObject) {
        super.init()
        id = .feed(feedId: object.feedId, commentId: object.commentId)
        name = object.name
        userId = object.userId
        if let replyId = object.replyUserId.value, let replyName = object.replyName {
            type = .user(replyName: replyName, replyUserId: replyId)
        } else {
            type = .text
        }
        content = object.content
        showTopIcon = object.showTopIcon
        sendStatus = SendStatus(rawValue: object.sendStatus)!
    }

    // MARK: Object
    override func object() -> FeedListCommentObject {
        let object = FeedListCommentObject()
        object.feedId = id["feedId"] ?? 0
        object.commentId = id["commentId"] ?? 0
        object.name = name
        object.userId = userId
        switch type {
        case .user(let replyName, let replyUserId):
            object.replyName = replyName
            object.replyUserId.value = replyUserId
        default:
            break
        }
        object.content = content
        object.showTopIcon = showTopIcon
        object.sendStatus = sendStatus.rawValue
        return object
    }
}
