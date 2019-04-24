//
//  TSTextButton.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  文字类按钮
//  此类按钮多用于标题栏右侧取消、发送、保存等文字类型按钮。有两种类型：
//  第一种：字体为 32px , 位于顶部标题栏
//  第二张：字体为 28px , 位于页面其他位置，例如地理位置选择器
//  综上，创建此类按钮，请务必保证设置过按钮的 putAreaType 属性。

import UIKit

private struct TSTextButtonUX {

    // 初始大小（可无视）
    static let InitialFrame = CGRect(x: 0, y: 0, width: 10, height: 44)

    static let ButtonHeight: CGFloat = 44
    /// 按钮左右两边的间距
    static let ButtonSpacing: CGFloat = 10

    static let TitleNormalColor = TSColor.main.theme
    static let TitleDisabledColor = TSColor.normal.disabled

    static let TitleFontTop = UIFont.systemFont(ofSize: 16)
    static let TitleFontNormal = UIFont.systemFont(ofSize: 14)
}

class TSTextButton: TSButton {
    enum TextButtonPutAreaType {
        case top
        case normal
    }

    private var _putAreaType: TextButtonPutAreaType?
    /// 按钮位置类型
    /// - 有 .top (位于顶部标题栏) 和 .normal (其他位置) 两种类型
    var putAreaType: TextButtonPutAreaType? {
        get {
            return _putAreaType
        }
        set(newValue) {
            _putAreaType = newValue
            let buttonTitleFont: UIFont
            if let newValue = newValue {
                switch newValue {
                case .top:
                    buttonTitleFont = TSTextButtonUX.TitleFontTop
                case .normal:
                    buttonTitleFont = TSTextButtonUX.TitleFontNormal
                }
                self.titleLabel?.font = buttonTitleFont
            }
        }
    }

    // MARK: Lifecycle
    /// 初始化方法
    ///
    /// - Parameter putAreaType: 按钮位置类型，有 .top (位于顶部标题栏) 和 .normal (其他位置) 两种类型
    class func initWith(putAreaType: TextButtonPutAreaType) -> TSTextButton {
        let button = TSTextButton(type: .system)
        button.putAreaType = putAreaType
        return button
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = TSTextButtonUX.InitialFrame
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = TSTextButtonUX.InitialFrame
    }

    override func draw(_ rect: CGRect) {
        assert(self._putAreaType != nil, "TSTextButton.swift 55, \(self), TSTextButton 的 putAreaType 不能为 nil")
        updateUX()
        super.draw(rect)
    }

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        updateUX()
    }

    func updateUX() {
        self.setTitleColor(TSTextButtonUX.TitleNormalColor, for: .normal)
        self.setTitleColor(TSTextButtonUX.TitleDisabledColor, for: .disabled)
        // 更新按钮的 size
        if let font = self.titleLabel?.font, let text = self.titleLabel?.text {
            let width = text.sizeOfString(usingFont: font).width
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width + TSTextButtonUX.ButtonSpacing * 2, height: TSTextButtonUX.ButtonHeight)
        }
    }

}
