//
//  TSWalletHistoryObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包明细 数据库数据结构

import UIKit
import RealmSwift

class TSWalletHistoryObject: Object {
    /// 凭据ID
    dynamic var id = -1
    /// 凭据对应用户（不一定有，该凭据对应的用户，客户端几乎用不到的。）
    var userIdentity = 0
    // 账户
    dynamic var account = ""
    /// 操作类型 recharge_ping_p_p - 充值, widthdraw - 提现, user - 转账, reward - 打赏
    dynamic var targetType = ""
    /// 操作金额（真实货币分单位）
    dynamic var amount = 0
    /// 订单标题
    dynamic var subject = ""
    /// 订单描述
    dynamic var body = ""
    /// 1 收入, -1 支出
    dynamic var type = 0
    /// 状态，0 - 未支付（等待）、1 - 成功、2 - 失败
    dynamic var status = 0
    /// 订单创建时间
    dynamic var created = NSDate()
    /// 订单更新时间
    dynamic var updated: NSDate?

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
