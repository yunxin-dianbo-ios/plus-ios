//
//  TSCommentViewModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论视图模型
//  之后的评论相关视图都加载该模型
//  如：动态中评论列表的某一条评论、其他详情页或列表页中的评论列表中的一条评论

import Foundation

/// 评论发送状态
enum TSCommentSendtatus: Int {
    /// 发送成功
    case normal = 0
    /// 发送失败
    case faild
    /// 发送中
    case sending
}

class TSCommentViewModel {
    /// 评论Id：normal状态为服务器id，faild状态为本地发送失败的评论id，sending状态为0
    var id: Int = 0
    /// 评论用户id
    var userId: Int = 0
    /// 用户信息 - 发送评论的用户
    var user: TSUserInfoModel?
    /// 回复的用户信息，注：可能并不存在，只有该评论是回复别人的才会存在。
    var replyUser: TSUserInfoModel?
    /// 评论内容
    var content: String = ""
    /// 时间
    var createDate: Date?
    /// 是否置顶
    var isTop = false
    /// 评论状态
    var status: TSCommentSendtatus = .normal
    /// 评论应用场景/评论类型
    var type: TSCommentType

    init(type: TSCommentType) {
        self.type = type
        self.userId = TSCurrentUserInfo.share.userInfo?.userIdentity ?? 0
    }
    init(type: TSCommentType, content: String, replyUserId: Int?, status: TSCommentSendtatus) {
        self.type = type
        self.content = content
        self.userId = TSCurrentUserInfo.share.userInfo?.userIdentity ?? 0
        self.user = TSCurrentUserInfo.share.userInfo?.convert()
        if let replyUserId = replyUserId {
            self.replyUser = TSDatabaseManager().user.getUserInfo(userId: replyUserId)
        }
        self.status = status
    }
    init(id: Int, userId: Int, type: TSCommentType, user: TSUserInfoModel?, replyUser: TSUserInfoModel?, content: String, createDate: Date?, status: TSCommentSendtatus, isTop: Bool = false) {
        self.id = id
        self.userId = userId
        self.type = type
        self.user = user
        self.replyUser = replyUser
        self.content = content
        self.createDate = createDate
        self.status = status
        self.isTop = isTop
    }

}
