//
//  TSPaidNodeObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSPaidFeedObject: Object {

    /// 当前用户是否已经付费
    let paid = RealmOptional<Bool>()
    /// 付费节点
    let node = RealmOptional<Int>()
    /// 付费金额
    let amount = RealmOptional<Int>()

}

extension TSPaidFeedObject {

    /// 通过 TSPaidFeedModel 设置 object
    func setInfo(model: TSPaidFeedModel) {
        paid.value = model.paid
        node.value = model.node
        amount.value = model.amount
    }

}
