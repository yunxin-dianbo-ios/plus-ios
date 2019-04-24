//
//  TSSAreaSearchModel.swift
//  date
//
//  Created by Fiction on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class TSSAreaSearchModel: Mappable {
    /// items	搜索的选中地址的下一级所有地区列表。
    var items: Array<TSSAreaSearchItemsModel>?
    /// tree	搜索的选中地区树。
    var tree: TSSAreaSearchTreeModel?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        items <- map["items"]
        tree <- map["tree"]
    }

    /// 转换成tableview展示需要的数据
    ///
    /// - Returns: 返回一个tableview.row需要的数据
    public func conversionData() -> [String] {
        var result = [String]()
        if self.tree != nil {
          let str = convertModel(self.tree!)
            result.append(str)
        }
        return result
    }

    private func convertModel(_ model: TSSAreaSearchTreeModel) -> String {
        var temp = model
        var bool = true
        var str = ""
        while bool {
            str.insert(contentsOf: ("，" + temp.name), at: str.startIndex)
            if temp.parent == nil {
                bool = false
            } else {
                temp = temp.parent!
            }
        }
        return str
    }
}

class TSSAreaSearchItemsModel: Mappable {
    /// items.name	地区名称
    var name: String = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        name <- map["name"]
    }
}

class TSSAreaSearchTreeModel: Mappable {
    /// tree.name	地区名称
    var name: String = ""
    /// tree.parent	父级地区数据。
    var parent: TSSAreaSearchTreeModel?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        name <- map["name"]
        parent <- map["parent"]
    }
}
