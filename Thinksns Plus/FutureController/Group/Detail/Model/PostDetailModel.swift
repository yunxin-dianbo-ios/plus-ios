//
//  PostDetailModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子详情模型

import Foundation
import ObjectMapper

class PostDetailModel: Mappable {

    var id: Int = 0
    /// 所属圈子
    var groupId: Int = 0
    /// 发布者
    var userId: Int = 0
    /// 标题
    var title: String = ""
    /// markdown 内容
    var body: String = ""
    /// 列表专用字段，概述，简短内容
    var summary: String = ""
    /// 喜欢数量统计
    var likesCount: Int = 0
    /// 评论数量统计
    var commentsCount: Int = 0
    /// 查看数量统计
    var viewsCount: Int = 0
    /// 是否置顶
    var pinned: Bool = false
    /// 是否点赞
    var liked: Bool = false
    /// 是否收藏
    var collected: Bool = false
    /// 打赏金额统计
    var rewardAmount: Float = 0
    /// 打赏人数统计
    var rewardCount: Int = 0
    var created_at: String = ""
    var updated_at: String = ""
    var group: GroupModel?
    var user: TSUserInfoModel?
    var createDate: Date = Date()
    var updateDate: Date = Date()
    // 精华帖标识，不为nil时代表加精时间
    var excellent: String?
    /// 标签
//    var tags

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        groupId <- map["group_id"]
        userId <- map["user_id"]
        title <- map["title"]
        body <- map["body"]
        summary <- map["summary"]
        likesCount <- map["likes_count"]
        commentsCount <- map["comments_count"]
        viewsCount <- map["views_count"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        pinned <- map["pinned"]
        liked <- map["liked"]
        collected <- map["collected"]
        rewardAmount <- map["reward_amount"]
        rewardCount <- map["reward_number"]
        group <- map["group"]
        user <- map["user"]
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        excellent <- map["excellent_at"]
    }
}
