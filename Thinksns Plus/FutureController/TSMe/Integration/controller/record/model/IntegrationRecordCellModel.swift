//
//  IntegrationRecordCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/19.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class IntegrationRecordCellModel {

    var id = 0
    // 标题
    var title = ""
    // 时间
    var time = ""
    // 金额数
    var amount = 0
    /// 标题文字颜色
    var titleColor: UIColor = TSColor.main.content
    /// 金额文字颜色
    var amountColor: UIColor = TSColor.button.orangeGold

    init(model: IntegrationModel) {
        id = model.id
        time = TSDate().dateString(.detail, nsDate: model.create as NSDate)

        amount = model.amount * model.type
        // 如果充值或提现失败，则金额为0
        if -1 == model.state {
            amount = 0
        }

        // state 订单状态 0 - 等待、1 - 完成、-1 - 失败
        // "待支付、充值成功、充值失败" "正在审核、提取成功、提取失败"
        title = model.title
        switch model.targetType {
        // 积分充值
        case "recharge":
            switch model.state {
            case 0:
                title = "待支付"
                titleColor = TSColor.normal.minor
                amountColor = TSColor.normal.minor
            case 1:
                title = "充值成功"
            case -1:
                title = "充值失败"
                titleColor = TSColor.normal.minor
                amountColor = TSColor.normal.minor
            default:
                break
            }
        // 积分提取
        case "cash":
            switch model.state {
            case 0:
                title = "正在审核"
            case 1:
                title = "提取成功"
            case -1:
                title = "提取失败"
                titleColor = TSColor.normal.minor
                amountColor = TSColor.normal.minor
            default:
                break
            }
        default:
            break
        }
    }
}
