//
//  WalletCreateCharegeModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/30.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class WalletCreateCharegeModel: Mappable {

    /// 传给后台的 order
    var order = WalletOrderModel()
    /// 传给 ping++ 的 order
    var pingOrder: Any?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        order <- map["order"]
        pingOrder <- map["pingpp_order"]
    }

}
