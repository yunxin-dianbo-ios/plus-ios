//
//  GroupCategoriesModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子分类数据模型

import UIKit
import ObjectMapper

class GroupCategoriesModel: Mappable {

    var id = 0
    /// 圈子分类名称
    var name = ""
    /// 圈子排序权重
    var sortby = 0
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        sortby <- map["sort_by"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }
}
