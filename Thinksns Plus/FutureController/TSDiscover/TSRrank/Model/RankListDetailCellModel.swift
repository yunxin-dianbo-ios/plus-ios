//
//  RankListDetailCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜 detail cell model

import UIKit

class RankListDetailCellModel: NSObject {

    /// 排行名次
    var rank = -1
    /// 用户信息
    var userInfo = TSUserInfoModel()
    /// 榜单相关信息
    var detailInfo = ""

    init(userInfo: TSUserInfoModel, detailInfo: String) {
        super.init()
        self.userInfo = userInfo
        self.detailInfo = detailInfo
    }

}
