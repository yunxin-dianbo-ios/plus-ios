//
//  TSUserInfoWalletObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包

import UIKit
import RealmSwift

class TSUserInfoWalletObject: Object {
    /// 钱包标识
    let id = RealmOptional<Int>()
    /// 用户标识
    let userIdentity = RealmOptional<Int>()
    /// 钱包余额，余额单位为「分」
    dynamic var balance: Int = 0
    /// 创建时间
    dynamic var createDate: String?
    /// 最后交易时间
    dynamic var updateDate: String?
    /// 删除时间
    dynamic var deleteDate: String?

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
