//
//  TSAccountNameModel.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSAccountNameModel {

    var nameStr: String = ""
    /// 从数据库模型转换
    init(object: TSAccountNameObject) {
        self.nameStr = object.nameStr
    }
    /// 转换为数据库对象
    func object() -> TSAccountNameObject {
        let object = TSAccountNameObject()
        object.nameStr = self.nameStr
        return object
    }
}
