//
//  TSMusicCommonObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  音乐模块下通用的Object模型
//  这部分模块也可能成为程序通用的Object模型，暂不确定，先作为音乐模块下的通用模型吧

import Foundation
import RealmSwift

/// 音乐模块下的图片数据库模型
class TSMusicImageObject: Object {
    // 图片id
    dynamic var id: Int = 0
    // 图片尺寸
    dynamic var size: String? = nil

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}

/// 音乐专辑下的支付节点数据库模型
class TSAlbumPaidNodeObject: Object {
    // 是否已付费
    var paid: Bool = false
    // 付费节点
    var node: Int = 0
    // 付费金额
    var amount: Float = 0
    // 暂不确定node字段能否作为主键
//    /// 设置索引
//    override static func indexedProperties() -> [String] {
//        return ["node"]
//    }
//    /// 设置主键
//    override static func primaryKey() -> String? {
//        return "node"
//    }
}
