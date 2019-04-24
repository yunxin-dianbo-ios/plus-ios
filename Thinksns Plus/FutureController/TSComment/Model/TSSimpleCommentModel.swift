//
//  TSSimpleCommentModel.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  展示评论的模型
//  该模型需弃用，使用CommentViewModel代替

import UIKit

struct TSSimpleCommentModel {

    /// 用户信息
    var userInfo: TSUserInfoObject? = nil
    /// 回复的用户信息
    var replyUserInfo: TSUserInfoObject?
    /// 评论内容
    var content: String = ""
    /// 时间
    var createdAt: NSDate? = nil
    /// 列表Id
    var id: Int = 0
    /// 唯一Id
    var commentMark: Int64 = 0
    /// 状态 0：已成功的 1：未成功的 2 : 正在发送中
    /// 之后应更改为枚举类型，便于判断处理
    var status = 0
    /// 是否置顶
    var isTop = false

//    /// 评论Id：normal状态为服务器id，faild状态为本地发送失败的评论id，sending状态为0
//    var id: Int = 0
//    /// 评论内容
//    var content: String = ""
//    /// 是否置顶
//    var isTop = false

    /// 评论用户id
    var userId: Int = 0
    /// 用户信息 - 发送评论的用户
    var user: TSUserInfoModel? {
        if let userInfo = self.userInfo {
            return TSUserInfoModel(object: userInfo)
        }
        return nil
    }
    /// 回复的用户信息，注：可能并不存在，只有该评论是回复别人的才会存在。
    var replyUser: TSUserInfoModel? {
        if let replyUserInfo = self.replyUserInfo {
            return TSUserInfoModel(object: replyUserInfo)
        }
        return nil
    }
    /// 时间
    var createDate: Date?
//    /// 评论状态
//    var status: TSCommentSendtatus = .normal
//    /// 评论应用场景/评论类型
//    var type: TSCommentType

    init() {

    }
    init(content: String, replyUserId: Int?, status: Int) {
        self.content = content
        self.createdAt = NSDate(timeIntervalSince1970: Date().timeIntervalSince1970)
        self.userInfo = TSCurrentUserInfo.share.userInfo?.convert().object()
        if let replyUserId = replyUserId {
            self.replyUserInfo = TSDatabaseManager().user.getUserInfo(userId: replyUserId)?.object()
        }
        self.status = status
    }
    init(userInfo: TSUserInfoObject?, replyUserInfo: TSUserInfoObject?, content: String, createdAt: NSDate?, id: Int, commentMark: Int64, status: Int, isTop: Bool) {
        self.userInfo = userInfo
        self.replyUserInfo = replyUserInfo
        self.content = content
        self.createdAt = createdAt
        self.id = id
        self.commentMark = commentMark
        self.status = status
        self.isTop = isTop
    }

}
