//
//  TSUserDiggsrankListObject.swift
//  ThinkSNS +
//
//  Created by LeonFa on 2017/4/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞榜的数据库模型

import UIKit
import RealmSwift

class TSUserDiggsrankListObject: Object {

    /// 列表用户ID
    let userId = RealmOptional<Int>()

    /// 对应的列表
    let detail = List<TSUserDiggsrankListDetailObject>()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "userId"
    }
}
