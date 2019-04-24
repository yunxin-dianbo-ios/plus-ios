//
//  TSAppSettingInfoModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  启动信息的数据模型

// 广告/支付配置/打赏金额配置等暂时使用的别处,后续迁移过来 2017年10月17日13:42:47
// 后台提供的 site内的站点开关等 暂时不支持解析和使用
// site.gold:open 暂不支持

import Foundation
import ObjectMapper

/// 注册的类型
enum RegisterMethod: String {
    case all
    case mobile = "mobile-only"
    case mail = "mail-only"
}

class RegisterMethodTransform: TransformType {
    public typealias Object = RegisterMethod
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> RegisterMethod? {
        if let type = value as? String {
            return RegisterMethod(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: RegisterMethod?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// 是否需要完善资料
enum RegisterFixed: String {
    case need = "need"
    case noneed = "no-need"
}

class RegisterFixedTransform: TransformType {
    public typealias Object = RegisterFixed
    public typealias JSON = String
    open func transformFromJSON(_ value: Any?) -> RegisterFixed? {
        if let type = value as? String {
            return RegisterFixed(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: RegisterFixed?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// 注册的方式
enum AccountType: String {
    case all
    case thirdPart
    case invited // 该类型暂时不支持更多操作
}

class AccountTypeTransform: TransformType {
    public typealias Object = AccountType
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> AccountType? {
        if let type = value as? String {
            return AccountType(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: AccountType?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// Note: - 此处记录的属性初始值没有意义,会被plist 文件内的值覆盖
class TSAppSettingInfoModel: Mappable {
    // IM 聊天助手用户信息
    var imHelper: Int?
    var walletRatio: Int = 0 {
        didSet {
            guard walletRatio >= 1 else {
                walletRatio = oldValue
                return
            }
        }
    }
    var walletRechargeType: [String] = [String]()
    var ads: [TSAdvertModel]?
    /// 申请精选所需支付金额
    var quoraApplyAmount: Int = 0 {
        didSet {
            guard quoraApplyAmount >= 0 else {
                quoraApplyAmount = oldValue
                return
            }
        }
    }
    /// 围观答案所需支付金额
    var quoraOutLookAmount: Int = 0 {
        didSet {
            guard quoraOutLookAmount >= 0 else {
                quoraOutLookAmount = oldValue
                return
            }
        }
    }
    /// 匿名规则,这个属性是从question-configs接口中获取的 ****备注: 现在修改成 Q&A 字段里面的 anonymity_rule
    var quoraAnonymityRule: String = ""
    var anonymousRule: String = ""
    var anonymousStatus = false
    /// 问答后台配置开关 默认开启问答(发现页面、发布弹框、我的页面回答)
    var quoraSwitch = true

    /// 是否开启付费投稿
    var newsContributePay: Bool = false
    /// 是否开启只允许认证用户投稿
    var newsContributeVerified: Bool = false
    /// 付费投稿金额，开启付费投稿时投稿会自动扣除
    var newsContributeAmount: Int = 0 {
        didSet {
            guard newsContributeAmount >= 0 else {
                newsContributeAmount = oldValue
                return
            }
        }
    }
    /// 后台是否配置签到
    var checkin: Bool = false
    /// 签到金额配置
    var checkBalance: Int = 0
    /// 是否开启打赏功能
    var isOpenReward: Bool = false
    /// 打赏参数
    var rewardAmounts: [Int] = [] {
        didSet {
            guard rewardAmounts.isEmpty == false && rewardAmounts.count >= 3 else {
                rewardAmounts = oldValue
                return
            }
            if rewardAmounts.count >= 3 {
                rewardAmounts = Array(rewardAmounts[0...2])
            }
        }
    }
    /// 悬赏规则 reward_rule
    var reward_rule: String = ""
    /// 积分名称
    var goldName: String = "积分"
    /// 站点预留昵称
    var reservedNicknames: [String] = ["root", "admin"]
    /// 是否开放注册
    var registerAllOpen: Bool = true
    /// 注册时展示服务条款及隐私政策
    var registerShowTerms: Bool = true
    /// 注册类型
    var registerMethod: RegisterMethod = .all
    /// 账号类型
    var accountType: AccountType = .all
    /// 用户服务条款及隐私政策
    ///
    /// - Note: markdown 格式
    var content: String = "" {
        didSet {
            guard content.count >= 1 else {
                content = oldValue
                return
            }
        }
    }
    /// 注册完成后是否需要立即完善资料
    ///
    /// - Note: 暂时处理为是否显示 选择标签页面
    var registerCompleteData: Bool = true
    var registerFixed: RegisterFixed = .need
    /// 动态打赏
    var isFeedReward: Bool = false
    /// 动态支付
    var isFeedPay: Bool = false
    /// 动态项目项目金额
    var feedItems: [Int] = []
    /// 动态文字数量
    var feedLimit: Int = 0
    /// 邀请信息
    var inviteUserInfo: String = "未正确配置邀请信息"
    /// 关于我们
    var aboutUsUrl: String = ""

    /// - Note: 虚拟货币只能使用苹果内购方式，暂时采用后台参数屏蔽充值和提现的展示。
    /// 钱包提现显示开关
    var showCash: Bool = false
    /// 钱包提现规则
    var cash_rule: String = ""
    /// 钱包充值显示开关
    var showRecharge: Bool = false
    /// 钱包余额转换积分开关
    var cashTransform: Bool = false
    /// 积分提现显示开关
    var showIntegration: Bool = false
    /// 积分充值显示开关
    var showIntegrationRecharge: Bool = false
    /// 积分充值规则
    var currency_recharge_rule: String = ""
    /// 是否仅支持IAP支付
    var showOnlyIAP: Bool = true
    // IAP积分规则
    var iapRule = ""
    /// 积分配置信息 代替原来 currency 接口信息
    var currencySetInfo: IntegrationConfigModel?
    /// 钱包配置信息 代替原来 wallet 接口信息
    var walletSetInfo: TSWalletConfigModel?
    // app本地显示的名称
    var appDisplayName: String {
        let infoDic = Bundle.main.infoDictionary
        var appName = NSLocalizedString("CFBundleDisplayName", tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "") as String
        if appName == "CFBundleDisplayName" {
            // 没有配置或者错误配置InfoPlist.strings
            if (infoDic?.keys.contains("CFBundleDisplayName"))! {
                // 配置了plist中的显示名称
                appName = infoDic!["CFBundleDisplayName"] as! String
            } else {
                appName = infoDic!["BundleName"] as! String
            }
        }
        return appName
    }
    var appURLScheme: String {
        return Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    }

    /// 创建圈子是否需要用户认证
    var groupBuildNeedVerified = false
    /// 圈子打赏开关
    var isGroupReward = false
    /// 数据请求数目
    var limit: Int = 10
    /// 是否开启积分支付输入密码
    var shouldShowPayAlert = false
    /// 发动态最小视频时长
    let postMomentsRecorderVideoMinDuration: CGFloat = 10
    /// 发动态最大视频时长
    let postMomentsRecorderVideoMaxDuration: CGFloat = 60

    required init?(map: Map) {
    }

    init() {
    }

    func mapping(map: Map) {
        imHelper <- (map["im:helper-user"], SingleStringTransform())
        walletRatio <- map["wallet.ratio"]
        walletRechargeType <- map["wallet.recharge.types"]
        ads <- map["ad"]
        quoraApplyAmount <- map["Q&A.apply_amount"]
        quoraOutLookAmount <- map["Q&A.onlookers_amount"]
        quoraSwitch <- map["Q&A.switch"]
        // 这个字段是本地拼接的
        quoraAnonymityRule <- map["Q&A.anonymity_rule"]//map["question:anonymity_rule"]
        newsContributePay <- map["news.contribute.pay"]
        newsContributeVerified <- map["news.contribute.verified"]
        newsContributeAmount <- map["news.pay_contribute"]
        checkin <- map["checkin.switch"]
        checkBalance <- map["checkin.balance"]
        isOpenReward <- map["site.reward.status"]
        rewardAmounts <- (map["site.reward.amounts"], StringArrayTransfrom())
        reward_rule <- map["Q&A.reward_rule"]
        goldName <- map["site.currency_name.name"]
        reservedNicknames <- (map["site.reserved_nickname"], StringArrayTransfromStrings())
        registerAllOpen <- map["registerSettings.open"]
        registerShowTerms <- map["registerSettings.showTerms"]
        registerMethod <- (map["registerSettings.method"], RegisterMethodTransform())
        accountType <- (map["registerSettings.type"], AccountTypeTransform())
        content <- map["registerSettings.content"]
        registerCompleteData <- map["registerSettings.completeData"]
        registerFixed <- (map["registerSettings.fixed"], RegisterFixedTransform())
        isFeedReward <- map["feed.reward"]
        isFeedPay <- map["feed.paycontrol"]
        feedItems <- (map["feed.items"], SingleStringTransform())
        feedLimit <- map["feed.limit"]
        showCash <- map["wallet.cash.status"]
        showRecharge <- map["wallet.recharge.status"]
        cashTransform <- map["wallet.transform-currency"]
        showIntegration <- map["currency.cash.status"]
        cash_rule <- map["currency.cash.rule"]
        showIntegrationRecharge <- map["currency.recharge.status"]
        currency_recharge_rule <- map["currency.recharge.rule"]
        showOnlyIAP <- map["currency.IAP.only"]
        iapRule <- map["currency.IAP.rule"]
        currencySetInfo <- map["currency"]
        walletSetInfo <- map["wallet"]
        groupBuildNeedVerified <- map["group:create.need_verified"]
        isGroupReward <- map["group:reward.status"]
        inviteUserInfo <- map["site.user_invite_template"]
        aboutUsUrl <- map["site.about_url"]
        limit <- map["limit"]
        shouldShowPayAlert <- map["pay-validate-user-password"]
        anonymousStatus <- map["site.anonymous.status"]
        anonymousRule <- map["site.anonymous.rule"]
    }
}

/// 资讯投稿限制类型
enum TSNewsContributeLimitType {
    /// 无限制
    case none
    /// 仅认证
    case onlyVerified
    /// 仅投稿付费
    case onlyPay
    /// 认证且投稿付费
    case verifiedAndPay
}

/// 配置扩展
extension TSAppSettingInfoModel {
    // 获取资讯投稿限制类型
    var newContributeLimitType: TSNewsContributeLimitType {
        var limitType: TSNewsContributeLimitType = .none
        if self.newsContributeVerified && self.newsContributePay {
            limitType = .verifiedAndPay
        } else if self.newsContributeVerified && !self.newsContributePay {
            limitType = .onlyVerified
        } else if !self.newsContributeVerified && self.newsContributePay {
            limitType = .onlyPay
        }
        return limitType
   }
}
