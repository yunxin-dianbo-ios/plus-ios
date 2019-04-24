//
//  TSNewsRewardCountModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSNewsRewardCountModel: Mappable {
    var count: Int = 0
    // 服务器的数据 单位分
    var amount: String?
    // 显示用的数据 单位元
    var realAmount: Double? {
        if let amount = amount, let doubleAmount = Double(amount) {
            return doubleAmount
//            let goldNumber = TSWalletConfigModel.convertToYuan(Int(doubleAmount))
//            return goldNumber
            /*
             [长期注释] 注释之前的计算方法留个底
             // 最初
             return Double(amount)! / 100.0
             // 后来: 0.00(String) -> Int(amount)!强制解析崩溃，但Double(amount)!不会崩溃，所以：String->Double->Int
             let goldNumber = TSWalletConfigModel.getGold(fromFen: Int(amount)!)
             return goldNumber
             */
        }
        return nil
    }

    required init?(map: Map) {
    }

    init() {
    }

    func mapping(map: Map) {
        count <- map["count"]
        amount <- map["amount"]
    }
}
