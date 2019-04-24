//
//  TSEditorCacheImageNodeObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 05/02/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  编辑器缓存图片节点的数据库模型

import Foundation
import RealmSwift

class TSEditorCacheImageNodeObject: Object {

    /// 缓存图片名字
    dynamic var name: String = ""
    /// 缓存图片的md5字符串
    dynamic var md5: String = ""

    /// 缓存图片的fileId列表，注：同一张图片可能产生多个fileId(后台)
    let fileIdList = List<Int>()

    /// 图片的引用计数/使用计数
    dynamic var refrenceCount: Int = 0

    /// 创建时间
    //dynamic var createDate: Date = Date()
    /// 最近一次修改时间
    //dynamic var updateDate: Date = Date()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "name"
    }
    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["name", "md5"]
    }

}
