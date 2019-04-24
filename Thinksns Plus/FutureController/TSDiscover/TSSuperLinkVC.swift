//
//  TSSuperLinkVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/10/11.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSSuperLinkVC: UIViewController {

    /// 整体白色背景视图与屏幕左右的间距
    var margin: CGFloat = 63.0 * ScreenWidth / 375.0
    /// 整体白色背景视图的高度
    var whiteHeight: CGFloat = 252
    /// 整体白色背景的宽度
    var whiteWidth: CGFloat = ScreenWidth - (63.0 * ScreenWidth / 375.0) * 2
    /// 整体白色背景的内部视图与白色背景左右间距
    var inMargin: CGFloat = 25.0
    /// 有透明度的背景视图
    var bgView = UIView()
    /// 整体白色背景视图
    var whiteView = UIView()
    /// 发送给谁 主题文字
    var titleLabel = UILabel()
    /// 分割线1
    var firstLine = UIView()
    /// 分割线2
    var secondLine = UIView()
    /// 链接网址输入框
    var linkTextField = UITextField()
    /// 链接标题输入框
    var linkTitleTextField = UITextField()
    /// 取消按钮
    var cancelButton = UIButton(type: .custom)
    /// 确认按钮
    var sureButton = UIButton(type: .custom)
    var currentKbH: CGFloat = 0
    /// 确定按钮信息回传
    var sendBlock: ((String, String) -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        setUI()
    }

    func setUI() {
        if (UIScreen.main.bounds.width < 330) {
            // 小屏幕
            whiteHeight = 220
        }
        whiteView.frame = CGRect(x: margin, y: 0, width: whiteWidth, height: whiteHeight)
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.cornerRadius = 5.0
        whiteView.centerY = ScreenHeight / 2.0
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(whiteViewTap))
        whiteView.addGestureRecognizer(tap)
        self.view.addSubview(whiteView)

        titleLabel.frame = CGRect(x: 0, y: 0, width: whiteWidth, height: 54)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.text = "插入链接"
        titleLabel.textAlignment = .center
        whiteView.addSubview(titleLabel)

        firstLine.frame = CGRect(x: inMargin, y: titleLabel.bottom, width: whiteWidth - inMargin * 2, height: 0.5)
        firstLine.backgroundColor = TSColor.inconspicuous.disabled
        whiteView.addSubview(firstLine)

        linkTextField.frame = CGRect(x: inMargin, y: firstLine.bottom + 30, width: whiteWidth - inMargin * 2, height: 35)
        if (UIScreen.main.bounds.width < 330) {
            // 小屏幕
            linkTextField.frame = CGRect(x: inMargin, y: firstLine.bottom + 15, width: whiteWidth - inMargin * 2, height: 35)
        }
        linkTextField.layer.cornerRadius = 3
        linkTextField.layer.masksToBounds = true
        linkTextField.layer.borderColor = UIColor(hex: 0xdedede).cgColor
        linkTextField.layer.borderWidth = 0.5
        linkTextField.placeholder = "输入链接地址"
        linkTextField.textColor = UIColor(hex: 0x333333)
        linkTextField.delegate = self
        let leftView1 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 35))
        linkTextField.leftView = leftView1
        linkTextField.leftViewMode = .always
        whiteView.addSubview(linkTextField)

        linkTitleTextField.frame = CGRect(x: inMargin, y: linkTextField.bottom + 15, width: whiteWidth - inMargin * 2, height: 35)
        linkTitleTextField.layer.cornerRadius = 3
        linkTitleTextField.layer.masksToBounds = true
        linkTitleTextField.layer.borderColor = UIColor(hex: 0xdedede).cgColor
        linkTitleTextField.layer.borderWidth = 0.5
        linkTitleTextField.placeholder = "输入链接标题"
        linkTitleTextField.textColor = UIColor(hex: 0x333333)
        linkTitleTextField.delegate = self
        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 35))
        linkTitleTextField.leftView = leftView2
        linkTitleTextField.leftViewMode = .always
        whiteView.addSubview(linkTitleTextField)

        secondLine.frame = CGRect(x: inMargin, y: linkTitleTextField.bottom + 15, width: whiteWidth - inMargin * 2, height: 0.5)
        secondLine.backgroundColor = TSColor.inconspicuous.disabled
        whiteView.addSubview(secondLine)

        cancelButton.frame = CGRect(x: 0, y: secondLine.bottom, width: whiteWidth / 2.0, height: whiteHeight - secondLine.bottom)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(TSColor.main.theme, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(hidSelf), for: UIControlEvents.touchUpInside)
        whiteView.addSubview(cancelButton)

        sureButton.frame = CGRect(x: whiteWidth / 2.0, y: secondLine.bottom, width: whiteWidth / 2.0, height: whiteHeight - secondLine.bottom)
        sureButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sureButton.setTitleColor(TSColor.main.theme, for: .normal)
        sureButton.setTitle("确认", for: .normal)
        sureButton.addTarget(self, action: #selector(sendBtnClick), for: UIControlEvents.touchUpInside)
        whiteView.addSubview(sureButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TSSuperLinkVC: UITextFieldDelegate {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - whiteView.bottom
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }

    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }

    @objc fileprivate func viewBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - whiteView.bottom
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }

    @objc fileprivate func viewEndEditingNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }

    /// 键盘相关的复原
    fileprivate func kbProcessReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}

extension TSSuperLinkVC {
    func hidSelf() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        NotificationCenter.default.removeObserver(self)
    }

    func whiteViewTap() {

    }

    func sendBtnClick() {
        if let sendBlock = self.sendBlock {
            sendBlock(self.linkTextField.text ?? "", self.linkTitleTextField.text ?? "")
        }
        self.hidSelf()
    }

    public func show(vc: TSSuperLinkVC, link: String?, linkTitle: String?, kbHeight: CGFloat) {
        self.linkTextField.text = link
        self.linkTitleTextField.text = linkTitle
        currentKbH = kbHeight
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        if let modalVC = window.rootViewController?.presentedViewController {

            // 不知道为什么提问时候没有走viewwill方法
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(viewBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(viewEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)

            modalVC.view.addSubview(vc.view)
            modalVC.addChildViewController(vc)
            modalVC.didMove(toParentViewController: window.rootViewController)
        } else {
            window.rootViewController?.view.addSubview(vc.view)
            window.rootViewController?.addChildViewController(vc)
            window.rootViewController?.didMove(toParentViewController: window.rootViewController)
        }
        self.linkTextField.becomeFirstResponder()
    }
}
