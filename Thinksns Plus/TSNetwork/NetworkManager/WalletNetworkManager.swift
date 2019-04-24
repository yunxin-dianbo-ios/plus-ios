//
//  TSWalletNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包相关网络请求

import UIKit

class WalletNetworkManager {

    /// 钱包配置
    class func getConfig(complete: @escaping (Bool, String?, TSWalletConfigModel?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest().config
        request.urlPath = request.fullPathWith(replacers: [])
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                complete(true, nil, success.model)
            }
        }
    }

    /// 钱包流水
    ///
    /// - Parameters:
    ///   - limit: 可以设置获取数量
    ///   - after: 获取更多数据，上一次获取列表的最后一条 ID
    ///   - action: income - 收入 expenses - 支出
    ///   - complete: 结果
    class func getOrders(limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, action: String?, complete: @escaping (Bool, String?, [WalletOrderModel]?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest().orders
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                complete(true, nil, success.models)
            }
        }
    }
}

// MARK: - 提现
extension WalletNetworkManager {

    /// 提现列表
    ///
    /// - Parameters:
    ///   - limit: 可以设置获取数量
    ///   - after: 获取更多数据，上一次获取列表的最后一条 ID
    ///   - complete: 结果
    class func getCashes(limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping (Bool, String?, [TSWithdrawHistoryModel]?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest.Cashes.list
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                complete(true, nil, success.models)
            }
        }
    }

    /// 发起提现
    ///
    /// - Parameters:
    ///   - value: 用户需要提现的金额
    ///   - type: 用户提现账户方式
    ///   - account: 用户提现账户
    ///   - complete: 结果
    class func createCash(value: Int, type: String, account: String, complete: @escaping (Bool, String?, CashesResultMessageModel?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest.Cashes.create
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["value": value, "type": type, "account": account]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                complete(true, nil, success.model)
            }
        }
    }

}

// MARK: - 充值
extension WalletNetworkManager {

    /// 转换积分
    ///
    /// - Parameters:
    ///   - amount: 转账金额，分单位
    ///   - complete: 结果
    class func transfer(amount: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest().transform
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["amount": amount]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                complete(true, success.message)
            }
        }
    }

    /// 发起充值
    ///
    /// - Parameters:
    ///   - type: 充值方式 （见「启动信息接口」或者「钱包信息」）
    ///   - amount: 充值金额，单位为真实货币「分」单位
    ///   - extra: 拓展信息字段，见 支付渠道-extra-参数说明（目前没有使用）
    ///   - complete: 结果
    class func createRecharge(type: String, amount: Int, extra: Any?, complete: @escaping (Bool, String?, Dictionary<String, Any>?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest.Recharge.create
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["amount": amount, "from": "3"]
        if type == "wx" {
            parameters.updateValue(WalletRechargeOrderType.WechatOrder.rawValue, forKey: "type")
        } else {
            parameters.updateValue(WalletRechargeOrderType.AlipayOrder.rawValue, forKey: "type")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                TSLogCenter.log.debug(success)
                let sourceData = success.sourceData as? Dictionary<String, Any>
                complete(true, nil, sourceData)
            }
        }
    }

    /// 取回凭据
    class func getOrder(orderId: Int, complete: @escaping (Bool, String?, WalletOrderModel?) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest.Recharge.order
        request.urlPath = request.fullPathWith(replacers: ["\(orderId)"])
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                complete(true, nil, success.model)
            }
        }
    }

    /// 支付宝支付校验
    class func checkAlipayCharge(resultStatus: String, result: String, memo: String, complete: @escaping (String?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = WalletNetworkRequest.Recharge.order
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["resultStatus": resultStatus, "result": result, "memo": memo]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                let sourceData = data.sourceData as? Dictionary<String, Any>
                complete(sourceData?["message"] as? String, nil, true)
            }
        }
    }
}
