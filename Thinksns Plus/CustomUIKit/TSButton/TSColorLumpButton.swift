//
//  TSColorLumpButton.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  色块填充类型按钮
//  色块填充类型按钮有两种大小，宽度 ＞ 180px 高度 ＞ 60px，称为大按钮；宽度 ≤ 180px 高度 ≤ 60px，称为小按钮。
//  综上，创建此类按钮，请务必保证设置过按钮的 sizeType 属性。
//

import UIKit

private struct TSColorLumpButtonUX {

    static let CornerRadiusLarge = 6.0
    static let CornerRadiusSmall = 4.0

    static let TitleFontLarge = UIFont.systemFont(ofSize: 16)
    static let TitleFontSmall = UIFont.systemFont(ofSize: 14)

    // normal
    static let TitleNormalColor = UIColor.white
    static let BackgroundNormalColor = MainColor().theme

    // highLight
    static let TitleHighLightColor = UIColor.white
    static let BackgroundHighLightColor = TSColor.main.theme.withAlphaComponent(0.7)

    // disable
    static let TitleDisableColor = UIColor.white
    static let BackgroundDisabledColor = NormalColor().disabled
}

class TSColorLumpButton: TSButton {
    enum ButtonSizeType {
        case large
        case small
    }

    private var _sizeType: ButtonSizeType?
    /// 按钮的大小类型
    /// - 有 .large 和 .small 两种类型
    var sizeType: ButtonSizeType? {
        get {
            return _sizeType
        }
        set (newValue) {
            _sizeType = newValue
            if let sizeType = _sizeType {
                setButtonUX(buttonSizeType: sizeType)
            }
        }
    }

    // MARK: Lifecycle
    /// 自定义初始化方法
    ///
    /// - Parameters:
    ///   - sizeType: 按钮的大小类型，有 .large 和 .small 两种类型
    class func initWith(sizeType type: ButtonSizeType) -> TSColorLumpButton {
        let button = TSColorLumpButton(type: .custom)
        button.sizeType = type
        return button
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        assert(_sizeType != nil, "TSColorLumpButton.swift 63,\(self), 色块按钮的大小类型没有设置")
    }

    // MARK: Custom user interface
    func setButtonUX(buttonSizeType: ButtonSizeType) {
        var cornerRadius = 0.0
        var titleFont = UIFont()
        switch buttonSizeType {
        case .large:
            cornerRadius = TSColorLumpButtonUX.CornerRadiusLarge
            titleFont = TSColorLumpButtonUX.TitleFontLarge
        case .small:
            cornerRadius = TSColorLumpButtonUX.CornerRadiusSmall
            titleFont = TSColorLumpButtonUX.TitleFontSmall
        }

        self.setTitleColor(TSColorLumpButtonUX.TitleNormalColor, for: .normal)
        self.setTitleColor(TSColorLumpButtonUX.TitleHighLightColor, for: .highlighted)
        self.setTitleColor(TSColorLumpButtonUX.TitleDisableColor, for: .disabled)

        self.setBackgroundImage(UIImage.imageWithColor(TSColorLumpButtonUX.BackgroundNormalColor, cornerRadius: cornerRadius), for: .normal)
        self.setBackgroundImage(UIImage.imageWithColor(TSColorLumpButtonUX.BackgroundHighLightColor, cornerRadius: cornerRadius), for: .highlighted)
        self.setBackgroundImage(UIImage.imageWithColor(TSColorLumpButtonUX.BackgroundDisabledColor, cornerRadius: cornerRadius), for: .disabled)

        self.titleLabel?.font = titleFont
        self.adjustsImageWhenHighlighted = true

    }

}
