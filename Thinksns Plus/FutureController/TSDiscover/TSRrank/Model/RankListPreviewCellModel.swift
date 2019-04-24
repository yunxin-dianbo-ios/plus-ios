//
//  RankListPreviewCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  总览榜 cell model

import UIKit

class RankListPreviewCellModel: NSObject {

    // 标题
    var title = ""
    // 用户信息
    var userInfos: [TSUserInfoModel] = []

    init(models: [TSUserInfoModel], title: String) {
        super.init()
        self.title = title
        let count = min(models.count, 5)
        userInfos = Array(models[0..<count])
    }
}
