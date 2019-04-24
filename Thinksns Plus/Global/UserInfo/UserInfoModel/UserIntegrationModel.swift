//
//  UserIntegrationModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class UserIntegrationModel: Mappable {

    var ownerId = 0
    var type = 0
    var sum = 0
    var create = Date()
    var update = Date()

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        ownerId <- map["owner_id"]
        type <- map["type"]
        sum <- map["sum"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }
}
