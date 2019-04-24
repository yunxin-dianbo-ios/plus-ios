//
//  TSToolbarItemModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  工具栏 item 数据配置类

import UIKit

class TSToolbarItemModel: NSObject {

    /// 图像
    var image: String? = nil
    /// 标题
    var title: String? = nil
    /// 表示 item 在工具栏上的位置坐标，有且仅有 0、1、2、3 这四种值，原因是根据 UI 的定义，工具栏上的按钮最多不会超过 4 个
    var index: Int = -1

    // MARK: - Lifecycle
    private override init() {
        super.init()
    }

    /// 自定义初始化方法
    ///
    /// - Parameters:
    ///   - imageValue: 图片名称
    ///   - titleValue: 标题
    ///   - indexValue: 位置坐标，有且仅有 0、1、2、3 这四种值，原因是根据 UI 的定义，工具栏上的按钮最多不会超过 4 个
    init(image imageValue: String?, title titleValue: String?, index indexValue: Int) {
        super.init()
        image = imageValue
        title = titleValue
        index = indexValue
    }

}
