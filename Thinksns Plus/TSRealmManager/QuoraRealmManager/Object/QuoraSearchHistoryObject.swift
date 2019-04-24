//
//  QuoraSearchHistoryObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答搜索历史记录数据模型

import RealmSwift

class QuoraSearchHistoryObject: Object {

    enum SearchType: Int {
        /// 话题搜索
        case topic
        /// 问题搜索
        case question
        /// 主页搜索
        case homeSearch
    }

    /// 时间戳
    dynamic var timeInterval: Int = 0
    /// 搜索内容
    dynamic var content = ""
    /// 搜索类型
    dynamic var typeId = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "timeInterval"
    }
}
