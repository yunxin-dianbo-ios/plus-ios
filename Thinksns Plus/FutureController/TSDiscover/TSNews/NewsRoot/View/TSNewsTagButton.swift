//
//  TSNewsTagButton.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSNewsTagButtonUX {
    /// 未选中状态下的标题字号
    static let normalTitleFont = UIFont.systemFont(ofSize: 14)
    /// 选中状态下的标题字号
    static let selectedTitleFont = UIFont.systemFont(ofSize: 16)
    /// 未选中状态下的标题字体颜色
    static let normalTitleColor = TSColor.normal.secondary
    /// 选中状态下的标题字体颜色
    static let selectedTitleColor = TSColor.normal.blackTitle
    /// 按钮高度
    static let buttonHeight: CGFloat = 44
}

class TSNewsTagButton: TSButton {
    /// 通过frame和标题来初始化
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        self.frame = CGRect(x: frame.minX, y: 0.0, width: frame.width, height: TSNewsTagButtonUX.buttonHeight)
        self.layoutViews(WithTitle: title)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - UI
    func layoutViews(WithTitle title: String) {
        self.setTitle(title, for: UIControlState.normal)
        self.setTitleColor(TSNewsTagButtonUX.normalTitleColor, for: UIControlState.normal)
        self.titleLabel?.font = TSNewsTagButtonUX.normalTitleFont
    }

    /// 计算按钮的宽度 （依照未点击状态下的标题字体大小来计算）
    ///
    /// - Parameter title: 标题
    /// - Returns: 按钮宽度
    class func caculateButtonWidth(WithTitle title: String) -> CGFloat {
        let textSize = title.heightWithConstrainedWidth(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT), font: TSNewsTagButtonUX.normalTitleFont)
        var buttonWidth = textSize.width
        buttonWidth += 20
        return buttonWidth
    }
}
