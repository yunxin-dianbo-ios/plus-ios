//
//  TSMomentCommnetObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 - 动态评论表

import UIKit
import RealmSwift

class TSMomentCommnetObject: Object {

    /// 动态的ID
    dynamic var feedId = 0
    /// 评论标识
    dynamic var commentIdentity = 0
    /// 创建时间
    dynamic var create: NSDate? = nil
    /// 内容
    dynamic var content = ""
    /// 评论者id
    dynamic var userIdentity = 0
    /// 动态作者id
    dynamic var toUserIdentity = 0
    /// 被回复者id
    dynamic var replayToUserIdentity = 0
    /// 发送状态 0为成功或者发送中， 1为失败
    dynamic var status = 0
    /// 唯一的id
    dynamic var commentMark: Int64 = 0

    // MARK: V2 接口数据

    // 是否是被固定（置顶）的评论
    let painned = RealmOptional<Int>()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "commentMark"
    }
}
