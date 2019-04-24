////
////  TSSongInfoObject.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class TSSongInfoObject: Object {
//
//    /// id
//    dynamic var infoID: Int = 0
//    /// 创建时间
//    dynamic var created_at: String = ""
//    /// 上传时间
//    dynamic var updated_at: String = ""
//    /// 歌曲名
//    dynamic var title: String = ""
//    /// 歌手
////    let singer = List<TSSingerObject>()
//    dynamic var singerId: Int = 0
//    /// 歌手信息
//    dynamic var singer: TSSingerObject?
//    /// 歌曲封面附件ID
//    dynamic var storage: Int = 0
//    /// 时长
//    dynamic var last_time: Int = 0
//    /// 歌词
//    dynamic var lyric: String = ""
//    /// 播放数
//    dynamic var taste_count: Int = 0
//    /// 分享数
//    dynamic var share_count: Int = 0
//    /// 评论数
//    dynamic var comment_count: Int = 0
//    /// 是否点赞/收藏
//    dynamic var isdiggmusic: Int = 0
//
//    /// 设置索引
//    override static func indexedProperties() -> [String] {
//        return ["infoID", "title", "singerId"]
//    }
//    /// 设置主键
//    override static func primaryKey() -> String? {
//        return "infoID"
//    }
//}
