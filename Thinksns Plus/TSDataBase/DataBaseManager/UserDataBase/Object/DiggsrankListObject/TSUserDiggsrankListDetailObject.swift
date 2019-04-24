//
//  TSUserDiggsrankListObject.swift
//  ThinkSNS +
//
//  Created by LeonFa on 2017/4/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞榜详情的数据库模型

import UIKit
import RealmSwift

class TSUserDiggsrankListDetailObject: Object {

    /// 用户ID
    let userId = RealmOptional<Int>()
    /// 排序ID
    let maxId = RealmOptional<Int>()
    /// 点赞数
    let diggNumber = RealmOptional<Int>()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "userId"
    }
}
