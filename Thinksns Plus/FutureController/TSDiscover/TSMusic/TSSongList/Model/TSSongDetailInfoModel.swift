////
////  TSSongDetailInfoModel.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//// TODO: MusicUpdate - 音乐模块更新中，To be removed
//
//import UIKit
//import SwiftyJSON
//
//class TSSongDetailInfoModel: NSObject {
//    /// 歌曲详情id
//    var id: Int = 0
//    /// 创建时间
//    var created_at: String = ""
//    /// 上传时间
//    var updated_at: String = ""
//    /// 歌曲名
//    var title: String = ""
//    /// 歌手信息
//    var singer: TSSingerModel? = nil
//    /// 歌曲封面附件id
//    var storage: Int = 0
//    /// 时长
//    var last_time: Int = 0
//    /// 歌词
//    var lyric: String = ""
//    /// 播放数
//    var taste_count: Int = 0
//    /// 分享数
//    var share_count: Int = 0
//    /// 评论数
//    var comment_count: Int = 0
//    /// 是否点赞
//    var isdiggmusic: Int = 0
//
//    init(json: [String:Any]) {
//        super.init()
//        let jsonData = JSON(json).dictionaryValue
//        self.id = jsonData["id"]!.int!
//        self.created_at = jsonData["created_at"]!.string!
//        self.updated_at = jsonData["updated_at"]!.string!
//        self.title = jsonData["title"]!.string!
//        self.storage = jsonData["storage"]!.int!
//        self.last_time = jsonData["last_time"]!.int!
//        self.lyric = jsonData["lyric"]!.string!
//        self.taste_count = jsonData["taste_count"]!.int!
//        self.share_count = jsonData["share_count"]!.int!
//        self.comment_count = jsonData["comment_count"]!.int!
//        self.isdiggmusic = jsonData["isdiggmusic"]!.int!
//
//        let singerInfoDic = jsonData["singer"]!.dictionaryObject!
//        let singerModel = TSSingerModel(json: singerInfoDic)
//        self.singer = singerModel
//    }
//
//    func converToObject() -> TSSongInfoObject {
//
//        let object = TSSongInfoObject()
//        object.infoID = self.id
//        object.updated_at = self.updated_at
//        object.created_at = self.created_at
//        object.title = self.title
//        object.last_time = self.last_time
//        object.lyric = self.lyric
//        object.taste_count = self.taste_count
//        object.share_count = self.share_count
//        object.comment_count = self.comment_count
//        object.isdiggmusic = self.isdiggmusic
//        object.singerId = (self.singer?.id)!
//        return object
//    }
//}
