//
//  PayPasswordVC.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/9/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
// 1、用于需要消耗积分的地方显示密码输入弹窗(UIViewController)
// 2、TSAppConfig.share.localInfo.shouldShowPayAlert 会控制是否显示该弹窗
// 2.2 如果显示该弹窗需要打断以前的支付流程;API请求结果的异常message在该弹窗左下角显示，正常状态的message和loading保持原顶部不变
// 3、显示弹窗和隐藏由TSUtil调用showPwdVC、dismissPwdVC

import UIKit
import IQKeyboardManagerSwift

class PayPasswordVC: UIViewController {
    @IBOutlet weak private var sureBtn: UIButton!
    @IBOutlet weak private var forgetPWDBtn: UIButton!
    @IBOutlet weak private var cancelBtn: UIButton!
    @IBOutlet weak private var pwdTF: UITextField!
    @IBOutlet weak private var noticeLab: UILabel!
    @IBOutlet weak private var TFBgView: UIView!
    /// 确定按钮点击Block
    var sureBtnClickBlock: ((String) -> Void)?
    /// 页面消失Block
    var dismissBlcok: (() -> Void)?
    /// 页面导航
    var payNav: UINavigationController!
    private var keyboardHeight: CGFloat = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        payNav.isNavigationBarHidden = true
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }

    override func viewDidAppear(_ animated: Bool) {
        registerNoti()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.pwdTF.becomeFirstResponder()
            if self.keyboardHeight > 0 {
                self.view.frame = CGRect(x: 0, y: -self.keyboardHeight + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: ScreenWidth, height: ScreenHeight)
            }
        }

        /// 隐藏白色的遮盖层
        if let bgView = navigationController?.view.viewWithTag(434_434) {
            bgView.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        payNav.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
//        pwdTF.addTarget(self, action: #selector(textFieldDidChange(tf:)), for: .editingChanged) 
        TFBgView.layer.borderColor = UIColor(hex: 0xCCCCCC).cgColor
        sureBtn.isEnabled = false
    }
    func registerNoti() {
        /// 注册显示提示语的通知
        NotificationCenter.default.addObserver(self, selector: #selector(showNotice(noti:)), name: NSNotification.Name.Pay.showMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHidden(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldValueDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    /// 处理确定按钮状态以及提示语
    @objc private func textFieldDidChange(tf: UITextField) {
        if tf.text?.isEmpty == false {
            sureBtn.backgroundColor = TSColor.main.theme
            sureBtn.setTitleColor(UIColor.white, for: .normal)
            sureBtn.isEnabled = true
        } else {
            sureBtn.backgroundColor = TSColor.normal.disabled
            sureBtn.setTitleColor(UIColor.lightGray, for: .normal)
            sureBtn.isEnabled = false
        }
        noticeLab.text = nil
        noticeLab.isHidden = true
    }
    /// 输入框通知
    func textFieldValueDidChanged(notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        // 输入框文字字数上限
        let stringCountLimit = 16
        TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
        if textField.text?.isEmpty == false {
            sureBtn.backgroundColor = TSColor.main.theme
            sureBtn.setTitleColor(UIColor.white, for: .normal)
            sureBtn.isEnabled = true
        } else {
            sureBtn.backgroundColor = TSColor.normal.disabled
            sureBtn.setTitleColor(UIColor.lightGray, for: .normal)
            sureBtn.isEnabled = false
        }
        noticeLab.text = nil
        noticeLab.isHidden = true
    }
    // MARK: - Btn Action
    @IBAction private func cancelBtnClick(_ sender: Any) {
        dismiss()
    }

    @IBAction private func sureBtnClick(_ sender: Any) {
        sureBtn.isEnabled = false
        if let pwd = pwdTF.text {
            sureBtnClickBlock?(pwd)
        } else {
            noticeLab.text = "请输入密码"
            noticeLab.isHidden = true
        }
    }

    @IBAction private func forgetPWDBtnClick(_ sender: Any) {
        /// 进入忘记密码页面
        /// 显示一个白色的遮盖层,否则二级跳转页面顶部能看到密码页面的半透明蒙层
        if let bgView = navigationController?.view.viewWithTag(434_434) {
            bgView.isHidden = false
        }
        let retrievePassword = TSRetrievePasswordVC(nibName: "TSRetrievePasswordVC", bundle: nil)
        navigationController?.pushViewController(retrievePassword, animated: true)
    }
    // MARK: - 显示message
    @objc private func showNotice(noti: Notification) {
        sureBtn.isEnabled = true
        noticeLab.isHidden = false
        noticeLab.alpha = 1
        if let userInfo = noti.userInfo as? Dictionary<String, Any>, let message = userInfo["message"] as? String {
            noticeLab.text = message
        }
        /// 延迟一会儿后隐藏提示Label
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            UIView.animate(withDuration: 0.5, animations: {
                self.noticeLab.alpha = 0
            }, completion: { (finish) in
                self.noticeLab.isHidden = true
            })
        }
    }

    func keyBoardWillShow(noti: Notification) {
        if let userInfo = noti.userInfo {
            if let animationDur: CGFloat = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as? CGFloat, let keyBoardEndFrame = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                UIView.animate(withDuration: TimeInterval(animationDur)) {
                    self.view.frame = CGRect(x: 0, y: -keyBoardEndFrame.height + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: ScreenWidth, height: ScreenHeight)
                    self.keyboardHeight = keyBoardEndFrame.height
                }
            }
        }
    }
    func keyBoardWillHidden(noti: Notification) {
//        self.view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
    }
    // MARK: - 移除视图
    func dismiss() {
        removeFromParentViewController()
        view.removeFromSuperview()
        payNav.removeFromParentViewController()
        payNav.view.removeFromSuperview()
        dismissBlcok?()
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
