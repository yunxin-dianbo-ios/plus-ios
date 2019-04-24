//
//  TSUnbindPhoneOrEmailView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  解除当前用户手机号或者邮箱绑定

import UIKit

protocol TSUnbindPhoneOrEmailViewDeleagte: NSObjectProtocol {
    /// 点击解绑方法回调
    ///
    /// - Parameters:
    ///   - pw: 用户密码
    ///   - code: 验证码
    func clickUnbind(pw: String, code: String)
}

class TSUnbindPhoneOrEmailView: UIView, TSSectionForCapatchaDelegate {
    /// 比如解除绑定【phone - UI】
    /// - 输入手机号cell
    var phoneCellView: TSSectionForCAPATCHA!
    /// 比如解除绑定【phone - UI】
    /// - 输入验证码cell
    var capatchaCellView: TSSectionNormal!
    /// 比如解除绑定【phone - UI】
    /// - 输入密码cell
    var passwordCellView: TSSectionForPW!

    /// 服务器提示信息显示
    let msgLabel = TSAccountMessagelabel()
    /// 确定按钮
    let btnForLogin = TSColorLumpButton(type: .custom)

    /// 获得phoneCellView - userinput.text
    var accountStr: String = ""
    /// 获得capatchaCellView - userinput.text
    var capatchaStr: String = ""
    /// 获得passwordCellView - userinput.text
    var passwordStr: String = ""

    /// 构造phoneCellView - leftlabel
    var labelStr = ""
    /// 构造phoneCellView - userinput.placeholder
    var labelPlaceholder = ""
    /// 验证码渠道，详情见TSSectionForCAPATCHA第173行
    var channel: TSAccountNetworkManager.CAPTCHAChannel = .phone
    var provider: ProviderType

    weak var delegate: TSUnbindPhoneOrEmailViewDeleagte?

    /// 构造方法
    /// - 根据provider作出对phoneCellView的改变
    /// - 根据provider做出是否对channel改变
    ///
    /// - Parameters:
    ///   - frame: 页面大小
    ///   - provider: phoneOrEmail
    init(frame: CGRect, provider: ProviderType) {
        self.provider = provider
        super.init(frame: frame)
        switch provider {
        case .phone:
            labelStr = "手机号"
            labelPlaceholder = "请输入电话号码"
            break
        case .email:
            labelStr = "邮箱"
            labelPlaceholder = "请输入邮箱"
            channel = .email
            break
        default:
            break
        }
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {

        let phoneCellView = TSSectionForCAPATCHA(frame: CGRect.zero, labelText: labelStr, userInputPlaceholder: labelPlaceholder, lineIsHidden: false, theType: .change, theChannel: channel)
        phoneCellView.delegate = self
        self.phoneCellView = phoneCellView
        self.phoneCellView.userInput.addTarget(self, action: #selector(getAC(_:)), for: .allEditingEvents)

        if provider == .phone {
            if let account = TSCurrentUserInfo.share.userInfo?.phone {
                phoneCellView.userInput.text = account
                phoneCellView.timeBtn.isEnabled = TSAccountRegex.isPhoneNnumberFormat(account)
            }
        } else if provider == .email {
            if let account = TSCurrentUserInfo.share.userInfo?.email {
                phoneCellView.userInput.text = account
                phoneCellView.timeBtn.isEnabled = TSAccountRegex.isEmailFormat(account)
            }
        }
        let capatchaCellView = TSSectionNormal(frame: CGRect.zero, labelText: "验证码", userInputPlaceholder: "请输入验证码", lineIsHidden: false)
        self.capatchaCellView = capatchaCellView
        self.capatchaCellView.userInput.addTarget(self, action: #selector(getCAPATCHA(_:)), for: .allEditingEvents)

        let passwordCellView = TSSectionForPW(frame: CGRect.zero, labelText: "密码", userInputPlaceholder: "请输入登录密码", lineIsHidden: true)
        self.passwordCellView = passwordCellView
        self.passwordCellView.userInput.addTarget(self, action: #selector(getPW(_:)), for: .allEditingEvents)

        btnForLogin.sizeType = .large
        btnForLogin.setTitle("解除绑定", for: .normal)
        btnForLogin.addTarget(self, action: #selector(submitBtnTaped), for: .touchUpInside)

        self.addSubview(phoneCellView)
        self.addSubview(capatchaCellView)
        self.addSubview(passwordCellView)
        self.addSubview(msgLabel)
        self.addSubview(btnForLogin)

        phoneCellView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(54)
        }
        capatchaCellView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneCellView.snp.bottom)
            make.height.left.right.equalTo(phoneCellView)
        }
        passwordCellView.snp.makeConstraints { (make) in
            make.top.equalTo(capatchaCellView.snp.bottom)
            make.height.left.right.equalTo(phoneCellView)
        }
        msgLabel.snp.makeConstraints { (make) in
            make.top.equalTo(passwordCellView.snp.bottom).offset(20)
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

        // 手机号和邮箱的键盘输入限定
        switch self.provider {
        case .phone:
            phoneCellView.userInput.keyboardType = .phonePad
        case .email:
            phoneCellView.userInput.keyboardType = .emailAddress
        default:
            break
        }
    }

    // MARK: - 获得用户输入
    func getAC(_ textField: UITextField) {
        if nil == textField.text {
            return
        }
        switch self.channel {
        case .phone:
            TextFieldHelper.limitTextField(textField, withMaxLen: 11)
            self.phoneCellView.timeBtn.isEnabled = TSAccountRegex.isPhoneNnumberFormat(textField.text!)
        case .email:
            TextFieldHelper.limitTextField(textField, withMaxLen: 99)
            self.phoneCellView.timeBtn.isEnabled = TSAccountRegex.isEmailFormat(textField.text!)
        }
        accountStr = textField.text!
        submitBtnEnabled()
        msgLabel.isHidden = true
    }

    func getCAPATCHA(_ textField: UITextField) {
        capatchaStr = textField.text!
        submitBtnEnabled()
        msgLabel.isHidden = true
    }

    func getPW(_ textField: UITextField) {
        passwordStr = textField.text!
        submitBtnEnabled()
        msgLabel.isHidden = true
    }

    /// 判断用户输入
    func submitBtnEnabled() {
        // 注：采用accountStr、capatchaStr、passwordStr进行的判空处理，但这样会有问题：解绑时默认有账号，但不点击账号那里，就不会触发getAC操作，则不会对accountStr进行赋值处理。
        // 解决方案：1.这里赋值；2.默认账号填写时顺便对accountStr进行赋值；3.不使用xxxStr，而使用xxxField.text代替
        accountStr = self.phoneCellView.userInput.text!
        capatchaStr = self.capatchaCellView.userInput.text!
        passwordStr = self.passwordCellView.userInput.text!
        guard accountStr != "" && capatchaStr != "" && passwordStr != "" else {
            btnForLogin.isEnabled = false
            return
        }
        guard accountStr.first != " " || capatchaStr.first != " " || passwordStr.first != " " else {
            btnForLogin.isEnabled = false
            return
        }
        btnForLogin.isEnabled = true
    }

    // MARK: - 提交按钮方法
    func submitBtnTaped() {
        let pw = passwordStr
        let code = capatchaStr
        self.delegate?.clickUnbind(pw: pw, code: code)
        btnForLogin.isUserInteractionEnabled = false
    }

    // MARK: - 回调显示服务器信息
    func showCapatchaMsg(msg: String) {
        self.msgLabel.text = msg
        self.msgLabel.isHidden = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(false)
    }
}
