//
//  TSIndicatorPayBasicView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/5/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  付费弹窗基础类
//  
//  - 使用付费弹窗请参见 TSIndicatorPay.swift

import UIKit
import TYAttributedLabel

class TSIndicatorPayBasicView: UIView, TYAttributedLabelDelegate {

    /// 白色背景图片
    public let whiteView = UIView()
    /// 标题
    public let labelForTitle = TSLabel()
    /// 灰色分割线
    public let lineGray = UIView()
    /// 价格
    public let labelForPrice = TSLabel()
    /// 描述
    public let labelForDescription = TYAttributedLabel()
    /// 购买按钮
    public let buttonForBuy = TSButton(type: .custom)
    /// 返回按钮
    public let buttonForBack = TSButton(type: .custom)

    /// 价格
    var price = 0.0
    /// 链接词点击事件
    var actionForLinkWord: ((_ linkWork: String?) -> Void)? = nil
    /// 购买按钮点击事件
    var actionForBuyButton: (() -> Void)? = nil
    /// 返回按钮点击事件
    var actionForBackButton: (() -> Void)? = nil
    /// 购买失败
    var buyError: (() -> Void)?

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let whiteViewWidth: CGFloat = 250
    let whiteViewHeight: CGFloat = 300
    let buttonWidth: CGFloat = 200
    let buttonHeight: CGFloat = 35

    // MARK: - Lifecycle
    init(price: Double) {
        super.init(frame: UIScreen.main.bounds)
        self.price = price
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface

    /// 设置视图
    func setUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.2)

        // 白色背景图片
        whiteView.frame = CGRect(x: (screenWidth - whiteViewWidth) / 2, y: (screenHeight - whiteViewHeight) / 2, width: whiteViewWidth, height: whiteViewHeight)
        whiteView.backgroundColor = UIColor.white
        whiteView.clipsToBounds = true
        whiteView.layer.cornerRadius = 10
        let backTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(whiteViewTap))
        whiteView.addGestureRecognizer(backTap)
        // 灰色分割线
        lineGray.frame = CGRect(x: (whiteViewWidth - buttonWidth) / 2, y: 54, width: buttonWidth, height: 0.5)
        lineGray.backgroundColor = TSColor.inconspicuous.disabled
        // 标题
        labelForTitle.textColor = TSColor.main.content
        labelForTitle.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        // 价格
        labelForPrice.textColor = TSColor.button.orangeGold
        labelForPrice.font = UIFont.systemFont(ofSize: TSFont.ContentText.price.rawValue)
        // 描述
        labelForDescription.textColor = TSColor.normal.minor
        labelForDescription.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue)
        // 购买按钮
        buttonForBuy.frame = CGRect(x: (whiteViewWidth - buttonWidth) / 2, y: 195.5, width: buttonWidth, height: buttonHeight)
        buttonForBuy.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        buttonForBuy.setTitle("支付弹窗_购买".localized, for: .normal)
        buttonForBuy.setTitleColor(UIColor.white, for: .normal)
        buttonForBuy.backgroundColor = TSColor.main.theme
        buttonForBuy.clipsToBounds = true
        buttonForBuy.layer.cornerRadius = 6
        buttonForBuy.addTarget(self, action: #selector(buyButtonTaped), for: .touchUpInside)
        // 返回按钮
        buttonForBack.frame = CGRect(x: (whiteViewWidth - buttonWidth) / 2, y: buttonForBuy.frame.maxY + 10, width: buttonWidth, height: buttonHeight)
        buttonForBack.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        buttonForBack.setTitle("支付弹窗_返回".localized, for: .normal)
        buttonForBack.setTitleColor(TSColor.main.theme, for: .normal)
        buttonForBack.backgroundColor = UIColor.white
        buttonForBack.clipsToBounds = true
        buttonForBack.layer.cornerRadius = 6
        buttonForBack.layer.borderColor = TSColor.main.theme.cgColor
        buttonForBack.layer.borderWidth = 1
        buttonForBack.addTarget(self, action: #selector(backButtonTaped), for: .touchUpInside)

        // 增加点击背景返回的手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
        addGestureRecognizer(tap)

        addSubview(whiteView)
        whiteView.addSubview(labelForTitle)
        whiteView.addSubview(lineGray)
        whiteView.addSubview(labelForPrice)
        whiteView.addSubview(labelForDescription)
        whiteView.addSubview(buttonForBuy)
        whiteView.addSubview(buttonForBack)
    }

    // MARK: - Button click

    /// 点击白色背景部分不做任何处理
    func whiteViewTap() {

    }

    /// 点击了购买按钮
    func buyButtonTaped() {
        // 检查用户积分余额是否足够
        checkUserJifen(enoughPay: price) { [weak self] (isEnough) in
            guard isEnough else {
                if let buyError = self?.buyError {
                    buyError()
                }
                return
            }
            if let actionForBuyButton = self?.actionForBuyButton {
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    self?.dissmiss()
                    /// 当前用户没有设置密码，需要先行设置
                    if TSCurrentUserInfo.share.isInitPwd == false {
                        NotificationCenter.default.post(name: NSNotification.Name.Setting.setPassword, object: nil)
                        return
                    }
                    TSUtil.showPwdVC(complete: { (inputCode) in
                        actionForBuyButton()
                    })
                    return
                } else {
                    actionForBuyButton()
                }
            }
        }
    }

    /// 点击了返回按钮
    func backButtonTaped() {
        if let actionForBackButton = actionForBackButton {
            actionForBackButton()
        } else {
            dissmiss()
        }
    }

    // MARK: - Public

    /// 显示
    public func show() {
        updateChildViewLayout()
        let topWindow = UIApplication.shared.keyWindow
        if superview == nil {
            topWindow?.addSubview(self)
        }
    }

    /// 隐藏
    public func dissmiss() {
        if superview != nil {
            removeFromSuperview()
        }
    }

    /// 更新子视图的布局
    public func updateChildViewLayout() {
        // 标题
        labelForTitle.sizeToFit()
        labelForTitle.frame = CGRect(x: (whiteViewWidth - labelForTitle.frame.width) / 2, y: 18, width: labelForTitle.frame.width, height: labelForTitle.frame.height)
        // 价格
        labelForPrice.sizeToFit()
        labelForPrice.frame = CGRect(x: (whiteViewWidth - labelForPrice.frame.width) / 2, y: 89, width: labelForPrice.frame.width, height: labelForPrice.frame.height)
        // 描述
        labelForDescription.setFrameWithOrign(CGPoint(x: (whiteViewWidth - 175) / 2, y: 126), width: 175)
    }

    /// 设置价格内容
    public func setPrice(content: String?) {
        if let content = content {
            let attributeString = NSMutableAttributedString(string: content)
            labelForPrice.attributedText = attributeString
        }
    }

    /// 设置描述内容
    ///
    /// - Parameters:
    ///   - content: 普通内容
    ///   - linkWord: 有点击效果的内容
    public func setDescription(content: String?, linkWord: String?) {
        let contentfinal = "  \(content ?? "")"
        labelForDescription.text = contentfinal
        if let linkWord = linkWord {
            labelForDescription.text = contentfinal + linkWord
            let location = contentfinal.count
            let storage = TYLinkTextStorage()
            storage.range = NSRange(location: location, length: linkWord.count)
            storage.textColor = TSColor.main.theme
            storage.underLineStyle = .init(rawValue: 0)
            storage.linkData = linkWord
            labelForDescription.addTextStorage(storage)
            labelForDescription.delegate = self
        }
    }

    /// 设置购买按钮的点击事件
    ///
    /// - Parameter action: 点击事件
    public func setActionForBuyButton(action: @escaping () -> Void) {
        actionForBuyButton = action
    }

    /// 设置返回按钮的点击事件
    ///
    /// - Parameter action: 点击事件
    public func setActionForBackButton(action: @escaping () -> Void) {
        actionForBackButton = action
    }

    /// 设置链接词的点击事件
    ///
    /// - Parameter action: 点击事件
    public func setActionForLinkWord(action: @escaping (_ linkWord: String?) -> Void) {
        actionForLinkWord = action
    }

    // MARK: - Delegate

    // MARK: TYAttributedLabelDelegate

    // 点击代理
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        if textStorage.isKind(of: TYLinkTextStorage.self) {
            let storage = textStorage as! TYLinkTextStorage
            if let actionForLinkWord = actionForLinkWord {
                actionForLinkWord(storage.linkData as? String)
            }
        }
    }

    /// 检查用户积分余额是否足够
    ///
    /// - Note: 如果用户积分金额不足，则跳转到积分页面
    ///
    /// - Parameters:
    ///   - price: 需要支付的积分金额
    ///   - complete: 结果
    func checkUserJifen(enoughPay price: Double, complete: @escaping(Bool) -> Void) {
        let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取余额...")
        alert.show()
        // 1. 获取当前登录用户的积分余额
        TSCurrentUserInfo.share.getCurrentUserJifen { [weak self] (status, jifen, message) in
            alert.dismiss()
            // 获取用户信息失败
            guard status else {
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: message)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            // 如果用户没有积分，那么接口会返回nil
            var jifenInt = 0
            if jifen == nil {
                jifenInt = 0
            } else {
                jifenInt = jifen!
            }
            // 2. 检查用户余额是否足够
            let isEnough = Double(jifenInt) >= price
            complete(isEnough)
            // 3. 如果余额不足，跳转到积分页面
            if isEnough {
                return
            }
            let goldName = TSAppConfig.share.localInfo.goldName
            let enoughAlert = TSIndicatorWindowTop(state: .faild, title: goldName + "不足")
            enoughAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            // 创建积分页面
            let jifenVC = IntegrationHomeController.vc()
            // 获取顶部视图控制器
            let topVC = UIApplication.topViewController()
            // 如果顶部视图是根视图控制器，增找出导航控制器来 push
            if let rootVC = topVC as? TSRootViewController, let tabVC = rootVC.currentShowViewcontroller as? UITabBarController {
                guard let nav = tabVC.selectedViewController as? UINavigationController else {
                    return
                }
                nav.pushViewController(jifenVC, animated: true)
                self?.dissmiss()
                return
            }
            // 如果顶部视图是普通的视图，则直接 push
            UIApplication.topViewController()?.navigationController?.pushViewController(jifenVC, animated: true)
            self?.dissmiss()
        }
    }
}
