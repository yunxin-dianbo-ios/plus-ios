//
//  TSQuoraDetailModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答详情模型
//  注：如果匿名提问是当前请求的认证用户所发布，则返回用户信息。

import Foundation
import ObjectMapper
import RealmSwift

/// 问题解决状态
enum TSQuoraStatus: Int {
    /// 未解决的
    case unsolved = 0
    /// 已解决了的
    case solved
    /// 问题已关闭
    case close
}

/// 问题的悬赏类型
enum TSQuoraOfferRewardType {
    /// 未设置悬赏
    case none
    /// 普通悬赏(公开悬赏)
    case normal
    /// 邀请悬赏
    case invitation
}

/// 问答列表 model
typealias TSQuestionListModel = TSQuoraDetailModel
/// 问答详情 model
typealias TSQuestionDetailModel = TSQuoraDetailModel
class TSQuoraDetailModel: Mappable {
    /// 问题唯一 ID 。
    var id: Int = 0
    /// 发布的用户 ID，如果是 anonymity 是 1 则该字段为 0。
    var userId: Int = 0
    /// 问题标题。
    var title: String = ""
    /// 问题详情，markdown，如果没有详情为 null。
    var body: String = ""
    /// 问题详情，纯文字版，可能为nil，用于兼容之前没有该字段时发布的问答
    var body_text: String?
    /// 是否匿名，1 代表匿名发布，匿名后不会返回任何用户信息。
    var isAnonymity: Bool = false
    /// 问题价值，悬赏金额，0 代表非悬赏。
    var amount: Int = 0     // 0 表示非悬赏
    /// 围观总金额 - 该字段不一定存在，来自邀请答案中的
    var outlookAmount: Int?
    /// 是否自动入账。客户端无用，邀请回答后端判断逻辑使用。
    var isAutomaticity: Bool = false
    /// 是否开启了围观。
    var isLook: Bool = true
    /// 是否属于精选问题。
    var isExcellent: Bool = false
    /// 问题评论总数统计。
    var commentsCount: Int = 0
    /// 问题答案数量统计。
    var answersCount: Int = 0
    /// 问题关注的人总数统计。
    var watchersCount: Int = 0
    /// 喜欢问题的人总数统计。
    var likesCount: Int = 0
    /// 问题查看数量统计。
    var viewsCount: Int = 0
    /// 问题创建时间。
    var createDate: Date = Date()
    /// 问题修改时间。
    var updateDate: Date = Date()
    /// 用户是否关注这个问题。
    var isWatched: Bool = false
    /// 问题状态，0 - 未解决，1 - 已解决， 2 - 问题关闭 。
    var status: TSQuoraStatus?
    /// 我的答案
    var myAnswer: TSAnswerListModel?

    /// 问题话题列表，参考「话题」文档。
    var topics: [TSQuoraTopicModel]?
    /// 问题邀请用户回答的答案列表，具体数据结构参考「回答」文档。
    var invitationAnswers: [TSAnswerListModel]?
    /// 问题采纳的答案列表，具体数据结构参考「回答」文档。
    var adoptionAnswers: [TSAnswerListModel]?
    /// 问题邀请回答的用户列表，参考「用户」文档。
    var invitations: [TSUserInfoModel]?
    /// 用户资料，如果是 anonymity 是 1 则该字段不存在。
    var user: TSUserInfoModel?

    // 问答列表独有字段，问题详情中并没有的。
    /// 需要在列表页显示的回答
    var listShowingAnswer: TSAnswerListModel?

    /// 是否已采纳有答案的标记，注注注：该字段仅仅在答案详情里的所属问题会有，其他地方都没有。
    var hasAdopted: Bool = false

    // 非服务器返回字段，根据已有字段构造生成

    /// 问题的悬赏类型
    var rewardType: TSQuoraOfferRewardType {
        // 悬赏类型： 未设置悬赏 已设置悬赏（对外公开的悬赏）和 已邀请悬赏
        if 0 >= self.amount {
            // 未设置悬赏
            return .none
        } else if nil == self.invitations || self.invitations!.isEmpty {
            // 已设置悬赏（对外公开的悬赏） - 无邀请
            return .normal
        } else {
            // 已邀请悬赏
            return .invitation
        }
    }

    // MARK: - Mappable

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        title <- map["subject"]
        body <- map["body"]
        body_text <- map["text_body"]
        isAnonymity <- map["anonymity"]
        amount <- map["amount"]
        isAutomaticity <- map["automaticity"]
        isLook <- map["look"]
        isExcellent <- map["excellent"]
        commentsCount <- map["comments_count"]
        answersCount <- map["answers_count"]
        watchersCount <- map["watchers_count"]
        likesCount <- map["likes_count"]
        viewsCount <- map["views_count"]
        isWatched <- map["watched"]
        myAnswer <- map["my_answer"]
        listShowingAnswer <- map["answer"]
        topics <- map["topics"]
        invitationAnswers <- map["invitation_answers"]
        adoptionAnswers <- map["adoption_answers"]
        invitations <- map["invitations"]
        user <- map["user"]
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        status <- (map["status"], TransformOf<TSQuoraStatus, Int>(fromJSON: { (value) -> TSQuoraStatus? in
            if let value = value {
                return TSQuoraStatus(rawValue: value)
            }
            return nil
        }, toJSON: { (status) -> Int? in
            return status?.rawValue
        }))
        outlookAmount <- (map["invitation_answers.0.onlookers_total"], TransformOf<Int, String>(fromJSON: { (value) -> Int? in
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
        hasAdopted <- map["has_adoption"]
    }

    // MARK: - DB
    init(object: TSQuoraDetailObject) {
        self.id = object.id
        self.userId = object.userId
        self.title = object.title
        self.body = object.body
        self.body_text = object.body_text
        self.isAnonymity = object.isAnonymity
        self.amount = object.amount
        self.outlookAmount = object.outlookAmount.value
        self.isAutomaticity = object.isAutomaticity
        self.isLook = object.isLook
        self.isExcellent = object.isExcellent
        self.commentsCount = object.commentsCount
        self.answersCount = object.answersCount
        self.watchersCount = object.watchersCount
        self.likesCount = object.likesCount
        self.viewsCount = object.viewsCount
        self.isWatched = object.isWatched
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        if let user = object.user {
            self.user = TSUserInfoModel(object: user)
        }
        if let status = object.status.value {
            self.status = TSQuoraStatus(rawValue: status)
        }
//        self.topics = object.topics
//        self.invitations = object.invitations
//        self.invitationAnswers = object.invitationAnswers
//        self.adoptionAnswers = object.adoptionAnswers
    }
    func object() -> TSQuoraDetailObject {
        let object = TSQuoraDetailObject()
        object.id = self.id
        object.userId = self.userId
        object.title = self.title
        object.body = self.body
        object.body_text = self.body_text
        object.isAnonymity = self.isAnonymity
        object.amount = self.amount
        object.outlookAmount = RealmOptional<Int>(self.outlookAmount)
        object.isAutomaticity = self.isAutomaticity
        object.isLook = self.isLook
        object.isExcellent = self.isExcellent
        object.commentsCount = self.commentsCount
        object.answersCount = self.answersCount
        object.watchersCount = self.watchersCount
        object.likesCount = self.likesCount
        object.viewsCount = self.viewsCount
        object.isWatched = self.isWatched
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.user = self.user?.object()
        object.status = RealmOptional<Int>(self.status?.rawValue)
//        object.topics = self.topics
//        object.invitations = self.invitations
//        object.invitationAnswers = self.invitationAnswers
//        object.adoptionAnswers = self.adoptionAnswers
        return object
    }
}
