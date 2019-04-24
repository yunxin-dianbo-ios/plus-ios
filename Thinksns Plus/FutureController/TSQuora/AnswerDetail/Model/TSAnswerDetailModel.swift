//
//  TSAnswerDetailModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案详情的数据模型

import Foundation
import ObjectMapper

class TSAnswerDetailModel: Mappable {
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

    // 相对列表模型中，详情模型里增加的数据

    /// 喜欢列表 - 点赞列表
    var likes: [TSLikeUserModel]?
    /// 打赏用户列表 - 打赏列表
    var rewarders: [TSNewsRewardModel]?
    /// 问题基础数据
    var question: TSQuestionDetailModel?
    /// 是否已围观，对于需要围观的答案，会返回本字段为 true 或者 false 来表示用户是否需要付费，对于普通答案不返回这个字段。
    var could: Bool?

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
        /// 详情模型相对列表模型增加部分
        likes <- map["likes"]
        rewarders <- map["rewarders"]
        question <- map["question"]
        could <- map["could"]
    }

    // 将答案详情转变成列表模型
    // 注：如果不考虑答案详情页的数据吃句话，则可考虑将答案详情模型和答案列表模型统一
    func toListModel() -> TSAnswerListModel {
        let model = TSAnswerListModel()
        model.id = self.id
        model.questionId = self.questionId
        model.userId = self.userId
        model.body = self.body
        model.body_text = self.body_text
        model.isAnonymity = self.isAnonymity
        model.isAdoption = self.isAdoption
        model.isInvited = self.isInvited
        model.commentsCount = self.commentsCount
        model.rewardsAmount = self.rewardsAmount
        model.rewardersCount = self.rewardersCount
        model.likesCount = self.likesCount
        model.viewsCount = self.viewsCount
        model.createDate = self.createDate
        model.updateDate = self.updateDate
        model.liked = self.liked
        model.collected = self.collected
        model.rewarded = self.rewarded
        model.user = self.user
        model.could = self.could
        return model
    }
}
