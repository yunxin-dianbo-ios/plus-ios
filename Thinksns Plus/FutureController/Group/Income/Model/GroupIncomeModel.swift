//
//  GroupIncomeModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子收益的数据模型

import Foundation
import ObjectMapper

class GroupIncomeModel: Mappable {

    var id: Int = 0
    var groupId: Int = 0
    var subject: String = ""
    var type: Int = 0
    var amount: Int = 0
    var userId: Int = 0
    var created_at: String = ""
    var updated_at: String = ""
    var createDate: Date = Date()
    var updateDate: Date = Date()
    var user: TSUserInfoModel?

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        groupId <- map["group_id"]
        subject <- map["subject"]
        type <- map["type"]
        amount <- map["amount"]
        userId <- map["user_id"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        createDate <- (map["created_at"], TSDateTransform)
        updateDate <- (map["updated_at"], TSDateTransform)
        user <- map["user"]
    }
}
