//
//  TSPostDraftObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  圈子帖子的草稿数据库模型

import Foundation
import RealmSwift

class TSPostDraftObject: Object {
    /// 草稿id
    dynamic var draftId: Int = 0

    /// 发帖样式
    dynamic var showType: Int = 0
    /// 发帖圈子信息
    var groupId = RealmOptional<Int>()
    dynamic var groupName: String? = nil

    /// 是否同步到动态
    var isSyncMoment = RealmOptional<Bool>()

    /// 帖子标题
    dynamic var title: String? = nil
    /// 帖子内容
    dynamic var summary: String? = nil
    dynamic var markdown: String? = nil

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
        let objects = realm.objects(TSPostDraftObject.self).sorted(byKeyPath: "draftId")
        if let last = objects.last {
            return last.draftId + 1
        } else {
            return 1
        }
    }
}
