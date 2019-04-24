//
//  TSAccountName.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation
import RealmSwift

class TSAccountNameObject: Object {
    dynamic var nameStr = ""

    override static func primaryKey() -> String? {
        return "nameStr"
    }
}
