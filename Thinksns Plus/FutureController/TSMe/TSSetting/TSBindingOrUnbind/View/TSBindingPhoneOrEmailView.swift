//
//  TSBindingPhoneOrEmailView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  绑定当前用户手机号或者邮箱

import UIKit
import SnapKit

protocol TSBindingPhoneOrEmailViewDeleagte: NSObjectProtocol {
    /// 点击绑定
    ///
    /// - Parameters:
    ///   - ac: 用户输入的phone或者email
    ///   - code: 验证码
    func clickBinding(ac: String, code: String)
    func clickBinding(pwd: String, secondlyPwd: String)
}

class TSBindingSetPwdView: UIView {
    /// 密码输入框
    var passwordView: TSSectionForPW!
    var secondlyPwdView: TSSectionForPW!

    /// 服务器提示信息显示
    let msgLabel = TSAccountMessagelabel()
    /// 确定按钮
    let submitBinding = TSColorLumpButton(type: .custom)
    // 代理
    weak var deleate: TSBindingPhoneOrEmailViewDeleagte?
    let provider: ProviderType

    init(frame: CGRect, provider: ProviderType) {
        self.provider = provider
        super.init(frame: frame)
        setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        let passwordView = TSSectionForPW(frame: CGRect.zero, labelText: "设置密码", userInputPlaceholder: "输入6位以上登录密码", lineIsHidden: true)
        self.passwordView = passwordView
        self.passwordView.userInput.addTarget(self, action: #selector(getPW(_:)), for: .editingChanged)

        let secondlyPwdView = TSSectionForPW(frame: CGRect.zero, labelText: "重复密码", userInputPlaceholder: "输入6位以上登录密码", lineIsHidden: true)
        self.secondlyPwdView = secondlyPwdView
        self.secondlyPwdView.userInput.addTarget(self, action: #selector(getPW(_:)), for: .editingChanged)

        submitBinding.sizeType = .large
        submitBinding.setTitle("下一步", for: .normal)
        submitBinding.addTarget(self, action: #selector(submitBtnTaped), for: .touchUpInside)

        self.addSubview(passwordView)
        self.addSubview(secondlyPwdView)
        self.addSubview(msgLabel)
        self.addSubview(submitBinding)
        // 布局
        passwordView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(54)
        }
        secondlyPwdView.snp.makeConstraints { (make) in
            make.top.equalTo(passwordView.snp.bottom)
            make.height.left.right.equalTo(passwordView)
        }
        msgLabel.snp.makeConstraints { (make) in
            make.top.equalTo(secondlyPwdView.snp.bottom).offset(20)
            make.left.equalTo(self).offset(15.5)
        }
        submitBinding.snp.makeConstraints { (make) in
            make.top.equalTo(msgLabel.snp.bottom).offset(23)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(45)
        }
        submitBinding.isEnabled = false
        msgLabel.isHidden = true
    }

    // MARK: - 获得用户输入
    func getPW(_ textField: UITextField) {
        submitBinding.isUserInteractionEnabled = true
        TextFieldHelper.limitTextField(textField, withMaxLen: 16)
        if let pwdStr = passwordView.userInput.text, let secondlyPwdStr = secondlyPwdView.userInput.text {
            submitBinding.isEnabled = !pwdStr.count.isEqualZero && !secondlyPwdStr.count.isEqualZero
            return
        }
        submitBinding.isEnabled = false
        msgLabel.isHidden = true
    }

    // MARK: - 提交按钮方法
    func submitBtnTaped() {
        guard let pwdStr = passwordView.userInput.text, let secondlyPwdStr = secondlyPwdView.userInput.text else {
            return
        }
        if !TSAccountRegex.countRigthFor(password: pwdStr) {
            showCapatchaMsg(msg: "提示信息_密码长度错误".localized)
            return
        } else if !TSAccountRegex.countRigthFor(password: secondlyPwdStr) {
            showCapatchaMsg(msg: "提示信息_密码长度错误".localized)
            return
        }
        submitBinding.isUserInteractionEnabled = false
        self.deleate?.clickBinding(pwd: pwdStr, secondlyPwd: secondlyPwdStr)
    }

    // MARK: - 回调显示服务器信息
    func showCapatchaMsg(msg: String) {
        self.msgLabel.text = msg
        self.msgLabel.isHidden = false
        submitBinding.isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(false)
    }
}

///  绑定当前用户手机号或者邮箱
class TSBindingPhoneOrEmailView: UIView, TSSectionForCapatchaDelegate {
    /// 比如【绑定邮箱 - UI】
    /// - 输入邮箱cell
    var emailCellView: TSSectionForCAPATCHA!
    /// 比如【绑定邮箱 - UI】
    /// - 输入验证码cell
    var capatchaCellView: TSSectionNormal!

    /// 服务器提示信息显示
    let msgLabel = TSAccountMessagelabel()
    /// 确定按钮
    let submitBinding = TSColorLumpButton(type: .custom)

    /// 构造emailCellView - leftlabel
    var labelStr = ""
    /// 构造emailCellView - userinput.placeholder
    var labelPlaceholder = ""
    /// 验证码渠道，详情见TSSectionForCAPATCHA第173行
    var channel: TSAccountNetworkManager.CAPTCHAChannel = .phone
    // 代理
    weak var deleate: TSBindingPhoneOrEmailViewDeleagte?
    var provider: ProviderType

    /// 构造方法
    /// - 根据provider作出对emailCellView的改变
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
        let emailCellView = TSSectionForCAPATCHA(frame: CGRect.zero, labelText: labelStr, userInputPlaceholder: labelPlaceholder, lineIsHidden: false, theType: .register, theChannel: channel)
        emailCellView.delegate = self
        self.emailCellView = emailCellView
        self.emailCellView.userInput.addTarget(self, action: #selector(getAC(_:)), for: .editingChanged)

        let capatchaCellView = TSSectionNormal(frame: CGRect.zero, labelText: "验证码", userInputPlaceholder: "请输入验证码", lineIsHidden: true)
        self.capatchaCellView = capatchaCellView
        self.capatchaCellView.userInput.addTarget(self, action: #selector(getCAPATCHA(_:)), for: .editingChanged)

        submitBinding.sizeType = .large
        submitBinding.setTitle("确认", for: .normal)
        submitBinding.addTarget(self, action: #selector(submitBtnTaped), for: .touchUpInside)

        self.addSubview(emailCellView)
        self.addSubview(capatchaCellView)
        self.addSubview(msgLabel)
        self.addSubview(submitBinding)

        emailCellView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(54)
        }
        capatchaCellView.snp.makeConstraints { (make) in
            make.top.equalTo(emailCellView.snp.bottom)
            make.height.left.right.equalTo(emailCellView)
        }
        msgLabel.snp.makeConstraints { (make) in
            make.top.equalTo(capatchaCellView.snp.bottom).offset(20)
            make.left.equalTo(self).offset(15.5)
        }
        submitBinding.snp.makeConstraints { (make) in
            make.top.equalTo(msgLabel.snp.bottom).offset(23)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(45)
        }
        submitBinding.isEnabled = false
        msgLabel.isHidden = true
        // 手机号和邮箱的键盘输入限定
        switch self.provider {
        case .phone:
            emailCellView.userInput.keyboardType = .phonePad
        case .email:
            emailCellView.userInput.keyboardType = .emailAddress
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
            self.emailCellView.timeBtn.isEnabled = TSAccountRegex.isPhoneNnumberFormat(textField.text!)
        case .email:
            TextFieldHelper.limitTextField(textField, withMaxLen: 99)
            self.emailCellView.timeBtn.isEnabled = TSAccountRegex.isEmailFormat(textField.text!)
        }
        submitBtnEnabled()
    }

    func getCAPATCHA(_ textField: UITextField) {
        submitBtnEnabled()
    }

    /// 判断用户输入
    func submitBtnEnabled() {
        submitBinding.isUserInteractionEnabled = true
        if let account = emailCellView.userInput.text, let capatcha = capatchaCellView.userInput.text {
            submitBinding.isEnabled = !account.count.isEqualZero && !capatcha.count.isEqualZero
            return
        }
        submitBinding.isEnabled = false
        msgLabel.isHidden = true
    }

    // MARK: - 提交按钮方法
    func submitBtnTaped() {
        guard let account = emailCellView.userInput.text, let capatcha = capatchaCellView.userInput.text else {
            return
        }
        if !TSAccountRegex.isPhoneNnumberFormat(account) && provider == .phone {
            self.showCapatchaMsg(msg: "提示信息_手机号格式不正确".localized)
            return
        } else if !TSAccountRegex.isEmailFormat(account) && provider == .email {
            self.showCapatchaMsg(msg: "提示信息_邮箱格式不正确".localized)
            return
        } else if !TSAccountRegex.isCAPTCHAFormat(capatcha) {
            self.showCapatchaMsg(msg: "提示信息_验证码格式不正确".localized)
            return
        }
        submitBinding.isUserInteractionEnabled = false
        self.deleate?.clickBinding(ac: account, code: capatcha)
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
