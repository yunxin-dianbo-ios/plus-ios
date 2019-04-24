//
//  TSBindingVC.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 绑定页面
/// - phone
/// - email
class TSBindingVC: TSViewController, TSBindingPhoneOrEmailViewDeleagte {
    weak var bindingPhoneOrEmailView: TSBindingPhoneOrEmailView!
    weak var settingPwdView: TSBindingSetPwdView!
    let providerType: ProviderType
    let isSettingPwdOrAccount: Bool
    /// 如果设置自动返回，完成后直接返回上一级页面，单独的密码设置流程
    var isAutoBack = false

    /// 通过类型初始化,只支持手机和邮箱, 是显示设置密码或者显示账号, autoBack完成后自动返回
    init(_ providerType: ProviderType, isSettingPwdOrAccount: Bool, isAutoBack: Bool = false) {
        self.providerType = providerType
        self.isSettingPwdOrAccount = isSettingPwdOrAccount
        self.isAutoBack = isAutoBack
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        var title = ""
        switch providerType {
        case .phone:
            if isSettingPwdOrAccount == false {
                title = BindingNameType.phone.rawValue
            } else {
               title = "设置密码"
            }
        case .email:
            if isSettingPwdOrAccount == false {
                title = BindingNameType.email.rawValue
            } else {
                title = "设置密码"
            }
        default:
            assert(false, "设置了不支持的类型")
            break
        }
        self.title = title
        settingPwdOrAccount(isSettingPwdOrAccount)
    }

    func settingPwdOrAccount(_ isSettingPwdOrAccount: Bool) {
        if isSettingPwdOrAccount == false { // 设置账号
            let bindingPhoneOrEmailView = TSBindingPhoneOrEmailView(frame: CGRect.zero, provider: providerType)
            bindingPhoneOrEmailView.deleate = self
            self.bindingPhoneOrEmailView = bindingPhoneOrEmailView
            self.view.addSubview(bindingPhoneOrEmailView)
            bindingPhoneOrEmailView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
            return
        }
        let settingPwdView = TSBindingSetPwdView(frame: CGRect.zero, provider: providerType)
        settingPwdView.deleate = self
        self.settingPwdView = settingPwdView
        self.view.addSubview(settingPwdView)
        settingPwdView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }

    // MARK: - 代理回调
    func clickBinding(ac: String, code: String) {
        var requestMethod = BindingNetworkRequest().bindingAuthUserPhoneOrEmail
        var type = ""
        switch providerType {
        case .phone:
            type = "phone"
        case .email:
            type = "email"
        default:
            assert(false, "传输provider出错")
            break
        }
        requestMethod.urlPath = requestMethod.fullPathWith(replacers: [])
        requestMethod.parameter = [type: ac, "verifiable_code": code]
        RequestNetworkData.share.text(request: requestMethod) { (result) in
            self.bindingPhoneOrEmailView.submitBinding.isUserInteractionEnabled = true
            switch result {
            case .error(_):
                self.bindingPhoneOrEmailView.showCapatchaMsg(msg: "网络错误,请稍后再试")
            case .failure(let response):
                if let info = response.message {
                    self.bindingPhoneOrEmailView.showCapatchaMsg(msg: info)
                    return
                }
                self.bindingPhoneOrEmailView.showCapatchaMsg(msg: "网络错误,请稍后再试")
            case .success(_):
                var navHasSettingPwdBinding = false
                var managerVC: TSAccountManagementVC?
                for childVC in self.navigationController!.childViewControllers {
                    if let childVC = childVC as? TSBindingVC {
                        if childVC.isSettingPwdOrAccount == true {
                            // 如果导航栏内的子控制器拥有设置密码的"绑定视图控制器"
                            navHasSettingPwdBinding = true
                        }
                    }
                    if let manager = childVC as? TSAccountManagementVC {
                        managerVC = manager
                    }
                }
                if navHasSettingPwdBinding == true && managerVC != nil {
                    _ = self.navigationController?.popToViewController(managerVC!, animated: true)
                    return
                }
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func clickBinding(pwd: String, secondlyPwd: String) {
        var request = BindingNetworkRequest().updatePassword
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["password": pwd, "password_confirmation": secondlyPwd]
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(let error):
                if error == NetworkError.networkTimedOut {
                    self.settingPwdView.showCapatchaMsg(msg: "网络请求超时,请稍后再试")
                    return
                }
                self.settingPwdView.showCapatchaMsg(msg: "网络错误,请稍后再试")
            case .failure(let reponse):
                if let info = reponse.message {
                    self.settingPwdView.showCapatchaMsg(msg: info)
                    return
                }
                self.settingPwdView.showCapatchaMsg(msg: "网络错误,请稍后再试")
            case .success(_):
                TSCurrentUserInfo.share.userInfo?.isInitPwd = true
                /// 如果设置自动返回，完成后直接返回上一级页面
                if self.isAutoBack {
                    TSIndicatorWindowTop.showDefaultTime(state: .success, title: "设置成功")
                    TSUtil.popViewController(currentVC: self, animated: true)
                } else {
                    let vc = TSBindingVC(self.providerType, isSettingPwdOrAccount: false)
                    _ = self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

}
