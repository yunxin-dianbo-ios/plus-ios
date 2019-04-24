//
//  TSMomentTaskObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/28.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 - 未完成任务表

import UIKit
import RealmSwift

class TSMomentDiggTaskObject: Object {

    /// 动态 Id
    dynamic var feedIdentity = -1
    /// 赞的状态
    dynamic var diggState = -1

    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskState = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "feedIdentity"
    }
}
