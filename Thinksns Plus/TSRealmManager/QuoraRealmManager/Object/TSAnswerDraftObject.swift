//
//  TSAnswerDraftObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案草稿箱的数据库模型

import Foundation
import RealmSwift

class TSAnswerDraftObject: Object {
    /// 草稿箱id
    dynamic var draftId: Int = 0
    /// 所回答的问题id
    dynamic var questionId: Int = 0
    /// 所回答的问题标题
    dynamic var questionTitle: String?
    /// 是否匿名
    var isAnonymity: Bool = false
    /// 草稿箱保存的答案，markdown版
    dynamic var markdown: String = ""
    /// 草稿箱保存的答案，纯文字版，用于列表展示
    dynamic var content: String? = nil
    /// 创建时间
    dynamic var createDate: Date = Date()
    /// 最近一次修改时间
    dynamic var updateDate: Date = Date()

    /// 答案id，用于判断是 发布答案的草稿 还是 编辑答案的草稿
    var answerId = RealmOptional<Int>()

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
        let objects = realm.objects(TSAnswerDraftObject.self).sorted(byKeyPath: "draftId")
        if let last = objects.last {
            return last.draftId + 1
        } else {
            return 1
        }
    }
}
