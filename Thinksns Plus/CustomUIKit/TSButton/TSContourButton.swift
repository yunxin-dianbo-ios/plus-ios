//
//  TSContourButton.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  描边类型按钮（幽灵按钮）
//  幽灵按钮有两种大小，宽度 ＞ 180px 高度 ＞ 60px，称为大按钮；宽度 ≤ 180px 高度 ≤ 60px，称为小按钮。
//  幽灵按钮有两种颜色类型，一种适用于深色背景，一种适用于浅色背景
//  综上，创建此类按钮，请务必保证这设置按钮的 colorType 和 sizeType 属性。
//

import UIKit

private struct TSContourButtonUX {

    static let CornerRadiusLarge = 6.0
    static let CornerRadiusSmall = 4.0

    static let TitleFontLarge = UIFont.systemFont(ofSize: 16)
    static let TitleFontSmall = UIFont.systemFont(ofSize: 14)

    static let BoarderWidthLarge: CGFloat = 1.0
    static let BoarderWidthSmall: CGFloat = 0.5

    // normal
    static let TitleNormalLightColor = MainColor().theme
    static let BackgroundNormalLightColor = UIColor.clear
    static let BorderNormalLightColor = MainColor().theme

    static let TitleNormalDarkColor = UIColor(hex: 0xffffff)
    static let BackgroundNormalDarkColor = UIColor.clear
    static let BorderNormalDarkColor = UIColor(hex: 0xffffff)

    // highLight
    static let TitleHighLightLightColor = MainColor().theme
    static let BackgroundHighLightLightColor = UIColor(hex: 0x59b6d7, alpha: 0.08)
    static let BorderHighLightLightColor = MainColor().theme

    static let TitleHighLightDarkColor = UIColor(hex: 0xffffff)
    static let BackgroundHighLightDarkColor = UIColor(hex: 0xffffff, alpha: 0.08)
    static let BorderHighLightDarkColor = UIColor(hex: 0xffffff)

    // disable
    static let TitleDisableLightColor = NormalColor().disabled
    static let BackgroundDisabledLightColor = UIColor.clear
    static let BorderDisableLightColor = NormalColor().disabled

    static let TitleDisableDarkColor = NormalColor().disabled
    static let BackgroundDisabledDarkColor = UIColor.clear
    static let BorderDisableDarkColor = NormalColor().disabled
}

class TSContourButton: TSButton {
    enum ContourButtonSizeType {
        case large
        case small
    }

    /// 按钮的颜色类型
    ///
    /// - dark: 适用于深色背景
    /// - light: 适用于浅色背景
    enum ContourButtonColorType {
        case dark
        case light
    }

    private var _sizeType: ContourButtonSizeType? = nil
    /// 按钮的大小类型
    /// - 有 .large 和 .small 两种类型
    var sizeType: ContourButtonSizeType? {
        get {
            return _sizeType
        }
        set (newValue) {
            _sizeType = newValue
            if let newValue = newValue {
                makeButtonUX(buttonSizeType: newValue)
            }
        }
    }

    private var _colorType: ContourButtonColorType? = nil
    /// 按钮颜色类型
    /// - 有 .dark (适用于深色背景) 和 .light (使用于浅色背景) 两种类型
    var colorType: ContourButtonColorType? {
        get {
            return _colorType
        }
        set (newValue) {
            _colorType = newValue
            if let newValue = newValue {
                setButtonUX(buttonColorType: newValue)
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            var highLightColor = UIColor.clear
            var normalColor = UIColor.clear
            if let colorType = colorType {
                switch colorType {
                case .dark:
                    highLightColor = TSContourButtonUX.BorderHighLightDarkColor
                    normalColor = TSContourButtonUX.BorderNormalDarkColor
                case .light:
                    highLightColor = TSContourButtonUX.BorderHighLightLightColor
                    normalColor = TSContourButtonUX.BorderNormalLightColor
                }
                switch isHighlighted {
                case true:
                    layer.borderColor = highLightColor.cgColor
                case false:
                    layer.borderColor = normalColor.cgColor
                }
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            var disableColor = UIColor.clear
            var normalColor = UIColor.clear
            if let colorType = colorType {
                switch colorType {
                case .dark:
                    disableColor = TSContourButtonUX.BorderDisableDarkColor
                    normalColor = TSContourButtonUX.BorderNormalDarkColor
                case .light:
                    disableColor = TSContourButtonUX.BorderDisableLightColor
                    normalColor = TSContourButtonUX.BorderNormalLightColor
                }
            }

            switch isEnabled {
            case true:
                layer.borderColor = normalColor.cgColor
            case false:
                layer.borderColor = disableColor.cgColor
            }
        }
    }

    // MARK: Lifecycle
    /// 自定义初始化方法
    ///
    /// - Parameters:
    ///   - sizeType: 按钮的大小类型，有 .large 和 .small 两种类型
    ///   - colorType: 按钮颜色类型，有 .dark (适用于深色背景) 和 .light (使用于浅色背景) 两种类型
    class func initWith(sizeType: ContourButtonSizeType!, colorType: ContourButtonColorType!) -> TSContourButton {
        let button = TSContourButton(type: .custom)
        button.sizeType = sizeType
        button.colorType = colorType
        return button
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        assert(_colorType != nil, "TSContourButton.swift 150,\(self), 描边按钮（幽灵按钮）的颜色类型没有设置")
        assert(_sizeType != nil, "TSContourButton.swift 151,\(self), 描边按钮（幽灵按钮）的大小类型没有设置")
    }

    // MARK: Custom user interface
    func setButtonUX(buttonColorType: ContourButtonColorType) {
        var normalTitleColor = UIColor.clear
        var normalBackgroundColor = UIColor.clear
        var highLightTitleColor = UIColor.clear
        var highLightBackgroundColor = UIColor.clear
        var disableTitleColor = UIColor.clear
        var disableBackGroundColor = UIColor.clear

        switch buttonColorType {
        case .dark:
            normalTitleColor = TSContourButtonUX.TitleNormalDarkColor
            normalBackgroundColor = TSContourButtonUX.BackgroundNormalDarkColor
            highLightTitleColor = TSContourButtonUX.TitleHighLightDarkColor
            highLightBackgroundColor = TSContourButtonUX.BackgroundHighLightDarkColor
            disableTitleColor = TSContourButtonUX.TitleDisableDarkColor
            disableBackGroundColor = TSContourButtonUX.BackgroundDisabledDarkColor
        case .light:
            normalTitleColor = TSContourButtonUX.TitleNormalLightColor
            normalBackgroundColor = TSContourButtonUX.BackgroundNormalLightColor
            highLightTitleColor = TSContourButtonUX.TitleHighLightLightColor
            highLightBackgroundColor = TSContourButtonUX.BackgroundHighLightLightColor
            disableTitleColor = TSContourButtonUX.TitleDisableLightColor
            disableBackGroundColor = TSContourButtonUX.BackgroundDisabledLightColor
        }
        self.setTitleColor(normalTitleColor, for: .normal)
        self.setTitleColor(highLightTitleColor, for: .highlighted)
        self.setTitleColor(disableTitleColor, for: .disabled)

        self.setBackgroundImage(UIImage.imageWithColor(normalBackgroundColor, cornerRadius: 0.0), for: .normal)
        self.setBackgroundImage(UIImage.imageWithColor(highLightBackgroundColor, cornerRadius: 0.0), for: .highlighted)
        self.setBackgroundImage(UIImage.imageWithColor(disableBackGroundColor, cornerRadius: 0.0), for: .disabled)
    }

    func makeButtonUX(buttonSizeType: ContourButtonSizeType) {
        var cornerRadius = 0.0
        var titleFont = UIFont()
        var boarderWidth: CGFloat = 0.0

        switch buttonSizeType {
        case .large:
            cornerRadius = TSContourButtonUX.CornerRadiusLarge
            titleFont = TSContourButtonUX.TitleFontLarge
            boarderWidth = TSContourButtonUX.BoarderWidthLarge
        case .small:
            cornerRadius = TSContourButtonUX.CornerRadiusSmall
            titleFont = TSContourButtonUX.TitleFontSmall
            boarderWidth = TSContourButtonUX.BoarderWidthSmall
        }

        self.layer.borderWidth = boarderWidth
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderColor = NormalColor().disabled.cgColor
        self.clipsToBounds = true
        self.titleLabel?.font = titleFont
        self.adjustsImageWhenHighlighted = true

    }

}
