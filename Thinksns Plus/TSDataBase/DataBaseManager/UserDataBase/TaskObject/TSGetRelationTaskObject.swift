//
//  TSGetRelationTaskObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSGetRelationTaskObject: Object {

    /// 当前用户标识
    dynamic var userIdentity = -1

    /// 任务的完成状态，0 未完成，1 已完成，2 进行中
    dynamic var taskState = 2

    /// 设置主键
    override static func primaryKey() -> String? {
        return "userIdentity"
    }
}
