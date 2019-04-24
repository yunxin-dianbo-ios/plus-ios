////
////  TSSingerObject.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class TSSingerObject: Object {
//
//    /// 歌手id
//    dynamic var id: Int = 0
//    /// 歌手名
//    dynamic var name: String = ""
//    /// 歌手封面附件ID
//    dynamic var coverID: Int = 0
//
//    /// 设置索引
//    override static func indexedProperties() -> [String] {
//        return ["id", "name"]
//    }
//    /// 设置主键
//    override static func primaryKey() -> String? {
//        return "id"
//    }
//}

typealias TSSingerObject = TSMusicSingerObject
