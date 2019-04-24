//
//  TSNewsRewardModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSNewsRewardModel: Mappable {
    var id: Int!
    var userId: Int!
    // 打赏数据 单位人民币分
    var amount: Int!
    var user: TSUserInfoModel!
    var created: String!
    var realAmount: Double {
        return Double(amount) / 100.0
    }
    var createdDate: NSDate {
        return created.convertToDate()
    }

    init(userId: Int, amount: Int, user: TSUserInfoModel) {
        self.id = 0
        self.userId = userId
        self.user = user
        self.amount = amount
        self.created = Date().string(format: "yyyy-MM-dd HH:mm:ss", timeZone: nil)
    }

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        amount <- map["amount"]
        user <- map["user"]
        created <- map["created_at"]
    }
}
