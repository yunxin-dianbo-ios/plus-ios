//
//  TSNewsCollectionTaskObject.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSNewsCollectionTaskObject: Object {

    /// 任务标识，格式 userIdentity + "#" + "newsIdentity"
    dynamic var id = ""
    /// 动态 Id
    dynamic var newsIdentity = -1
    /// 当前用户标识
    dynamic var userIdentity = -1
    /// 收藏的状态
    dynamic var collectionState = -1

    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskState = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
