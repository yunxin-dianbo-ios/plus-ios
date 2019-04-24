//
//  RankListCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜 normal cell model

import UIKit

class RankListCellModel: NSObject {

    /// 排行名次
    var rank = -1
    /// 用户信息
    var userInfo = TSUserInfoModel()

    init(userInfo: TSUserInfoModel) {
        super.init()
        self.userInfo = userInfo
    }
}
