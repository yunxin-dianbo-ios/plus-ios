//
//  QuoraStackFullImageCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 拉伸图片 cell model

import UIKit

class QuoraStackFullImageCellModel: QuoraStackCellModel {

    // 图片 URL
    var imageURL: URL?

    // 图片高度
    var imageHeight: CGFloat = 150
    /// 控件上边距边距距离
    var top: CGFloat = 15
    /// 控件下边距边距的距离
    var bottom: CGFloat = 0

    override var cellHeight: CGFloat {
        return imageHeight + top + bottom
    }

    override init() {
        super.init()
    }

    init(imageHeight: CGFloat, top: CGFloat, bottom: CGFloat) {
        super.init()
        self.imageHeight = imageHeight
        self.top = top
        self.bottom = bottom
    }
}
