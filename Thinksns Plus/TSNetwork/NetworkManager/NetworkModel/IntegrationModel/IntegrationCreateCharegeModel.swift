//
//  IntegrationCreateCharegeModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class IntegrationCreateCharegeModel: Mappable {

    /// 传给后台的 order
    var order = IntegrationChargeResultModel()
    /// 传给 ping++ 的 order
    var pingOrder: Any?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        order <- map["order"]
        pingOrder <- map["pingpp_order"]
    }

}
