//
//  IntegrationRechargeModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 积分充值选项
enum IntegrationRechargeType: String {
    /// Apple Pay (仅对 iOS 有效)
    case applepay = "applepay_upacp"
    /// App 发起支付宝支付选项
    case alipay
//    /// 手机网页发起支付宝支付
//    case alipayWap = "alipay_wap"
//    /// 支付宝扫码支付，前度生成二维码
//    case alipayQR = "alipay_qr"
    /// App 发起微信支付
    case wx
//    /// 手机网页发起微信支付
//    case wxWap = "wx_wap"
    /// 钱包余额充值
    case wallet
}

enum IntegrationCashType: String {
    case alipay
    case wechat
}

class IntegrationRechargeModel {

    /// 充值选项
    var moneyArray: [String] = []
    /// 充值方式
    var chargeTypeArray: [IntegrationRechargeType] = []
    /// 转换比例
    var ratio = 0
    /// 充值规则
    var rule = ""

    init() {
    }

    init(model: IntegrationConfigModel) {
        moneyArray = (model.options().flatMap({ (option) -> String? in
            // model.options() 是真实货币分单位，显示给用户的是真实货币元单位，所以这里是将分单位转换成元单位
            if let IntOption = Int(option) {
                let CNYOption = Double(IntOption) / 100
                return CNYOption.tostring()
            } else {
                return nil
            }
        }))
        chargeTypeArray = (TSAppConfig.share.launchInfo?.walletSetInfo?.recharge.flatMap { IntegrationRechargeType(rawValue: $0) })!
        ratio = model.ratio
        rule = model.chargeRule
        // 查看启动配置，如果“余额转积分”的开关打开了，就增加“余额转积分”的充值方式
        let canCashTransform = TSAppConfig.share.launchInfo?.cashTransform
        if canCashTransform! {
            chargeTypeArray.insert(.wallet, at: 0)
        }

    }

}
