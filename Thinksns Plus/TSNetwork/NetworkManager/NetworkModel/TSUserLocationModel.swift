//
//  TSUserLocationModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  向后台发送经纬度获取到的定位地址数据模型

import ObjectMapper

class TSUserLocationModel: Mappable {
    // 高德数据id
    var id: Int = -1
    // 经纬度坐标
    var location: String = ""
    // name
    var name: String = ""
    // 地址(暂时可忽略)
    var address: String = ""
    // ts+用户id
    var userId: Int = -1
    // 数据创建时间
    var create: Date = Date()
    // 数据更新时间
    var update: Date = Date()
    // 省
    var province: String = ""
    // 市
    var city: String = ""
    // 区
    var district: String = ""
    // 到中心坐标的距离
    var distance: String = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["_id"]
        location <- map["_location"]
        name <- map["_name"]
        address <- map["_address"]
        userId <- map["user_id"]
        create <- map["_createtime"]
        update <- map["_updatetime"]
        province <- map["_province"]
        city <- map["_city"]
        district <- map["_district"]
        distance <- map["_distance"]
    }

    func latitudes() -> String? {
        let info = location.components(separatedBy: ",")
        return info.last
    }

    func longitudes() -> String? {
        let info = location.components(separatedBy: ",")
        return info.first
    }
}
