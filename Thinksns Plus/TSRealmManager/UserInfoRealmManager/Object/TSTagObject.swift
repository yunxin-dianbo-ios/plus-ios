//
//  TSTagObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户标签

import UIKit
import RealmSwift

class TSTagObject: Object {

    ///  标签id
    dynamic var id: Int = 0
    /// 标签名称
    dynamic var name: String = ""
    /// 标签的分类id/上一级id
    dynamic var categoryId: Int = 0

}
