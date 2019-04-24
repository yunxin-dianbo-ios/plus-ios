//
//  RealmBasicType.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class RealmInt: Object {
    dynamic var value = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "value"
    }

}

class RealmString: Object {
    dynamic var value = ""

    /// 设置主键
    override static func primaryKey() -> String? {
        return "value"
    }

}
