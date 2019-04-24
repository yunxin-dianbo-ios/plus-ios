//
//  KeyboardToolbar.swift
//  KeyboardToolbar
//
//  Created by LeonFa on 2017/2/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 键盘输入工具栏
// 使用详情见文档

import UIKit

protocol TSKeyboardToolbarDelegate: NSObjectProtocol {
    /// 回传字符串和响应对象
    ///
    /// - Parameter message: 回传的String
    func keyboardToolbarSendTextMessage(message: String, inputBox: AnyObject?)

    /// 回传键盘工具栏的Frame
    ///
    /// - Parameter frame: 坐标和尺寸
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType)

    /// 键盘准备收起
    func keyboardWillHide()
}

enum keyboardRectChangeType {
    /// 弹出键盘
    case popUp

    /// 打字
    case typing

    /// 收起键盘
    case willHide
}

class TSKeyboardToolbar: UIView, TSTextToolBarViewDelegate {
    /// 是否正则At跳转
    var isAtActionPush: Bool = false
    private let emojiHeight: CGFloat = 145 + TSBottomSafeAreaHeight
    // 工具栏初始高度
    private let toolBarHeight: CGFloat = 42.0 + 145 + TSBottomSafeAreaHeight
    // 键盘通知单例
    private let keyboard = Typist.shared
    // 键盘工具栏单例
    static let share = TSKeyboardToolbar()
    // 工具栏内部布局视图
    private var textToolBarView: TSTextToolBarView? = nil
    // 是否需要回调
    private var isBlock = true
    // 背景遮罩层
    lazy private var bgView: UIView = {
        let view = UIView()
        self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        var frame = UIScreen.main.bounds
        frame.size.height += 64.0
        view.frame = frame
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBG))
        view.addGestureRecognizer(tap)
        return view
    }()

    // 改变后需要增加的高度
    private var changeHeight: CGFloat = 0.0
    // 记录Y坐标位置
    private var originY: CGFloat = 0.0
    // 代理
    weak var keyboardToolbarDelegate: TSKeyboardToolbarDelegate?
    // 键盘的高度
    private var currentToolBarHeight: CGFloat = 0
    // MARK: - 初始化键盘
    public func configureKeyboard () {
        let keyboardToolbar = TSKeyboardToolbar.share
        keyboardToolbar.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: toolBarHeight)
        if textToolBarView == nil {
            textToolBarView = TSTextToolBarView(frame: keyboardToolbar.bounds, superViewSourceHeight: toolBarHeight)
            textToolBarView?.toolBarViewDelegate = self
            guard let textToolBarView = textToolBarView else {
                assert(false, "\(TSTextToolBarView.self)初始化失败")
                return
            }

            textToolBarView.changeHeightClosure = {[weak self] value in
                if let weak = self {
                    weak.changeHeight = value - weak.toolBarHeight
                    keyboardToolbar.frame = CGRect(x: 0, y: weak.originY - weak.changeHeight, width: textToolBarView.frame.size.width, height: value)
                    if weak.currentToolBarHeight != value {
                        if weak.isBlock {
                            weak.keyboardToolbarDelegate?.keyboardToolbarFrame(frame: keyboardToolbar.frame, type: .typing)
                            weak.currentToolBarHeight = value
                        }
                    }
                }
            }

            keyboardToolbar.addSubview(textToolBarView)
        }
        setKeyboardFun()
    }

    // MARK: - 获取相应的输入框
    ///
    /// - Parameter inputbox: 接收TextView或者TextField
    public func keyboardGetInputbox<T>(inputbox: T, maximumWordLimit: Int, placeholderText: String?) {
        textToolBarView?.setSendViewParameter(placeholderText:  placeholderText ?? " ", inputbox: inputbox as AnyObject, maximumWordLimit: maximumWordLimit)
    }

    // MARK: - BecomeFirstResponder
    /// 响应弹出键盘
    public func keyboardBecomeFirstResponder() {
        if self.isBlock == false {
            // 使用的页面没有开启,手动开启并输出日志提醒开发人员进行修复。
            self.keyboardstartNotice()
            TSLogCenter.log.debug(
                """
                \n\n\n请注意!!!!!\n
                当前列表使用了TSKeyboardToolbar,但是没有开启监听!
                请在viewWillAppear中设置
                TSKeyboardToolbar.share.keyboardstartNotice()
                并在viewWillDisappear中注销
                TSKeyboardToolbar.share.keyboarddisappear()
                TSKeyboardToolbar.share.keyboardStopNotice()
                \n\n\n
                """
            )
        }
        textToolBarView?.sendTextView.becomeFirstResponder()
        let window = UIApplication.shared.keyWindow
        window?.addSubview(bgView)
        UIView.animate(withDuration: 0.2) {
            self.bgView.backgroundColor = TSColor.normal.transparentBackground
        }
        window?.addSubview(self)
    }

    // MARK: - 切换视图或者需要收起键盘的时候使用的方法
    public  func keyboarddisappear() {
        textToolBarView?.sendTextView.resignFirstResponder()
    }

    // MARK: - 停止通知
    public func keyboardStopNotice() {
        if TSKeyboardToolbar.share.isAtActionPush {
            return
        }
        let keyboardToolbar = TSKeyboardToolbar.share
        textToolBarView?.sendTextView.text = ""
        /// 这里是为重置键盘的高度
        self.isBlock = false
        textToolBarView?.textViewDidChange((textToolBarView?.sendTextView)!)
        keyboardToolbar.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        }, completion: { (_) in
            self.bgView.removeFromSuperview()
        })
        keyboard.stop()
    }

    // MARK: - 开启通知
    public func keyboardstartNotice() {
        self.isBlock = true
        self.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height)
        setKeyboardFun()
        if self.isAtActionPush {
            self.keyboardBecomeFirstResponder()
            if (self.textToolBarView != nil) {
                if (!self.textToolBarView!.sendTextView.text.contains("@")) {
                    self.textToolBarView!.sendTextView.text = "\(self.textToolBarView!.sendTextView.text ?? "")@"
                }
            }
        }
        self.isAtActionPush = false
    }

    // MARK: - 设置占位符
    /// 传入占位字符串方法(此方法在点击按钮弹出时使用，textView, 和TextField有单独的占位符参数)
    ///
    /// - Parameter placeholderText: 占位字符串内容
    public func keyboardSetPlaceholderText(placeholderText: String) {
        textToolBarView?.sendTextView.placeholder = placeholderText
    }

    // MARK: - 设置最大字数显示
    /// 设置最大字数显示(此方法在点击按钮弹出时使用，textView, 和TextField有单独的最大字数参数)
    ///
    /// - Parameter limit: 最大字数限制
    public func keyboardSetMaximumWordLimit(limit: Int) {
        textToolBarView?.maximumWordLimit = limit
    }

    // MARK: - 窃取textView或TextField文本相应
    /// 获取textView和TextField的方法
    ///
    /// - Parameters:
    ///   - message: 输入的文本信息
    ///   - inputBox: 把当前的textView或TextField传进去
    public func sendTextMessage(message: String, inputBox: AnyObject?) {
        self.keyboardToolbarDelegate?.keyboardToolbarSendTextMessage(message: message, inputBox: inputBox)
    }

    func removeToolBar() {
        TSKeyboardToolbar.share.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        }, completion: { (_) in
            self.bgView.removeFromSuperview()
        })
    }

    func emojiClick(emoji: String) {
        originY = ScreenHeight - (self.textToolBarView?.height)! + changeHeight
        self.textToolBarView?.sendTextView.insertText(emoji)
        self.textToolBarView?.sendTextView.scrollRangeToVisible((self.textToolBarView?.sendTextView.selectedRange)!)
    }

    // MARK: - Private
    var isShow = true
    private func changeUI(keyboard: Typist.KeyboardOptions, event: Typist.KeyboardEvent) {
        let window = UIApplication.shared.keyWindow
        guard let mWindow = window else {
            assert(false, "\(TSTextToolBarView.self)没有获取到window")
            return
        }

        let keyboardToolbar = TSKeyboardToolbar.share
        keyboardToolbar.backgroundColor = UIColor.white

        switch event {
        case .willShow:
            textToolBarView?.smileButton.isSelected = false
            setKeyboardToolbarOrigin(keyboard: keyboard, keyboardToolbar: keyboardToolbar, mWindow: mWindow, show: true)
            currentToolBarHeight = keyboardToolbar.bounds.size.height

            self.keyboardToolbarDelegate?.keyboardToolbarFrame(frame: self.frame, type: .popUp)
        case .didShow:
            break
        case .willHide:
            self.keyboardToolbarDelegate?.keyboardWillHide()
            setKeyboardToolbarOrigin(keyboard: keyboard, keyboardToolbar: keyboardToolbar, mWindow: mWindow, show: false)
        case .didHide:
            break
        default:
            break
        }
    }

    private func setKeyboardFun () {
        keyboard.on(event: .willChangeFrame) { (options) in
            TSLogCenter.log.debug("setKeyboardFun" + "\(options)")
            }.on(event: .willShow) { (options) in
                self.changeUI(keyboard: options, event: .willShow)
            }.on(event: .didShow) { (options) in
                self.changeUI(keyboard: options, event: .didShow)
            }.on(event: .willHide) { (options) in
                self.changeUI(keyboard: options, event: .willHide)
            }.on(event: .didHide) { (options) in
                self.changeUI(keyboard: options, event: .didHide)
            }.start()
    }

    @objc private func tapBG() {
//        keyboarddisappear()
        removeToolBar()
    }

    private func setKeyboardToolbarOrigin(keyboard: Typist.KeyboardOptions, keyboardToolbar: TSKeyboardToolbar, mWindow: UIWindow, show: Bool) {
        if show {
            originY = keyboard.endFrame.origin.y - toolBarHeight + emojiHeight
            keyboardToolbar.frame = CGRect(x: 0, y: keyboard.endFrame.origin.y - (toolBarHeight + changeHeight - emojiHeight), width: mWindow.bounds.size.width, height: toolBarHeight + changeHeight)
        } else {
            originY = keyboard.endFrame.origin.y - toolBarHeight + emojiHeight
            keyboardToolbar.frame = CGRect(x: 0, y: ScreenHeight - (toolBarHeight + changeHeight), width: mWindow.bounds.size.width, height: toolBarHeight + changeHeight)
        }
    }

    // MARK: - 测试接口
    public func keyboardTestText() -> String {

        guard let strText = textToolBarView?.sendTextView.text else {
            return "没有数据"
        }
        return strText
    }
}
