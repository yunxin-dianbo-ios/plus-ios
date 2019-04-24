//
//  IntegrationCashRecordCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  提现记录 cell model

import UIKit

/// 积分交易状态
enum IntegrationRecordStatusType {
    /// 未知
    case unknow
    /// 等待中
    case ongoing
    /// 成功交易
    case success
    /// 交易失败
    case faild
}

class IntegrationCashRecordCellModel {

    var id = 0
    // 时间
    var time = ""
    // 信息
    var message = ""
    // 积分额度
    var amount = 0
    // 交易状态
    var statusType: IntegrationRecordStatusType = .unknow

    init(model: IntegrationModel) {
        id = model.id
        time = TSDate().dateString(.detail, nsDate: model.create as NSDate)
        message = model.title
        amount = model.amount * model.type
        switch model.state {
        case 0:
            // 等待中
            statusType = .ongoing
        case 1:
            statusType = .success
        case -1:
            statusType = .faild
        default:
            statusType = .unknow
        }
    }

}
