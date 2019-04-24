//
//  TSNewsDiggTaskObject.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSNewsDiggTaskObject: Object {

    /// 资讯id
    dynamic var newsID: Int = -1
    /// 赞状态 0：取消赞， 1：点赞
    dynamic var diggStatus: Int = 0
    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskStatus: Int = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "newsID"
    }
}
