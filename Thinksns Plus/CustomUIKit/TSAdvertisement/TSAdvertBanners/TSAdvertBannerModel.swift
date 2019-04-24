//
//  TSAdvertBannerModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSAdvertBannerModel {

    /// 标题
    var title: String? = nil
    /// 广告视图数据
    var advertModel: TSAdvertViewModel
}

extension TSAdvertBannerModel {

    /// 初始化
    init(object: TSAdvertObject) {
        title = object.title
        advertModel = TSAdvertViewModel(object: object)
    }

}
