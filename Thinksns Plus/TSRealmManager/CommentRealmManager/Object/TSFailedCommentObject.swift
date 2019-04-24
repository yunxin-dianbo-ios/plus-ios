//
//  TSFailedCommentObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 19/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  通用的发送失败的评论的数据库模型

import Foundation
import RealmSwift

class TSFailedCommentObject: Object {
    /// 评论id
    dynamic var id: Int = 0
    /// 资源标识
    dynamic var commentTableType: String = ""
    /// 资源Id
    dynamic var commentTableId: Int = 0
    /// 评论者id
    dynamic var userId: Int = 0
    /// 资源作者id
    dynamic var targetUserId: Int = 0
    /// 回复者id
    var replyUserId = RealmOptional<Int>()
    /// 创建时间
    dynamic var createDate: Date?
    /// 更新时间
    dynamic var updateDate: Date?
    /// 评论内容
    dynamic var body: String = ""

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }

    /// 构建自增主键值
    class func incrementaID() -> Int {
        let realm = try! Realm()
        let objects = realm.objects(TSFailedCommentObject.self).sorted(byKeyPath: "id")
        if let last = objects.last {
            return last.id + 1
        } else {
            return 1
        }
    }

}
