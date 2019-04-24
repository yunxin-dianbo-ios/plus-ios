//
//  TSCommentObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  通用评论数据库模型

import Foundation
import RealmSwift

/// 通用评论的数据库模型
typealias TSCommonCommentObject = TSCommentObject
class TSCommentObject: Object {
    /// 评论id
    dynamic var id: Int = 0
    /// 评论者id
    dynamic var userId: Int = 0
    /// 评论对象的发布者id
    dynamic var targetUserId: Int = 0
    /// 被回复者id，可能不存在
    var replyUserId = RealmOptional<Int>()
    /// 评论内容
    dynamic var body: String = ""
    /// 资源id
    dynamic var commentTableId: Int = 0
    /// 资源标识
    dynamic var commentTableType: String = ""
    /// 更新时间
    dynamic var updateDate: Date?
    /// 创建时间
    dynamic var createDate: Date?
    /// 是否置顶
    dynamic var isTop: Bool = false

    /// 主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
