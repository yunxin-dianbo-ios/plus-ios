//
//  TSLikeListObject.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSLikeListObject: Object {

    /// 动态Id
    dynamic var feedId = 0
    /// 排序id
    let userInfos = List<TSLikeListUserInfoObject>()
    /// 设置主键
    override static func primaryKey() -> String? {
        return "feedId"
    }
}
