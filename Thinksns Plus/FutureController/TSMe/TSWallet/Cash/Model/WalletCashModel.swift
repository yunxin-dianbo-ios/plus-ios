//
//  TSWithdrawMoneyModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  提现 视图控制器 数据模型

import UIKit

class WalletCashModel {

    /// 提现选项数组
    var cashTypes: [WalletCashType] = []
    /// 最低提现金额
    var cashMin = "0.0"

    // MARK: - Lifecycle

    init() {
    }

    init(model: TSWalletConfigModel) {
        cashTypes = model.cash.flatMap { WalletCashType(rawValue: $0) }
        cashMin = (Double(model.cashMin) / 100).tostring()
    }
}
