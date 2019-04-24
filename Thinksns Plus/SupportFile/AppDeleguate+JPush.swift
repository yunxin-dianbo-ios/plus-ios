//
//  AppDelegate+JPush.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  推送相关

import UIKit

extension AppDeleguate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
        /// 环信绑定设备
        let globalQueueDefault = DispatchQueue.global()
        globalQueueDefault.async() {
            EMClient.shared().bindDeviceToken(deviceToken)
        }
    }

    func setupJPush(didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let types: UInt = UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue
        if #available(iOS 10.0, *) {
            let entity = JPUSHRegisterEntity()
            entity.types = Int(types)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        }
        JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)

        #if DEBUG
            let isProduction = false
        #else
            let isProduction = true
        #endif
        let jPushKey = TSAppConfig.share.environment.jPushKey
        guard jPushKey.count.isEqualZero == false else {
            fatalError("环境配置错误,检查 AppEnvironment.plist 文件")
        }
        JPUSHService.setup(withOption: launchOptions, appKey: jPushKey, channel: nil, apsForProduction: isProduction)

        let remote = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? Dictionary<String, Any>

        if remote != nil {
            self.perform(#selector(receivePush), with: remote, afterDelay: 1.0)
        }
    }

    func registerJPushAlias() {
        if registerJPushAliasTimer == nil {
            registerJPushAliasTimer?.invalidate()
            registerJPushAliasTimer = nil
        }
        registerJPushAliasTimer = Timer(timeInterval: kRegisterJPushAliasDistance, target: self, selector: #selector(setJPushAlias), userInfo: nil, repeats: true)
        RunLoop.main.add(registerJPushAliasTimer!, forMode: .commonModes)
        setJPushAlias()
    }

    @objc private func setJPushAlias() {
        guard TSCurrentUserInfo.share.isLogin else {
            return
        }
        guard let userId = TSCurrentUserInfo.share.userInfo?.userIdentity else {
            return
        }
        JPUSHService.setAlias("user_\(userId)", callbackSelector: nil, object: nil)
    }

    func logoutJPushAlias() {
        JPUSHService.setAlias("", callbackSelector: nil, object: nil)
    }

    // MARK: - receive noti
    // 前台收到消息
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        processReceivePush(userInfo as! Dictionary<String, Any>)
        let badge = Int(UNNotificationPresentationOptions.badge.rawValue)
        completionHandler(badge)
    }

    /// 后台点击了通知栏,会调用该方法
    /// 接收数据后,跳转页面,不对数据做处理
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        // 跳转页面
        perform(#selector(switchShowView), with: userInfo as! Dictionary<String, Any>, afterDelay: 0.5)
        processReceivePush(userInfo as! Dictionary<String, Any>)
        completionHandler()
    }

    /// 接收数据
    /// iOS 9 上会调用该处相关代码,暂未做处理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    /// `App`状态为未运行时,用户点击`apn`通知导致`app`被启动运行
    /// 如果未调用该方法则表示`App`不是因点击`apn`而被启动,可能为直接点击icon被启动或其他.
    /// 接收数据后,跳转页面,不对数据做处理
    func receivePush(_ userInfo: Dictionary<String, Any>) {
        perform(#selector(switchShowView), with: userInfo, afterDelay: 0.5)
    }

    /// 处理推送数据
    func processReceivePush(_ userInfo: Dictionary<String, Any>) {
        guard let type = userInfo["type"] as? String else {
            return
        }
        switch type {
        case "im":
            // 即时聊天不通过接收推送作出任意操作,详情查看即时聊天推送
        break
        default:
            NotificationCenter.default.post(name: NSNotification.Name.APNs.receiveNotice, object: nil, userInfo: nil)
        }
    }

    /// 处理推送点击后的页面切换
    func switchShowView(_ userInfo: Dictionary<String, Any>) {
        // 这里aps已经是[String:Any]
        guard let _ = userInfo["aps"] else {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name.APNs.changeView, object: nil, userInfo: userInfo)
    }
}
