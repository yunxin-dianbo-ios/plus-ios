//
//  AppVersionCheckModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/11/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class AppVersionCheckModel: Mappable {

    /**
     "id": 1,
     "type": "ios",
     "version": "1.0.0",
     "version_code": 0,
     "description": "更新一次",
     "link": "https://itunes.apple.com/cn/app/%E6%94%AF%E4%BB%98%E5%AE%9D-%E8%AE%A9%E7%94%9F%E6%B4%BB%E6%9B%B4%E7%AE%80%E5%8D%95/id333206289?mt=8",
     "is_forced": 0,
     "created_at": "2018-11-09 02:05:18",
     "updated_at": "2018-11-09 02:05:18"
    */

    /// 版本数据id
    var id = -1
    /// 客服端类型
    var type = ""
    /// 客服端类型
    var version = ""
    /// 客服端类型
    var version_code = 0
    /// 客服端类型
    var description = ""
    /// 客服端类型
    var link = ""
    /// 客服端类型
    var is_forced = false

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        version <- map["version"]
        version_code <- map["version_code"]
        description <- map["description"]
        link <- map["link"]
        is_forced <- map["is_forced"]
    }

}
