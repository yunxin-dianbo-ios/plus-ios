//
//  TSTransationCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包明细视图 数据模型

import UIKit

class TSTransationCellModel {

    // 日期
    var dateString = ""
    // 详情
    var detailString = ""
    // 金额
    var money = 0.0
    // 操作状态描述
    var stateString = ""
    /// 是否显示金额，不显示金额就显示操作状态
    /// 注：钱包明细中都显示金额，而提现明细中"操作中"和"操作失败"时都显示操作状态
    var isShowMoney: Bool = false

    // 钱包提现明细初始化
    public init(withdraw object: TSWithdrawHistoryObject) {
        // 日期
        dateString = TSDate().dateString(.walletList, nsDate: object.create)
        // 详情
        if object.type == "alipay" {
            detailString = "支付宝 账户提现 "
        } else if object.type == "wechat" {
            detailString = "微信 账户提现 "
        }
        detailString = detailString + object.account
        // 金额，提现为负
        money = Double(object.value) / 100 * -1
        // 操作状态
        switch object.status {
        case 0:
            stateString = "操作中"
        case 1:
            stateString = "已审批"
            self.isShowMoney = true
        case 2:
            stateString = "操作失败"
        default:
            break
        }
    }

    /// 钱包明细
    init(walletObject object: TSWalletHistoryObject) {
        dateString = TSDate().dateString(.walletList, nsDate: object.created)
        detailString = object.body
        if object.body.isEmpty {
            detailString = object.subject
        }
        money = Double(object.amount) / 100 * (object.type == -1 ? -1 : 1)
        // 操作状态
        switch object.status {
        case 0:
            stateString = "审核中"
        case 1:
            stateString = "已审批"
            self.isShowMoney = true
        case 2:
            stateString = "操作失败"
        default:
            stateString = ""
        }
    }

    /// 圈子收益
    init(groupIncomeModel model: GroupIncomeModel) {
        // 日期
        self.dateString = TSDate().dateString(.walletList, nsDate: NSDate(timeIntervalSince1970: model.createDate.timeIntervalSince1970))
        // 详情
        self.detailString = model.subject
        // 金额
        let goldNumber = TSWalletConfigModel.convertToYuan(model.amount)
        self.money = goldNumber
        // 操作状态
        self.stateString = ""
    }
}
