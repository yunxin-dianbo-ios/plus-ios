//
//  TSMomentCollectTaskObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSMomentCollectTaskObject: Object {

    /// 动态 Id
    dynamic var feedIdentity = -1
    /// 收藏的状态
    dynamic var collectState = -1

    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskState = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "feedIdentity"
    }
}
