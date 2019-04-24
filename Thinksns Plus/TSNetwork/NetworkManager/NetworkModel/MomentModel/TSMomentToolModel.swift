//
//  TSMomentToolModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态工具栏数据模型

import UIKit
import SwiftyJSON

struct TSMomentToolModel {

    // [长期注释] 为方便 v2 的数据接入，增加了初始值

    /// 点赞数
    var digg: Int = 0
    /// 浏览量
    var view: Int = 0
    /// 评论数
    var comment: Int = 0
    /// 当前用户是否有点在，0 为否，1 为是
    var isDigg: Int = 0
    /// 当前用户是否有收藏，0 为否，1 为是
    var isCollect: Int = 0

}

extension TSMomentToolModel {
    init(_ json: [String: Any]) {
        let jsonData = JSON(json).dictionaryValue
        self.digg = jsonData["feed_digg_count"]!.int!
        self.view = jsonData["feed_view_count"]!.int!
        self.comment = jsonData["feed_comment_count"]!.int!
        self.isDigg = jsonData["is_digg_feed"]!.int!
        self.isCollect = jsonData["is_collection_feed"]!.int!
    }
}
