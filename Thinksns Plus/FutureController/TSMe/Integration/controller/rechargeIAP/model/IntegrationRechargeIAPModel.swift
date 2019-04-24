//
//  IntegrationRechargeModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

struct IAPProductModel: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["product_id"]
        name <- map["name"]
        appleId <- map["apple_id"]
        amount <- (map["amount"], SingleStringTransform())
    }

    var id: String = ""
    var name: String = ""
    var appleId: String = ""
    var amount: Int = 0
    // 兑换比例,来自积分配置接口
    var ratio: Int = 0
    // 积分规则,来自积分配置接口
    var rule: String = "请配置IAP\(TSAppConfig.share.localInfo.goldName)规则"
}
