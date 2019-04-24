//
//  TSWalletTransationDetailModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包明细详情视图 数据模型

import UIKit

class TSWalletTransationDetailModel {

    /// 交易状态
    var resultString = ""
    /// 交易金额
    var moneyString = ""
    /// 交易人类型
    var userType = ""
    /// 交易人 id
    var userIdentity: Int?
    /// 交易说明
    var descriptionString = ""
    /// 交易账户
    var accountString = ""
    /// 交易时间
    var dateString = ""
    /// 交易类型
    var channel = ""

    /// 钱包明细初始话
    init(walletObject object: TSWalletHistoryObject) {
        // 操作状态
        switch object.status {
        case 0:
            resultString = "审核中..."
        case 1:
            resultString = "交易成功"
        case 2:
            resultString = "交易失败"
        default:
            resultString = ""
        }

        let money = Double(object.amount) / 100 * (object.type == -1 ? -1 : 1)
        if money == 0 {
            moneyString = money.tostring()
        } else if money > 0 {
            userType = "付款人"
            moneyString = "+" + money.tostring()
        } else {
            userType = "收款人"
            moneyString = money.tostring()
        }

        descriptionString = object.subject
        dateString = TSDate().dateString(.walletDetail, nsDate: object.created)

        // 交易类型
        if !object.targetType.isEmpty {
            channel = object.targetType
        }
        /// 6.交易对象
        /// 6.1 如果交易类型是用户交易，account 为用户 id
        if (channel == "user" || channel == "reward"), let accountId = Int(object.account) {
            userIdentity = accountId
        }
    }

    /// 提现明细初始化
    init(withdraw object: TSWithdrawHistoryObject) {
        /// 交易状态
        switch object.status {
        case 0:
            resultString = "审核中"
        case 1:
            resultString = "交易成功"
        case 2:
            resultString = "交易失败"
        default:
            break
        }
        /// 交易金额
        moneyString = String(format: "-%.2f", Double(object.value / 100))
        /// 交易说明
        descriptionString = "提现"
        /// 交易账户
        accountString = object.account
        /// 交易时间
        dateString = TSDate().dateString(.walletDetail, nsDate: object.create)
    }
}
