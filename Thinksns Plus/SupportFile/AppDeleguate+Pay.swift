//
//  AppDeleguate+Pay.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/31.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import Foundation
/// 支付完成校验之后通过通知的方式告知页面刷新
extension AppDeleguate {
    /// 支付宝回调
    func checkAlipayCharge(payBackInfoDic: Dictionary<String, String>) {
        guard let resultStatus = payBackInfoDic["resultStatus"], let result = payBackInfoDic["result"], let memo = payBackInfoDic["memo"] else {
            TSLogCenter.log.debug("\n\ncheckAlipayCharge必须字段获取失败\n\n")
            return
        }
        // 异常处理
        // 错误码详见 https://docs.open.alipay.com/204/105302
        /// 只处理取消支付和网络异常的情况，其他后端处理
        if resultStatus == "6001" {
            // 用户中途取消
            let notiInfo = ["status": false, "type": "alipay", "result": "支付已取消", "message": ""] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
            return
        } else if resultStatus == "6002" {
            // 网络连接出错
            let notiInfo = ["status": false, "type": "alipay", "result": "网络连接出错", "message": ""] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
            return
        }
        let pay_type = UserDefaults.standard.value(forKey: "pay_type") as? String
        if pay_type == "wallet" {
            WalletNetworkManager.checkAlipayCharge(resultStatus: resultStatus, result: result, memo: memo) { (result, message, status) in
                TSLogCenter.log.debug(result)
                /// 支付宝结果校验通知 info.status: true/false type:alipay/wechat result: result message: message
                let notiInfo = ["status": status, "type": "alipay", "result": (result != nil ? result : ""), "message": (message != nil ? message : "")] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
            }
        } else {
            IntegrationNetworkManager.checkAlipayCharge(resultStatus: resultStatus, result: result, memo: memo) { (result, message, status) in
                TSLogCenter.log.debug(result)
                /// 支付宝结果校验通知 info.status: true/false type:alipay/wechat result: result message: message
                let notiInfo = ["status": status, "type": "alipay", "result": (result != nil ? result : ""), "message": (message != nil ? message : "")] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
            }
        }
    }
    // MARK: -- 微信支付回调
    func onReq(_ req: BaseReq!) {
        TSLogCenter.log.debug(req)
    }
    func onResp(_ resp: BaseResp!) {
        let errCode = resp.errCode
        switch errCode {
        case 0:
            let notiInfo = ["status": true, "type": "wxpay", "result": "支付成功", "message": ""] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
        case -2:
            let notiInfo = ["status": false, "type": "wxpay", "result": "支付已取消", "message": ""] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
        default:
            let notiInfo = ["status": false, "type": "wxpay", "result": "支付异常,请稍后充值", "message": ""] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name.Pay.checkResult, object: nil, userInfo: notiInfo)
        }
    }
}
