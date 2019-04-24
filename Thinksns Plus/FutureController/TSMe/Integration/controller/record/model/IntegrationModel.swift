//
//  IntegrationModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  积分流水 网络数据模型

import UIKit
import ObjectMapper

class IntegrationModel: Mappable {

    // 数据id
    var id = 0
    // 用户（所属者）id
    var ownerId = 0
    // 记录标题
    var title = ""
    // 记录信息
    var body = ""
    // 增减类型 1 - 收入、 -1 - 支出
    var type = 0
    // 操作类型 目前有： default - 默认操作、commodity - 购买积分商品、user - 用户到用户流程（如采纳、付费置顶等）、task - 积分任务、recharge - 充值、cash - 积分提取
    var targetType = ""
    // 当操作类型为user时，为用户id、当操作类型为recharge且充值完成时，为ping++订单号
    var targetId = ""
    // 后台预设积分类型id，当前需求中暂无该需求，默认为1，类型为积分
    var currency = 0
    // 积分额
    var amount = 0
    // 订单状态 0 - 等待、1 - 完成、-1 - 失败
    var state = 0
    var create = Date()
    var update = Date()

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        ownerId <- map["owner_id"]
        title <- map["title"]
        body <- map["body"]
        type <- map["type"]
        targetType <- map["target_type"]
        targetId <- map["target_id"]
        currency <- map["currency"]
        amount <- map["amount"]
        state <- map["state"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }
}
