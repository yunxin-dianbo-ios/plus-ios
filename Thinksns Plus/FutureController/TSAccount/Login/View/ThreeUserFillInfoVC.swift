//
// Created by lip on 2017/9/20.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//
// 三方用户完善信息视图控制器

import Foundation

class ThreeUserFillInfoVC: UIViewController, TSHasAccountViewDelegate {
    var socialite: TSSocialite!
    weak var hasAccountView: TSHasAccountView!

    func binding(ac: String, pw: String) {
        BindingNetworkManager().accountPWBinding(provider: self.socialite.provider, token: self.socialite.token, account: ac, PW: pw) { (token, model, msg, status) in
            guard status else {
                self.hasAccountView.msgLabel.text = msg
                self.hasAccountView.msgLabel.isHidden = false
                self.hasAccountView.btnForLogin.isUserInteractionEnabled = true
                return
            }
            BindingNetworkManager().saveUserInfo(token: token!, model: model!, isRegister: false)
            if TSCurrentUserInfo.share.isLogin {
                let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                appDeleguate.getHyPassword()
            }
            if self.socialite.isLogin == false { // 游客进入该页面登录成功
                NotificationCenter.default.post(name: NSNotification.Name.Visitor.login, object: nil)
                self.dismiss(animated: true, completion: nil)
            } else {
                TSRootViewController.share.show(childViewController: .tabbar)
            }
            self.hasAccountView.btnForLogin.isUserInteractionEnabled = true
        }
    }
}
