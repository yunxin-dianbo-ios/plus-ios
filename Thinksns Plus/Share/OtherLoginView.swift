//
//  OtherLoginView.swift
//  date
//
//  Created by Fiction on 2017/8/7.
//  Copyright © 2017年 段泽里. All rights reserved.
//
//  三方登录框UI

import UIKit

class OtherLoginView: UIView {
    /// 标题
    let titleLabel: UILabel = UILabel()
    /// 左边线
    let leftSeparatorView = UIView()
    /// 右边线
    let rightSeparatorView = UIView()
    /// 按钮 - qq
    let qqItem: TSShareButton = TSShareButton(normalImage: #imageLiteral(resourceName: "IMG_login_qq.png"), title: "QQ")
    /// 按钮 - 微博
    let weiboItem: TSShareButton = TSShareButton(normalImage: #imageLiteral(resourceName: "IMG_login_weibo-.png"), title: "微博")
    /// 按钮 - 微信
    let weChatItem: TSShareButton = TSShareButton(normalImage: #imageLiteral(resourceName: "IMG_login_wechat.png"), title: "微信")
    /// 判断怎么布局需要的array
    var layoutArray: Array<TSShareButton> = []
    weak var pushVC: TSLoginVC!

    init(frame: CGRect, VC: TSLoginVC) {
        super.init(frame: frame)
        self.pushVC = VC
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        titleLabel.text = "社交账号登录"
        titleLabel.textColor = TSColor.normal.disabled
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.comment.rawValue)
        leftSeparatorView.backgroundColor = TSColor.normal.disabled
        rightSeparatorView.backgroundColor = TSColor.normal.disabled

        qqItem.addTarget(self, action: #selector(loginForQQ), for: .touchUpInside)
        weiboItem.addTarget(self, action: #selector(loginForWeiBo), for: .touchUpInside)
        weChatItem.addTarget(self, action: #selector(loginForWeChat), for: .touchUpInside)

        self.addSubview(titleLabel)
        self.addSubview(leftSeparatorView)
        self.addSubview(rightSeparatorView)
        self.addSubview(qqItem)
        self.addSubview(weiboItem)
        self.addSubview(weChatItem)

        layoutArray = [qqItem, weiboItem, weChatItem]

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
        }
        leftSeparatorView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(self).offset(41.5)
            make.right.equalTo(titleLabel.snp.left).offset(-10)
            make.height.equalTo(0.5)
        }
        rightSeparatorView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.right.equalTo(self).offset(-41.5)
            make.height.equalTo(0.5)
        }

        self.setLayoutHaveThreeItmes()
    }

    /// 布局有三个按钮的时候
    func setLayoutHaveThreeItmes() {
        qqItem.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(41.5)
            make.bottom.equalTo(self)
            make.width.equalTo(40)
            make.height.equalTo(62)
        }
        weiboItem.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.width.height.equalTo(qqItem)
        }
        weChatItem.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-41.5)
            make.bottom.width.height.equalTo(qqItem)
        }
    }

    // MARK: - 按钮方法
    func loginForQQ() {
        TSTripartiteAuthorizationManager().qqForAuthorization { (name, token, status) in
            guard status else {
                return
            }
            self.isSocialited(provider: .qq, token: token!, name: name!)
        }
    }

    func loginForWeiBo() {
        TSTripartiteAuthorizationManager().weiboForAuthorization { (name, token, status) in
            guard status else {
                return
            }
            self.isSocialited(provider: .weibo, token: token!, name: name!)
        }
    }

    func loginForWeChat() {
        TSTripartiteAuthorizationManager().weichatForAuthorization { (name, token, status) in
            guard status else {
                return
            }
            self.isSocialited(provider: .wechat, token: token!, name: name!)
        }
    }

    /// - 未绑定，走三方注册
    func pushOtherRegisteredVC(provider: ProviderType, asscesToken: String, name: String) -> Void {
        let vc = TSOtherRegisteredVC(socialite: TSSocialite(provider: provider, token: asscesToken, name: name, isLogin: self.pushVC.isHiddenDismissButton!))
        pushVC.navigationController?.pushViewController(vc, animated: true)
    }

    /// - 判断是否已经绑定
    func isSocialited(provider: ProviderType, token: String, name: String) {
        BindingNetworkManager().isSocialited(provider: provider, token: token) { (userToken, model, _, status) in
            guard status else {
                self.pushOtherRegisteredVC(provider: provider, asscesToken: token, name: name)
                return
            }
            BindingNetworkManager().saveUserInfo(token: userToken!, model: model!, isRegister: false)
            if self.pushVC.isHiddenDismissButton! == false { // 游客进入该页面登录成功
                NotificationCenter.default.post(name: NSNotification.Name.Visitor.login, object: nil)
                self.pushVC.dismiss(animated: true, completion: nil)
            } else {
                TSRootViewController.share.show(childViewController: .tabbar)
            }
        }
    }
}
