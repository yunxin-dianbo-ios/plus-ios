//
//  QuoraStackAvatarContentCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 带头像的内容 cell model

import UIKit

class QuoraStackAvatarContentCellModel: QuoraStackCellModel {

    /// 头像 URL
    var avatarURL: String?
    /// 用户信息
    var user: TSUserInfoModel?
    /// 是否需要围观
    var shouldHiddenContent = false
    /// 用户性别
    var sex = 0
    /// 是否是匿名回答 。
    var isAnonymity: Bool = false
    /// 内容
    var content = ""
    /// 字体大小
    var font: CGFloat = 14
    /// 字体颜色
    var textColor = TSColor.normal.content
    /// 控件左边距边距距离
    var left: CGFloat = 15
    /// 控件右边距边距的距离
    var right: CGFloat = 15
    /// 控件上边距边距距离
    var top: CGFloat = 15
    /// 控件下边距边距距离
    var bottom: CGFloat = 13
    /// 内部控件的高度（这个属性的值由 cell 内部计算，不需要外部传入）
    var avatarAndLabelHeight: CGFloat = 20

    override var cellHeight: CGFloat {
        return top + avatarAndLabelHeight + bottom
    }

    override init() {
        super.init()
    }

    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, font: CGFloat, textColor: UIColor) {
        super.init()
        self.font = font
        self.textColor = textColor
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}
