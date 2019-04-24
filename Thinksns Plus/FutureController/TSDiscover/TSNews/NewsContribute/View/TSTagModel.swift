//
//  TSTagModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  用户标签模型

import Foundation
import ObjectMapper

class TSTagModel: Mappable {
    ///  标签id
    var id: Int = 0
    /// 标签名称
    var name: String = ""
    /// 标签的分类id/上一级id
    var categoryId: Int = 0

    // MARK: - 列表展示使用的属性，不是从json中获取，也不是从数据库中加载
    /// 选中状态
    var isSelected: Bool = false

    init() {

    }

    init(object: TSTagObject) {
        id = object.id
        name = object.name
        categoryId = object.categoryId
    }

    /// 自定义拷贝构造方法   Remark：暂时不需要使用也可解决问题
    func copy() -> TSTagModel {
        let tag = TSTagModel()
        tag.id = self.id
        tag.name = self.name
        tag.categoryId = self.categoryId
        tag.isSelected = self.isSelected
        return tag
    }
    init(label: TSLabelModel) {
        self.id = label.id
        self.name = label.name
        self.categoryId = label.tagCategoryId
    }

    // MARK: - Mappable

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        categoryId <- map["tag_category_id"]
    }

    func object() -> TSTagObject {
        let object = TSTagObject()
        object.id = id
        object.name = name
        object.categoryId = categoryId
        return object
    }
}
