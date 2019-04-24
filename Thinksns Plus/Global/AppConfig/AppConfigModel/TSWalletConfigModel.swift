//
//  TSWalletConfigModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包配置相关
/*
 
 这个类的使用状态很模糊，需要重写
 
 */

import UIKit
import ObjectMapper

/// 支付方式
public enum WalletRechargeOrderType: String {
    /// 支付宝
    case AlipayOrder
    /// 微信
    case WechatOrder
}

/// 支付方式
public enum WalletRechargeType: String {
    /// 支付宝
    case alipay
    /// 微信
    case wx
}

/// 提现方式
public enum WalletCashType: String {
    /// 支付宝
    case alipay
    /// 提现
    case wechat
}
class TSWalletConfigModel: Mappable {

    /// 充值选项
    var options: [Int] = []
    /// 转换比例
    var ratio = 0
    /// 充值提现规则。（以后需求中，可能是 markdown 目前是多行文本）
    var rule = ""
    /// 提现方式
    ///
    /// 可选提现的「提现方式」，按照现在系统预设，只有 alipay 和 wechat
    /// - Note: type: array|null 如果 alipay 和 wechat 都不存在，则代表关闭提现功能
    var cash: [String] = []
    /// 真实金额分单位，用户最低提现金额。
    var cashMin = 0

    /// 支付方式
    ///
    /// - Note: 对于移动端而言，alipay wx 不存在则表示关闭了充值功能，单个不存在则表示关闭单个充值选项，iOS多一个 apple pay 选项，其他端，例如 h5 或者 pc 参考平台后缀。例如没有 alipay_wap 表示关闭 h5 的支付宝。
    var recharge: [String] = []
    /// 钱包充值显示开关
    var showRecharge: Bool = false
    /// 钱包余额转换积分开关
    var cashTransform: Bool = false
    /// 钱包提现显示开关
    var showCash: Bool = false

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        options <- map["labels"]
        ratio <- map["ratio"]
        rule <- map["rule"]
        cash <- map["cash.types"]
        cashMin <- map["cash.min-amount"]
        recharge <- map["recharge.types"]
        showRecharge <- map["recharge.status"]
        cashTransform <- map["transform-currency"]
        showCash <- map["cash.status"]
    }

    init() {
    }

    /// 启动配置接口返回数据转化
    init(initialConfig data: [String: Any]) {
        if let ratioDate = data["wallet.ratio"] as? Int {
            ratio = ratioDate
        }
        if let rechargeData = data["wallet.recharge.types"]  as? [String] {
            recharge = rechargeData
        }
    }

}

// MARK: - 其他方法
extension TSWalletConfigModel {

    /*
     1.和后台通信时，用的始终是真实货币分单位的数值。
     2.给用户展示时，用的是金币单位的数值
     3.注意ratio的值，必须保证和服务器一致
     */

    /// 金币 -> 分
    ///
    /// - Note: 这个方法中的转换比例读取的是本地缓存
    ///
    /// - Parameter gold: 金币数
    /// - Returns: 真实货币分单位数
    @available(*, deprecated, message: "正在逐渐废弃掉该接口")
    public static func getFen(fromGold gold: Double) -> Int {
        let ratio = 1_000
        let fen = gold * 100 * 100 / Double(ratio)
        return Int(fen)
    }
    /// 元 -> 分
    static func convertToFen(_ fromYuan: Double) -> Int {
        return Int(fromYuan) * 100
    }

    /// 分 -> 金币
    ///
    /// - Note: 这个方法中的转换比例读取的是本地缓存
    ///
    /// - Parameter fen: 真实货币分单位数
    /// - Returns: 保留两位小数的金币数
    @available(*, deprecated, message: "正在逐渐废弃掉该接口")
    static func getGold(fromFen fen: Int) -> Double {
        let ratio = 1_000
        let gold = Double(fen) * (Double(ratio) / 100) / 100
        return Double(round(gold * 100) / 100)
    }

    /// 分 -> 元
    ///
    /// TODO: 未了兼容旧的逻辑这里的相关转换还是使用了Double，后续都应该使用Int
    static func convertToYuan(_ fromFen: Int) -> Double {
//        return Double(fromFen) / 100
        return Double(fromFen)
    }
}
