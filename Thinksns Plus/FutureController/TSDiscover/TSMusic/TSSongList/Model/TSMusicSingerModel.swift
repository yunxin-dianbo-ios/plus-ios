//
//  TSMusicSingerModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  音乐歌手的数据模型

import Foundation
import ObjectMapper

class TSMusicSingerModel: Mappable {
    // 歌手id
    var id: Int = 0
    var createDate: String = ""
    var updateDate: String = ""
    // 歌手名称
    var name: String = ""
    // 歌手图片
    var cover: TSMusicImageModel?

    // MARK: - Mappable

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        name <- map["name"]
        cover <- map["cover"]
    }

    // MARK: - DB

    init(object: TSMusicSingerObject) {
        self.id = object.id
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.name = object.name
        self.cover = object.cover == nil ? nil : TSMusicImageModel(object: object.cover!)
    }
    func object() -> TSMusicSingerObject {
        let object = TSMusicSingerObject()
        object.id = self.id
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.name = self.name
        object.cover = self.cover?.object()
        return object
    }
}
