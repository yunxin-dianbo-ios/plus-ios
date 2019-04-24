////
////  TSSongInfoNetModel.swift
////  ThinkSNS +
////
////  Created by LiuYu on 2017/4/1.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//
//class TSSongInfoNetModel: NSObject {
//    /// 歌曲id
//    var id: Int = -1
//    /// 创建时间
//    var createdAt: String = ""
//    /// 上传时间
//    var updatedAt: String = ""
//    /// 歌名
//    var title: String = ""
//    /// 歌手
//    var singer: TSSingerNetModel? = nil
//    /// 歌曲附件id
//    var storage: Int = -1
//    /// 总时长
//    var lastTime: Int = -1
//    /// 歌词
//    var lyric: String? = "暂无歌词"
//    /// 播放数
//    var tasteCount: Int = 0
//    /// 分享数
//    var shareCount: Int = 0
//    /// 评论数
//    var commentCount: Int = 0
//    /// 是否点了赞
//    var isdiggmusic: Int = 0
//
//    /// 通过json数据来初始化
//    init(json: [String:Any]) {
//        let jsonData = JSON(json).dictionaryValue
//        self.id = jsonData["id"]!.int!
//        self.createdAt = jsonData["created_at"]!.string!
//        self.updatedAt = jsonData["updated_at"]!.string!
//        self.title = jsonData["title"]!.string!
//        self.storage = jsonData["storage"]!.int!
//        self.lastTime = jsonData["last_time"]!.int!
//        if let lyric = jsonData["lyric"]?.string {
//            self.lyric = lyric
//        }
//        self.tasteCount = jsonData["taste_count"]!.int!
//        self.shareCount = jsonData["share_count"]!.int!
//        self.commentCount = jsonData["comment_count"]!.int!
//        self.isdiggmusic = jsonData["isdiggmusic"]!.int!
//        let singerData = jsonData["singer"]!.dictionaryObject!
//        self.singer = TSSingerNetModel(json: singerData)
//    }
//}
//
//extension TSSongInfoNetModel {
//    /// 转object
//    func convertToObject() -> TSSongInfoObject {
//        let object = TSSongInfoObject()
//        object.infoID = self.id
//        object.created_at = self.createdAt
//        object.updated_at = self.updatedAt
//        object.title = self.title
//        object.storage = self.storage
//        object.last_time = self.lastTime
//        object.lyric = self.lyric!
//        object.taste_count = self.tasteCount
//        object.share_count = self.shareCount
//        object.comment_count = self.commentCount
//        object.isdiggmusic = self.isdiggmusic
//        object.singerId = (self.singer?.id)!
//        object.singer = self.singer?.convertToObject()
//        return object
//    }
//}
// TODO: MusicUpdate - 音乐模块更新中，To be removed
