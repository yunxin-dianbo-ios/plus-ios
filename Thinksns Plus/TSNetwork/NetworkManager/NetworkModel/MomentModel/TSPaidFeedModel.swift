//
//  TSPaidNodeModel.swift
//  RealmTest
//
//  Created by GorCat on 2017/7/4.
//  Copyright © 2017年 GorCat. All rights reserved.
//  
//  动态相关付费 数据模型

import UIKit

struct TSPaidFeedModel {

    /// 当前用户是否已经付费
    var paid: Bool?
    /// 付费节点
    var node: Int?
    /// 付费金额
    var amount: Int?

    init(data: [String: Any]) {
        paid = data["paid"] as? Bool
        node = data["node"] as? Int
        amount = data["amount"] as? Int
    }

}
