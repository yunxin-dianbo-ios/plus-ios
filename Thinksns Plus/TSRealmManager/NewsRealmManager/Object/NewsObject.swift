//
//  NewsObject.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

///  资讯列表中的资讯数据库模型
class NewsObject: Object {
    /// 数据标识
    dynamic var id: Int = 0
    /// 标题
    dynamic var title: String = ""
    /// 副标题
    dynamic var subject: String = ""
    /// 来源
    dynamic var from: String = ""
    /// 作者
    dynamic var author:	String = ""
    /// 发布者id
    dynamic var authorId: Int = 0
    /// 点击量
    dynamic var hits: Int = 0
    /// 当前用户是否已收藏
    dynamic var isCollected: Bool = false
    /// 当前用户是否已点赞
    dynamic var isLike: Bool = false
    /// 创建时间
    dynamic var createdDate: NSDate = NSDate()
    /// 更新时间
    dynamic var updatedDate: NSDate = NSDate()
    /// 所属分类信息
    dynamic var categoryInfo: NewsCategoryObject!
    /// 封面图信息
    dynamic var coverInfo: NewsImageObject?

    override static func primaryKey() -> String? {
        return "id"
    }
}

///  资讯列表中的置顶资讯数据库模型
class TopNewsObject: NewsObject {
}

class NewsCategoryObject: Object {
    /// 标识
    dynamic var id: Int = 0
    /// 名称
    dynamic var name: String = ""
    /// 所属分类排序
    dynamic var rank: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

class NewsImageObject: Object {
    /// 资讯封面附件id
    dynamic var id: Int = 0
    /// 资讯封面尺寸
    dynamic var size: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
