////
////  TSSongObject.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class TSSongObject: Object {
//    /// 歌曲ID
//    dynamic var songID: Int = 0
//    /// 创建时间
//    dynamic var created_at: String = ""
//    /// 上传时间
//    dynamic var updated_at: String = ""
//    /// 歌曲id
//    dynamic var music_id: Int = 0
//    /// 歌曲信息
//    dynamic var songInfo: TSSongInfoObject?
//
//
//    /// 设置索引
//    override static func indexedProperties() -> [String] {
//        return ["songID", "music_id"]
//    }
//    /// 设置主键
//    override static func primaryKey() -> String? {
//        return "songID"
//    }
//}

typealias TSSongObject = TSAlbumMusicObject
