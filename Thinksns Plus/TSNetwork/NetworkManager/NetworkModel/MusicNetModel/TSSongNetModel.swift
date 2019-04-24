////
////  TSSongNetModel.swift
////  ThinkSNS +
////
////  Created by LiuYu on 2017/4/1.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////  歌曲数据模型，用于解析json数据、转换 model -> object
//// TODO: MusicUpdate - 音乐模块更新中，To be removed
//
//import UIKit
//import SwiftyJSON
//
//class TSSongNetModel {
//    /// 歌曲id
//    var id: Int = -1
//    /// 创建时间
//    var createdAt: String = ""
//    /// 上传时间
//    var updatedAt: String = ""
//    /// 歌曲id
//    var musicID: Int = -1
//    /// 歌曲的详细信息
//    var musicInfo: TSSongInfoNetModel? = nil
//
//    /// 通过json数据来初始化
//    init(json: [String:Any]) {
//        let jsonData = JSON(json).dictionaryValue
//        self.id = jsonData["id"]!.int!
//        self.createdAt = jsonData["created_at"]!.string!
//        self.updatedAt = jsonData["updated_at"]!.string!
//        self.musicID = jsonData["music_id"]!.int!
//        let musicInfoData = jsonData["music_info"]!.dictionaryObject!
//        self.musicInfo = TSSongInfoNetModel(json: musicInfoData)
//    }
//}
//
//extension TSSongNetModel {
//    /// 转object
//    func convertToObject() -> TSSongObject {
//        let object = TSSongObject()
//        // TODO: MusicUpdate - 音乐模块更新中，To be done
////        object.songID = self.id
////        object.created_at = self.createdAt
////        object.updated_at = self.updatedAt
////        object.music_id = (self.musicInfo?.id)!
////        object.songInfo = self.musicInfo?.convertToObject()
//        return object
//    }
//}
