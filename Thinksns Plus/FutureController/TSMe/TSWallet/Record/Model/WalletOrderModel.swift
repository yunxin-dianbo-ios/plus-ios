//
//  WalletOrderModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/17.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class WalletOrderModel: Mappable {

    /// 记录id
    var id = 0
    /// 所属者id
    var ownerId = 0
    /// 操作类型 recharge_ping_p_p - 充值, widthdraw - 提现, user - 转账, reward - 打赏
    var targetType = ""
    /// 账户
    var targetId = ""
    /// 标题
    var title = ""
    /// 内容
    var body = ""
    /// 1 收入,-1 支出
    var type = 0
    /// 金额，分单位
    var amount = 0
    /// 订单状态，0: 等待，1：成功，-1: 失败
    var state = 0
    var create = Date()
    var update = Date()

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        ownerId <- map["owner_id"]
        targetType <- map["target_type"]
        targetId <- map["target_id"]
        title <- map["title"]
        body <- map["body"]
        type <- map["type"]
        amount <- map["amount"]
        state <- map["state"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }

    func walletHistoryObject() -> TSWalletHistoryObject {
        let object = TSWalletHistoryObject()
        object.id = id
        object.userIdentity = ownerId
        object.account = targetId
        object.status = state
        object.created = create as NSDate
        object.amount = amount
        object.subject = title
        object.targetType = targetType
        object.body = body
        object.type = type
        return object
    }
}
