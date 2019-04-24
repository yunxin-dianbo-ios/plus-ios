//
//  IntegrationConfigModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class IntegrationConfigModel: Mappable {

    // 兑换比例，人民币一分钱可兑换的积分数量（例如：ratio = 10，1分钱 = 10积分）
    var ratio = 0
    // 充值选项，人民币分单位
    var optiongs = ""
    // 单笔最高充值额度
    var rechargeMax = 0
    // 单笔最小充值额度
    var rechargeMin = 0
    // 积分规则
    var rule = ""
    // IAP积分规则
    var iapRule = ""
    // 充值规则
    var chargeRule = ""
    // 提现规则
    var cashRule = ""
    // 提现最小额度
    var cashMin = 0
    // 提现最大额度
    var cashMax = 0
    // 提现方式
    var cashType: [String] = []
    // 充值方式
    var rechargeType: [String] = []
    /// 是否仅支持IAP支付
    var showOnlyIAP: Bool = true
    /// 积分充值显示开关
    var showIntegrationRecharge: Bool = false
    /// 积分提现显示开关
    var showIntegration: Bool = false

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        ratio <- map["settings.recharge-ratio"]
        optiongs <- map["settings.recharge-options"]
        rechargeMax <- (map["settings.recharge-max"], SingleStringTransform())
        rechargeMin <- (map["settings.recharge-min"], SingleStringTransform())
        rule <- map["rule"]
        iapRule <- map["IAP.rule"]
        showOnlyIAP <- map["IAP.only"]
        chargeRule <- map["recharge.rule"]
        cashRule <- map["cash.rule"]
        cashMax <- (map["settings.cash-max"], SingleStringTransform())
        cashMin <- (map["settings.cash-min"], SingleStringTransform())
        cashType <- map["cash-type"]
        rechargeType <- map["recharge-type"]
        showIntegrationRecharge <- map["recharge.status"]
        showIntegration <- map["cash.status"]
    }

    func options() -> [String] {
        let optiongStrs = optiongs.components(separatedBy: ",")
        var clearStrs: [String] = []
        // 过滤调空格
        for optionStr in optiongStrs {
            let clearStr = optionStr.replacingAll(matching: " ", with: "")
            clearStrs.append(clearStr)
        }
        return clearStrs
    }
}
