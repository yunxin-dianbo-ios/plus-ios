//
//  TSCurrentUserInfo.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  当前用户数据存储类

import UIKit
import RealmSwift
import Kingfisher

class TSCurrentUserInfo: NSObject {
    static let OneDaySecond: Int = 24 * 60 * 60
    static let share = TSCurrentUserInfo()
    static let isFirstToWalletVCKey = "isFirstToWalletVC"
    static let lastIgnoreAppVesinKey = "lastIgnoreAppVesin"
    static let lastCheckAppVesinKey = "lastCheckAppVesin"
    private override init() {
        accountToken = TSAccountTokenModel()
        accountManagerInfo = TSCurrentUserInfoSave()
    }
    /// 当前用户的信息
    internal var _userInfo: TSCurrentUserInfoModel?
    /// 把当前用户的UID保存在了沙盒里边，用于OC部分的取值
    var userInfo: TSCurrentUserInfoModel? {
        set {
            if newValue?.userIdentity != -1 {
                _userInfo = newValue
                UserDefaults.standard.set(newValue?.userIdentity, forKey: "TSCurrentUserInfoModel.uid")
                UserDefaults.standard.synchronize()
            }
        }
        get {
            return _userInfo
        }
    }
    /// 当前用户的未读数信息
    lazy var unreadCount = TSUnreadCount()
    /// 是否同意使用蜂窝网络查看短视频
    var isAgreeUserCelluarWatchShortVideo: Bool = false
    /// 是否同意使用蜂窝网络下载短视频
    var isAgreeUserCelluarDownloadShortVideo: Bool = false
    var isInitPwd: Bool {
        set {
            _userInfo?.isInitPwd = newValue
        }
        get {
            return (_userInfo?.isInitPwd)!
        }
    }
    var createID: Int = 0

    /// 账户鉴权口令
    ///
    /// - Note: 只要拥有该口令,就认为用户是合法的登录后的状态
    var accountToken: TSAccountTokenModel? = nil
    /// 用户管理权限信息
    var accountManagerInfo: TSCurrentUserInfoSave? = nil
    /// 登录状态
    var isLogin: Bool {
        return (self.accountToken == nil ? false : true)
    }
    /// 当前登录用户本次软件启动中,资讯查看状态
    let newsViewStatus = TSNewsViewStatusController()

    /// 检查鉴权口令的过期状态
    func isOvertimeAccount() -> Bool {
        if accountToken == nil || accountToken!.token.isEmpty || accountToken?.expireInterval == 0 {
            return false
        }
        let currentTime = Int(Date().timeIntervalSince1970)
        // 注：之前token有效期不足一天时则刷新口令，但刷新时别的地方有使用token的请求导致异常。
        let overtimerTimeStamp = accountToken!.createInterval + accountToken!.expireInterval * 60
        return currentTime > overtimerTimeStamp
    }

    /// 当前用户创建的资源的本地唯一标志
    ///
    /// Note: 唯一标志等于 MaxInt * 0.5 + 已发送失败的资源数量(来自数据库) - 秒时间戳 + 1 拼接上用户id，每获取一次，该数字+1。应用重启后数字重置
    func createResourceID() -> Int {
        let resourceID = Int(Date().timeIntervalSince1970)
        let failMoments = TSDatabaseMoment().getFaildSendMoments()
        guard let uid = self.userInfo?.userIdentity else {
            assertionFailure()
            return 0
        }

        var failResource = 0
        if failMoments.isEmpty == false {
            for item in failMoments {
                failResource += item.pictures.count
                failResource += 1
            }
        }
        self.createID = self.createID + uid + resourceID + failResource + 1
        return self.createID
    }

    /// 当前用户注销
    func logOut() {
        // 注销鉴权数据
        TSAccountTokenModel.reset()
        TSCurrentUserInfoSave.reset()
        IMTokenModel.reset()
        accountToken = nil
        accountManagerInfo = nil
        RequestNetworkData.share.configAuthorization(nil)
        // 注销推送别名
        let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
        appDeleguate.logoutJPushAlias()
        // 退出环信登录
        appDeleguate.logoutHy()
        unreadCount.clearAllUnreadCount()
        // 数据库
        TSDatabaseManager().deleteAll()
        // 删除阅读记录
        UserDefaults.standard.set(false, forKey: alreadyEnteredIntoIntegrationHomeController)
        UserDefaults.standard.set(false, forKey: alreadyEnteredIntoWalletHomeController)
        newsViewStatus.removeAll()
        TSCurrentUserInfo.resetIsFirstToWalletVC()
        isInitPwd = false
        // 清空所有缓存图片
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
    }
    // MARK: - 钱包

    /// 通过网络请求获取当前登录用户的余额信息
    ///
    /// - Parameter complete: (余额，错误信息)
    func getCurrentUserGold(currentUserGold complete: @escaping(Double?, String?) -> Void) {
//         获取当前登录用户的信息
        TSUserNetworkingManager().getCurrentUserInfo { [weak self] (userModel, message, status) in
            var balance: Double?
            if status, let userModel = userModel {
                // 储存用户信息
                TSDatabaseManager().user.saveCurrentUser(userModel)
                // 更新当前用户信息
                self?.userInfo = userModel
                // 获取用户的余额
                balance = TSWalletConfigModel.convertToYuan((userModel.wallet?.balance ?? 0))
            }
            complete(balance, message)
        }
    }

    /// 获取当前用户的积分余额
    func getCurrentUserJifen(complete: @escaping((_ status: Bool, _ jifen: Int?, _ message: String?) -> Void)) -> Void {
        TSUserNetworkingManager().getCurrentUserInfo { [weak self](userModel, msg, status) in
            guard status, let userModel = userModel else {
                complete(false, nil, msg)
                return
            }
            // 用户信息更新 并 回调
            TSDatabaseManager().user.saveCurrentUser(userModel)
            self?.userInfo = userModel
            complete(true, userModel.integration?.sum, msg)
        }
    }

    /// 获取当前用户的金额数
    class func getCurrentUserGold() -> Double? {
        guard let moneyFen = TSCurrentUserInfo.share.userInfo?.wallet?.balance else {
            return nil
        }
        // 检查数据无误后，计算显示金额
        let goldNumber = Double(moneyFen) / 100.0
        return goldNumber
    }

    /// 钱包页面是否第一次进入状态
    var isFirstToWalletVC: Bool {
        return UserDefaults.standard.bool(forKey: TSCurrentUserInfo.isFirstToWalletVCKey)
    }

    /// 重置钱包页面是否第一次进入状态
    class func resetIsFirstToWalletVC() {
        UserDefaults.standard.removeObject(forKey: TSCurrentUserInfo.isFirstToWalletVCKey)
    }

    /// 改变钱包页面是否第一次进入状态
    class func setNoTheFirstToWalletVC() {
        UserDefaults.standard.set(true, forKey: TSCurrentUserInfo.isFirstToWalletVCKey)
    }
    /// 最新忽略的版本号
    var lastCheckAppVesin: AppVersionCheckModel? {
        set {
            let modelJson = newValue?.toJSONString() != nil ? newValue?.toJSONString() : ""
            UserDefaults.standard.set(modelJson, forKey: TSCurrentUserInfo.lastIgnoreAppVesinKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let modelJson = UserDefaults.standard.value(forKey: TSCurrentUserInfo.lastIgnoreAppVesinKey) as? String {
                if let model = AppVersionCheckModel(JSONString: modelJson) {
                    return model
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    /// 最新忽略的版本号
    var lastIgnoreAppVesin: AppVersionCheckModel? {
        set {
            let modelJson = newValue?.toJSONString()
            if modelJson != nil {
                UserDefaults.standard.set(modelJson, forKey: TSCurrentUserInfo.lastCheckAppVesinKey)
                UserDefaults.standard.synchronize()
            }
        }
        get {
            if let modelJson = UserDefaults.standard.value(forKey: TSCurrentUserInfo.lastCheckAppVesinKey) as? String {
                if let model = AppVersionCheckModel(JSONString: modelJson) {
                    return model
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
}
