//
//  TSRewardObject.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSRewardObject: Object {
    /// 打赏金额
    dynamic var amount: String?
    /// 打赏次数
    dynamic var count = -1
}
