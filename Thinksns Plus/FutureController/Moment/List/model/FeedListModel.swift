//
//  FeedListModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表数据模型

import UIKit
import ObjectMapper

/// 批量获取动态 网络数据模型
class FeedListResultsModel: Mappable {

    /// 置顶动态列表
    var pinned: [FeedListModel] = []
    /// 普通动态列表
    var feeds: [FeedListModel] = []

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        pinned <- map["pinned"]
        feeds <- map["feeds"]
    }
}

/// 动态列表数据模型
class FeedListModel: Mappable {
    /// 动态数据id
    var id = 0
    /// index 话题动态列表分页
    var index = 0
    /// 发布者id
    var userId = 0
    /// 动态内容
    var content = ""
    /// 动态来源 1:pc 2:h5 3:ios 4:android 5:其他
    var from = 0
    /// 点赞数
    var likeCount = 0
    /// 查看数
    var viewCount = 0
    /// 评论数
    var commentCount = 0
    /// 纬度
    var latitude = ""
    /// 经度
    var longtitude = ""
    /// GEO
    var geo = ""
    /// 审核状态
    var auditStatus = 0
    /// 标记
    var feedMark: Int64 = 0
    ///	置顶标记
    var pinned = 0
    /// 置顶金额
    var pinnedAmount = 0
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()
    /// 删除时间
    var delete = Date()
    /// 加精时间
    var excellent: String?
    /// 话题，为空则不显示评论
    var topics: [TopicListModel] = []
    /// 动态评论 列表中返回五条
    var comments: [FeedListCommentModel] = []
    /// 是否已收藏
    var hasCollect = false
    /// 是否已赞
    var hasLike = false
    /// 图片信息 同单条动态数据结构一致
    var images: [FeedImageModel] = []
    /// 付费节点信息 同单条动态数据结构一致 不存在时为null
    var paidNode: FeedPaidModel?
    /// 视频数据
    var feedVideo: FeedVideoModel?
    /// 发布者信息，需要请求用户信息接口来获取
    var userInfo = TSUserInfoModel()
    /// 转发的类型
    var repostType: String? = nil
    /// 转发的ID
    var repostId: Int = 0
    /// 转发信息
    var repostModel: TSRepostModel? = nil
    /// 热门标识
    var hot: Int = 0

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        index <- map["index"]
        userId <- map["user_id"]
        content <- map["feed_content"]
        // 自定义的image标签替换为空字符串
        content = content.ts_customMarkdownToClearString()
        from <- map["feed_from"]
        likeCount <- map["like_count"]
        viewCount <- map["feed_view_count"]
        commentCount <- map["feed_comment_count"]
        latitude <- map["feed_latitude"]
        longtitude <- map["feed_longtitude"]
        geo <- map["feed_geohash"]
        auditStatus <- map["audit_status"]
        feedMark <- map["feed_mark"]
        pinned <- map["pinned"]
        pinnedAmount <- map["pinned_amount"]
        create <- (map["created_at"], TSDateTransfrom())
        excellent <- (map["excellent_at"])
        update <- (map["updated_at"], TSDateTransfrom())
        delete <- (map["deleted_at"], TSDateTransfrom())
        comments <- map["comments"]
        topics <- map["topics"]
        // 手动写入动态ID
        for item in comments {
            item.feedid = id
        }
        hasCollect <- map["has_collect"]
        hasLike <- map["has_like"]
        images <- map["images"]
        images = images.filter { (image) -> Bool in
            return image.size != CGSize.zero
        }
        paidNode <- map["paid_node"]
        feedVideo <- map["video"]
        userInfo <- map["user"]
        // 转发
        repostId <- map["repostable_id"]
        repostType <- map["repostable_type"]
        // 转发的信息需要单独的接口去获取
        // 热门标识
        hot <- map["hot"]
    }

    /// 动态相关用户的 id
    func userIds() -> [Int] {
        var ids: [Int] = [userId]
        for comment in comments {
            ids.append(contentsOf: comment.userIds())
        }
        return Set(ids).filter { $0 != 0 }
    }

    /// 添加用户信息
    func set(userInfos: [Int: TSUserInfoModel]) {
        // 设置动态用户信息
        if let userInfo = userInfos[userId] {
            self.userInfo = userInfo
        }
        // 设置评论用户信息
        for comment in comments {
            comment.set(userInfos: userInfos)
        }
    }
}

/// 动态列表 评论模型
/// - Note: 当用户不存在时，用户 id 为 0
class FeedListCommentModel: Mappable {
    /// 动态id
    var feedid = 0
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

    /// 评论者信息，需要请求用户信息接口来获取
    var userInfo = TSUserInfoModel()
    /// 资源作者信息，需要请求用户信息接口来获取
    var targetInfo = TSUserInfoModel()
    /// 被回复者信息，需要请求用户信息接口来获取
    var replyInfo = TSUserInfoModel()

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

    /// 评论相关用户的 id
    func userIds() -> [Int] {
        return [userId, targetId, replyId].filter { $0 != 0 }
    }

    /// 添加用户信息
    func set(userInfos: [Int: TSUserInfoModel]) {
        if let userInfo = userInfos[userId] {
            self.userInfo = userInfo
        }
        if let targetInfo = userInfos[targetId] {
            self.targetInfo = targetInfo
        }
        if let replyInfo = userInfos[replyId] {
            self.replyInfo = replyInfo
        }
    }
}

/// 动态相关付费 数据模型
class FeedPaidModel: Mappable {

    /// 当前用户是否已经付费
    var paid = false
    /// 付费节点
    var node = 0
    /// 付费金额
    var amount = 0

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        paid <- map["paid"]
        node <- map["node"]
        amount <- map["amount"]
    }

}

/// 可付费图片 数据模型
class FeedImageModel: Mappable {

    /// 文件 file_with 标识 不收费图片只存在 file 这一个字段。
    var file = 0
    /// 图像尺寸，非图片为 null，图片没有尺寸也为 null
    var size = CGSize.zero
    /// 收费方式
    var type = ""
    /// 当前用户是否购买
    var paid = true
    /// 付费节点
    var node = 0
    /// 收费多少
    var amount = 0
    /// 图片类型 miniType
    var mimeType: String = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        file <- map["file"]
        size <- (map["size"], CGSizeTransform())
        type <- map["type"]
        paid <- map["paid"]
        node <- map["paid_node"]
        amount <- map["amount"]
        mimeType <- map["mime"]
    }
}

/// 短视频 数据模型
class FeedVideoModel: Mappable {

    /// 文件 file_with 标识 不收费图片只存在 file 这一个字段。
    var videoID = 0
    /// 视频宽度
    var width = 0
    /// 视频高度
    var height = 0
    /// 封面文件id
    var videoCoverID = 0

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        videoID <- map["video_id"]
        width <- map["width"]
        height <- map["height"]
        videoCoverID <- map["cover_id"]
    }
}
