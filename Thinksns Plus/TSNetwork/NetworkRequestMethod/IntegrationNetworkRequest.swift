//
//  IntegrationNetworkRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  积分

import UIKit

class IntegrationNetworkRequest: NSObject {

    // 积分配置
    let config = Request<IntegrationConfigModel>(method: .get, path: "currency", replacers: [])

    // 积分流水
    let orders = Request<IntegrationModel>(method: .get, path: "currency/orders", replacers: [])

    // 充值
    struct Recharge {
        /// 发起充值
        static let recharge = Request<IntegrationCreateCharegeModel>(method: .post, path: "currencyRecharge/orders", replacers: [])
        /// 取回凭据
        static let order = Request<IntegrationChargeResultModel>(method: .post, path: "currencyRecharge/checkOrders", replacers: [])
    }

    // 回调通知，供给ping++平台回调通知调用的接口
    let webhooks = Request<Empty>(method: .post, path: "currency/webhooks", replacers: [])

    // 发起提现
    let cash = Request<Empty>(method: .post, path: "currency/cash", replacers: [])
}

struct IntegrationIAPNetworkRequest {
    // iap产品信息
    let config = Request<IAPProductModel>(method: .get, path: "currency/apple-iap/products", replacers: [])
    // 申请发起iap充值
    let recharge = Request<IntegrationModel>(method: .post, path:"currency/recharge/apple-iap", replacers: [])
    // 验证iap充值结果
    let order = Request<IntegrationChargeResultModel>(method: .post, path:"currency/orders/:order/apple-iap/verify", replacers: [":order"])
}
