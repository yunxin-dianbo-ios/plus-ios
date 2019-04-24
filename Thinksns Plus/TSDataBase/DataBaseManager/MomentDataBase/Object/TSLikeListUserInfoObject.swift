//
//  TSLikeListUserInfoObject.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSLikeListUserInfoObject: Object {

    /// 用户Id
    dynamic var userId = 0
    /// 排序id
    dynamic var feedDiggId = 0
    /// 设置主键
    override static func primaryKey() -> String? {
        return "userId"
    }
}
