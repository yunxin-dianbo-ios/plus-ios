//
//  GroupAgreementModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class GroupAgreementModel: Mappable {

    /// 协议内容
    var agreement = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        agreement <- map["protocol"]
    }
}
