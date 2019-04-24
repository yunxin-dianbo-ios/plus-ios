//
//  TSNewsAllTagsModel.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON

class TSNewsAllTagsModel: NSObject {

    /// 已订阅的栏目
    var markedTags: [TSNewsTagObject] = []
    /// 为订阅的栏目
    var unmarkedTags: [TSNewsTagObject] = []

    /// 通过json数据来初始化
    func setData(json: [String:Any]) {

        let jsonData = JSON(json).dictionaryValue
        let markedArray = jsonData["my_cates"]?.arrayObject
        let unmarkedArray = jsonData["more_cates"]?.arrayObject

        var i = 1 /// 因为有个默认的栏目始终是被订阅的 所以这里的角标从1开始
        for data in markedArray! {
            let tagModel = TSNewsTagModel(json: (data as? [String:Any])!)
            let object = tagModel.converToObject(markStatus: 1, index: i)
            self.markedTags.append(object)
            i += 1
        }

        for data in unmarkedArray! {
            let tagModel = TSNewsTagModel(json: (data as? [String:Any])!)
            let object = tagModel.converToObject(markStatus: 0, index: nil)
            self.unmarkedTags.append(object)
        }
    }
}
