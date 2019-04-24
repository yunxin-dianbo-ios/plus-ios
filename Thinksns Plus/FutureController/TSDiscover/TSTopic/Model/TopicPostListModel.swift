//
//  TopicPostListModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TopicPostListModel: Mappable {
    /// 帖子 id
    var id = 0
    /// 圈子 id
    var groupId = 0
    /// 用户 id
    var userId = 0
    /// 标题
    var title = ""
    /// 内容
    var body = ""
    /// 帖子介绍
    var summary = ""
    /// 点赞数
    var likesCount = 0
    /// 评论数
    var commentCount = 0
    /// 浏览量
    var viewCount = 0
    /// 是否点赞
    var liked = false
    /// 是否收藏
    var collected = false
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()
    /// 用户信息
    var userInfo = TSUserInfoModel()
    /// 圈子信息
    var groupInfo = TopicModel()
    /// 图片信息
    var images: [TopicPostImageModel] = []
    /// 评论信息
    var comments: [TopicPostListCommentModel] = []

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        groupId <- map["group_id"]
        userId <- map["user_id"]
        title <- map["title"]
        body <- map["body"]
        // 需要替换调@image等标签为空格
        summary <- map["summary"]
        summary = summary.ts_customMarkdownToClearString()
        likesCount <- map["likes_count"]
        commentCount <- map["comments_count"]
        viewCount <- map["views_count"]
        liked <- map["liked"]
        collected <- map["collected"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
        userInfo <- map["user"]
        groupInfo <- map["group"]
        images <- map["images"]
        comments <- map["comments"]
    }
}

class TopicPostImageModel: Mappable {

    /// 图片 id
    var id = 0
    /// 图片大小
    var size: CGSize = .zero
    /// 图片类型
    var mimeType: String = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        size <- (map["size"], CGSizeTransform())
        mimeType <- map["mime"]
    }
}

/// 帖子评论数据模型
class TopicPostListCommentModel: Mappable {
    /// 评论 id
    var id = 0
    /// 评论者id
    var userId = 0
    /// 资源作者 id
    var targetId = 0
    /// 被回复者 id（坑：如果没有被回复者，后台会返回 0）
    var replyId = 0
    /// 评论内容
    var body = ""
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()
    /// 后台文档注释没有写
    var commentableId = 0
    /// 后台文档注释没有写
    var commentableType = ""
    /// 是否置顶
    var pinned = false

    /// 评论者信息
    var userInfo = TSUserInfoModel()
    /// 被回复者信息
    var replyInfo = TSUserInfoModel()

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetId <- map["target_user"]
        replyId <- map["reply_user"]
        body <- map["body"]
        commentableId <- map["commentable_id"]
        commentableType <- map["commentable_type"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
        pinned <- map["pinned"]
        userInfo <- map["user"]
        replyInfo <- map["reply"]
    }
}

/// 发送了评论帖子的网络请求后，后台返回的数据模型，其中 comment 只有部分数据
class TopicPostSendCommentModel: Mappable {

    var message = ""
    var comment = TopicPostListCommentModel()

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        message <- map["message"]
        comment <- map["comment"]
    }
}
