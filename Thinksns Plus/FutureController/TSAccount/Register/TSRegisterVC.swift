//
//  TSRegisterVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/22.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  注册页面

import UIKit

class TSRegisterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labelForAccount: TSAccountLabel!
    @IBOutlet weak var indicatorForSecureTextEnty: TSIndicatorFlowerView!
    @IBOutlet weak var indicatorForRegister: TSIndicatorFlowerView!
    @IBOutlet weak var labelForPrompt: TSAccountMessagelabel!
    @IBOutlet weak var textFieldForAccount: TSAccountTextField!
    @IBOutlet weak var textFieldForPassword: TSAccountTextField!
    @IBOutlet weak var textFieldForCAPTCHA: TSAccountTextField!
    @IBOutlet weak var textFieldForUserName: TSAccountTextField!

    @IBOutlet weak var buttonForRegister: TSColorLumpButton!

    // 倒计时
    @IBOutlet weak var labelForCutDown: TSCutDownLabel!
    @IBOutlet weak var buttonForSendCAPTCHA: TSSendCAPTCHAButton!
    /// 显示用户协议按钮
    @IBOutlet weak var showTermsBtn: UIButton!

    // 输入框输入情况记录
    var accountsUsable: Dictionary<String, Bool> = ["account": false, "CAPTCHA": false, "userName": false, "password": false]
    /// 验证码渠道
    fileprivate var channel: TSAccountNetworkManager.CAPTCHAChannel = .phone
    /// 长度限定
    let AccountPhoneLen: Int = 11
    let AccountEmailMinLen: Int = 6
    let AccountEmailMaxLen: Int = 40
    let CapachaPhoneLen: Int = 6
    let CapachaEmailLen: Int = 6
    let PasswordMaxLen: Int = 16

    // 发送验证码按钮计时器
    var timer: Timer? = Timer()
    // 当前倒计时
    var cutDownNumber = 0
    // 总倒计时
    let cutDownNumberMax = 60

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.view.frame.size.height <= 480 {
            return
        }
        self.textFieldForUserName.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除检测输入框状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: Custom user interface
    func setUI() {
        // 便于二开修改协议名
        let agreementTitle = "显示_注册_协议提示".localized + String(format: "注册_协议名".localized, TSAppSettingInfoModel().appDisplayName)
        showTermsBtn.setTitle(agreementTitle, for: .normal)
        showTermsBtn.isHidden = !TSAppConfig.share.localInfo.registerShowTerms
        buttonForRegister.sizeType = .large
        switch TSAppConfig.share.localInfo.registerMethod {
        // 全渠道，优先显示手机
        case .all:
            title = "手机注册"
            // 右侧按钮
            let rightBtn = UIButton(type: .custom)
            rightBtn.bounds = CGRect(x: 0, y: 0, width: 70, height: 44)
            rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            rightBtn.contentHorizontalAlignment = .right
            rightBtn.setTitleColor(TSColor.main.theme, for: .normal)
            rightBtn.setTitle("邮箱", for: .normal)
            rightBtn.setTitle("手机", for: .selected)
            rightBtn.addTarget(self, action: #selector(channelBtnClick(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        // 仅仅邮箱注册
        case .mail:
            title = "邮箱注册"
            let btn = TSButton()
            btn.isSelected = false
            self.channelBtnClick(btn)
            self.navigationItem.rightBarButtonItem = nil
        // 仅仅手机号注册
        case .mobile:
            title = "手机注册"
            let btn = TSButton()
            btn.isSelected = true
            self.channelBtnClick(btn)
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    // MARK: IBActions

    /// 注册协议点击响应
    @IBAction func showTermsBtnClick(_ sender: UIButton) {
        let content: String = TSAppConfig.share.localInfo.content
        let markdownVC = TSMarkdownController(markdown: content)
        markdownVC.title = "注册协议"
        self.navigationController?.pushViewController(markdownVC, animated: true)
    }

    /// 注册渠道按钮点击响应
    @objc private func channelBtnClick(_ button: TSButton) -> Void {
        self.view.endEditing(true)
        button.isSelected = !button.isSelected
        if button.isSelected {
            // selected状态，邮箱找回
            title = "邮箱注册"
            labelForAccount.text = "邮箱"
            textFieldForAccount.keyboardType = .emailAddress
            textFieldForAccount.placeholder = "输入邮箱地址"
            channel = .email
        } else {
            // normal状态，手机找回
            title = "手机注册"
            labelForAccount.text = "手机号"
            textFieldForAccount.keyboardType = .phonePad
            textFieldForAccount.placeholder = "输入11位手机号"
            channel = .phone
        }
        // 清空输入框
        self.textFieldForAccount.text = ""
        self.textFieldForCAPTCHA.text = ""
        self.textFieldForPassword.text = ""
        self.textFieldForUserName.text = ""
        // 计时器处理
        self.stopTimer()
        // 验证码按钮重置不可点击
        self.buttonForSendCAPTCHA.isEnabled = false
        // 提示标签重置
        self.labelForPrompt.text = nil
    }

    /// 发送验证码按钮点击事件
    @IBAction func sendCAPTCHAButtonTaped() {
        guard let account = self.textFieldForAccount.text else {
            return
        }
        disabledCAPTCHAButton()
        TSAccountNetworkManager().sendCaptcha(channel: channel, type: .register, account: account) { (msg, status) in
            self.enabledCAPTCHAButton()
            guard status == true else {
                self.showPrompt(msg ?? errorNetworkInfo)
                return
            }
            // 发送验证码成功，则重置提示信息
            // (避免因已使用过的手机号 重新更换未使用的手机号发送验证码后 错误提示仍存在)
            self.showPrompt("")
            // 开启倒计时
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.timerFired), object: nil)
            self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
            if let timer = self.timer {
                RunLoop.main.add(timer, forMode: .commonModes)
            }
        }
    }

    func disabledCAPTCHAButton() {
        self.buttonForSendCAPTCHA.isHidden = true
        self.indicatorForSecureTextEnty.starAnimationForFlowerGrey()
    }

    func enabledCAPTCHAButton() {
        self.buttonForSendCAPTCHA.isHidden = false
        self.indicatorForSecureTextEnty.dismiss()
    }

    /// 注册按钮点击事件
    @IBAction func registerButtonTaped() {
        self.view.endEditing(true)
        if let userName = self.textFieldForUserName.text, let account = textFieldForAccount.text, let password = self.textFieldForPassword.text, let CAPTCHA = self.textFieldForCAPTCHA.text {
            // 检查格式
            if !checkFormat() {
                return
            }
            disabled()
            // 发起注册网络请求
            TSAccountNetworkManager().register(name: userName, account: account, password: password, captcha: CAPTCHA, channel: channel, complete: { (msg, status) in
                if status {
                    // 请求当前用户信息
                    self.requestCurrentUserInfo()
                    TSUserNetworkingManager.currentUserManagerInfo(complete: { (_, _) in
                    })
                } else {
                    self.enabled()
                    self.showPrompt(msg ?? errorNetworkInfo)
                }
            })
        }
    }

    /// 请求当前用户信息
    private func requestCurrentUserInfo() -> Void {
        TSUserNetworkingManager().getCurrentUserInfo(complete: { (userModel, msg, status) in
            if status, let userModel = userModel {
                // token中更新
                TSCurrentUserInfo.share.accountToken?.save()
                // 请求用户认证信息
                TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
                // 将当前用户信息存入数据库
                TSCurrentUserInfo.share.userInfo = userModel
                TSDatabaseManager().user.saveCurrentUser(userModel)
                // 环信登录
                if TSCurrentUserInfo.share.isLogin {
                    let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                    appDeleguate.getHyPassword()
                }
                // 注册推送别名
                let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                appDeleguate.registerJPushAlias()
                // 根据注册配置项 是否需要完善资料进行分别处理
                switch TSAppConfig.share.localInfo.registerFixed {
                case .need:
                    self.showLableVC()  // 跳转到标签选择页面
                case .noneed:
                    self.gotoTabbar()
                }

            } else {
                self.showPrompt(msg ?? errorNetworkInfo)
            }
        })
    }

    func enabled() {
        buttonForSendCAPTCHA.isEnabled = true
        buttonForRegister.isEnabled = true
        self.indicatorForRegister.dismiss()
    }

    func disabled() {
        buttonForSendCAPTCHA.isEnabled = false
        buttonForRegister.isEnabled = false
        self.indicatorForRegister.starAnimationForFlowerWhite()
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

    // MARK: Private
    /// 检测输入框的输入状态，判断注册按钮和发送验证码按钮的点击状态
    func textFiledDidChanged(notification: Notification) {
        if let textField = notification.object as? UITextField {
            // 输入框文字字数上限
            var stringCountLimit = 999
            // 输入框类型 key
            var stringType = ""
            switch textField {
            case self.textFieldForAccount:
                stringType = "account"; stringCountLimit = 11
                stringCountLimit = (self.channel == .phone) ? self.AccountPhoneLen : self.AccountEmailMaxLen
            case self.textFieldForCAPTCHA:
                stringType = "CAPTCHA"; stringCountLimit = 30
                stringCountLimit = (self.channel == .phone) ? self.CapachaPhoneLen : self.CapachaEmailLen
            case self.textFieldForUserName:
                stringType = "userName"
                TSAccountRegex.checkAndUplodTextField(textField: textField, byteLimit: 24)
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
                if stringType == "phone" {
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
                if stringType == "CAPTCHA", let captchaNumber = self.textFieldForCAPTCHA.text {
                    //判断输入框类型，更新输入框记录情况
                    self.accountsUsable.updateValue(TSAccountRegex.isCAPTCHAFormat(captchaNumber), forKey: stringType)
                }
            }
            updateRegisterButtonStatue()
        }
    }

    /// 更新注册按钮的状态
    private func updateRegisterButtonStatue() {
        self.buttonForRegister.isEnabled = true
        for (_, value) in self.accountsUsable {
            // 有输入框没有内容或者验证码长度检测不足3位时，注册按钮不可点击
            if !value {
                self.buttonForRegister.isEnabled = false
            }
        }
    }

    /// 提示用户信息
    private func showPrompt(_ message: String!) {
        self.labelForPrompt.text = message
    }

    /// 计时器启动
    func timerFired() {
        self.labelForCutDown.isHidden = false
        self.buttonForSendCAPTCHA.isHidden = true
        self.cutDownNumber += 1
        self.labelForCutDown.text = "\(self.cutDownNumberMax - self.cutDownNumber)s后重发"
        if self.cutDownNumber == self.cutDownNumberMax - 1 {
            stopTimer()
        }
    }

    /// 计时器停止
    func stopTimer() {
        self.labelForCutDown.isHidden = true
        self.buttonForSendCAPTCHA.isHidden = false
        self.buttonForSendCAPTCHA.isEnabled = true
        self.timer?.invalidate()
        self.timer = nil
        self.cutDownNumber = 0
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timerFired), object: nil)
    }

    /// 检查格式
    func checkFormat() -> Bool {
        var isFormatRight = true
        if let userName = self.textFieldForUserName.text, let account = self.textFieldForAccount.text, let password = self.textFieldForPassword.text, let CAPTCHA = self.textFieldForCAPTCHA.text {
            // 检查昵称
            if TSAccountRegex.countShortFor(userName: userName) || TSAccountRegex.countTooLongFor(userName: userName, count: 24) {
                self.showPrompt("提示信息_昵称长度错误".localized)
                isFormatRight = false
            } else if TSAccountRegex.isUserNameStartWithNumber(userName) {
                self.showPrompt("提示信息_昵称以数字开头".localized)
                isFormatRight = false
            } else if !TSAccountRegex.isUserNameFormat(userName) {
                self.showPrompt("提示信息_昵称含有不合法字符".localized)
                isFormatRight = false
            } else if !TSAccountRegex.isPhoneNnumberFormat(account) && channel == .phone {
                self.showPrompt("提示信息_手机号格式不正确".localized)
                isFormatRight = false
            } else if !TSAccountRegex.isEmailFormat(account) && channel == .email {
                self.showPrompt("提示信息_邮箱格式不正确".localized)
                isFormatRight = false
            } else if !TSAccountRegex.isCAPTCHAFormat(CAPTCHA) {
                self.showPrompt("提示信息_验证码格式不正确".localized)
                isFormatRight = false
            } else if !TSAccountRegex.countRigthFor(password: password) {
                self.showPrompt("提示信息_密码长度错误".localized)
                isFormatRight = false
            }
        }
        return isFormatRight
    }

    /// 跳转到标签选择页面
    func showLableVC() {
        let labelVC = TSUserLabelSetting(type: .register)
        self.navigationController?.pushViewController(labelVC, animated: true)
    }

    /// 注册时进入主页 —— 后台配置注册时完善资料为不需要强制完善时，不需要进入标签选择页面
    fileprivate func gotoTabbar() -> Void {
        // 注：需要判断当前导航控制器页(loginVC)是通过rootVC.present出来的，还是通过rootVC.change出来的
        if nil != self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
            // 发送游客注册通知 - tabbar中刷新数据
            NotificationCenter.default.post(name: NSNotification.Name.Visitor.login, object: nil)
        } else {
            TSRootViewController.share.show(childViewController: .tabbar)
        }
    }
}
