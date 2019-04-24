//
//  TSWithdrawHistoryModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  提现明细 数据模型

import UIKit
import ObjectMapper

class TSWithdrawHistoryModel: Mappable {

    /// 提现记录 id
    var id: Int = 0
    /// 提现金额
    var value: Int = 0
    /// 提现方式
    var type: String = ""
    /// 提现账户
    var account: String = ""
    /// 提现状态， 0 - 待审批，1 - 已审批，2 - 被拒绝
    var status: Int = 0
    /// 备注，审批或者拒绝的时候由管理填写
    var remark: String?
    /// 申请时间
    var create = Date()

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        value <- map["value"]
        type <- map["type"]
        account <- map["account"]
        status <- map["status"]
        remark <- map["remark"]
        create <- (map["created_at"], TSDateTransfrom())
    }
}

extension TSWithdrawHistoryModel {

    // 转换成 object
    func convertToObject() -> TSWithdrawHistoryObject {
        let object = TSWithdrawHistoryObject()
        object.id = id
        object.value = value
        object.type = type
        object.account = account
        object.status = status
        object.remark = remark
        object.create = create as NSDate
        return object
    }
}
