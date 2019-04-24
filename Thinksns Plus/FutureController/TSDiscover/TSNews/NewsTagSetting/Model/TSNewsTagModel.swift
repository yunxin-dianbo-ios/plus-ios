//
//  TSNewsTagModel.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON

class TSNewsTagModel: NSObject {
    /// 栏目id
    var tagID = -1
    /// 栏目名称
    var tagName = ""

    /// 通过json数据来初始化
    init(json: [String: Any]) {
        super.init()
        let jsonData = JSON(json).dictionaryValue
        self.tagID = jsonData["id"]!.int!
        self.tagName = jsonData["name"]!.string!
    }

    /// TSNewsTagModel转换为TSNewsTagObject
    ///
    /// - Parameters:
    ///   - isMaked: 是否订阅 （0：未订阅, 1：已订阅）
    ///   - index: 已订阅的栏目排序序号
    /// - Returns: Object
    func converToObject(markStatus isMarked: Int, index: Int?) -> TSNewsTagObject {
        let object = TSNewsTagObject()
        object.tagID = self.tagID
        object.name = self.tagName
        object.isMarked = isMarked
        if isMarked == 0 {
            object.index = -1
        } else {
            object.index = index!
        }
        return object
    }
}
