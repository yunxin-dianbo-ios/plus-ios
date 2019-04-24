//
//  TSFeedAnalogObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态模拟数据

import RealmSwift

class TSFeedAnalogObject: Object {

    /// 动态模拟数据 头像
    dynamic var avatar: String = ""
    /// 动态模拟数据 用户名
    dynamic var name: String = ""
    /// 动态模拟数据 内容
    dynamic var content: String = ""
    /// 动态模拟数据 图片
    dynamic var image: String = ""
    /// 动态模拟数据 时间
    dynamic var time: NSDate = NSDate()
    /// 动态模拟数据 链接
    dynamic var link: String = ""
    dynamic var width: Int = 260
    dynamic var height: Int = 130
}
