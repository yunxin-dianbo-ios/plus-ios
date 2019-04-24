//
//  TSNewsTagObject.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSNewsTagObject: Object {

    /// 栏目id
    dynamic var tagID = 1
    /// 栏目名
    dynamic var name = ""
    /// 是否已订阅 （0： 未订阅， 1：已订阅）
    dynamic var isMarked = 0
    /// 排序 （只有已订阅的栏目才有这个值）
    dynamic var index = -1

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["tagID", "isMarked"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "tagID"
    }
}
