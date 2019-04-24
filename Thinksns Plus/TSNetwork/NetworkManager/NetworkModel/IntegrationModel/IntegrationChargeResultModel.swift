//
//  IntegrationChargeResultModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class IntegrationChargeResultModel: Mappable {

    var id = 0
    var ownerId = 0
    var title = ""
    var body = ""
    var type = 0
    var targetType = ""
    var targetId = 0
    var currency = 0
    var amount = 0
    var state = 0
    var create = Date()
    var update = Date()

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        ownerId <- map["owner_id"]
        title <- map["title"]
        body <- map["body"]
        type <- map["type"]
        targetType <- map["target_type"]
        targetId <- map["target_id"]
        currency <- map["currency"]
        amount <- map["amount"]
        state <- map["state"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }
}
