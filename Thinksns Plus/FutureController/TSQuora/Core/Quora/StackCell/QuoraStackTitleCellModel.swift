//
//  QuoraStackTitleCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 标题 cell model

import UIKit

class QuoraStackTitleCellModel: QuoraStackCellModel {

    /// 尾部图片类型
    enum AppendImageType {
        /// 加精标签
        case excellent
    }

    /// 标题内容
    var title = ""
    /// 尾部图片
    var appendImage: AppendImageType?

    /// 字体大小
    var font: CGFloat = 16
    /// 字体颜色
    var textColor = TSColor.main.content
    /// 控件左边距边距距离
    var left: CGFloat = 15
    /// 控件右边距边距的距离
    var right: CGFloat = 15
    /// 控件下边距边距的距离
    var bottom: CGFloat = 0
    /// 控件上边距边距的距离
    var top: CGFloat = 0

    /// 内部控件的总高度 （这个属性的值由 cell 内部计算，不需要外部传入）
    var labelHeight: CGFloat = 20

    override var cellHeight: CGFloat {
        return top + labelHeight + bottom
    }

    override init() {
        super.init()
    }

    init(font: CGFloat, textColor: UIColor, left: CGFloat, right: CGFloat, bottom: CGFloat, top: CGFloat) {
        super.init()
        self.font = font
        self.textColor = textColor
        self.left = left
        self.right = right
        self.bottom = bottom
        self.top = top
    }
}
