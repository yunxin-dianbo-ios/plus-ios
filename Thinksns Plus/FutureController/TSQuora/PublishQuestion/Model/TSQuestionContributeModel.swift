//
//  TSQuestionContributeModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题发布的数据模型
//  参考TSNewsContributeModel

import Foundation
import RealmSwift

class TSQuestionContributeModel {
    // 发布所需字段

    /// 标题
    var title: String?

    /// 正文，markdown版
    var content: String?
    /// 正文，纯文字版，用于列表展示
    var content_text: String?
    /// 是否匿名
    var isAnonymous: Bool = false

    /// 选中的话题
    var topics: [TSQuoraTopicModel]?

    /// 悬赏价格
    var offerRewardPrice: Int?

    /// 是否开启悬赏邀请
    var isOpenOfferRewardInvitation: Bool = false
    /// 邀请的专家/邀请的用户
    var invitationExpert: TSUserInfoModel?
    /// 是否开启围观
    var isOpenOutlook: Bool = false

    // 修改问题所需字段

    /// 修改的问题id
    var updatedQuestionId: Int?
    /// 是否采纳有答案 - 用于修改时判断能否进入悬赏设置页
    var isAdoptedAnswer: Bool = false

    // 存草稿所需字段

    /// 创建时间
    var createDate: Date = Date()
    /// 最近一次修改时间
    var updateDate: Date = Date()
    /// 草稿id
    var draftId: Int = 0

    init() {
    }
    /// 从问题详情中加载
    init(quora: TSQuoraDetailModel) {
        self.title = quora.title
        self.content = quora.body
        self.isAnonymous = quora.isAnonymity
        self.topics = quora.topics

        // 是否有悬赏
        if quora.amount > 0 {
            self.offerRewardPrice = quora.amount
            // 是否开启了悬赏邀请
            if nil != quora.invitations?.first {
                self.isOpenOfferRewardInvitation = true
                self.invitationExpert = quora.invitations!.first
                self.isOpenOutlook = quora.isLook
            }
        }

        // 是否有采纳答案
        if nil != quora.adoptionAnswers && !quora.adoptionAnswers!.isEmpty {
            isAdoptedAnswer = true
        }
        self.updatedQuestionId = quora.id

        self.createDate = quora.createDate
        self.updateDate = quora.updateDate
    }
    /// 从数据库中加载
    init(object: TSQuestionContributeObject) {
        self.title = object.title
        self.content = object.content
        self.content_text = object.content_text
        self.isAnonymous = object.isAnonymous
        self.offerRewardPrice = object.offerRewardPrice.value
        self.isOpenOfferRewardInvitation = object.isOpenOfferRewardInvitation
        self.isOpenOutlook = object.isOpenOutlook
        self.updatedQuestionId = object.updatedQuestionId.value
        self.isAdoptedAnswer = object.isAdoptedAnswer
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        if let invitationExpert = object.invitationExpert {
            self.invitationExpert = TSUserInfoModel(object: invitationExpert)
        }
        var topicList = [TSQuoraTopicModel]()
        for topicObject in object.topics {
            topicList.append(TSQuoraTopicModel(object: topicObject))
        }
        self.topics = topicList
        self.draftId = object.draftId
    }
    /// 转换成数据库模型
    func object() -> TSQuestionContributeObject {
        let object = TSQuestionContributeObject()
        object.draftId = draftId
        object.title = self.title
        object.content = self.content
        object.content_text = self.content_text
        object.isAnonymous = self.isAnonymous
        object.isOpenOfferRewardInvitation = self.isOpenOfferRewardInvitation
        object.isOpenOutlook = self.isOpenOutlook
        object.isAdoptedAnswer = self.isAdoptedAnswer
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.offerRewardPrice = RealmOptional<Int>(self.offerRewardPrice)
        object.updatedQuestionId = RealmOptional<Int>(self.updatedQuestionId)
        object.invitationExpert = self.invitationExpert?.object()
        if let topiclist = self.topics {
            for topic in topiclist {
                object.topics.append(topic.object())
            }
        }
        return object
    }

    /// 判空
    func isEmpty() -> Bool {
        var emptyFlag: Bool = true
        // 任何一个有值，都不为空
        if nil != self.title && !self.title!.isEmpty {
            emptyFlag = false
        } else if nil != self.content && !self.content!.isEmpty {
            emptyFlag = false
        } else if nil != self.topics && !self.topics!.isEmpty {
            emptyFlag = false
        } else if nil != self.content_text && !self.content_text!.isEmpty {
            emptyFlag = false
        }
        return emptyFlag
    }
    /// 判空 - 除了title不判断
    func isEmptyExceptTitle() -> Bool {
        var emptyFlag: Bool = true
        // 任何一个有值，都不为空 - 不判断title
        if nil != self.content && !self.content!.isEmpty {
            emptyFlag = false
        } else if nil != self.topics && !self.topics!.isEmpty {
            emptyFlag = false
        } else if nil == self.content_text || self.content_text!.isEmpty {
            emptyFlag = false
        }
        return emptyFlag
    }

    /// 判断是否可以发布
    func couldPublish() -> Bool {
        var couldFlag: Bool = true
        if nil == self.title || self.title!.isEmpty {
            couldFlag = false
        } else if nil == self.content || self.content!.isEmpty {
            couldFlag = false
        } else if nil == self.topics || self.topics!.isEmpty {
            couldFlag = false
        } else if nil == self.content_text || self.content_text!.isEmpty {
            couldFlag = false
        }
        return couldFlag
    }

}
