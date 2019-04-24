//
// Created by lip on 2017/9/18.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//
// 收到待处理评论置顶数据模型

import Foundation
import ObjectMapper

class ReceivePendingCommentTopModel: Mappable {
    /// 标识
    var id: Int!
    /// 发起审核用户标识
    var userId: Int!
    /// 发起审核用户信息
    var userInfo: TSUserInfoModel?
    /// 发起的置顶价格
    var amount: Int!
    /// 置顶时间
    var day: Int!
    /// 到期时间
    ///
    /// - Note: 状态以该值为准，nil 状态为待审核，存在时间，标记为 已处理
    var expiresDate: Date?
    /// 创建时间
    var createdDate: Date!
    /// 更新时间
    var updatedDate: Date?
    /// 评论内容
    var commentInfo: ReceivePendingCommentInfo?
    /// 扩展信息
    var exten: ReceiveExtenModel?
    /// 审核状态
    var pendingStatus: Bool {
        return expiresDate == nil ? false : true
    }
    /// 数据源是否已删除
    var sourceIsDelete = false
    /// 数据源是否已审核
    var sourceIsPending = false
    // MARK: - lifecycle
    required init?(map: Map) {
    }
    init() {
    }
    func mapping(map: Map) {
        assert(false, "需要子类实现该方法")
    }
    func convertTo() -> NoticePendingCellLayoutConfig {
        assert(false, "需要子类实现该方法")
    }
}

class ReceivePendingCommentInfo {
    var content: String?
    var id: Int!
}

class ReceivePendingNewsCommentTopModel: ReceivePendingCommentTopModel {
    override func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        amount <- map["amount"]
        day <- map["day"]
        expiresDate <- (map["expires_at"], TSDateTransfrom())
        createdDate <- (map["created_at"], TSDateTransfrom())
        updatedDate <- (map["updated_at"], TSDateTransfrom())
        let tempExten = ReceiveExtenModel()
        tempExten.targetId <- map["news.id"]
        tempExten.content <- map["news.title"]
        tempExten.coverId <- map["news.image.id"]
        exten = tempExten
        if tempExten.targetId == nil {
            exten = nil
        }

        let commentInfo = ReceivePendingCommentInfo()
        commentInfo.content <- map["comment.body"]
        commentInfo.id <- map["comment.id"]
        self.commentInfo = commentInfo
        if commentInfo.id == nil {
            self.commentInfo = nil
        }
    }
    override func convertTo() -> NoticePendingCellLayoutConfig {
        // 处理待操作区的状态和待操作区内容
        var status: NoticePendingCellPendingReginStatus = .normal
        var pendingContent: String = ""
        if exten != nil && commentInfo == nil {
            status = .warning
            pendingContent = "该评论已删除"
            sourceIsDelete = true
        }
        if exten != nil && commentInfo != nil {
            if pendingStatus == true {
                status = .hightLight
                pendingContent = "已审核"
                sourceIsPending = true
            } else {
                status = .normal
                pendingContent = "待审核"
            }
        }
        if exten == nil {
            status = .warning
            pendingContent = "该资讯已删除"
            sourceIsDelete = true
        }

        // 处理正文内容和扩展内容
        var isHiddenContent = commentInfo == nil ? true : false
        let isHiddenExtenRegin = exten == nil ? true : false

        var content: String?
        var hightLightInContent: String?
        if var commentContent = commentInfo?.content {
            if commentContent.count > 15 {
                commentContent = commentContent.substring(from: commentContent.index(commentContent.startIndex, offsetBy: 14))
                commentContent += "..."
            }
            content = "对你的资讯进行了“" + commentContent + "评论并且申请置顶，请及时审核。"
            hightLightInContent = commentContent
        } else {
            isHiddenContent = true
            status = .warning
            pendingContent = "该评论已被删除"
        }

        let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27 * 3, height: 27 * 3))
        return NoticePendingCellLayoutConfig(pendingReginStatus: status, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: isHiddenContent, avatarUrl: TSUtil.praseTSNetFileUrl(netFile: userInfo?.avatar), verifyType: userInfo?.verified?.type, verifyIcon: userInfo?.verified?.icon, userId: userId, title: userInfo!.name, titleInfo: nil, subTitle: nil, date: createdDate, content: content, hightLightInContent: hightLightInContent, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: pendingContent, amount: amount, day: day)
    }
}

class ReceivePendingFeedCommentTopModel: ReceivePendingCommentTopModel {
    override func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        amount <- map["amount"]
        day <- map["day"]
        expiresDate <- (map["expires_at"], TSDateTransfrom())
        createdDate <- (map["created_at"], TSDateTransfrom())
        updatedDate <- (map["updated_at"], TSDateTransfrom())

        let tempExten = ReceiveExtenModel()
        tempExten.targetId <- map["feed.id"]
        tempExten.content <- map["feed.feed_content"]
        tempExten.coverId <- map["feed.images.0.file"]

        // 先判断是否是图片动态，然后尝试读取视频封面图
        if tempExten.coverId == nil {
            tempExten.coverId <- map["feed.video.cover_id"]
            tempExten.isVieo = true
        }
        exten = tempExten
        if tempExten.targetId == nil {
            exten = nil
        }

        let commentInfo = ReceivePendingCommentInfo()
        commentInfo.content <- map["comment.body"]
        commentInfo.id <- map["comment.id"]
        self.commentInfo = commentInfo
        if commentInfo.id == nil {
            self.commentInfo = nil
        }
    }
    override func convertTo() -> NoticePendingCellLayoutConfig {
        // 处理待操作区的状态和待操作区内容
        var status: NoticePendingCellPendingReginStatus = .normal
        var pendingContent: String = ""
        if exten != nil && commentInfo == nil {
            status = .warning
            pendingContent = "该评论已被删除"
            sourceIsDelete = true
        }
        if exten != nil && commentInfo != nil {
            if pendingStatus == true {
                status = .hightLight
                pendingContent = "已审核"
                sourceIsPending = true
            } else {
                status = .normal
                pendingContent = "审核"
            }
        }
        if exten == nil {
            status = .warning
            pendingContent = "该动态已被删除"
            sourceIsDelete = true
        }
        // 处理正文内容和扩展内容
        var isHiddenContent = commentInfo == nil ? true : false
        let isHiddenExtenRegin = exten == nil ? true : false

        var content: String?
        var hightLightInContent: String?
        if var commentContent = commentInfo?.content {
            if commentContent.count > 15 {
                commentContent = commentContent.substring(from: commentContent.index(commentContent.startIndex, offsetBy: 14))
                commentContent += "..."
            }
            content = "对你的动态进行了“" + commentContent + "”评论并且申请置顶，请及时审核。"
            hightLightInContent = commentContent
        } else {
            isHiddenContent = true
            status = .warning
            pendingContent = "该评论已被删除"
        }

        let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27, height: 27))
        return NoticePendingCellLayoutConfig(pendingReginStatus: status, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: isHiddenContent, avatarUrl: TSUtil.praseTSNetFileUrl(netFile: userInfo?.avatar), verifyType: userInfo?.verified?.type, verifyIcon: userInfo?.verified?.icon, userId: userId, title: userInfo!.name, titleInfo: nil, subTitle: nil, date: createdDate, content: content, hightLightInContent: hightLightInContent, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: pendingContent, amount: amount, day: day)
    }
}

class ReceivePendingPostCommentTopModel: ReceivePendingCommentTopModel {
    override func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        amount <- map["amount"]
        day <- map["day"]
        expiresDate <- (map["expires_at"], TSDateTransfrom())
        createdDate <- (map["created_at"], TSDateTransfrom())
        updatedDate <- (map["updated_at"], TSDateTransfrom())

        let tempExten = ReceiveExtenModel()
        tempExten.targetId <- map["post.id"]
        tempExten.content <- map["post.summary"]
        tempExten.groupId <- map["post.group_id"]
        // 暂无该选项
        //tempExten.coverId <- map["feed.images.0.id"]
        exten = tempExten
        if tempExten.targetId == nil {
            exten = nil
        }

        let commentInfo = ReceivePendingCommentInfo()
        commentInfo.content <- map["comment.body"]
        commentInfo.id <- map["comment.id"]
        self.commentInfo = commentInfo
        if commentInfo.id == nil {
            self.commentInfo = nil
        }
    }
    override func convertTo() -> NoticePendingCellLayoutConfig {
        // 处理待操作区的状态和待操作区内容
        var status: NoticePendingCellPendingReginStatus = .normal
        var pendingContent: String = ""
        if exten != nil && commentInfo == nil {
            status = .warning
            pendingContent = "该评论已被删除"
            sourceIsDelete = true
        }
        if exten != nil && commentInfo != nil {
            if pendingStatus == true {
                status = .hightLight
                pendingContent = "已审核"
                sourceIsPending = true
            } else {
                status = .normal
                pendingContent = "审核"
            }
        }
        if exten == nil {
            status = .warning
            pendingContent = "该帖子已被删除"
            sourceIsDelete = true
        }

        // 处理正文内容和扩展内容
        var isHiddenContent = commentInfo == nil ? true : false
        let isHiddenExtenRegin = exten == nil ? true : false

        var content: String?
        var hightLightInContent: String?
        if var commentContent = commentInfo?.content {
            if commentContent.count > 15 {
                commentContent = commentContent.substring(from: commentContent.index(commentContent.startIndex, offsetBy: 14))
                commentContent += "..."
            }
            content = "对你的动态进行了“" + commentContent + "”评论并且申请置顶，请及时审核。"
            hightLightInContent = commentContent
        } else {
            isHiddenContent = true
            status = .warning
            pendingContent = "该评论已被删除"
        }

        let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: exten?.coverId, compressionRatio: 100, cgSize: CGSize(width: 27, height: 27))
        return NoticePendingCellLayoutConfig(pendingReginStatus: status, isHiddenExtenRegin: isHiddenExtenRegin, isHiddenContent: isHiddenContent, avatarUrl: TSUtil.praseTSNetFileUrl(netFile: userInfo?.avatar), verifyType: userInfo?.verified?.type, verifyIcon: userInfo?.verified?.icon, userId: userId, title: userInfo!.name, titleInfo: nil, subTitle: nil, date: createdDate, content: content, hightLightInContent: hightLightInContent, extenContent: exten?.content, extenCover: coverUrl, isVideo: exten?.isVieo, pendingContent: pendingContent, amount: amount, day: day)
    }
}
