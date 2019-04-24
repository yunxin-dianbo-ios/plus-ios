//
//  GroupLocationModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子定位模型

import Foundation
import objc_geohash

struct GroupLocationModel {
    /// 地区
    var location: String = ""
    /// 纬度
    var latitude: String = ""
    /// 经度
    var longitude: String = ""
    /// geoHash
    var geoHash: String = ""

    init(poi: AMapPOI) {
        self.location = poi.name
        self.latitude = "\(poi.location.latitude)"
        self.longitude = "\(poi.location.longitude)"
        // 构建geoHash
        if let box: GeohashBox = Geohash.geohashbox(latitude: Double(poi.location.latitude), longitude: Double(poi.location.longitude)) {
            self.geoHash = box.hash
        }
    }

}
