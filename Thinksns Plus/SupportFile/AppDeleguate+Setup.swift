//
//  AppDelegate+Setup.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  应用相关配置扩展

import UIKit
import MonkeyKing
import RealmSwift
import Kingfisher
import IQKeyboardManagerSwift
import GCDWebServer

extension AppDeleguate {
    func userDefaultsRegister() {
        /// 用户是否设置密码
        ///
        /// - Note: 默认用户是设置了密码,因为用户能登录进入,在需要使用该值时都是有密码的,如果用户三方登录,用户是否设置密码服务器会返回,然后覆盖该值
        UserDefaults.standard.register(defaults: ["isInitPwd": true])
    }
    // 配置日志输出等级
    func setupLogLevel() {
        /// 详细日志等级说明
        ///
        /// - verbose: 网络请求,请求数据
        /// - verbose: 网络请求,响应数据
        /// - verbose: 打印沙盒地址
        /// - verbose: 打印`JPush`信息
        ///
        /// - debug: 即时聊天,发送数据
        /// - debug: 即时聊天,响应数据
        TSLogCenter.configLogLevel(.debug)
    }

    func setupCrash() {
        Bugly.start(withAppId: TSAppConfig.share.environment.buglyAppID)
    }

    func setupRootViewController() {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin {
            TSCurrentUserInfo.share.userInfo = TSDatabaseManager().user.getCurrentUser()
            TSRootViewController.share.show(childViewController: .tabbar)
        } else {
            TSRootViewController.share.show(childViewController: .login)
        }
        setupAdvert()
        window?.backgroundColor = TSColor.inconspicuous.background
        window?.rootViewController = TSRootViewController.share
    }

    func setupAdvert() {
        // 1.获取所有广告
        TSDataQueueManager.share.advert.getAllAd()
        // 2.显示启动页广告
        TSRootViewController.share.showAdvert()
    }

    func setupShareConfig() {
        MonkeyKing.registerAccount(ShareManager.thirdAccout(type: .qq))
        MonkeyKing.registerAccount(ShareManager.thirdAccout(type: .weibo))
        MonkeyKing.registerAccount(ShareManager.thirdAccout(type: .wechat))
    }

    func setupReachabilityObserve() {
        TSReachability.share.startNotifier()
    }

    func setupIQKeyboardManager() {
        TSKeyboardToolbar.share.configureKeyboard()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }

    func setupDataBaseVersion() {
        let config = Realm.Configuration(
            schemaVersion: 7, // 当前数据库版本号
            migrationBlock: { migration, oldSchemaVersion in
                /*
         [长期注释]
         <注意>
         1、需要Realm数据存储的数据模型一旦变动都需要做数据迁移
         非主键变动都可以保留原数据，或者直接全部删除掉😂
         否则覆盖安装的低版本数据库App会崩溃无法启动
         <版本更新记录>
         build:1.8.2.0704及其以前
         Version1:
         GroupSearchHistoryObject 修改了主键和低版本不兼容，所以移除低版本的圈子以及帖子搜索记录

         build:研发中
         Version2:
         TSQuoraTopicObject 增加expertsCount字段
         TSMomentListObject 增加 topics
         /// version4
         TSMomentListObject 增加 repostType、repostID、repostModel、typeStr字段
         /// version5
         改动了用户信息模型，直接移除整个数据库/坏笑
         /// version6
         TopicListObject 增加 topicFollow 字段
        */
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: GroupSearchHistoryObject.className(), { (oldObject, newObject) in
                        migration.delete(oldObject!)
                    })
                }

                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: TSQuoraTopicObject.className(), { (oldObject, newObject) in
                        newObject!["expertsCount"] = 0
                    })
                }
                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: TSMomentListObject.className(), { (oldObject, newObject) in
                        newObject!["topics"] = []
                    })
                }
                if oldSchemaVersion < 4 {
                    migration.enumerateObjects(ofType: TSMomentListObject.className(), { (oldObject, newObject) in
                        newObject!["repostType"] = nil
                        newObject!["repostID"] = 0
                        newObject!["repostModel"] = nil
                        newObject!["typeStr"] = nil
                    })
                }
                if oldSchemaVersion < 5 {
                    migration.enumerateObjects(ofType: Object.className(), { (oldObject, newObject) in
                        migration.delete(oldObject!)
                    })
                }
                if oldSchemaVersion < 6 {
                    migration.enumerateObjects(ofType: TSMomentListObject.className(), { (oldObject, newObject) in
                        newObject!["sendStateReason"] = nil
                    })
                }
                if oldSchemaVersion < 7 {
                    migration.enumerateObjects(ofType: TopicListObject.className(), { (oldObject, newObject) in
                        newObject!["topicFollow"] = nil
                    })
                }
        })
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm() // 关闭iOS文件目录锁定保护
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
    }

    func setupImageCache() {
        // 当收到内存警告时，Kingfisher将清除内存缓存，并在需要时清除已过期和大小超时的缓存。通常没有必要清理缓存。
        // Kingfisher 默认支持自动处理PNG, JPEG 和 GIF 图片格式
        ImageCache.default.maxCachePeriodInSecond = TimeInterval(60 * 60 * 24 * 7) // 7天的秒数
        ImageCache.default.maxDiskCacheSize = 209_715_200 // 200M 最大图片缓存
        ImageDownloader.default.downloadTimeout = 20.0 // 20秒
    }

    // MARK: - 配置环信环境(推送等)
    func setupHY(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        // AppKey: 注册的 AppKey
        // apnsCertName: 推送证书名（不需要加后缀）
        // SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
        // 注1：这里的配置跟服务器有关。不同的服务器，配置不一样
        let apnsCertName: String = TSAppConfig.share.environment.imApnsName
        let appKey: String = TSAppConfig.share.environment.imAppKey
        let options: EMOptions = EMOptions(appkey: appKey)
        options.apnsCertName = apnsCertName
        EMClient.shared().initializeSDK(with: options)
        var config = [String: NSNumber]()
        config = ["httpsOnly": NSNumber(value: true), kSDKConfigEnableConsoleLogger: NSNumber(value: true), "easeSandBox": NSNumber(value: true)]
        EaseSDKHelper.share().hyphenateApplication(application, didFinishLaunchingWithOptions: launchOptions, appkey: appKey, apnsCertName: apnsCertName, otherConfig: config)
        EMClient.shared().chatManager.add(self as EMChatManagerDelegate, delegateQueue: nil)
        EMClient.shared().groupManager.add(self as EMGroupManagerDelegate, delegateQueue: nil)
        EMClient.shared().chatManager.remove(self as EMChatManagerDelegate)
        EMClient.shared().groupManager.removeDelegate(self)
    }

    // MARK: - 注册环信用户(放弃app端注册)
    func registerHyWithUsername(uidString: String) {
        let emRegisterError = EMClient.shared().register(withUsername: uidString, password: "123456")
        if emRegisterError == nil {
            //注册成功
        } else {
            //未注册成功
        }
    }

    // MARK: - 获取环信登录密码
    /// 该方法会间隔3秒自动重试3次，如果依旧获取不到数据
    func getHyPassword() {
        let nowTimeStamp = self.getTimeStamp()
        if self.isIMReconnecting == false {
            if self.IMReconnectTime < 3 {
                if (self.IMlastReconnectionTimeStamp + 3_000) < nowTimeStamp {
                    /// 可以重连
                    self.IMlastReconnectionTimeStamp = nowTimeStamp
                    self.IMReconnectTime += 1
                    self.isIMReconnecting = true
                    let hyRegisterUid = TSCurrentUserInfo.share.userInfo?.userIdentity
                    let hyUid = String(describing: hyRegisterUid)
                    TSAccountNetworkManager().getHyLoginPassword(account: hyUid) { (password, message, status) in
                        self.isIMReconnecting = false
                        guard status, let password = password else {
                            // 网络异常需要处理登录失败逻辑
                            // 通知需要处理的VC，当次请求失败
                            DispatchQueue.main.asyncAfter(deadline: (.now() + 3)) {
                                TSLogCenter.log.debug("getHyLoginPassword asyncAfter " + "\(self.IMReconnectTime)")
                                self.getHyPassword()
                            }
                            return
                        }
                        let hyRegisterUid = TSCurrentUserInfo.share.userInfo?.userIdentity
                        let hyUid = String(describing: hyRegisterUid)
                        self.loginHyWithUserId(userId: hyUid, pwString: password)
                    }
                } else {
                    TSLogCenter.log.debug("等待上一次环信信息获取完毕")
                }
            } else {
                self.IMReconnectTime = 0
                NotificationCenter.default.post(name: Notification.Name.Chat.hyGetPasswordFalse, object: nil)
            }
        } else {
            TSLogCenter.log.debug("正在获取环信信息")
        }
    }

    // MARK: - 获取环信登录密码之后，登录环信
    func loginHyWithUserId(userId: String, pwString: String) {
        if userId.isEmpty {

        } else {
            let globalQueueDefault = DispatchQueue.global()
            globalQueueDefault.async {
                guard let userIdentity = TSCurrentUserInfo.share.userInfo?.userIdentity else {
                    return
                }
                let hyLoginUid = String(userIdentity)
                let emLoginError = EMClient.shared().login(withUsername: hyLoginUid, password: pwString)
                DispatchQueue.main.async {
                    if emLoginError == nil {
                        TSIMReceiveManager.share.registerNotifications()
                        //这里需要处理下判断是否打开离线推送权限(下面是开启权限)
                        EMClient.shared().setApnsNickname(TSCurrentUserInfo.share.userInfo?.name)
                        //                        let emPushError = EMError?(nil)
                        EMClient.shared().getPushOptionsFromServerWithError(nil)
                        let emoptions = EMClient.shared().pushOptions
                        emoptions?.noDisturbStatus = EMPushNoDisturbStatusClose
                        emoptions?.displayStyle = EMPushDisplayStyleMessageSummary
                        EMClient.shared().updatePushOptionsToServer()

                        /// 要手动去创建小助手会话列表，并添加一句未读消息内容。
                        self.addImHelperChatList()
                        /// 在环信所有配置完了之后,让单列获取会话列表(检测未读消息)
                        TSIMReceiveManager.share.getHyChatList()
                        //关闭离线推送
//                        let emoptions = EMClient.shared().pushOptions
//                        options.noDisturbStatus = EMPushNoDisturbStatusDay
//                        options.noDisturbingStartH = 0
//                        options.noDisturbingEndH = 24
//                        EMClient.shared().updatePushOptionsToServer()
                    } else {
                        self.IMReconnectTime = 0
                        NotificationCenter.default.post(name: Notification.Name.Chat.hyGetPasswordFalse, object: nil)
                    }
                }
            }
        }
    }

    // MARK: - 退出环信登录
    func logoutHy() {
        let globalQueueDefault = DispatchQueue.global()
        globalQueueDefault.async {
            let _ = EMClient.shared().logout(true)
        }
    }

    func launchGCDWebUploader() {
        #if DEBUG
//            GCDWebServer.setLogLevel(2)
//            let path = NSHomeDirectory()
//            server = GCDWebUploader(uploadDirectory: path)
//            server?.start()
        #else
        #endif
    }

    func addImHelperChatList() {
        let hyIsLogin = EMClient.shared().isLoggedIn
        if hyIsLogin == false {
            return
        }
        guard let imHelperUid = TSAppConfig.share.localInfo.imHelper else {
            return
        }
        if imHelperUid == TSCurrentUserInfo.share.userInfo?.userIdentity {
            return
        }
        // 先拉取一下小助手的用户信息，优化在会话列表中的现实效果
        TSDataQueueManager.share.userInfoQueue.getUsersInfo(usersId: [imHelperUid], isQueryDB: false, complete: { (models: [TSUserInfoModel]?, message: String?, status: Bool) in
            TSLogCenter.log.debug(message)
        })

        let hyLoginUid = String(imHelperUid)
        let hyConversation = EMClient.shared().chatManager.getConversation(hyLoginUid, type: EMConversationTypeChat, createIfNotExist: false)
        if hyConversation != nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
            return
        }
        let hyConversationNew = EMClient.shared().chatManager.getConversation(hyLoginUid, type: EMConversationTypeChat, createIfNotExist: true)
        // 需要判断当前账号是否已经清理过了
        let clearedIMHelperUserArray = UserDefaults.standard.array(forKey: "clearedIMHelperUserArrayKey")
        if clearedIMHelperUserArray != nil {
            let userArray: Array<String> = clearedIMHelperUserArray as! Array<String>
            if userArray.contains(where: { (uid) -> Bool in
                let currentUID = String((TSCurrentUserInfo.share.userInfo?.userIdentity)!)
                return uid == currentUID
            }) {
                // 当前账号已经清理过就不再新加一个消息
            } else {
                // 提示语
                let messageBody: EMTextMessageBody = EMTextMessageBody(text: "小助手_默认消息".localized)
                let messageFrom = hyLoginUid
                let messageReal = EMMessage(conversationID: hyConversationNew?.conversationId, from: messageFrom, to: EMClient.shared().currentUsername, body: messageBody, ext: nil)
                messageReal?.chatType = EMChatTypeChat
                messageReal?.isRead = false
                messageReal?.direction = EMMessageDirectionReceive
                messageReal?.status = EMMessageStatusSucceed
                var resultError: EMError? = nil
                hyConversationNew?.insert(messageReal, error: &resultError)
            }
        } else {
            // 提示语
            let messageBody: EMTextMessageBody = EMTextMessageBody(text: "小助手_默认消息".localized)
            let messageFrom = hyLoginUid
            let messageReal = EMMessage(conversationID: hyConversationNew?.conversationId, from: messageFrom, to: EMClient.shared().currentUsername, body: messageBody, ext: nil)
            messageReal?.chatType = EMChatTypeChat
            messageReal?.isRead = false
            messageReal?.direction = EMMessageDirectionReceive
            messageReal?.status = EMMessageStatusSucceed
            var resultError: EMError? = nil
            hyConversationNew?.insert(messageReal, error: &resultError)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
    }
    /// 获取时间戳
    /// - Returns: 返回时间戳
    func getTimeStamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1_000)
    }
}
