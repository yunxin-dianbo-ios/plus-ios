//
//  AppDelegate.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/13.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  应用代理

import UIKit
import MonkeyKing
import RealmSwift
import Regex
import GCDWebServer

@UIApplicationMain
class AppDeleguate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate, EMChatManagerDelegate, EMChatroomManagerDelegate, EMGroupManagerDelegate, EMCallManagerDelegate, WXApiDelegate,IMLSDKRestoreDelegate {
    //EMCDDeviceManagerDelegate
    var window: UIWindow?
    /// 注册推送别名计时器
    var registerJPushAliasTimer: Timer?
    /// 注册别名重连计时器间隔
    let kRegisterJPushAliasDistance = 60.0
    var server: GCDWebUploader?
    var IMReconnectTime: Int = 0
    var isIMReconnecting: Bool = false
    var IMlastReconnectionTimeStamp: Int64 = 0
    var statusBarHeight: CGFloat = 0

    // MARK: - Application and setup
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /// 该类初始化之后,配置整个应用主题色等
        DispatchQueue.main.async {
            UITextField.appearance().tintColor = TSColor.main.theme
            UITextView.appearance().tintColor = TSColor.main.theme
        }
        setupDataBaseVersion()

        let apiKey = TSAppConfig.share.environment.aMapApiKey
        guard apiKey.count.isEqualZero == false else {
            fatalError("环境配置错误,检查 AppEnvironment.plist 文件")
        }
        AMapServices.shared().apiKey = apiKey
        // 配置服务器地址
        // V2 版本网络请求
        let noteworkManager2 = RequestNetworkData.share
        noteworkManager2.configRootURL(rootURL: TSAppConfig.share.rootServerAddress)
        // 配置应用相关
        userDefaultsRegister()
        // 优先配置数据库
        setupDataBaseVersion()
        setupLogLevel()
        setupCrash()
        setupShareConfig()
        setupHY(application, didFinishLaunchingWithOptions: launchOptions)
        setupRootViewController()
        setupReachabilityObserve()
        setupIQKeyboardManager()
        setupImageCache()
        launchGCDWebUploader()
        setupJPush(didFinishLaunchingWithOptions: launchOptions)
        window?.backgroundColor = UIColor.white
        // 注册状态栏改变的通知
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarFrameDidChange(notice:)), name: Notification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarFrameWillChange(notice:)), name: Notification.Name.UIApplicationWillChangeStatusBarFrame, object: nil)
        /// 应用启动2秒后
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.clearPostVideoFeedLocVideo()
        }

        MobLink.setDelegate(self as IMLSDKRestoreDelegate)
        return true
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    func imlsdkStartCheckScene() {
        
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url) { (resultDic) in
                if let payBackInfoDic = resultDic as! Dictionary<String, String>? {
                    self.checkAlipayCharge(payBackInfoDic: payBackInfoDic)
                }
            }
        }
        if WXApi.handleOpen(url, delegate: self) || MonkeyKing.handleOpenURL(url) {
            return true
        }
        return false
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url) { (resultDic) in
                if let payBackInfoDic = resultDic as! Dictionary<String, String>? {
                    self.checkAlipayCharge(payBackInfoDic: payBackInfoDic)
                }
            }
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        EMClient.shared().applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        EMClient.shared().applicationWillEnterForeground(application)
    }

    func statusBarFrameDidChange(notice: Notification) {
        if statusBarHeight == 40 {
            TSUtil.share().statusHeight = ScreenHeight - 20
        } else if statusBarHeight == 20 {
            TSUtil.share().statusHeight = ScreenHeight
        }
    }

    func statusBarFrameWillChange(notice: Notification) {
        let cgrectValue: NSValue = notice.userInfo!["UIApplicationStatusBarFrameUserInfoKey"] as! NSValue
        let frame: CGRect = cgrectValue.cgRectValue
        statusBarHeight = frame.size.height
        if statusBarHeight == 40 {
            TSUtil.share().statusHeight = ScreenHeight - 20
        } else if statusBarHeight == 20 {
            TSUtil.share().statusHeight = ScreenHeight
        }
    }
    /// 清理发布视频动态缓存的视频文件
    func clearPostVideoFeedLocVideo() {
        let rootVideoPath = TSUtil.getWholeFilePath(name: "")
        if TSCurrentUserInfo.share.isLogin == false {
            /// 未登录直接删除全部视频
            if FileManager.default.fileExists(atPath: rootVideoPath) {
                try! FileManager.default.removeItem(at: URL(fileURLWithPath: rootVideoPath))
            }
        } else {
            /// 已经登录
            /// 获取发送失败的动态model
            let faildMoments = TSDatabaseManager().moment.getFaildSendMoments().map { FeedListCellModel(faildMoment: $0) }
            if faildMoments.isEmpty {
                /// 没有发送失败的动态，直接删除视频文件
                if FileManager.default.fileExists(atPath: rootVideoPath) {
                    try! FileManager.default.removeItem(at: URL(fileURLWithPath: rootVideoPath))
                }
                return
            }
            if let names = FileManager.default.enumerator(atPath: rootVideoPath) {
                for name in names {
                    if let fileName = name as? String, fileName.components(separatedBy: ".").isEmpty == false {
                        let fileId = fileName.components(separatedBy: ".")[0]
                        TSLogCenter.log.debug(name)
                        /// 对比是否是发布失败的动态的视频
                        var shouldDelete = true
                        for faildModel in faildMoments {
                            if String((faildModel.id["feedId"])!) == fileId {
                                shouldDelete = false
                                continue
                            }
                        }
                        /// 没有匹配到对应的视频动态，需要删除
                        if shouldDelete {
                            let videoPath = TSUtil.getWholeFilePath(name: fileName)
                            /// 直接删除视频文件
                            if FileManager.default.fileExists(atPath: videoPath) {
                                try! FileManager.default.removeItem(at: URL(fileURLWithPath: videoPath))
                            }
                        }
                    }
                }
            }
        }
    }
    /** [临时注释] 暂时未使用到的系统提供的方法 2017-02-10
     func applicationWillResignActive(_ application: UIApplication) {
     // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
     }
     
     func applicationWillEnterForeground(_ application: UIApplication) {
     // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
     }
     
     func applicationDidBecomeActive(_ application: UIApplication) {
     // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     }
     
     func applicationWillTerminate(_ application: UIApplication) {
     // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     }
     */
}
