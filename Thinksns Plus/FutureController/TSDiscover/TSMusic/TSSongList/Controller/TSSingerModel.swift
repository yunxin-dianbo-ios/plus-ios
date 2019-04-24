////
////  TSSingerModel.swift
////  Thinksns Plus
////
////  Created by LiuYu on 2017/3/22.
////  Copyright © 2017年 ZhiYiCX. All rights reserved.
////
////  
//
//import UIKit
//import SwiftyJSON
//
//class TSSingerModel: NSObject {
//    /// 歌手id
//    var id: Int = 0
//    /// 创建时间
//    var created_at: String = ""
//    /// 上传时间
//    var updated_at: String = ""
//    /// 歌手名
//    var name: String = ""
//    /// 歌手封面附件id
//    var coverID: Int = 0
//
//    init(json: [String:Any]) {
//        super.init()
//        let jsonData = JSON(json).dictionaryValue
//        self.id = jsonData["id"]!.int!
//        self.created_at = jsonData["created_at"]!.string!
//        self.updated_at = jsonData["updated_at"]!.string!
//        self.name = jsonData["name"]!.string!
//        self.coverID = jsonData["cover"]!["id"].int!
//    }
//
//    func converToObject() -> TSSingerObject {
//
//        let object = TSSingerObject()
//        object.id = self.id
//        object.name = self.name
////        object.updated_at = self.updated_at
////        object.created_at = self.created_at
//        object.coverID = self.coverID
//
//        return object
//    }
//}

typealias TSSingerModel = TSMusicSingerModel
