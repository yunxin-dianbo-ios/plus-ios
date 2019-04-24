//
//  ReceiveLikeModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户收到的赞 数据模型

import UIKit
import ObjectMapper

class ReceiveLikeModel: Mappable {
    // 点赞标识
    var id: Int = -1
    // 点赞用户
    var userId: Int = -1
    // 接收用户（你能收到就是因为这个ID就是你）
    var targetUserId: Int = -1
    /// 所属资源类型
    var sourceType: ReceiveInfoSourceType = .feed
    // 赞时间
    var createDate: Date!
    // 更新时间
    var updateDate: Date?
    /// 附属信息
    var exten: ReceiveExtenModel?
    // 点赞用户信息
    var userInfo: TSUserInfoModel!

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        sourceType <- (map["likeable_type"], ReceiveInfoSourceTypeTransform())
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        let tempExten = ReceiveExtenModel()
        var contentType = ""
        switch sourceType {
        case .feed:
            contentType = "动态"
            tempExten.content <- map["likeable.feed_content"]
            tempExten.coverId <- map["likeable.images.0.id"]
            tempExten.targetId <- map["likeable.id"]
            // 先判断是否是图片动态，然后尝试读取视频封面图
            if tempExten.coverId == nil {
                tempExten.coverId <- map["likeable.video.cover_id"]
                tempExten.isVieo = true
            }

        case .group:
            contentType = "帖子"
            tempExten.targetId <- map["likeable.id"]
            tempExten.content <- map["likeable.title"]
            tempExten.coverId <- map["likeable.images.0.id"]
            tempExten.groupId <- map["likeable.group_id"]
        case .song, .musicAlbum:
            contentType = "音乐"
            tempExten.targetId <- map["likeable.id"]
            tempExten.content <- map["likeable.title"]
            tempExten.coverId <- map["likeable.storage"]
        case .news:
            contentType = "文章"
            tempExten.content <- map["likeable.title"]
            tempExten.coverId <- map["likeable.images.id"]
            tempExten.targetId <- map["likeable.id"]
        case .answers:
            contentType = "回答"
            tempExten.targetId <- map["likeable.id"]
            if tempExten.targetId != nil {
                // 答案的点赞模型特殊处理 - 可参考对应消息的模型
                tempExten.content <- map["likeable.body"]
                tempExten.coverId = tempExten.content.ts_getCustomMarkdownImageId().first
                tempExten.content = tempExten.content.ts_customMarkdownToNormal()
            }
        case .question:
            contentType = "问题"
            tempExten.targetId <- map["likeable.id"]
            if tempExten.targetId != nil {
                // 问题的点赞模型特殊处理
                tempExten.content <- map["likeable.body"]
                tempExten.coverId = tempExten.content.ts_getCustomMarkdownImageId().first
                tempExten.content <- map["likeable.subject"]
            }
        }
        exten = tempExten
        if tempExten.targetId == nil {
            // 点赞的资源被删除时，仍然展示，不过只展示内容 且为 "该动态/帖子/回答/文章... 已被删除"
            exten?.content = "该" + contentType + "已被删除"
        }
    }

    func convert() -> NoticePendingCellLayoutConfig {
        var titleInfo: String?
        switch sourceType {
        case .feed:
            titleInfo = "显示_资源被点赞_动态".localized
        case .group:
            titleInfo = "显示_资源被点赞_圈子动态".localized
        case .musicAlbum:
            titleInfo = "显示_资源被点赞_专辑".localized
        case .song:
            titleInfo = "显示_资源被点赞_歌曲".localized
        case .news:
            titleInfo = "显示_资源被点赞_资讯".localized
        case .question:
            titleInfo = "显示_资源被点赞_问题".localized
        case .answers:
            titleInfo = "显示_资源被点赞_答案".localized
        }

        let isHiddenExtenRegin = exten == nil
        let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27 * 3, height: 27 * 3))
        let config = NoticePendingCellLayoutConfig(pendingReginStatus: .heart, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: true, avatarUrl: TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar), verifyType: userInfo.verified?.type, verifyIcon: userInfo.verified?.icon, userId: userId, title: userInfo.name, titleInfo: titleInfo, subTitle: nil, date: createDate, content: nil, hightLightInContent: nil, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: nil, amount: nil, day: nil)
        return config
    }
}
