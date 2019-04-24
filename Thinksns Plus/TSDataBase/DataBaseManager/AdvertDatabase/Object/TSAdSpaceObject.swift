//
//  TSAdSpaceObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告位数据模型

import RealmSwift

class TSAdSpaceObject: Object {

    // 广告位的位置类型
    dynamic var space = ""
    // 广告位 id 数据
    dynamic var id = -1

    /// 设置主键
    override static func primaryKey() -> String? {
        return "space"
    }
}

extension TSAdSpaceObject {

    /// 解析 json 数据的初始化方式
    class func object(for data: [String: Any]) -> TSAdSpaceObject {
        let object = TSAdSpaceObject()
        object.space = data["space"] as! String
        object.id = data["id"] as! Int
        return object
    }

}
