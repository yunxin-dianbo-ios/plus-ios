//
//  TSSetPasswordVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  修改密码

import UIKit

class TSSetPasswordVC: TSViewController {

    /// 更改按钮
    let buttonForChange = TSTextButton.initWith(putAreaType: .top)

    @IBOutlet weak var labelForPrompt: TSAccountMessagelabel!
    @IBOutlet weak var textFieldForOld: TSAccountTextField!
    @IBOutlet weak var textFieldForNew: TSAccountTextField!
    @IBOutlet weak var textFieldForConfirm: TSAccountTextField!

    /// 输入框输入情况记录
    /// - 有值为 true, 反之为 false
    var accountUsable = ["old": false, "new": false, "confirm": false]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setNacigation()
        addNotificatin()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        updateRightButtonFrame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除检测输入框状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    deinit {
        // 移除检测音乐按钮的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }

    // MARK: - Custom user interface 
    func setUI() {
        self.title = "修改密码"
    }

    func setNacigation() {
        let frameView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        buttonForChange.setTitle("更改", for: .normal)
        buttonForChange.addTarget(self, action: #selector(changeButtonTaped), for: .touchUpInside)
        frameView.addSubview(buttonForChange)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: frameView)
        buttonForChange.frame = CGRect(x: 16, y: 0, width: buttonForChange.frame.width, height: buttonForChange.frame.height)
        buttonForChange.isEnabled = false
    }

    /// 更新右方按钮的位置
    func updateRightButtonFrame() {
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        buttonForChange.frame = CGRect(x: isMusicButtonShow ? 16 - 44 : 16, y: 0, width: buttonForChange.frame.width, height: buttonForChange.frame.height)
    }

    // MARK: - IBAction
    @IBAction func secureTextEntryButtonTaped(_ sender: UIButton) {
        var selectedTextField: UITextField? = nil
        switch sender.restorationIdentifier! {
        case "new":
            selectedTextField = textFieldForNew
        case "confirm":
            selectedTextField = textFieldForConfirm
        default:
            return
        }
        if let textField = selectedTextField {
            textField.isSecureTextEntry = !textField.isSecureTextEntry
            sender.setImage(UIImage(named: textField.isSecureTextEntry ? "IMG_ico_closeeye" : "IMG_ico_openeye"), for: .normal)
        }
    }

    // MARK: - Button click
    func changeButtonTaped() {
        // 检查旧密码
        if !TSAccountRegex.countRigthFor(password: self.textFieldForOld.text!) {
            self.showPrompt("提示信息_旧密码输入错误".localized)
            return
        }
        // 检查新密码
        if !TSAccountRegex.countRigthFor(password: self.textFieldForNew.text!) {
            self.showPrompt("提示信息_密码长度错误".localized)
            return
        }
        // 检查新密码和确认密码是否相同
        if self.textFieldForConfirm.text! != self.textFieldForNew.text! {
            self.showPrompt("提示信息_新密码和确认密码不一致".localized)
            return
        }
        let oldPwd = self.textFieldForOld.text!
        let newPwd = self.textFieldForNew.text!
        TSAccountNetworkManager().updatePassword(oldPwd: oldPwd, newPwd: newPwd) { (msg, status) in
            if !status {
                self.showPrompt(msg ?? errorNetworkInfo)
                return
            }
            let top = TSIndicatorWindowTop(state: .success, title: msg!)
            top.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            })
        }
    }

    // MARK: Private
    /// 检测输入框的输入状态，判断登录按钮的点击状态
    func textFiledDidChanged(notification: Notification) {
        let textField = (notification.object! as? UITextField)!
        var stringCountLimit = 999
        // 输入框类型 key
        var stringType = ""
        switch textField {
        case textFieldForOld:
            stringType = "old"
            stringCountLimit = 16
        case textFieldForNew:
            stringType = "new"
            stringCountLimit = 16
        case textFieldForConfirm:
            stringType = "confirm"
            stringCountLimit = 16
        default:
            return
        }
        if textField.text == nil || textField.text! == "" {
            // 更新输入框输入状态
            self.accountUsable.updateValue(false, forKey: stringType)
        } else {
            self.accountUsable.updateValue(true, forKey: stringType)
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
        }
        uploadChangeButtonStatue()
    }

    func uploadChangeButtonStatue() {
        self.buttonForChange.isEnabled = true
        for (_, value) in self.accountUsable {
            if !value {
                self.buttonForChange.isEnabled = false
            }
        }
    }

    /// 显示提示信息
    func showPrompt(_ message: String!) {
        self.labelForPrompt.text = message
    }

    // MARK: - Notification
    func addNotificatin() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateRightButtonFrame), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
}
