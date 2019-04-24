//
//  StackSeperatorCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 分割线 cell

import UIKit

class StackSeperatorCellModel: QuoraStackCellModel {

    /// 颜色
    var lineColor = TSColor.normal.background
    /// 高度，默认为 2px
    var height: CGFloat = 1
    /// 控件左边距边距距离
    var left: CGFloat = 0
    /// 控件右边距边距的距离
    var right: CGFloat = 0
    /// 控件下边距边距的距离
    var bottom: CGFloat = 0
    /// 控件上边距边距的距离
    var top: CGFloat = 0

    override var cellHeight: CGFloat {
        return top + height + bottom
    }
}
