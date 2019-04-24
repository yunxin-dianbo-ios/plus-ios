//
//  TSNewsImageObject.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSNewsImageObject: Object {

    /// 图片附件id
    dynamic var id: Int = -1
    /// 图片size
    dynamic var imageSize: String = ""

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
