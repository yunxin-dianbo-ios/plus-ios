//
//  TSNewsAndTagsRelationObject.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  栏目-资讯 关系表

import UIKit
import RealmSwift
class TSNewsAndTagsRelationObject: Object {

    /// 栏目id
    dynamic var tagID = -1
    /// 资讯id
    dynamic var newsID = 0
    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["tagID", "newsID"]
    }
}
