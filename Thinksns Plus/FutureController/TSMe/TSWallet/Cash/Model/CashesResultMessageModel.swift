//
//  CashesResultMessageModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/18.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class CashesResultMessageModel: Mappable {

    // 金额错误
    var value: [String] = []
    // 提现方式错误
    var type: [String] = []
    // 账户错误
    var account: [String] = []
    // 申请结果
    var message: [String] = []

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        value <- map["value"]
        type <- map["type"]
        account <- map["account"]
        message <- map["message"]
    }

    func getOneMessage() -> String? {
        var infos = value + type + account + message
        guard !infos.isEmpty else {
            return nil
        }
        return infos.first
    }

}
