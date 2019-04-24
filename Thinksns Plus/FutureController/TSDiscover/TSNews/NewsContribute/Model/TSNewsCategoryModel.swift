//
//  TSNewsCategoryModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯分类的数据模型/资讯栏目的数据模型

import Foundation
import ObjectMapper

struct TSNewsCategoryModel: Mappable {
    var id: Int = 0
    var name: String = ""

    // MARK: - Mappable
    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    init(newsCategory: NewsCategoryModel) {
        self.id = newsCategory.id
        self.name = newsCategory.name
    }
}
