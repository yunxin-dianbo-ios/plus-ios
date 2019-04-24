//
//  IntegrationNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  积分 网络请求

import UIKit

class IntegrationNetworkManager {

    /// 取回凭据
    ///
    /// - Parameters:
    ///   - orderId: 凭据 id
    ///   - complete: 结果
    class func getChargeOrder(orderId: Int, complete: @escaping (IntegrationChargeResultModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest.Recharge.order
        request.urlPath = request.fullPathWith(replacers: ["\(orderId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model, nil, true)
            }
        }
    }

    /// 发起支付宝充值
    ///
    /// - Parameters:
    ///   - type: 充值方式 （见「启动信息接口」或者「钱包信息」）
    ///   - amount: 用户充值金额，单位为真实货币「分」单位，充值完成后会根据积分兑换比例增加相应数量的积分
    ///   - complete: 结果
    class func createAlipayCharge(amount: Int, complete: @escaping (String?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest.Recharge.recharge
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["type": WalletRechargeOrderType.AlipayOrder.rawValue, "amount": amount, "from": "3"]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                TSLogCenter.log.debug(data)
                let sourceData = data.sourceData as? Dictionary<String, Any>
                complete(sourceData?["data"] as? String, nil, true)
            }
        }
    }
    /// 支付宝支付校验
    class func checkAlipayCharge(resultStatus: String, result: String, memo: String, complete: @escaping (String?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest.Recharge.order
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
    /// 发起微信充值
    ///
    /// - Parameters:
    ///   - type: 充值方式 （见「启动信息接口」或者「钱包信息」）
    ///   - amount: 用户充值金额，单位为真实货币「分」单位，充值完成后会根据积分兑换比例增加相应数量的积分
    ///   - complete: 结果
    /*
     PayReq *request = [[[PayReq alloc] init] autorelease];
     
     request.partnerId = @"10000100";
     
     request.prepayId= @"1101000000140415649af9fc314aa427";
     
     request.package = @"Sign=WXPay";
     
     request.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
     
     request.timeStamp= @"1397527777";
     
     request.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
     
     [WXApi sendReq：request];
     
     */
    class func createWeChatCharge(amount: Int, complete: @escaping (Dictionary<String, Any>?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest.Recharge.recharge
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["type": WalletRechargeOrderType.WechatOrder.rawValue, "amount": amount, "from": "3"]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                TSLogCenter.log.debug(data)
                let sourceData = data.sourceData as? Dictionary<String, Any>
                complete(sourceData?["data"] as? Dictionary<String, Any>, nil, true)
            }
        }
    }

    /// 获取积分配置
    class func getIntegrationConfig(complete: @escaping (IntegrationConfigModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest().config
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model, nil, true)
            }
        }
    }

    class func getIAPIntegrationConfig(complete: @escaping ([IAPProductModel], String?, Bool) -> Void) {
        TSRootViewController.share.updateLaunchConfigInfo { (status) in
            if status == true {
                guard let model = TSAppConfig.share.localInfo.currencySetInfo else {
                    complete([], "网络请求错误", status)
                    return
                }
                var request = IntegrationIAPNetworkRequest().config
                request.urlPath = request.fullPathWith(replacers: [])
                RequestNetworkData.share.text(request: request) { (result) in
                    switch result {
                    case .error(_):
                        complete([], "网络请求错误", false)
                    case .failure(let response):
                        complete([], response.message ?? "网络请求错误", false)
                    case .success(let response):
                        var iapModels = [IAPProductModel]()
                        for iapModel in response.models {
                            var tempM = iapModel
                            tempM.ratio = model.ratio
                            tempM.rule = TSAppConfig.share.localInfo.iapRule
                            iapModels.append(tempM)
                        }
                        complete(iapModels, nil, true)
                    }
                }
            } else {
                complete([], "网络请求错误", status)
                return
            }
        }
        /**
        self.getIntegrationConfig { (model, message, result) in
            guard let model = model else {
                complete([], message, result)
                return
            }
            var request = IntegrationIAPNetworkRequest().config
            request.urlPath = request.fullPathWith(replacers: [])
            RequestNetworkData.share.text(request: request) { (result) in
                switch result {
                case .error(_):
                    complete([], "网络请求错误", false)
                case .failure(let response):
                    complete([], response.message ?? "网络请求错误", false)
                case .success(let response):
                    var iapModels = [IAPProductModel]()
                    for iapModel in response.models {
                        var tempM = iapModel
                        tempM.ratio = model.ratio
                        tempM.rule = model.iapRule
                        iapModels.append(tempM)
                    }
                    complete(iapModels, nil, true)
                }
            }
        }
        */
    }

    /// 获取积分流水
    ///
    /// - Parameters:
    ///   - limit: 数据返回条数
    ///   - after: 翻页数据id
    ///   - action: 筛选类型 recharge - 充值记录 cash - 提现记录 默认为全部
    ///   - complete: 结果
    class func getOrders(limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, action: String?, complete: @escaping ([IntegrationModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest().orders
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        if let action = action {
            parameters.updateValue(action, forKey: "action")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 发起提现
    ///
    /// - Parameters:
    ///   - amount: 提取积分，发起该操作后会根据积分兑换比例取人民币分单位整数后扣减相应积分
    ///   - complete: 结果
    class func cash(amount: Int, complete: @escaping (String?, Bool) -> Void) {
        // 1.请求 url
        var request = IntegrationNetworkRequest().cash
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["amount": amount]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                var message = failure.message
                if let datas = failure.sourceData as? [String: Any], let messageData = datas["message"] as? [String] {
                    message = messageData.first
                }
                complete(message, false)
            case .success(let data):
                var message = data.message
                if let datas = data.sourceData as? [String: Any], let messageData = datas["message"] as? [String] {
                    message = messageData.first
                }
                complete(message, true)
            }
        }
    }

}
