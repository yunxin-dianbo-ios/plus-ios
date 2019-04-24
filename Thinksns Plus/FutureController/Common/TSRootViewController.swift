//
//  TSRootViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  根视图控制器
//  负责切换/控制 登录控制器和主页标签控制器
//  每次该视图控制器初始化(应用启动)或者切换根视图(登录,注销)时都会检查一次当前登录用户口令有效期

import UIKit
import ObjectMapper

enum TSMainViewControllerType {
    case login
    case tabbar
}

class TSRootViewController: UIViewController {
    static let share = TSRootViewController()
    /// 环信需要保存的数量
    var groupArray = NSMutableArray()
    var userArray = NSMutableArray()
    var datasArray = NSMutableArray()
    var tempArray = NSMutableArray()
    /// bar的高度
    let barHeight: CGFloat = 49
    /// 登录控制器
    var loginVC: TSNavigationController? = nil
    /// 主页标签控制器
    var tabbarVC: TSHomeTabBarController? = nil
    var isFirst = true
    /// 当前显示的视图的控制器
    var currentShowViewcontroller: UIViewController? = nil
    /// 广告启动图
    lazy var advert: TSAdvetLaunchView = {
       return TSAdvetLaunchView()
    }()
    /// 版本检测弹窗
    var appVersionCheckVC: TSVersionCheck?
    /// 是否已经更新过服务器配置的app版本信息
    var didUpdateAppVersionInfo = false

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLaunchConfigInfo { (status) in
            TSLogCenter.log.debug("updateLaunchConfigInfo" + "\(status)")
        }
        if tabbarVC?.tabBar.frame.origin.y != UIScreen.main.bounds.size.height - barHeight {
            tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - barHeight - UIApplication.shared.statusBarFrame.size.height
            NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationIllicit(notification:)), name: NSNotification.Name.Network.Illicit, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hostDown(notification:)), name: NSNotification.Name.Network.HostDown, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notiNetstatesChange), name: Notification.Name.Reachability.Changed, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 注册推送别名
        let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
        appDeleguate.registerJPushAlias()
        NotificationCenter.default.addObserver(self, selector: #selector(showUnknowUserUIWindow), name: Notification.Name.AvatarButton.UnknowDidClick, object:nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* 
         需求要求：
         如果用户点击了启动页广告，跳转到了广告网页，
         启动页广告是不可跳过的，就要暂停，等用户从网页回来之后，再继续刚才的进度显示.
         启动广告是可跳过的，返回时进入APP首页.
         */
        if advert.getCurrentAdInfo()?.canSkip == false {
            advert.resumeAnimation()
        } else if advert.getCurrentAdInfo()?.canSkip == true {
            advert.dismiss()
        }
        /// 请求服务器配置的版本信息
        getVersionData()
        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin {
            checkAppVersion(lastCheckModel: lastCheckModel)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
         需求要求：
         如果用户点击了启动页广告，跳转到了广告网页，
         启动页广告是不可跳过的，就要暂停，等用户从网页回来之后，再继续刚才的进度显示.
         启动广告是可跳过的，返回时进入APP首页.
         */
        if advert.getCurrentAdInfo()?.canSkip == false {
            advert.pauseAnimation()
        }
    }
    /// 网络环境改变
    func notiNetstatesChange() {
        if TSAppConfig.share.reachabilityStatus != .NotReachable && didUpdateAppVersionInfo == false {
            /// 请求服务器配置的版本信息
            getVersionData()
        }
    }

    func changeStatuBar () {
        if UIApplication.shared.statusBarFrame.size.height == 20 {
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            if isFirst {
                tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - barHeight
                isFirst = false
                return
            }
            tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - 29
        } else {
            tabbarVC?.tabBar.frame.origin.y = UIScreen.main.bounds.size.height - barHeight - UIApplication.shared.statusBarFrame.size.height
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Custom user interface

    /// 切换根控制器显示的控制器
    ///
    /// - Parameter mainViewControllerType: 显示的控制器对应类型
    func show(childViewController mainViewControllerType: TSMainViewControllerType) {
        checkAccountStatus()

        switch mainViewControllerType {
        case .login:
            if currentShowViewcontroller == nil {
                addLoginVC()
                currentShowViewcontroller = self.loginVC
                return
            }
            if currentShowViewcontroller == loginVC {
                assert(false, "错误的根视图切换")
                return
            }
            addLoginVC()
            currentShowViewcontroller = loginVC
            tabbarVC?.view.removeFromSuperview()
            tabbarVC?.removeFromParentViewController()
            tabbarVC = nil
        case .tabbar:
            if currentShowViewcontroller == nil {
                addHomeTabVC()
                currentShowViewcontroller = self.tabbarVC
                return
            }
            if currentShowViewcontroller == tabbarVC {
                assert(false, "错误的根视图切换")
                return
            }
            addHomeTabVC()
            currentShowViewcontroller = self.tabbarVC
            loginVC?.view.removeFromSuperview()
            loginVC?.removeFromParentViewController()
            loginVC = nil
        }
    }

    /// 游客进入登录视图
    func guestJoinLoginVC() {
        if currentShowViewcontroller == loginVC {
            fatalError("尝试切换到登录页时,已显示了登录页")
        }
        let login = TSLoginVC(isHiddenDismissButton: false, isHiddenGuestLoginButton: true)
        loginVC = TSNavigationController(rootViewController: login)
        present(loginVC!, animated: true, completion: nil)
    }

    /// 创建主页标签控制器
    func addHomeTabVC() {
        tabbarVC = TSHomeTabBarController()
        self.addChildViewController(tabbarVC!)
        self.view.addSubview(tabbarVC!.view)
    }

    /// 创建登录视图控制器
    func addLoginVC() {
        let isHiddenGuestLoginButtonInLaunch = TSAppConfig.share.environment.isHiddenGuestLoginButtonInLaunch
        let login = TSLoginVC(isHiddenDismissButton: true, isHiddenGuestLoginButton: isHiddenGuestLoginButtonInLaunch)
        loginVC = TSNavigationController(rootViewController: login)
        self.addChildViewController(loginVC!)
        self.view.addSubview(loginVC!.view)
    }

    private func checkAccountStatus() {
        RequestNetworkData.share.configAuthorization(TSCurrentUserInfo.share.accountToken?.token)
        guard TSCurrentUserInfo.share.isOvertimeAccount() == true else {
            return
        }
        guard let accountToken = TSCurrentUserInfo.share.accountToken else {
            return
        }

        var readUUID = TSUUIDManager().readUUID()
        if readUUID == nil {
            let currentUUID = UIDevice.current.identifierForVendor?.uuidString
            TSUUIDManager().saveUUID(UUID: currentUUID!)
            readUUID = currentUUID!
        }

        // 刷新口令成功才会替换旧的数据,所以失败不用做任何处理,下次会使用上次的数据
        TSAccountNetworkManager.refreshAccountToken(token: accountToken.token) { (_, _) in
        }
        TSUserNetworkingManager.currentUserManagerInfo { (_, _) in
        }
    }

    // MARK: - Private

    /// 是否正在显示超时警告框
    var isShowingOverTimeAlert = false
    /// 显示超时的警告框
    func showOverTimeAlert(message: String?) {
        if currentShowViewcontroller == loginVC {
            return
        }
        if !isShowingOverTimeAlert {
            isShowingOverTimeAlert = true
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "提示信息_确定".localized, style: .default, handler: { [unowned self] (_) in
                TSRootViewController.share.show(childViewController: .login)
                TSCurrentUserInfo.share.logOut()
                self.isShowingOverTimeAlert = false
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    /// 检查版本更新
    func checkAppVersion(lastCheckModel: AppVersionCheckModel) {
        if let appVersionCheckVC = self.appVersionCheckVC {
            appVersionCheckVC.hidSelf()
        }
        let locVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let locVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let lastIgnoreModel = TSCurrentUserInfo.share.lastIgnoreAppVesin
        let showNoticeVC = { (checkModel: AppVersionCheckModel)
            in
            /// 没有忽略的版本直接提示更新
            let messagePopVC = TSVersionCheck()
            messagePopVC.show(vc: messagePopVC, presentVC: self.currentShowViewcontroller!)
            messagePopVC.setVersionInfo(model: checkModel)
            self.appVersionCheckVC = messagePopVC
        }
        if let locVersionString = locVersionString, let locVersionCode = locVersionCode, let locVersionCodeInt = Int(locVersionCode) {
            /// 服务器版本信息比本地更高
            if lastCheckModel.version.compare(locVersionString) == ComparisonResult.orderedDescending {
                /// 有忽略版本信息
                if let lastIgnoreModel = lastIgnoreModel {
                    if lastCheckModel.version.compare(lastIgnoreModel.version) == ComparisonResult.orderedDescending {
                        showNoticeVC(lastCheckModel)
                    } else if lastCheckModel.version.compare(lastIgnoreModel.version) == ComparisonResult.orderedSame, lastCheckModel.version_code > lastIgnoreModel.version_code {
                        showNoticeVC(lastCheckModel)
                    } else {
                        /// 已经忽略过，不提示
                        return
                    }
                } else {
                    /// 没有忽略的版本信息，直接升级
                    showNoticeVC(lastCheckModel)
                }
                /// version相同，build更高 需要更新
            } else  if lastCheckModel.version.compare(locVersionString) == ComparisonResult.orderedSame, lastCheckModel.version_code > locVersionCodeInt {
                /// 有忽略版本信息
                if let lastIgnoreModel = lastIgnoreModel {
                    if lastCheckModel.version.compare(lastIgnoreModel.version) == ComparisonResult.orderedDescending {
                        showNoticeVC(lastCheckModel)
                    } else if lastCheckModel.version.compare(lastIgnoreModel.version) == ComparisonResult.orderedSame, lastCheckModel.version_code > lastIgnoreModel.version_code {
                        showNoticeVC(lastCheckModel)
                    } else {
                        /// 已经忽略过，不提示
                        return
                    }
                } else {
                    /// 没有忽略的版本信息，直接升级
                    showNoticeVC(lastCheckModel)
                }
            } else {
                /// 本地版本信息比缓存信息更高不提示
            }
        }
    }

    // MARK: - Notification
    // Note: 当收到"口令违法"通知时,根据口令超时时间决定提示文字,然后注销用户
    func authenticationIllicit(notification: Notification) {
        var message: String?
        if TSCurrentUserInfo.share.isOvertimeAccount() == true {
            message = "提示信息_token刷新失败".localized
        } else {
            message = "提示信息_多设备登录".localized
        }
        showOverTimeAlert(message: message)
    }

    func hostDown(notification: Notification) {
        let vc = HostDownViewController(nibName: "HostDownViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: vc)
        let backBarItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(popBack))
        vc.navigationItem.leftBarButtonItem = backBarItem
        TSRootViewController.share.addChildViewController(nav)
        TSRootViewController.share.view.addSubview(nav.view)
    }

    func popBack() {
        #if DEBUG
        #else
        fatalError("503的情况下，要求APP点击返回关闭应用")
        #endif
    }

    /// 收到未知用户头像点击后显示弹窗
    func showUnknowUserUIWindow() {
        let alert = TSIndicatorWindowTop(state: .success, title: "用户已删除")
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
}
