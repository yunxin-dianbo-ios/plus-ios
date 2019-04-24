//
//  TSMomentNetworkRequest.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/4/18.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

struct TSMomentNetworkRequest {
    /// 打赏
    ///
    /// - Parameter:
    ///    - amount: int类型。必传。打赏金额
    let reward = TSNetworkRequestMethod(method: .post, path: "feeds/{feed}/new-rewards", replace: "{feed}")
    /// 打赏列表
    ///
    /// - Parameter:
    ///    - limit: int类型。非必须。列表返回数据条数
    ///    - since: int类型。非必须。翻页标识 时间排序时为数据id 金额排序时为打赏金额amount
    ///    - order: string类型。非必须。正序-asc 倒序desc
    ///    - order_type: string类型。非必须。排序规则 date-按时间 amount-按金额
    let rewardList = TSNetworkRequestMethod(method: .get, path: "feeds/{feed}/rewards", replace: "{feed}")
}
