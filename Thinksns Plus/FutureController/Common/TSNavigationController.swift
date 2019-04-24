//
//  TSNavigationController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  抽象类

import UIKit

class TSNavigationController: UINavigationController, TSIndicatorAProrocol {
    // 右侧按钮容器视图
    //
    // - Warning: 为了处理对音乐的显示情况,右侧按钮使用该视图
    lazy var rightBarContentView = UIView(frame: CGRect.zero)
    lazy var rightBarContentWidth: CGFloat = 0

    // MARK: - Lifecycle
    override class func initialize() {
        super.initialize()
        let navigationBar = UINavigationBar.appearance()
        let navigationBarTitleAttributes = [NSForegroundColorAttributeName: InconspicuousColor().navTitle, NSFontAttributeName: UIFont.boldSystemFont(ofSize: TSFont.Navigation.headline.rawValue)]
        navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navigationBar.titleTextAttributes = navigationBarTitleAttributes
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = InconspicuousColor().navTitle
        navigationBar.isTranslucent = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveAvatarDidClick), name: NSNotification.Name.AvatarButton.DidClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showIndicatorA(noti:)), name: NSNotification.Name.NavigationController.showIndicatorA, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pushAtSelectedList(noti:)), name: NSNotification.Name(rawValue: "tsnotiNamepushAtSelectedList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pushSetPasswordVC), name: NSNotification.Name.Setting.setPassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeView(_:)), name: NSNotification.Name.APNs.changeView, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AvatarButton.DidClick, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NavigationController.showIndicatorA, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "tsnotiNamepushAtSelectedList"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Setting.setPassword, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.APNs.changeView, object: nil)
    }
    
    /// 收到APNs 切换视图
    func changeView(_ noti: NSNotification) {
        if let userinfo = noti.userInfo {
            print(userinfo)
            guard let aps = userinfo["aps"] as? [String:Any]  else {
                return
            }
            guard let type = aps["thread-id"] as? String else {
                return
            }
            switch type {
            case "notification:comments":
                if let vc = viewControllers.last as? ReceiveCommentTableVC {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let receiveCommentVC = ReceiveCommentTableVC()
                    pushViewController(receiveCommentVC, animated: true)
                }
            case "notification:likes":
                if let vc = viewControllers.last as? ReceiveLikeTableVC {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let receiveLikeTableVC = ReceiveLikeTableVC()
                    pushViewController(receiveLikeTableVC, animated: true)
                }
            case "notification:system":
                if let vc = viewControllers.last as? NoticeTableViewController {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let systemNoticeVC = NoticeTableViewController()
                    pushViewController(systemNoticeVC, animated: true)
                }
            case "notification:at":
                if let vc = viewControllers.last as? TSAtMeListVCViewController {
                    vc.tableView.mj_header.beginRefreshing()
                } else {
                    let atMeListVC = TSAtMeListVCViewController()
                    pushViewController(atMeListVC, animated: true)
                }
            default:
                assert(false, "点击效果未配置完毕")
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.isEmpty == false {
            let backBarItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(popBack))
            viewController.navigationItem.leftBarButtonItem = backBarItem
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    func popBack() {
        self.popViewController(animated: true)
    }

    func didReciveAvatarDidClick(noti: Notification) {
        // 1.判断是否为游客模式
        if !TSCurrentUserInfo.share.isLogin {
            // 如果是游客模式，拦截操作显示登录界面
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 判断跳转方式是uid还是uname分别进行跳转
        // uid兼容Int、String、NSNumber
        // uname只支持String
        // 如果都不是就不跳转
        if let userInfo = noti.userInfo as? Dictionary<String, Any>, userInfo["uid"] != nil {
            var uidInt: Int = 0
            if let uid = userInfo["uid"] as? Int {
                uidInt = uid
            } else if let uidStr = userInfo["uid"] as? String, let uid = Int(uidStr) {
                uidInt = uid
            } else if let uidNumber = userInfo["uid"] as? NSNumber {
                uidInt = uidNumber.intValue
            }
            if uidInt > 0 {
                let userHomPage = TSHomepageVC(uidInt)
                pushViewController(userHomPage, animated: true)
            }
        } else if let userInfo = noti.userInfo as? Dictionary<String, Any>, let userName = userInfo["uname"] as? String {
            let userHomPage = TSHomepageVC(0, userName)
            pushViewController(userHomPage, animated: true)
        }
    }

    func showIndicatorA(noti: Notification) {
        var title: String
        if let str = noti.userInfo?["content"] as? String {
            title = str
        } else {
            title = "提示信息_网络错误".localized
        }
        show(indicatorA: title)
    }
    /// 跳转到可选at人的列表
    func pushAtSelectedList(noti: Notification) {
        let atselectedListVC = TSAtSelectListVC()
        let notiData = noti.object as! Dictionary<String, Any>
        var contentTextView = notiData["textView"] as! UITextView
        atselectedListVC.selectedBlock = { (userInfo) in
            /// 先移除光标所在前一个at
            contentTextView = TSCommonTool.atMeTextViewEdit(contentTextView)
            let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
            let insertStr = spStr! + "@" + userInfo.name + spStr! + " "
            contentTextView.insertText(insertStr)
        }
        pushViewController(atselectedListVC, animated: true)
    }
    /// 跳转到设置密码页面
    func pushSetPasswordVC() {
        // 进入设置密码页面
        let vc = TSBindingVC(.phone, isSettingPwdOrAccount: true, isAutoBack: true)
        pushViewController(vc, animated: true)
    }
}

extension TSNavigationController {
    fileprivate func customSetup() {
        view.backgroundColor = TSColor.inconspicuous.background
    }
}
