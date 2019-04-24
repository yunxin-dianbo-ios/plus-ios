//
//  TSNewsListObject.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  资讯列表-资讯表

import UIKit
import RealmSwift

class TSNewsListObject: Object {
    /// 资讯id
    dynamic var id: Int = -1
    /// 标题
    dynamic var title: String = ""
    /// 上传时间
    dynamic var updated_at: String = ""
    /// 发布平台
    dynamic var from: String = ""
    /// 是否收藏  0：未收藏， 1：已收藏
    dynamic var isConllected: Int = 0
    /// 是否已点赞 0 未点赞， 1：已点赞
    dynamic var isDiged: Int = 0
    /// 缩略图
    let storage = List<TSNewsImageObject>()

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
