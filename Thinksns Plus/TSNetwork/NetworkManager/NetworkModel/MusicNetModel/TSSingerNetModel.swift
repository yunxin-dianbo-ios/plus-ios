////
////  TSSingerNetModel.swift
////  ThinkSNS +
////
////  Created by LiuYu on 2017/4/1.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//
//class TSSingerNetModel {
//    /// 歌手id
//    var id: Int = -1
//    /// 歌手名
//    var name: String = ""
//    /// 歌手封面附件id
//    var cover: Int = -1
//
//    /// 通过json数据来初始化
//    init(json: [String:Any]) {
//        let jsonData = JSON(json).dictionaryValue
//        self.id = jsonData["id"]!.int!
//        self.name = jsonData["name"]!.string!
//        self.cover = jsonData["cover"]!["id"].int!
//    }
//}
//
//extension TSSingerNetModel {
//    /// 模型转object
//    func convertToObject() -> TSSingerObject {
//        let object = TSSingerObject()
//        object.id = self.id
//        object.name = self.name
//        object.coverID = self.cover
//        return object
//    }
//}

// TODO: MusicUpdate - 音乐模块更新中，To be removed
