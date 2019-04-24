//
//  TSCurrentUserManagerAuthority.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/11/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSCurrentUserManagerAuthority: Mappable {

    /**
     "name": "[feed] Delete Feed",
     "display_name": "[动态]->删除动态",
     "description": "删除动态权限"
    */
    /// 权限类型
    var name = ""
    /// 默认权限描述
    var display_name = ""
    /// 权限描述
    var desc = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        name <- map["name"]
        display_name <- map["display_name"]
        desc <- map["description"]
    }

}
