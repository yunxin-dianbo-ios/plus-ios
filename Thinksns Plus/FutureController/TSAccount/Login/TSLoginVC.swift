//
//  TSLoginVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  登录界面
//  说明：当前页面含原密码登录的业务逻辑和新添加的短信验证码登录业务逻辑
//  1、页面布局在xib中，默认SMSLoginView是隐藏的
//  2、短信登录隐式注册流程：
//  2.1 如果手机为未注册号码-> 产生一个“用户+6位随机” -> 接口验证是否存在 -> 调用注册API

import UIKit

class TSLoginVC: UIViewController, didSelectShowsSearchResultsCellDelegate {
    @IBOutlet weak var indicatorViewForLogin: TSIndicatorFlowerView!
    @IBOutlet weak var labelForPrompt: TSAccountMessagelabel!
    @IBOutlet weak var textFieldForPassword: TSAccountTextField!
    @IBOutlet weak var textFieldForPhone: TSAccountTextField!
    @IBOutlet weak var buttonForSecureTextEntry: UIButton!
    @IBOutlet weak var buttonForPushToRetrievePassword: UIButton!
    @IBOutlet weak var buttonForLogin: TSColorLumpButton!
    @IBOutlet weak var guestLoginButton: UIButton!
    var isHiddenGuestLoginButton: Bool?
    var isHiddenDismissButton: Bool?
    var isPhoneRegister = false

    /// 是否是短信快速登录, 默认不是
    private var isSMSLogin = false {
        didSet {
            /// 情况已经输入的数据
            showsSearchResults.isHidden = true
            textFieldForPhone.text = ""
            textFieldForPassword.text = ""
            phoneTF.text = ""
            codeTF.text = ""
            /// 切换时清空提示
            self.showPrompt("")

            if isSMSLogin {
                title = "一键登录"
                SMSLoginView.isHidden = false
                namePhoneLoginView.isHidden = true
                switchLoginTypeBtn.setTitle("使用账号密码登录", for: .normal)
            } else {
                title = "登录"
                SMSLoginView.isHidden = true
                namePhoneLoginView.isHidden = false
                switchLoginTypeBtn.setTitle("使用手机号一键登录", for: .normal)

            }
        }
    }
    /// 帐号密码登录View
    @IBOutlet weak var namePhoneLoginView: UIView!
    /// 短信登录View
    @IBOutlet weak var SMSLoginView: UIView!
    @IBOutlet weak var switchLoginTypeBtn: UIButton!
    @IBOutlet weak var phoneTF: TSAccountTextField!
    @IBOutlet weak var codeTF: TSAccountTextField!
    // 倒计时
    @IBOutlet weak var buttonForSendCAPTCHA: TSSendCAPTCHAButton!
    @IBOutlet weak var labelForCutDown: TSCutDownLabel!
    // 发送验证码按钮计时器
    var timer: Timer? = Timer()
    // 当前倒计时
    var cutDownNumber = 0
    // 总倒计时
    let cutDownNumberMax = 60

    let buttonForPushToRegisterVC = TSTextButton.initWith(putAreaType: .top)

    /// 输入框输入情况记录
    /// - 有值为 true, 反之为 false
    var accountUsable = ["phone": false, "password": false]

    /// 模糊查询视图
    let  showsSearchResults: TSAccountCellShowsSearchResults = TSAccountCellShowsSearchResults(frame: CGRect.zero, style: .plain)

    // MARK: Lifecycle
    convenience init(isHiddenDismissButton: Bool, isHiddenGuestLoginButton: Bool) {
        self.init(nibName: "TSLoginVC", bundle: nil)
        self.isHiddenGuestLoginButton = isHiddenGuestLoginButton
        self.isHiddenDismissButton = isHiddenDismissButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SMSLoginView.isHidden = !isSMSLogin
        namePhoneLoginView.isHidden = isSMSLogin

        setupUI()
        setNavigationBar()
        showsSearchResults.didSelectShowsSearchResultsCellDelegate = self
        showsSearchResults.backgroundColor = UIColor.clear
        self.view.addSubview(showsSearchResults)
        showsSearchResults.isHidden = true
        showsSearchResults.snp.makeConstraints { (make) in
            make.top.equalTo(textFieldForPhone.snp.bottom).offset(14)
            make.left.right.equalTo(self.view)
            make.height.equalTo(120)
        }
        switchLoginTypeBtn.setTitleColor(TSColor.main.theme, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        showsSearchResults.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除检测输入框状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    // MARK: Custom user interface
    func setNavigationBar() {
        // debug模式下切换服务器
        #if DEBUG
        let leftItem = UIBarButtonItem(title: "切换服务器", style: .done, target: self, action: #selector(pushServiceSwitchVC))
        self.navigationItem.leftBarButtonItem = leftItem
        #else
        // 不添加
        #endif
        let frameView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        buttonForPushToRegisterVC.setTitle("注册", for: .normal)
        buttonForPushToRegisterVC.addTarget(self, action: #selector(pushToRegisterVCButtonTaped), for: .touchUpInside)
        frameView.addSubview(buttonForPushToRegisterVC)
        // 6pt 设计尺寸
        buttonForPushToRegisterVC.frame = CGRect(x: 6, y: 0, width: buttonForPushToRegisterVC.frame.width, height: buttonForPushToRegisterVC.frame.height)
        // 如果关闭了全局注册 或者 只设置了三方注册,那么就不显示注册按钮
        if TSAppConfig.share.localInfo.registerAllOpen == false || TSAppConfig.share.localInfo.accountType == .thirdPart {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: frameView)
        }
        // 游客取消按钮
        if isHiddenDismissButton! == true {
            return
        }
        let guestDismissContentView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        let guestDismissButton = TSTextButton.initWith(putAreaType: .top)
        guestDismissButton.setTitle("显示_导航栏_返回".localized, for: .normal)
        guestDismissButton.addTarget(self, action: #selector(guestDismissButtonTaped), for: .touchUpInside)
        guestDismissContentView.addSubview(guestDismissButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: guestDismissContentView)
        guestDismissButton.frame = CGRect(x: -12, y: 0, width: guestDismissButton.frame.width, height: guestDismissButton.frame.height)
    }

    func setupUI() {
        title = "登录"
        guestLoginButton.setTitle("显示_游客按钮".localized, for: .normal)
        guestLoginButton.isHidden = isHiddenGuestLoginButton!
        buttonForLogin.sizeType = .large
        buttonForPushToRetrievePassword.addTarget(self, action: #selector(buttonForPushToRetrievePasswordTaped), for: .touchUpInside)

        if TSAppConfig.share.localInfo.registerAllOpen == false || TSAppConfig.share.localInfo.accountType == .invited {
            // 不显示三方登录窗口
        } else {
            let otherlogin: OtherLoginView = OtherLoginView(frame: CGRect.zero, VC: self)
            self.view.addSubview(otherlogin)
            otherlogin.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.view).offset(-31)
                make.left.right.equalTo(self.view)
                make.height.equalTo(104)
            }
        }
    }
    // 切换服务器控制器
    func pushServiceSwitchVC() {
        let switchServiceVC = TSSwitchServiceVC()
        self.navigationController?.pushViewController(switchServiceVC, animated: true)
    }
    // MARK: Button click
    /// 登录按钮点击事件
    @IBAction func loginButtonTaped() {
        self.view.endEditing(true)
        if isSMSLogin == false {
            namePhoneLogin()
        } else {
            SMSLogin()
        }
    }
    /// 帐号密码登录
    private func namePhoneLogin() {
        if let phoneNumber = self.textFieldForPhone.text, let password = self.textFieldForPassword.text {
            // 检查密码
            if !TSAccountRegex.countRigthFor(password: password) {
                self.showPrompt("提示信息_密码长度错误".localized)
                return
            }
            disabled()
            TSAccountNetworkManager().login(loginField: phoneNumber, password: password, complete: { (msg, status) in
                if status {
                    // 请求当前用户信息
                    self.requestCurrentUserInfo()
                    self.getCurrentUserManagerInfo()
                    // 请求用户认证信息
                    TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
                    let account = TSAccountNameObject()
                    account.nameStr = phoneNumber
                    TSAccountDataBase().saveName(account)
                } else {
                    self.enabled()
                    self.showPrompt(msg ?? errorNetworkInfo)
                }
            })
        }
    }
    /// 短信登录
    private func SMSLogin() {
        if let phone = phoneTF.text, let code = codeTF.text {
            if isPhoneRegister {
                /// 当前手机号没有注册过，隐式注册一个
                getRandomName { (name) in
                    // 然后注册一个用户
                    // 发起注册网络请求
                    TSAccountNetworkManager().register(name: name, account: phone, password: nil, captcha: code, channel: .phone, complete: { (msg, status) in
                        if status {
                            // 请求当前用户信息
                            self.requestCurrentUserInfo()
                            self.getCurrentUserManagerInfo()
                        } else {
                            self.enabled()
                            self.showPrompt(msg ?? errorNetworkInfo)
                        }
                    })
                }
            } else {
                /// 已经有的手机号直接登录
                TSAccountNetworkManager().login(loginField: phone, password: "", code: code, complete: { (msg, status) in
                    if status {
                        // 请求当前用户信息
                        self.requestCurrentUserInfo()
                        self.getCurrentUserManagerInfo()
                        // 请求用户认证信息
                        TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
                        let account = TSAccountNameObject()
                        account.nameStr = phone
                        TSAccountDataBase().saveName(account)
                    } else {
                        self.enabled()
                        self.showPrompt(msg ?? errorNetworkInfo)
                    }
                })
            }
        }
    }
    /// 请求当前用户信息
    private func requestCurrentUserInfo() -> Void {
        TSUserNetworkingManager().getCurrentUserInfo(complete: { (userModel, msg, status) in
            self.enabled()
            if status, let userModel = userModel {
                // 发布用户登录成功的通知,创建IM
                NotificationCenter.default.post(name: NSNotification.Name.User.login, object: nil)
                // 注册推送别名
                let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                appDeleguate.registerJPushAlias()
                if self.isHiddenDismissButton! == false { // 游客进入该页面登录成功，取消限制操作，刷新数据
                    NotificationCenter.default.post(name: NSNotification.Name.Visitor.login, object: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    TSRootViewController.share.show(childViewController: .tabbar)
                }
                // 将当前用户信息存入数据库
                TSCurrentUserInfo.share.userInfo = userModel
                TSDatabaseManager().user.saveCurrentUser(userModel)
                if TSCurrentUserInfo.share.isLogin {
                    let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                    appDeleguate.getHyPassword()
                }
            } else {
                self.showPrompt(msg ?? errorNetworkInfo)
            }
        })
    }

    func enabled() {
        buttonForPushToRegisterVC.isEnabled = true
        buttonForSecureTextEntry.isEnabled = true
        buttonForPushToRetrievePassword.isEnabled = true
        buttonForLogin.isEnabled = true
        self.indicatorViewForLogin.dismiss()
    }

    func disabled() {
        buttonForPushToRegisterVC.isEnabled = false
        buttonForSecureTextEntry.isEnabled = false
        buttonForPushToRetrievePassword.isEnabled = false
        buttonForLogin.isEnabled = false
        self.indicatorViewForLogin.starAnimationForFlowerWhite()
    }

    /// 切换密码模式按钮点击事件
    @IBAction func secureTextEntryButtonTaped() {
        textFieldForPassword.isSecureTextEntry = !textFieldForPassword.isSecureTextEntry
        var imageName = ""
        switch textFieldForPassword.isSecureTextEntry {
        case true:
            imageName = "IMG_ico_closeeye"
        case false:
            imageName = "IMG_ico_openeye"
        }
        self.buttonForSecureTextEntry.setImage(UIImage(named: imageName), for: .normal)
    }

    /// 导航栏注册按钮点击事件
    func pushToRegisterVCButtonTaped() {
        let registerButton = TSRegisterVC(nibName: "TSRegisterVC", bundle: nil)
        self.navigationController?.pushViewController(registerButton, animated: true)
    }

    /// 找回密码按钮点击事件
    func buttonForPushToRetrievePasswordTaped() {
        let retrievePassword = TSRetrievePasswordVC(nibName: "TSRetrievePasswordVC", bundle: nil)
        self.navigationController?.pushViewController(retrievePassword, animated: true)
    }

    /// 游客进入按钮点击
    @IBAction func guestJoin(_ sender: Any) {
        TSRootViewController.share.show(childViewController: .tabbar)
    }

    func guestDismissButtonTaped() {
        dismiss(animated: true, completion: nil)
    }
    /// 切换登录方式（密码登录和短信登录）
    @IBAction func switchLoginTypeBtnClick(_ sender: Any) {
        isSMSLogin = !isSMSLogin
    }
    /// 发送验证码按钮点击事件
    @IBAction func sendCAPTCHAButtonTaped() {
        guard let phoneNumber = self.phoneTF.text else {
            return
        }
        // 发送验证码网络请求
        buttonForSendCAPTCHA.isHidden = true
        // 检查当前手机号是否已经注册
        TSUserNetworkingManager().phoneDidRegister(number: phoneNumber) { (didRegister) in
            self.isPhoneRegister = !didRegister
            /// 已经注册使用直接登录的短信获取
            if didRegister {
                TSAccountNetworkManager().sendCaptcha(channel: .phone, type: .change, account: phoneNumber) { (msg, status) in
                    self.buttonForSendCAPTCHA.isHidden = false
                    guard status == true else {
                        self.showPrompt(msg)
                        return
                    }
                    // 开启倒计时
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.timerFired), object: nil)
                    self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                    if let timer = self.timer {
                        RunLoop.main.add(timer, forMode: .commonModes)
                    }
                }
            } else {
                /// 没有注册就调用注册使用的验证码
                TSAccountNetworkManager().sendCaptcha(channel: .phone, type: .register, account: phoneNumber) { (msg, status) in
                    self.buttonForSendCAPTCHA.isHidden = false
                    guard status == true else {
                        self.showPrompt(msg)
                        return
                    }
                    // 开启倒计时
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.timerFired), object: nil)
                    self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                    if let timer = self.timer {
                        RunLoop.main.add(timer, forMode: .commonModes)
                    }
                }
            }
        }
    }

    // MARK: - Private
    /// 检测输入框的输入状态，判断登录按钮的点击状态
    func textFiledDidChanged(notification: Notification) {
        // 输入框输入文字上限
        var stringCountLimit = 999
        // 输入框类型 key
        if let textField = notification.object as? UITextField {
            var stringType = ""
            switch textField {
            case textFieldForPhone:
                stringType = "phone"
            case textFieldForPassword:
                stringType = "password"
                stringCountLimit = 16
                /// 短信验证码登录
            case phoneTF:
                if let phone = phoneTF.text, phone.count == 11 {
                    buttonForSendCAPTCHA.isEnabled = true
                } else {
                    buttonForSendCAPTCHA.isEnabled = false
                }
                if codeTF.text?.isEmpty == false, let phone = phoneTF.text, phone.count == 11 {
                    self.buttonForLogin.isEnabled = true
                } else {
                    self.buttonForLogin.isEnabled = false
                }
                return
            case codeTF:
                if codeTF.text?.isEmpty == false, let phone = phoneTF.text, phone.count == 11 {
                    self.buttonForLogin.isEnabled = true
                } else {
                    self.buttonForLogin.isEnabled = false
                }
                return
            default:
                return
            }
            if textField.text == nil || textField.text == "" {
                // 更新输入框输入状态
                self.accountUsable.updateValue(false, forKey: stringType)
            } else {
                self.accountUsable.updateValue(true, forKey: stringType)
                TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
            }
            uploadLoginButtonStatue()
        }
    }

    /// 更新登录按钮状态
    func uploadLoginButtonStatue() {
        self.buttonForLogin.isEnabled = true
        for (_, value) in self.accountUsable {
            if !value {
                self.buttonForLogin.isEnabled = false
            }
        }
    }

    /// 显示提示信息
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
    // MARK: - 显示联想视图方法
    func showSearch(_ str: String) {
        let models = TSAccountDataBase().getSamAccount(str)
        let arry = models as NSArray
        showsSearchResults.changeData(arry)
        if arry.count.isEqualZero {
            showsSearchResults.isHidden = true
        } else {
            showsSearchResults.isHidden = false
            var newHight: CGFloat = 0
            guard arry.count < 3 else {
                newHight = CGFloat(Double(arry.count)) * AccountCellType().cellHight - AccountCellType().lastCellHigt
                showsSearchResults.snp.updateConstraints({ (make) in
                    make.height.equalTo(newHight)
                })
                return
            }
            newHight = CGFloat(Double(arry.count)) * AccountCellType().cellHight
            showsSearchResults.snp.updateConstraints({ (make) in
                make.height.equalTo(newHight)
            })
        }
    }
    func inputChanged(_ changed: TSAccountTextField) {
        let str = changed.text!
        showSearch(str)
    }
    @IBAction func chaged(_ sender: Any) {
        let str = textFieldForPhone.text!
        showSearch(str)
    }
    @IBAction func BeginChanged(_ sender: Any) {
        let str = textFieldForPhone.text!
        showSearch(str)
    }

    @IBAction func passwordChangeBegin(_ sender: Any) {
        showsSearchResults.isHidden = true
    }
    func didSelectShowsSearchResultsCell(rowStr: String) {
        self.textFieldForPhone.text = rowStr
        showsSearchResults.isHidden = true
    }
    // MARK: - 隐式注册流程
    func getRandomName(complete: @escaping ((_ name: String) -> Void)) {
        var name = "用户"
        let characters = "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"
        let characterArr = characters.components(separatedBy: ",")
        var ranCodeString = ""
        for _ in 0 ..< 6 {
            let index = Int(arc4random_uniform(UInt32(characterArr.count)))
            ranCodeString.append(characterArr[index])
        }
        name.append(ranCodeString)
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + name
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            /// 如果注册了 就返回用户信息，否者404
            if status == false {
                complete(name)
            } else {
                /// 重新再生成一个
                self.getRandomName(complete: { (aName) in
                    complete(aName)
                })
            }
        })
    }
    // MARK: - 请求用户管理权限信息
    func getCurrentUserManagerInfo() {
        TSUserNetworkingManager.currentUserManagerInfo { (_, _) in
        }
    }
}
