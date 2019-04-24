//
//  TSSystemMessageObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  系统消息 数据库数据

import UIKit
import RealmSwift

class TSSystemMessageObject: Object {

    /// 数据id
    dynamic var id = -1
    /// 会话类型
    dynamic var type = ""
    /// 发送者id 系统通知时为0
    dynamic var userId = -1
    /// 接收者id 系统广播通知及意见反馈时为0
    dynamic var toUserId = -1
    /// 内容
    dynamic var content: String?
    /// 系统通知额外扩展参数
    dynamic var options: String?
    /// 创建时间
    dynamic var creatTime = NSDate()
    /// 更新时间
    dynamic var updateTime = NSDate()
    /// 系统消息标识
    dynamic var systemMark = -1

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
