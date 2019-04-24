//
//  TSTagCategoryModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  用户标签分类模型，含有该分类下的标签列表

import Foundation
import ObjectMapper

class TSTagCategoryModel: Mappable {
    /// 标签的分类id
    var id: Int = 0
    /// 标签的分类名称
    var name: String = ""
    /// 标签列表
    var tags: [TSTagModel] = [TSTagModel]()

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        tags <- map["tags"]
    }
}
