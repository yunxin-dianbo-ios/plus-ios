//
//  TSGroupPostPublishModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 06/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子帖子的发布模型

import Foundation

class TSGroupPostPublishModel {

    /// 帖子标题
    var title: String = ""
    /// 帖子内容
    var body: String = ""
    /// 列表专用字段，概述，简短内容
    var summary: String = ""
    /// 文件id,例如[1,2,3]
    var images: [Int] = [Int]()
    /// 同步至动态，同步需要传sync_feed = 1
    var sync_feed: Int = 0
    /// 设备标示 同步动态需要传 1:pc 2:h5 3:ios 4:android 5:其他
    var feed_from: Int = 3

    /// 编辑时的帖子id
    var id: Int?

}
