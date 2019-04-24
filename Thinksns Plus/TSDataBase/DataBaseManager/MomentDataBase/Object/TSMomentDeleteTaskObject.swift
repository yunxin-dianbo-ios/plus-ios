//
//  TSMomentDeleteTaskObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 17/4/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 - 未完成的删除任务表

import UIKit
import RealmSwift

class TSMomentDeleteTaskObject: Object {

    /// 动态 Id
    dynamic var feedIdentity = -1

    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskState = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "feedIdentity"
    }
}
