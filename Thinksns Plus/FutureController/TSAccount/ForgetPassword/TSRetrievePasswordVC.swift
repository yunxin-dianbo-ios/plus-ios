//
//  TSRetrievePasswordVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  找回密码

import UIKit

class TSRetrievePasswordVC: UIViewController {

    @IBOutlet weak var accountLabel: TSAccountLabel!
    @IBOutlet weak var indicatorViewForSubmit: TSIndicatorFlowerView!
    @IBOutlet weak var indicatorForSecureTextEntry: TSIndicatorFlowerView!
    @IBOutlet weak var labelForPrompt: TSAccountMessagelabel!

    @IBOutlet weak var textFieldForAccount: TSAccountTextField!
    @IBOutlet weak var textFieldForCAPTCHA: TSAccountTextField!
    @IBOutlet weak var textFieldForPassword: TSAccountTextField!

    @IBOutlet weak var buttonForSubmit: TSColorLumpButton!

    // 倒计时
    @IBOutlet weak var buttonForSendCAPTCHA: TSSendCAPTCHAButton!
    @IBOutlet weak var labelForCutDown: TSCutDownLabel!

    // 输入框输入情况记录
    var accountsUsable: Dictionary<String, Bool> = ["account": false, "CAPTCHA": false, "password": false]

    // 发送验证码按钮计时器
    var timer: Timer? = Timer()
    // 当前倒计时
    var cutDownNumber = 0
    // 总倒计时
    let cutDownNumberMax = 60
    /// 验证码渠道
    fileprivate var channel: TSAccountNetworkManager.CAPTCHAChannel = .phone
    /// 长度限定
    let AccountPhoneLen: Int = 11
    let AccountEmailMinLen: Int = 6
    let AccountEmailMaxLen: Int = 40
    let CapachaPhoneLen: Int = 6
    let CapachaEmailLen: Int = 6
    let PasswordMinLen: Int = 6
    let PasswordMaxLen: Int = 16

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    deinit {
        self.stopTimer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textFieldForAccount.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除检测输入框状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Custom user interface
    func setUI() {
        self.title = "找回密码"
        self.buttonForSubmit.sizeType = .large
        // 右侧按钮
        let rightBtn = UIButton(type: .custom)
        rightBtn.bounds = CGRect(x: 0, y: 0, width: 70, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightBtn.contentHorizontalAlignment = .right
        rightBtn.setTitleColor(TSColor.main.theme, for: .normal)
        rightBtn.setTitle("邮箱找回", for: .normal)
        rightBtn.setTitle("手机找回", for: .selected)
        rightBtn.addTarget(self, action: #selector(channelBtnClick(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }

    // MARK: IBAction
    /// 发送验证码按钮点击事件
    @IBAction func sendCAPTCHAButtonTaped() {
        guard let phoneNumber = self.textFieldForAccount.text else {
            return
        }
        // 发送验证码网络请求
        disabledCAPTCHAButton()
        TSAccountNetworkManager().sendCaptcha(channel: self.channel, type: .change, account: phoneNumber) { (msg, status) in
            self.enabledCAPTCHAButton()
            guard status == true else {
                self.showPrompt(msg)
                return
            }
            self.showPrompt("验证码发送成功")
            // 开启倒计时
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.timerFired), object: nil)
            self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
            if let timer = self.timer {
                RunLoop.main.add(timer, forMode: .commonModes)
            }
        }
    }

    func enabledCAPTCHAButton() {
        self.buttonForSendCAPTCHA.isHidden = false
        self.indicatorForSecureTextEntry.dismiss()
    }

    func disabledCAPTCHAButton() {
        self.buttonForSendCAPTCHA.isHidden = true
        self.indicatorForSecureTextEntry.starAnimationForFlowerGrey()
    }

    /// 提交按钮点击事件
    @IBAction func submitButtonTaped() {
        guard let account = self.textFieldForAccount.text, let captcha = self.textFieldForCAPTCHA.text, let password = self.textFieldForPassword.text else {
            return
        }
        // 账号检查
        switch self.channel {
        case .phone:
            if !TSAccountRegex.isPhoneNnumberFormat(account) {
                self.showPrompt("提示信息_手机号格式不正确".localized)
                return
            }
        case .email:
            if !TSAccountRegex.isEmailFormat(account) {
                self.showPrompt("提示信息_邮箱格式不正确".localized)
                return
            }
        }
        // 检查验证码
        if !TSAccountRegex.isCAPTCHAFormat(captcha) {
            self.showPrompt("提示信息_验证码格式不正确".localized)
            return
        }
        // 检查密码
        if !TSAccountRegex.countRigthFor(password: password) {
            self.showPrompt("提示信息_密码长度错误".localized)
            return
        }
        disabled()
        // 发送找回密码网络请求
        TSAccountNetworkManager().retrievePassword(account: account, password: password, captcha: captcha, channel: self.channel, complete: { (msg, status) in
            self.enabled()
            if status {
                self.showPrompt("修改密码成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    if let navigationController = self.navigationController {
                        navigationController.popViewController(animated: true)
                    }
                })
            } else {
                self.showPrompt(msg ?? errorNetworkInfo)
            }
        })
    }

    func enabled() {
        buttonForSendCAPTCHA.isEnabled = true
        buttonForSubmit.isEnabled = true
        self.indicatorViewForSubmit.dismiss()
    }

    func disabled() {
        buttonForSendCAPTCHA.isEnabled = false
        buttonForSubmit.isEnabled = false
        self.indicatorViewForSubmit.starAnimationForFlowerWhite()
    }

    /// 切换密码模式按钮点击事件
    @IBAction func secureTextEntryButtonTaped(_ sender: UIButton) {
        textFieldForPassword.isSecureTextEntry = !textFieldForPassword.isSecureTextEntry
        var imageName = ""
        switch textFieldForPassword.isSecureTextEntry {
        case true:
            imageName = "IMG_ico_closeeye"
        case false:
            imageName = "IMG_ico_openeye"
        }
        sender.setImage(UIImage(named: imageName), for: .normal)
    }

    /// 找回密码渠道按钮点击响应
    @objc private func channelBtnClick(_ button: TSButton) -> Void {
        self.view.endEditing(true)
        button.isSelected = !button.isSelected
        if button.isSelected {
            // selected状态，邮箱找回
            self.accountLabel.text = "邮箱"
            self.textFieldForAccount.keyboardType = .emailAddress
            self.textFieldForAccount.placeholder = "输入邮箱地址"
            self.channel = .email
        } else {
            // normal状态，手机找回
            self.accountLabel.text = "手机号"
            self.textFieldForAccount.keyboardType = .phonePad
            self.textFieldForAccount.placeholder = "请输入11位手机号"
            self.channel = .phone
        }
        // 清空输入框
        self.textFieldForAccount.text = ""
        self.textFieldForCAPTCHA.text = ""
        self.textFieldForPassword.text = ""
        // 计时器处理
        self.stopTimer()
        // 验证码按钮重置不可点击
        self.buttonForSendCAPTCHA.isEnabled = false
    }

    // MARK: Private
    /// 检测输入框的输入状态，判断注册按钮和发送验证码按钮的点击状态
    func textFiledDidChanged(notification: Notification) {
        if  let textField = notification.object as? UITextField {
            // 输入框文字字数上限
            var stringCountLimit = 999
            // 输入框类型 key
            var stringType = ""
            switch textField {
            case self.textFieldForAccount:
                stringType = "account"
                stringCountLimit = (self.channel == .phone) ? self.AccountPhoneLen : self.AccountEmailMaxLen
            case self.textFieldForCAPTCHA:
                stringType = "CAPTCHA"
                stringCountLimit = (self.channel == .phone) ? self.CapachaPhoneLen : self.CapachaEmailLen
            case self.textFieldForPassword:
                stringType = "password"
                stringCountLimit = self.PasswordMaxLen
            default:
                return
            }
            if textField.text == nil || textField.text == "" {
                // 更新输入框状态
                self.accountsUsable.updateValue(false, forKey: stringType)
                // 更新验证码按钮状态
                if stringType == "account" {
                    self.buttonForSendCAPTCHA.isEnabled = false
                }
            } else {
                self.accountsUsable.updateValue(true, forKey: stringType)
                TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
                // 刷新发送验证码按钮状态
                if stringType == "account", let text = self.textFieldForAccount.text {
                    switch self.channel {
                    case .phone:
                        self.buttonForSendCAPTCHA.isEnabled = TSAccountRegex.isPhoneNnumberFormat(text)
                    case .email:
                        self.buttonForSendCAPTCHA.isEnabled = TSAccountRegex.isEmailFormat(text)
                    }
                }
            }
            updateRegisterButtonStatue()
        }
    }

    /// 更新注册按钮的状态
    func updateRegisterButtonStatue() {
        self.buttonForSubmit.isEnabled = true
        for (key, value) in self.accountsUsable {
            // 有输入框没有内容时，注册按钮不可点击
            if !value {
                TSLogCenter.log.debug(key + " 不合法")
                self.buttonForSubmit.isEnabled = false
            }
        }
    }

    /// 提示用户信息
    func showPrompt(_ message: String!) {
        self.labelForPrompt.text = message
    }

    /// 计时器启动
    func timerFired() {
        self.buttonForSendCAPTCHA.isHidden = true
        self.labelForCutDown.isHidden = false
        self.cutDownNumber += 1
        self.labelForCutDown.text = "\(self.cutDownNumberMax - self.cutDownNumber)s"
        if self.cutDownNumber == self.cutDownNumberMax - 1 {
            self.stopTimer()
        }
    }
    /// 停止定时器
    private func stopTimer() -> Void {
        self.labelForCutDown.isHidden = true
        self.buttonForSendCAPTCHA.isHidden = false
        self.buttonForSendCAPTCHA.isEnabled = true
        self.timer?.invalidate()
        self.timer = nil
        self.cutDownNumber = 0
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timerFired), object: nil)
    }

}
