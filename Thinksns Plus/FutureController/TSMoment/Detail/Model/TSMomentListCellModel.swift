//
//  TSMomentListCellModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 cell 数据模型

import UIKit

struct TSMomentListCellModel {

    // 用户信息
    var userInfo: TSUserInfoObject? = nil
    // 动态数据模型
    var data: TSMomentListObject? = nil
    // 评论数据模型
    var comments: [TSSimpleCommentModel]? = nil
    // cell 高度
    var height: CGFloat = UIScreen.main.bounds.height
    // 是否显示置顶标签
    var isShowTopTag = false

    // MARK: 广告相关

    /// 该 model 是否由广告转化的
    var isAdvert = false
    /// 广告的跳转链接
    var advertLink: String?
}
