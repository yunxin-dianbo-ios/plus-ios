//
//  TSLocationModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import ObjectMapper

struct TSLocationModel: Mappable {

    /// 地址全称
    var formattedAddress: String?
    /// 城市标号
    var cityCode: String?
    /// 省
    var province: String?
    /// 市
    var city: String?
    /// 区
    var district: String?
    /// 经纬度
    var location: String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        formattedAddress <- map["formatted_address"]
        cityCode <- map["citycode"]
        province <- map["province"]
        city <- map["city"]
        district <- map["district"]
        location <- map["location"]
    }

    func latitudes() -> String? {
        let info = location?.components(separatedBy: ",")
        return info?.last
    }

    func longitudes() -> String? {
        let info = location?.components(separatedBy: ",")
        return info?.first
    }
}
