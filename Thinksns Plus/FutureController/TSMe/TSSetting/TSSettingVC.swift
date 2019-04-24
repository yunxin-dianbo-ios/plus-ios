//
//  TSSettingVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  设置

import UIKit
import Kingfisher

class TSSettingVC: TSViewController, TSCustomAcionSheetDelegate {
    let megaByte = 1_024.0 * 1_024.0

    /// 版本号展示 label
    @IBOutlet weak var labelForVersion: UILabel!
    /// 缓存信息展示 label
    @IBOutlet weak var labelForCache: UILabel!

    /// 缓存大小
    fileprivate  var cacheSize: Float = 0
    @IBOutlet weak var logoutLab: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        showImageCache()
    }

    // MARK: - Custom user interface
    func setUI() {
        self.title = "设置"
        // 获取版本号信息
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if let version = versionString {
            labelForVersion.text = "V\(version)"
        }
        logoutLab.textColor = TSColor.main.theme
    }

    /// 计算缓存大小并展示
    private func showImageCache() {
        ImageCache.default.calculateDiskCacheSize { (size) in
            let sdSize = Float(Double(size) / self.megaByte)
            let tsSize = TSWebEditorImageManager.default.cacheSize()
            self.cacheSize = sdSize + tsSize
            self.labelForCache.text = String(format:"%.2fM", self.cacheSize)
        }
    }
    /// 点击了黑名单
    @IBAction func blackListBtnAction(_ sender: Any) {
        let vc = BlackListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func AccountManagement() {
        let vc = TSAccountManagementVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 点击了修改密码
    @IBAction func setPasswordTaped() {
        navigationController?.pushViewController(TSSetPasswordVC(nibName: "TSSetPasswordVC", bundle: nil), animated: true)
    }

    /// 点击了已经反馈
    @IBAction func feedBackBtnAction(_ sender: Any) {
        // 判断是否设置了小助手，以及获取小助手的用户数据，以及是否正常登录了聊天
        if let uid = TSAppConfig.share.localInfo.imHelper, let userInfo = TSDatabaseUser().get(uid), EMClient.shared().isLoggedIn == true, uid != TSCurrentUserInfo.share.userInfo?.userIdentity {
            let idSt: String = String(uid)
            let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
            vc?.chatTitle = userInfo.name
            navigationController?.pushViewController(vc!, animated: true)
            return
        }
        let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
        appDeleguate.getHyPassword()
        let vc = TSFeedBackViewController()
        navigationController?.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 点击了清理缓存
    @IBAction func clearCacheTaped() {
        let message = String(format:"缓存大小: %.2fM, ", self.cacheSize)
        let actionsheetView = TSCustomActionsheetView(titles: [message + "提示信息_清理缓存".localized, "提示信息_确定".localized])
        actionsheetView.delegate = self
        actionsheetView.tag = 3
        actionsheetView.notClickIndexs = [0]
        actionsheetView.show()
    }

    /// 点击了关于我们
    @IBAction func aboutUsTaped() {
        var urlString = TSAppConfig.share.localInfo.aboutUsUrl
        if urlString.isEmpty {
           urlString = TSAppConfig.share.rootServerAddress + TSURLPath.application.aboutUs.rawValue
        }
        TSUtil.pushURLDetail(url: URL(string: urlString)!, currentVC: self)
    }

    /// 点击了退出登录
    @IBAction func logoutTaped() {
        let actionsheetView = TSCustomActionsheetView(titles: ["提示信息_退出登录".localized, "提示信息_退出".localized])
        actionsheetView.setColor(color: TSColor.main.warn, index: 1)
        actionsheetView.delegate = self
        actionsheetView.tag = 2
        actionsheetView.notClickIndexs = [0]
        actionsheetView.show()
    }

    // MARK: - Public
    func logout() {
        TSRootViewController.share.show(childViewController: .login)
        TSCurrentUserInfo.share.logOut()
        TSCurrentUserInfo.resetIsFirstToWalletVC()
    }

    // MARK: - Delegate

    // MARK: TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            logout()
        }
        if view.tag == 3 {
            ImageCache.default.clearDiskCache()
            // 自定义缓存文件清除
            TSWebEditorImageManager.default.cacheClear()
            self.showImageCache()
        }
    }
}
