//
//  TSCheckinModel.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSCheckinModel: Mappable {
    /// 当日前五签到用户，按照签到时间顺序排列。
    var rankUsers: Array<TSUserInfoModel>?
    /// 当前用户是否已签到。
    var checkedIn: Bool = false
    /// 当前用户签到总天数。
    var checkinCount: Int = 0
    /// 当前用户连续签到天数。
    var lastCheckinCount: Int = 0
    /// 签到用户积分增加值，单位是真实货币「分」单位。
    var attachBalance: Int = 0

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        rankUsers <- map["rank_users"]
        checkedIn <- map["checked_in"]
        checkinCount <- map["checkin_count"]
        lastCheckinCount <- map["last_checkin_count"]
        attachBalance <- map["attach_balance"]
    }
}
