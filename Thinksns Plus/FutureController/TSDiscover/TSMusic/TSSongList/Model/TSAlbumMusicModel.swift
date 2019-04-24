//
//  TSAlbumMusicModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 31/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  专辑详情中音乐模型

import Foundation
import ObjectMapper
import RealmSwift

class TSAlbumMusicModel: Mappable {

    // 音乐id
    var id: Int = 0
    var createDate: String = ""
    var updateDate: String = ""
    var deleteDate: String?
    // 音乐标题
    var title: String = ""
    // 歌手信息
    var singer: TSMusicSingerModel?
    // 音乐附件信息
    var storage: TSMusicStorageModel?
    // 歌曲时间(app暂时自行下载解析时间)
    var lastTime: Int = 0
    // 歌词
    // 别的界面中总使用强制解析，故这里不适用可选
//    var lyric: String?
    var lyric: String = "暂无歌词"
    // 播放数
    var tasteCount: Int = 0
    // 分享数
    var shareCount: Int = 0
    // 评论数
    var commentCount: Int = 0
    // 是否已赞
    var isLiked: Bool = false

    // MARK: - Mappable

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        deleteDate <- map["deleted_at"]
        title <- map["title"]
        singer <- map["singer"]
        storage <- map["storage"]
        lastTime <- map["last_time"]
        lyric <- map["lyric"]
        tasteCount <- map["taste_count"]
        shareCount <- map["share_count"]
        commentCount <- map["comment_count"]
        isLiked <- map["has_like"]
    }

    // MARK: - DB
    init(object: TSAlbumMusicObject) {
        self.id = object.id
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.deleteDate = object.deleteDate
        self.title = object.title
        self.lastTime = object.lastTime
        self.lyric = object.lyric
        self.tasteCount = object.tasteCount
        self.shareCount = object.shareCount
        self.commentCount = object.commentCount
        self.isLiked = object.isLiked
        self.singer = object.singer == nil ? nil : TSMusicSingerModel(object: object.singer!)
        self.storage = object.storage == nil ? nil : TSMusicStorageModel(object: object.storage!)
    }
    func object() -> TSAlbumMusicObject {
        let object = TSAlbumMusicObject()
        object.id = self.id
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.deleteDate = self.deleteDate
        object.title = self.title
        object.lastTime = self.lastTime
        object.lyric = self.lyric
        object.tasteCount = self.tasteCount
        object.shareCount = self.shareCount
        object.commentCount = self.commentCount
        object.isLiked = self.isLiked
        object.singer = self.singer?.object()
        object.storage = self.storage?.object()
        return object
    }
}

/// 音乐附件信息
struct TSMusicStorageModel: Mappable {
    // 附件id
    var id: Int = 0
    // 付费金额 音乐免费时该字段不存在
    var amount: Float?
    // 付费类型  音乐免费时该字段不存在
    var type: String?
    // 是否已付费 音乐免费时 该字段不存在
    var paid: Bool?
    // 付费节点  音乐免费时 该字段不存在
    var paidNode: Int?

    // MARK: - Mappable

    init?(map: Map) {
        if nil == map.JSON["id"] {
            return nil
        }
    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        amount <- map["amount"]
        type <- map["type"]
        paid <- map["paid"]
        paidNode <- map["paid_node"]
    }

    // MARK: - DB

    init(object: TSMusicStorageObject) {
        self.id = object.id
        self.amount = object.amount.value
        self.type = object.type
        self.paid = object.paid.value
        self.paidNode = object.paidNode.value
    }
    func object() -> TSMusicStorageObject {
        let object = TSMusicStorageObject()
        object.id = self.id
        object.type = self.type
        object.amount = RealmOptional<Float>(self.amount)
        object.paid = RealmOptional<Bool>(self.paid)
        object.paidNode = RealmOptional<Int>(self.paidNode)
        return object
    }
}
