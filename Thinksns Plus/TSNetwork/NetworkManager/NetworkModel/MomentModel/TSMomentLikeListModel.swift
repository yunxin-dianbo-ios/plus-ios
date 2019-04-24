//
//  TSMomentLikeListModel.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞榜模型

import UIKit
import SwiftyJSON

struct TSMomentLikeListModel {
    /// 排序id
    var feedDiggId = 0
    /// 用户id
    var userId = 0
    // 目标用户
    var targetUser = -1
    // 目标内容ID
    var likeableId = -1
    // 目标来源
    var likeableType = ""
    // 点赞时间
    var created = NSDate()
    // 点赞更新时间
    var updated: NSDate?

}

extension TSMomentLikeListModel {

    init(_ json: [String: Any]) {
        let jsonData = JSON(json).dictionaryValue
        self.feedDiggId = (jsonData["id"]?.int)!
        self.userId = (jsonData["user_id"]?.int)!
        self.targetUser = (jsonData["target_user"]?.int)!
        self.likeableId = (jsonData["likeable_id"]?.int)!
        self.likeableType = (jsonData["likeable_type"]?.string)!
        self.created = (jsonData["created_at"]?.string)!.convertToDate()
        self.updated = jsonData["updated_at"]?.string?.convertToDate()
    }
}

struct TSMomentLikeListPostModel {
    var id = -1
    var userId = -1

    init(_ json: [String: Any]) {
        id = json["id"] as! Int
        userId = json["user_id"] as! Int
    }
}
