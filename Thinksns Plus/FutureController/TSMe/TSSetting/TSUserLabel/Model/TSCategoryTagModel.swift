//
//  TSCategoryTagModel.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 全集标签的model

import UIKit
import SwiftyJSON
import ObjectMapper

class TSCategoryTagModel: Mappable {
    ///  id
    var id = -1
    /// 一个类别的名字
    var idName: String?
    /// 一个类别的多个子model
    var idTags: Array<TSCategoryIdTagModel>?

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        idName <- map["name"]
        idTags <- map["tags"]
    }
}

/// 子model
class TSCategoryIdTagModel: Mappable {
    /// 独立的id
    var tagId = -1
    /// 独立名字
    var tagName = ""
    /// 所属的类别的id
    var tagCategoryId = -1
    // MARK: - collection需要
    /// 是否点击过了
    var isTouch = false
    /// 储存的一个位置信息
    var isTouchedItem: IndexPath? = nil

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        tagId <- map["id"]
        tagName <- map["name"]
        tagCategoryId <- map["tag_category_id"]
    }
}

class TSLabelModel: Mappable {
    /// 标签标识
    var id = -1
    /// 标签名称
    var name = ""
    /// 所属的类别的id
    var tagCategoryId = -1

    init() {
    }
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        tagCategoryId <- map["tag_category_id"]
    }
}
