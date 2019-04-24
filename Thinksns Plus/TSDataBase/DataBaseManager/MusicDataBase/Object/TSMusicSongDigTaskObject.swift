//
//  TSMusicSongDigTaskObject.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSMusicSongDigTaskObject: Object {

    /// 任务标识，格式 userIdentity + "#" + "songIdentity"
    dynamic var id = ""
    /// 专辑 Id
    dynamic var songIdentity = -1
    /// 当前用户标识
    dynamic var userIdentity = -1
    /// 点赞的状态
    dynamic var digState = -1

    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskState = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }

}
