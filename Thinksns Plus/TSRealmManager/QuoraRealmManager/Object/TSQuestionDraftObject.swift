//
//  TSQuestionDraftObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 23/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题草稿的数据库模型
//  注：问题草稿的数据模型为TSQuestionDraftModel == TSQuestionContributeModel问题的发布模型

import Foundation
import RealmSwift

typealias TSQuestionContributeObject = TSQuestionDraftObject
class TSQuestionDraftObject: Object {
    /// 自增id
    dynamic var draftId: Int = 0

    /// 标题
    dynamic var title: String?
    /// 正文
    dynamic var content: String?
    /// 正文，纯文字版，用于列表展示
    dynamic var content_text: String?
    /// 是否匿名
    dynamic var isAnonymous: Bool = false
    /// 选中的话题
    var topics = List<TSQuoraTopicObject>()
    /// 悬赏价格
    var offerRewardPrice = RealmOptional<Int>()
    /// 是否开启悬赏邀请
    dynamic var isOpenOfferRewardInvitation: Bool = false
    /// 邀请的专家/邀请的用户
    dynamic var invitationExpert: TSUserInfoObject?
    /// 是否开启围观
    dynamic var isOpenOutlook: Bool = false
    /// 修改的问题id
    var updatedQuestionId = RealmOptional<Int>()
    /// 是否采纳有答案 - 用于修改时判断能否进入悬赏设置页
    dynamic var isAdoptedAnswer: Bool = false
    /// 创建时间
    dynamic var createDate: Date = Date()
    /// 最近一次修改时间
    dynamic var updateDate: Date = Date()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "draftId"
    }
    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["draftId"]
    }

    /// 构建自增主键值
    class func incrementaID() -> Int {
        let realm = try! Realm()
        let objects = realm.objects(TSQuestionDraftObject.self).sorted(byKeyPath: "draftId")
        if let last = objects.last {
            return last.draftId + 1
        } else {
            return 1
        }
    }
}
