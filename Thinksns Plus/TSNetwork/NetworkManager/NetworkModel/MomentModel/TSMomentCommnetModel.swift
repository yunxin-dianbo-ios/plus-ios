//
//  TSMomentCommnetModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态评论数据模型

import UIKit
import SwiftyJSON

struct TSMomentCommnetModel {

    /// 评论标识
    var commentIdentity: Int
    /// 创建时间
    var create: NSDate
    /// 内容
    var content: String
    /// 评论者id
    var userIdentity: Int
    /// 动态作者id
    var toUserIdentity: Int
    /// 被回复者id
    var replayToUserIdentity: Int
    /// 唯一Id
    var commentMark: Int64

    // MARK: V2 接口数据

    // 是否是被固定（置顶）的评论
    var painned: Int?
}

extension TSMomentCommnetModel {
    init(postComment json: [String: Any]) {
        let jsonData = JSON(json).dictionaryValue
        commentIdentity = jsonData["id"]!.int!
        create = (jsonData["created_at"]?.string!.convertToDate())!
        content = jsonData["body"]!.string!
        userIdentity = jsonData["user_id"]!.int!
        toUserIdentity = jsonData["target_user"]!.int!
        replayToUserIdentity = jsonData["reply_user"]!.int!
        commentMark = jsonData["id"]!.int64Value
    }

    init(_ json: [String: Any]) {
        let jsonData = JSON(json).dictionaryValue
        self.commentIdentity = jsonData["id"]!.int!
        let dateString = jsonData["created_at"]?.string!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.create = (dateString?.convertToDate())!
        self.content = jsonData["body"]!.string!
        self.userIdentity = jsonData["user_id"]!.int!
        self.toUserIdentity = jsonData["target_user"]!.int!
        self.replayToUserIdentity = jsonData["reply_user"]!.int!
        self.commentMark = jsonData["id"]!.int64Value
        if let pinnedData = jsonData["pinned"]?.boolValue {
            self.painned = pinnedData ? 1 : 0
        }
        self.painned = jsonData["pinned"]?.int
    }
}
