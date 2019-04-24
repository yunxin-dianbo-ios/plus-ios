//
//  TSHasAccountView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 已有账号

import UIKit

protocol TSHasAccountViewDelegate: NSObjectProtocol {
    /// 代理回调用户输入信息
    ///
    /// - Parameters:
    ///   - ac: 账号
    ///   - pw: 密码
    func binding(ac: String, pw: String)
}

/// 已有账号，对一下三方的绑定流程
/// - qq
/// - weibo
/// - wechat
class TSHasAccountView: UIView {
    var accountView: TSSectionNormal!
    var passwordView: TSSectionForPW!
    let msgLabel = TSAccountMessagelabel()

    let btnForLogin = TSColorLumpButton(type: .custom)

    var accountStr: String = ""
    var pwStr: String = ""
    weak var delegate: TSHasAccountViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        let accountView = TSSectionNormal(frame: CGRect.zero, labelText: "账号", userInputPlaceholder: "用户名/手机号/邮箱", lineIsHidden: false)
        self.accountView = accountView
        self.accountView.userInput.addTarget(self, action: #selector(getAccount(_:)), for: .allEditingEvents)

        let passwordView = TSSectionForPW(frame: CGRect.zero, labelText: "密码", userInputPlaceholder: "输入6位以上登录密码", lineIsHidden: true)
        self.passwordView = passwordView
        self.passwordView.userInput.addTarget(self, action: #selector(getPW(_:)), for: .allEditingEvents)

        btnForLogin.sizeType = .large
        btnForLogin.setTitle("确认绑定", for: .normal)
        btnForLogin.addTarget(self, action: #selector(loginBtnTaped), for: .touchUpInside)

        self.addSubview(accountView)
        self.addSubview(passwordView)
        self.addSubview(msgLabel)
        self.addSubview(btnForLogin)

        accountView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(54)
        }
        passwordView.snp.makeConstraints { (make) in
            make.top.equalTo(accountView.snp.bottom)
            make.height.left.right.equalTo(accountView)
        }
        msgLabel.snp.makeConstraints { (make) in
            make.top.equalTo(passwordView.snp.bottom).offset(20)
            make.left.equalTo(self).offset(15.5)
        }
        btnForLogin.snp.makeConstraints { (make) in
            make.top.equalTo(msgLabel.snp.bottom).offset(23)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(45)
        }
        btnForLogin.isEnabled = false
        msgLabel.isHidden = true
    }

    func getAccount(_ textField: UITextField) {
        accountStr = textField.text!
        loginBtnEnabled()
        msgLabel.isHidden = true
    }
    func getPW(_ textField: UITextField) {
        pwStr = textField.text!
        loginBtnEnabled()
        msgLabel.isHidden = true
    }

    func loginBtnEnabled() {
        guard accountStr != "" && pwStr != "" else {
            btnForLogin.isEnabled = false
            return
        }
        guard accountStr.first != " " || pwStr.first != " " else {
            btnForLogin.isEnabled = false
            return
        }
        btnForLogin.isEnabled = true
    }

    func loginBtnTaped() {
        self.btnForLogin.isUserInteractionEnabled = false
        self.delegate?.binding(ac: self.accountStr, pw: self.pwStr)
    }
}
