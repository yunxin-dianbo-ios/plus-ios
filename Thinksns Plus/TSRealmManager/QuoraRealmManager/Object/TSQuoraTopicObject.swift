//
//  TSQuoraTopicObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答话题 数据库 数据模型

import RealmSwift

class TSQuoraTopicObject: Object {
    /// 话题ID
    dynamic var id = 0
    /// 话题名称
    dynamic var name = ""
    /// 话题描述
    dynamic var topicDescription = ""
    /// 话题下的问题数量统计
    dynamic var questionsCount = 0
    /// 话题下的关注用户统计
    dynamic var followsCount = 0
    /// 话题头像，如果存在则为「字符串」，否则固定值 null
    dynamic var avatar: TSNetFileObject?
    /// 专家列表
    let experts = List<TSUserInfoObject>()
    var expertsCount = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
