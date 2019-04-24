//
//  QuoraStackBottomButtonsCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 包含问答中“关注/回答/悬赏”三按钮的 cell model

import UIKit

class QuoraStackBottomButtonsCellModel: QuoraStackCellModel {

    /// 关注数
    var followCount = 0
    /// 回答数
    var answerCount = 0
    /// 悬赏金额
    var rewardNumber: Int = 0
    /// 时间
    var time = NSDate()

    /// 控件左边距边距距离
    var left: CGFloat = 10
    /// 控件右边距边距的距离
    var right: CGFloat = 10
    /// 控件上边距边距的位置
    var top: CGFloat = 10
    /// 控件下边距边距的位置
    var bottom: CGFloat = 0

    /// 内部控件的总高度 （这个属性的值由 cell 内部计算，不需要外部传入）
    var buttonsHeight: CGFloat = 20

    override var cellHeight: CGFloat {
        return top + buttonsHeight + bottom
    }

    override init() {
        super.init()
    }

    init(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        super.init()
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}
