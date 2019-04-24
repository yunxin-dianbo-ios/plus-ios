//
//  ReceiveCommentModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  收到的评论数据模型

import UIKit
import ObjectMapper

/// 评论类型
///
/// - commentToMe: 评论我的
/// - replyToMe: 回复我的
/// - replyToOther: 回复别人的
enum ReceiveCommentType {
    case commentToMe
    case replyToMe
    case replyToOther
}

class ReceiveCommentModel: Mappable {
    /// 评论 ID
    var id: Int!
    /// 评论发送用户
    var userId: Int!
    /// 目标用户
    var targetUserId: Int!
    /// 被回复用户
    var replyUserId: Int?
    /// 评论时间
    var createDate: Date?
    /// 更新时间
    var updateDate: Date?
    /// 评论内容
    var content: String!
    /// 所属资源类型
    var sourceType: ReceiveInfoSourceType = .feed
    /// 附属信息
    var exten: ReceiveExtenModel?
    /// 圈子标识
    ///
    /// - Note: 该条评论来自圈子将单独使用该字段,同时 self.exten.targetId 是post id
    var groupId: Int?
    /// 置顶积分
    var amount: Int?
    /// 置顶天数
    var day: Int?
    /// 是否是at类型的内容（现在只有动态）
    var isAtContent: Bool = false
    /// 对应at类型的ID
    var atMessageID: Int = 0

    // 发送评论用户
    var user: TSUserInfoModel!
    // 被回复用户
    var replyUser: TSUserInfoModel?
    /// 评论信息状态
    var type: ReceiveCommentType {
        if let reply = replyUserId, reply != 0 {
            if let current = TSCurrentUserInfo.share.userInfo?.userIdentity {
                if reply == current {
                    return ReceiveCommentType.replyToMe
                }
            }
            return ReceiveCommentType.replyToOther
        }
        return ReceiveCommentType.commentToMe
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        replyUserId <- map["reply_user"]
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        content <- map["body"]
        sourceType <- (map["commentable_type"], ReceiveInfoSourceTypeTransform())
        amount <- map["amount"]
        day <- map["day"]
        let tempExten = ReceiveExtenModel()
        tempExten.isVieo = false
        switch sourceType {
        case .feed:
            tempExten.content <- map["commentable.feed_content"]
            tempExten.coverId <- map["commentable.images.0.id"]
            // 先判断是否是图片动态，然后尝试读取视频封面图
            if tempExten.coverId == nil {
                tempExten.coverId <- map["commentable.video.cover_id"]
                tempExten.isVieo = true
            }
            tempExten.targetId <- map["commentable.id"]
        case .group:
            tempExten.targetId <- map["commentable.id"]
            tempExten.content <- map["commentable.title"]
            tempExten.coverId <- map["commentable.images.0.id"]
            tempExten.groupId <- map["commentable.group_id"]
        case .song, .musicAlbum:
            tempExten.targetId <- map["commentable.id"]
            tempExten.content <- map["commentable.title"]
            tempExten.coverId <- map["commentable.storage"]
        case .news:
            tempExten.content <- map["commentable.title"]
            tempExten.coverId <- map["commentable.image.id"]
            tempExten.targetId <- map["commentable.id"]
        case .answers:
            tempExten.targetId <- map["commentable.id"]
            if tempExten.targetId != nil {
                tempExten.content <- map["commentable.body"]
                // 封面使用答案内容中的第一张图片
                tempExten.coverId = tempExten.content.ts_getCustomMarkdownImageId().first
                tempExten.content = tempExten.content.ts_customMarkdownToNormal() // 图片处理
            }
        case .question:
            tempExten.targetId <- map["commentable.id"]
            if tempExten.targetId != nil {
                // 封面使用问题内容中得一张图片，这里的关系对应暂时使用内容代替，仅为了下面的操作获取封面
                tempExten.content <- map["commentable.body"]
                tempExten.coverId = tempExten.content.ts_getCustomMarkdownImageId().first
                // 问题展示内容是标题
                tempExten.content <- map["commentable.subject"]
            }
        }
        exten = tempExten
        if tempExten.targetId == nil {
            exten = nil
        }
        groupId <- map["commentable.group_id"]
    }

    func convert() -> NoticePendingCellLayoutConfig {
        var titleInfo: String?
        var subTitle: String? = replyUser?.name
        switch type {
        case .commentToMe:
            switch sourceType {
            case .feed:
                titleInfo = "显示_资源被评论_动态".localized
            case .group:
                titleInfo = "显示_资源被评论_圈子动态".localized
            case .musicAlbum:
                titleInfo = "显示_资源被评论_专辑".localized
            case .song:
                titleInfo = "显示_资源被评论_歌曲".localized
            case .news:
                titleInfo = "显示_资源被评论_资讯".localized
            case .question:
                titleInfo = "显示_资源被评论_问题".localized
            case .answers:
                titleInfo = "显示_资源被评论_答案".localized
            }
        case .replyToMe:
            titleInfo = "显示_评论_被回复".localized
            subTitle = nil
        case .replyToOther:
            titleInfo = "显示_评论_回复".localized
        }

        let isHiddenExtenRegin = exten == nil
        var pendingReginStatus: NoticePendingCellPendingReginStatus = .report
        var pendingContent: String?
        if isHiddenExtenRegin == true {
            pendingReginStatus = .warning
            switch sourceType {
            case .feed:
                pendingContent = "显示_资源被删除_动态".localized
            case .group:
                pendingContent = "显示_资源被删除_圈子动态".localized
            case .musicAlbum:
                pendingContent = "显示_资源被删除_专辑".localized
            case .song:
                pendingContent = "显示_资源被删除_歌曲".localized
            case .news:
                pendingContent = "显示_资源被删除_资讯".localized
            case .question:
                pendingContent = "显示_资源被删除_问题".localized
            case .answers:
                pendingContent = "显示_资源被删除_答案".localized
            }
        }

        let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27 * 3, height: 27 * 3))
        let config = NoticePendingCellLayoutConfig(pendingReginStatus: pendingReginStatus, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: false, avatarUrl: TSUtil.praseTSNetFileUrl(netFile:user.avatar), verifyType: user.verified?.type, verifyIcon: user.verified?.icon, userId: userId, title: user.name, titleInfo: titleInfo, subTitle: subTitle, date: createDate, content: content, hightLightInContent: nil, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: pendingContent, amount: amount, day: day)
        return config
    }
}

class ReceiveExtenModel {
    /// 目标id, 点击跳转等操作的目标
    var targetId: Int?
    /// 内容
    var content: String!
    /// 封面
    var coverId: Int?
    /// 视频 只有动态才有
    var isVieo: Bool?

    /// 圈子id
    ///
    /// Note: - 只有在有圈子的时候才有这个值
    var groupId: Int?
}
