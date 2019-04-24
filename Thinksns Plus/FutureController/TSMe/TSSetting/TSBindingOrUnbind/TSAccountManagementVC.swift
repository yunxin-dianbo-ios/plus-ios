//
//  TSAccountManagementVC.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  账户管理 - 页面

import UIKit
import PKHUD

/// 绑定的名称选择
/// - 用来显示tableview内容
/// - 用来显示导航栏标题
enum BindingNameType: String {
    case phone = "绑定手机号"
    case email = "绑定邮箱"
    case qq = "绑定QQ"
    case wechat = "绑定微信"
    case weibo = "绑定微博"
}

/// tableview.cell的结构体数据
/// - nameType: 名称
/// - status:   是否绑定
///   - true:   绑定了
///   - false:  未绑定
struct TSBindingItme {
    let nameType: BindingNameType
    var status: Bool
}

class TSAccountManagementVC: TSViewController, TSBindingOrUnbindTableViewDelegate, TSCustomAcionSheetDelegate {

    weak var bindingOrUnbindTableView: TSBindingOrUnbindTableView!

    /// tableview默认数据
    var arry: Array<TSBindingItme> = [TSBindingItme(nameType: .phone, status: false), TSBindingItme(nameType: .email, status: false), TSBindingItme(nameType: .qq, status: false), TSBindingItme(nameType: .wechat, status: false), TSBindingItme(nameType: .weibo, status: false)]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "账户管理"
        self.view.backgroundColor = TSColor.inconspicuous.background
        setUI()
        bindingOrUnbindTableView.isUserInteractionEnabled = false
        bindingOrUnbindTableView.setBindingOrUnbindDataSource(data: arry)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserBinding()
    }

    func setUI() {
        let bindingOrUnbindTableView = TSBindingOrUnbindTableView(frame: self.view.frame, style: .plain)
        bindingOrUnbindTableView.bindingOrUnbindTableViewDelegate = self
        self.bindingOrUnbindTableView = bindingOrUnbindTableView

        self.view.addSubview(bindingOrUnbindTableView)
    }

    /// 获取这个tableview的数据
    /// - 更新用户信息，按照信息判断
    /// - 请求三方绑定信息，按照信息判断
    func getUserBinding() {
        TSUserNetworkingManager().getCurrentUserInfo { (userModel, _, status) in
            guard status, let userModel = userModel else {
                return
            }
            for (index, _) in self.arry.enumerated() {
                self.arry[index].status = false
            }
            TSCurrentUserInfo.share.userInfo = userModel
            if (TSCurrentUserInfo.share.userInfo?.phone) != nil {
                self.arry[0].status = true
            }
            if (TSCurrentUserInfo.share.userInfo?.email) != nil {
                self.arry[1].status = true
            }
            BindingNetworkManager().getUserSocialite { [weak self] (result, status) in
                guard let `self` = self else {
                    return
                }
                self.bindingOrUnbindTableView.isUserInteractionEnabled = true
                self.bindingOrUnbindTableView.isFirstShow = false
                guard status else {
                    self.bindingOrUnbindTableView.setBindingOrUnbindDataSource(data: self.arry)
                    return
                }
                for str in result {
                    if str == ProviderType.qq.rawValue {
                        self.arry[2].status = true
                    }
                    if str == ProviderType.wechat.rawValue {
                        self.arry[3].status = true
                    }
                    if str == ProviderType.weibo.rawValue {
                        self.arry[4].status = true
                    }
                }
                self.bindingOrUnbindTableView.setBindingOrUnbindDataSource(data: self.arry)
            }
        }
    }

    // MARK: - 代理回调
    func itemForDataSoruce(item: TSBindingItme) {
        switch item.nameType {
        case .phone:
            bindingOrUnbindForIphone(status: item.status)
        case .email:
            bindingOrUnbindForEmail(status: item.status)
        case .qq:
            if self.arry[0].status == true {
                bindingOrUnbindForQQ(status: item.status)
            } else {
                let faild = TSIndicatorWindowTop(state: .faild, title: "绑定三方账号前,需要绑定手机号")
                faild.show(timeInterval: 2)
            }
        case .wechat:
            if self.arry[0].status == true {
                bindingOrUnbindForWeChat(status: item.status)
            } else {
                let faild = TSIndicatorWindowTop(state: .faild, title: "绑定三方账号前,需要绑定手机号")
                faild.show(timeInterval: 2)
            }
        case .weibo:
            if self.arry[0].status == true {
                bindingOrUnbindForWeiBo(status: item.status)
            } else {
                let faild = TSIndicatorWindowTop(state: .faild, title: "绑定三方账号前,需要绑定手机号")
                faild.show(timeInterval: 2)
            }
        }
    }

    /// 是否绑定phone
    ///
    /// - Parameter status:
    ///     - true:     已绑定：走解绑
    ///     - false:    未绑定：走绑定
    func bindingOrUnbindForIphone(status: Bool) {
        if status {
            if !self.couldUnBind(.phone) {
                self.notUnBindProcess()
                return
            }
            let vc = TSUnbindVC(socialite: TSSocialite(provider: .phone, token: "", name: "", isLogin: true))
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // 根据是否初始化了密码 或者 是否绑定过手机或者邮箱 来决定进入密码设置页面或者 账号设置页面
            if TSCurrentUserInfo.share.isInitPwd == true {
                // 进入设置账号页面
                let vc = TSBindingVC(.phone, isSettingPwdOrAccount: false)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                // 进入设置密码页面
                let vc = TSBindingVC(.phone, isSettingPwdOrAccount: true)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    /// 是否绑定email
    ///
    /// - Parameter status:
    ///     - true:     已绑定：走解绑
    ///     - false:    未绑定：走绑定
    func bindingOrUnbindForEmail(status: Bool) {
        if status {
            if !self.couldUnBind(.email) {
                self.notUnBindProcess()
                return
            }
            let vc = TSUnbindVC(socialite: TSSocialite(provider: .email, token: "", name: "", isLogin: true))
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // 根据是否初始化了密码 或者 是否绑定过手机或者邮箱 来决定进入密码设置页面或者 账号设置页面
            if TSCurrentUserInfo.share.isInitPwd == true {
                // 进入设置账号页面
                let vc = TSBindingVC(.email, isSettingPwdOrAccount: false)
                _ = navigationController?.pushViewController(vc, animated: true)
            } else {
                // 进入设置密码页面
                let vc = TSBindingVC(.email, isSettingPwdOrAccount: true)
                _ = navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    /// 是否绑定QQ
    ///
    /// - Parameter status:
    ///     - true:     已绑定：走解绑
    ///     - false:    未绑定：走绑定
    func bindingOrUnbindForQQ(status: Bool) {
        guard status == false else {
            if !self.couldUnBind(.qq) {
                self.notUnBindProcess()
                return
            }
            unbindForUserSocialite(type: .qq)
            return
        }
        TSTripartiteAuthorizationManager().qqForAuthorization(complete: { (_, token, _) in
            if let token = token {
                HUD.show(HUDContentType.progress)
                var request = BindingNetworkRequest().loginUserProvider
                request.urlPath = request.fullPathWith(replacers: ["qq"])
                let parameter: [String: Any] = ["access_token": token]
                request.parameter = parameter

                RequestNetworkData.share.text(request: request, complete: { (networkResult) in
                    HUD.hide()
                    var bool: Bool = false
                    var info: String = "网络错误"
                    switch networkResult {
                    case .error(let netError):
                        if netError == .networkTimedOut {
                            info = "网络请求超时"
                        }
                    case .failure(let response):
                        if let message = response.message {
                            info = message
                        }
                    case .success(_):
                        bool = true
                        info = "绑定成功"
                        self.getUserBinding()
                    }
                    if bool == false {
                        let faild = TSIndicatorWindowTop(state: .faild, title: info)
                        faild.show(timeInterval: 2)
                    } else {
                        let faild = TSIndicatorWindowTop(state: .success, title: info)
                        faild.show(timeInterval: 2)
                    }
                })
                return
            }
        })
    }

    /// 是否绑定wechat
    ///
    /// - Parameter status:
    ///     - true:     已绑定：走解绑
    ///     - false:    未绑定：走绑定
    func bindingOrUnbindForWeChat(status: Bool) {
        guard status == false else {
            if !self.couldUnBind(.wechat) {
                self.notUnBindProcess()
                return
            }
            unbindForUserSocialite(type: .wechat)
            return
        }
        TSTripartiteAuthorizationManager().weichatForAuthorization(complete: { (_, token, _) in
            if let token = token {
                HUD.show(HUDContentType.progress)
                var request = BindingNetworkRequest().loginUserProvider
                request.urlPath = request.fullPathWith(replacers: ["wechat"])
                let parameter: [String: Any] = ["access_token": token]
                request.parameter = parameter

                RequestNetworkData.share.text(request: request, complete: { (networkResult) in
                    HUD.hide()
                    var bool: Bool = false
                    var info: String = "网络错误"
                    switch networkResult {
                    case .error(let netError):
                        if netError == .networkTimedOut {
                            info = "网络请求超时"
                        }
                    case .failure(let response):
                        if let message = response.message {
                            info = message
                        }
                    case .success(_):
                        bool = true
                        info = "绑定成功"
                        self.getUserBinding()
                    }
                    if bool == false {
                        let faild = TSIndicatorWindowTop(state: .faild, title: info)
                        faild.show(timeInterval: 2)
                    } else {
                        let faild = TSIndicatorWindowTop(state: .success, title: info)
                        faild.show(timeInterval: 2)
                    }
                })
                return
            }
        })
    }

    /// 是否绑定weibo
    ///
    /// - Parameter status:
    ///     - true:     已绑定：走解绑
    ///     - false:    未绑定：走绑定
    func bindingOrUnbindForWeiBo(status: Bool) {
        guard status == false else {
            if !self.couldUnBind(.weibo) {
                self.notUnBindProcess()
                return
            }
            unbindForUserSocialite(type: .weibo)
            return
        }
        TSTripartiteAuthorizationManager().weiboForAuthorization(complete: { (_, token, _) in
            if let token = token {
                HUD.show(HUDContentType.progress)
                var request = BindingNetworkRequest().loginUserProvider
                request.urlPath = request.fullPathWith(replacers: ["weibo"])
                let parameter: [String: Any] = ["access_token": token]
                request.parameter = parameter

                RequestNetworkData.share.text(request: request, complete: { (networkResult) in
                    HUD.hide()
                    var bool: Bool = false
                    var info: String = "网络错误"
                    switch networkResult {
                    case .error(let netError):
                        if netError == .networkTimedOut {
                            info = "网络请求超时"
                        }
                    case .failure(let response):
                        if let message = response.message {
                            info = message
                        }
                    case .success(_):
                        bool = true
                        info = "绑定成功"
                        self.getUserBinding()
                    }
                    if bool == false {
                        let faild = TSIndicatorWindowTop(state: .faild, title: info)
                        faild.show(timeInterval: 2)
                    } else {
                        let faild = TSIndicatorWindowTop(state: .success, title: info)
                        faild.show(timeInterval: 2)
                    }
                })
                return
            }
        })
    }

    /// 解绑三方
    ///
    /// - Parameter type: 类型
    ///     -   "qq"
    ///     -   "weicaht"
    ///     -   "weibo"
    func unbindForUserSocialite(type: ProviderType) {
        let title: String
        switch type {
        case .qq:
            title = "QQ"
        case .email:
            title = "邮箱"
        case .phone:
            title = "手机"
        case .wechat:
            title = "微信"
        case .weibo:
            title = "微博"
        }
        let actionsheetView = TSCustomActionsheetView(titles: ["你已绑定\(title)，是否解除绑定？", "解除绑定"], cancelText: "保留")
        actionsheetView.setColor(color: TSColor.main.warn, index: 1)
        actionsheetView.delegate = self
        actionsheetView.tag = 2
        actionsheetView.notClickIndexs = [0]
        actionsheetView.show()
        actionsheetView.finishBlock = { [weak self] (_, _, _) in
            BindingNetworkManager().deleteUserProvider(provider: type) { (message, status) in
                guard status else {
                    let str = message
                    let faild = TSIndicatorWindowTop(state: .faild, title: str)
                    faild.show(timeInterval: 2)
                    self?.getUserBinding()
                    return
                }
                let success = TSIndicatorWindowTop(state: .success, title: "解绑成功")
                success.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self?.getUserBinding()
                    success.dismiss()
                })
            }
        }
    }

    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
    }
}

/// 解绑前的处理
extension TSAccountManagementVC {
    /// 是否可以解绑
    /// 解绑的前提：邮箱和手机必须保留一个
    fileprivate func couldUnBind(_ type: BindingNameType) -> Bool {
        var couldFlag: Bool = false
        switch type {
        case .phone:
            // 解绑手机，必须绑定邮箱 (保证：邮箱和手机必须保留一个)
            if self.arry[1].status {
                couldFlag = true
            }
        case .email:
            // 解绑邮箱，必须绑定手机 (保证：邮箱和手机必须保留一个)
            if self.arry[0].status {
                couldFlag = true
            }
        case .qq:
            fallthrough
        case .wechat:
            fallthrough
        case .weibo:
            // 三方解绑，只需要绑定手机或邮箱 有一个即可
            if self.arry[0].status || self.arry[1].status {
                couldFlag = true
            }
        }
        return couldFlag
    }

    /// 不可解绑时的提示处理
    fileprivate func notUnBindProcess() -> Void {
        let alert = TSIndicatorWindowTop(state: .faild, title: "邮箱和手机必须保留一个")
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

}
