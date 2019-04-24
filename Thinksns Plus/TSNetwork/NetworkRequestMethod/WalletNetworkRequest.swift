//
//  WalletNetworkRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/17.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class WalletNetworkRequest {

    // 钱包配置
    let config = Request<TSWalletConfigModel>(method: .get, path: "wallet", replacers: [])

    // 钱包流水
    let orders = Request<WalletOrderModel>(method: .get, path: "plus-pay/orders", replacers: [])
    // 转账
    let transfer = Request<Empty>(method: .post, path: "plus-pay/transfer", replacers: [])
    // 转换积分
    let transform = Request<Empty>(method: .post, path: "plus-pay/transform", replacers: [])
    // 提现
    struct Cashes {
        /// 提现列表
        static let list = Request<TSWithdrawHistoryModel>(method: .get, path: "plus-pay/cashes", replacers: [])
        /// 发起提现
        static let create = Request<CashesResultMessageModel>(method: .post, path: "plus-pay/cashes", replacers: [])
    }

    // 充值
    struct Recharge {
        /// 发起充值
        static let create = Request<WalletCreateCharegeModel>(method: .post, path: "walletRecharge/orders", replacers: [])//plus-pay/recharge
        /// 取回凭据
        static let order = Request<WalletOrderModel>(method: .post, path: "walletRecharge/checkOrders", replacers: [])
//        static let order = Request<WalletOrderModel>(method: .get, path: "plus-pay/orders/{order}", replacers: ["{order}"])
        /// 回调通知
        static let webhooks = Request<Empty>(method: .post, path: "plus-pay/webhooks", replacers: [])
    }
}
