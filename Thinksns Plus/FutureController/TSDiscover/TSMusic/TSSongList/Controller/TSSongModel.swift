////
////  TSSongModel.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//import ObjectMapper
//
//class TSSongModel: NSObject {
//    /// 歌曲id
//    var id: Int = 0
//    /// 创建时间
//    var created_at: String = ""
//    /// 发布时间
//    var updated_at: String = ""
//    /// 专辑id
//    var special_id: Int = 0
//    /// 歌曲附件id
//    var music_id: Int = 0
//    /// 歌曲详情
//    var songInfo: TSSongDetailInfoModel? = nil
//
//    init(josn: [String:Any]) {
//        super.init()
//        let jsonData = JSON(josn).dictionaryValue
//        self.id = jsonData["id"]!.int!
//        self.created_at = jsonData["created_at"]!.string!
//        self.updated_at = jsonData["updated_at"]!.string!
//        self.special_id = jsonData["special_id"]!.int!
//        self.music_id = jsonData["music_id"]!.int!
//        let infoDic = jsonData["music_info"]!.dictionaryObject!
//        let infoModel = TSSongDetailInfoModel(json: infoDic)
//        self.songInfo = infoModel
//    }
//
//    func converToObject() -> TSSongObject {
//
//        let object = TSSongObject()
//        object.songID = self.id
//        object.updated_at = self.updated_at
//        object.created_at = self.created_at
////        object.special_id = self.special_id
//        object.music_id = self.music_id
//
//        return object
//    }
//}

typealias TSSongModel = TSAlbumMusicModel
