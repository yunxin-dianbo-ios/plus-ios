//
//  IntegrationCashModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class IntegrationCashModel {

    var ratio = 0
    /// 最小积分提取数量
    var cashMin = 0
    /// 提现规则
    var rule = ""
    /// 提现方式
    var cashType: [String] = []

    init() {
    }

    init(model: IntegrationConfigModel) {
        ratio = model.ratio
        cashMin = model.cashMin
        rule = model.cashRule
        cashType = model.cashType
    }
}
