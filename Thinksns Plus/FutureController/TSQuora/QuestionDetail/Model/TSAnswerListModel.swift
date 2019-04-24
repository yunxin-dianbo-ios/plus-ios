//
//  TSAnswerListModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案列表的数据模型
//  注：可考虑将答案列表的数据模型和答案详情的数据模型统一来使用

import Foundation
import ObjectMapper

/// 答案排序方式
enum TSAnserOrderType: String {
    /// 点赞数
    case diggCount = "default"
    /// 发布时间 - 默认
    case publishTime = "time"
}

typealias TSAnswerReceiveModel = TSAnswerListModel
class TSAnswerListModel: Mappable {
    /// 回答唯一标识 ID 。
    var id: Int = 0
    /// 回答所属问题标识 ID 。
    var questionId: Int = 0
    /// 发布回答用户标识ID，如果 anonymity 为 1 则只为 0 。
    var userId: Int = 0
    /// 回答的内容，markdown 。
    var body: String = ""
    /// 回答的内容，纯文本字段，为nil表示兼容之前没该字段时的处理，
    var body_text: String? = nil
    /// 是否是匿名回答 。
    var isAnonymity: Bool = false
    /// 是否是采纳答案。
    var isAdoption: Bool = false
    /// 是否该回答是被邀请的人的回答。
    var isInvited: Bool = false
    /// 评论总数统计。
    var commentsCount: Int = 0
    /// 回答打赏总额统计。
    var rewardsAmount: Float = 0
    /// 打赏的人总数统计。
    var rewardersCount: Int = 0
    /// 回答喜欢总数统计。
    var likesCount: Int = 0
    /// 回答浏览量统计。
    var viewsCount: Int = 0
    /// 回答创建时间。
    var createDate: Date?
    /// 回答更新时间。
    var updateDate: Date?
    /// 是否喜欢这个回答。
    var liked: Bool = false
    /// 是否已收藏这个回答。
    var collected: Bool = false
    /// 是否已打赏这个问题。
    var rewarded: Bool = false
    /// 回答的用户资料，参考「用户」文档，如果 anonymity 为 1 则不存在这个字段或者为 null 。
    var user: TSUserInfoModel?

    // 下面字段，Object中暂不存在
    /// 围观数 - 仅在邀请答案中存在
    var outlookCount: Int?
    /// 被围观总金额 - 仅在邀请答案中存在
    var outlookAmount: Int?
    /// 是否已围观 - 仅在邀请答案中存在
    /// 是否已围观，对于需要围观的答案，会返回本字段为 true 或者 false 来表示用户是否需要付费，对于普通答案不返回这个字段。
    var could: Bool?

    init() {
    }

    // MARK: - Mappable
    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        questionId <- map["question_id"]
        userId <- map["user_id"]
        body <- map["body"]
        body_text <- map["text_body"]
        isAnonymity <- map["anonymity"]
        isAdoption <- map["adoption"]
        isInvited <- map["invited"]
        commentsCount <- map["comments_count"]
        rewardsAmount <- map["rewards_amount"]
        rewardersCount <- map["rewarder_count"]
        likesCount <- map["likes_count"]
        viewsCount <- map["views_count"]
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        user <- map["user"]
        liked <- map["liked"]
        collected <- map["collected"]
        rewarded <- map["rewarded"]
        outlookCount <- map["onlookers_count"]
        could <- map["could"]
        outlookAmount <- (map["onlookers_total"], TransformOf<Int, String>(fromJSON: { (value) -> Int? in
            if let value = value {
                return Int(value)
            }
            return nil
        }, toJSON: { (value) -> String? in
            if let value = value {
                return String(format: "%d", value)
            }
            return nil
        }))
    }

    // MARK: - DB
    init(object: TSAnswerListObject) {
        self.id = object.id
        self.questionId = object.questionId
        self.userId = object.userId
        self.body = object.body
        self.body_text = object.body_text
        self.isAnonymity = object.isAnonymity
        self.isAdoption = object.isAdoption
        self.isInvited = object.isInvited
        self.commentsCount = object.commentsCount
        self.rewardsAmount = object.rewardsAmount
        self.rewardersCount = object.rewardersCount
        self.likesCount = object.likesCount
        self.viewsCount = object.viewsCount
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.liked = object.liked
        self.collected = object.collected
        self.rewarded = object.rewarded
        if let user = object.user {
            self.user = TSUserInfoModel(object: user)
        }
    }
    func object() -> TSAnswerListObject {
        let object = TSAnswerListObject()
        object.id = self.id
        object.questionId = self.questionId
        object.userId = self.userId
        object.body = self.body
        object.body_text = self.body_text
        object.isAnonymity = self.isAnonymity
        object.isAdoption = self.isAdoption
        object.isInvited = self.isInvited
        object.commentsCount = self.commentsCount
        object.rewardsAmount = self.rewardsAmount
        object.rewardersCount = self.rewardersCount
        object.likesCount = self.likesCount
        object.viewsCount = self.viewsCount
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.liked = self.liked
        object.collected = self.collected
        object.rewarded = self.rewarded
        object.user = self.user?.object()
        return object
    }
}
