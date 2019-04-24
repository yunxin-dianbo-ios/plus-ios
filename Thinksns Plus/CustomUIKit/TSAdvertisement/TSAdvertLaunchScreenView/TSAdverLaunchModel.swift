//
//  TSAdverLaunchModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSAdverLaunchModel {

    /// 已经播放的时间，由广告视图内部设置，初始化 model 时设为 0 即可。
    var alreadyTimeInterval = 0
    /// 是否可以跳过当前广告
    var canSkip = true
    /// 广告显示时长
    var timeInterval = 5

    /// 广告视图数据
    var advertModel: TSAdvertViewModel
}

extension TSAdverLaunchModel {
    /// 初始化
    init(object: TSAdvertObject) {
        advertModel = TSAdvertViewModel(object: object)
        self.timeInterval = object.imageDuration
    }
}
