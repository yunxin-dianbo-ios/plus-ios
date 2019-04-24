//
//  TSRechargeModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  充值 视图控制器 数据模型

import UIKit

class TSRechargeModel {

    /// 可选充值金额
    var options: [String] = []
    /// 充值方式
    var rechargeTypes: [WalletRechargeType] = []

    // MARK: - Lifecycle

    init() {
    }

    init(model: TSWalletConfigModel) {
        options = model.options.flatMap({ (option) in
            // model.options() 是真实货币分单位，显示给用户的是真实货币元单位，所以这里是将分单位转换成元单位
            let CNYOption = Double(option) / 100
            return CNYOption.tostring()
        })
        rechargeTypes = model.recharge.flatMap { WalletRechargeType(rawValue: $0) }
    }

}
