//
//  FilterSectionViewModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  带有过滤弹窗按钮的 section view model

import UIKit

class FilterSectionViewModel {

    /// 数量信息
    var countInfo = ""
    /// 过滤信息数组
    var filterInfo: [String] = []
    /// 话题详情页
    var followStatus = false
    var hidFolloeButton = false
}
