//
//  TSMusicCommonModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  音乐模块下通用的数据模型
//  这部分模块也可能成为程序通用的数据模型，暂不确定，先作为音乐模块下的通用模型吧

import Foundation
import ObjectMapper

/// 音乐模块下的图片数据模型
struct TSMusicImageModel: Mappable {
    // 图片id
    var id: Int = 0
    // 图片尺寸
    var size: String?

    // MARK: - Mappable

    init?(map: Map) {
        if map.JSON["id"] == nil {
            return nil
        }
    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        size <- map["size"]
    }

    // MARK: - DB

    init(object: TSMusicImageObject) {
        self.id = object.id
        self.size = object.size
    }
    func object() -> TSMusicImageObject {
        let object = TSMusicImageObject()
        object.id = self.id
        object.size = self.size
        return object
    }

}

/// 音乐专辑的支付节点数据模型
struct TSAlbumPaidNodeModel: Mappable {
    // 是否已付费
    var paid: Bool = false
    // 付费节点
    var node: Int = 0
    // 付费金额
    var amount: Float = 0

    // MARK: - Mappable

    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        paid <- map["paid"]
        node <- map["node"]
        amount <- map["amount"]
    }

    // MARK: - DB

    init(object: TSAlbumPaidNodeObject) {
        self.paid = object.paid
        self.node = object.node
        self.amount = object.amount
    }
    func object() -> TSAlbumPaidNodeObject {
        let object = TSAlbumPaidNodeObject()
        object.paid = self.paid
        object.node = self.node
        object.amount = self.amount
        return object
    }

}

/// 音乐下评论类型
enum TSMusicCommentType: String {
    /// 专辑
    case album = "music_specials"
    /// 歌曲
    case song = "musics"
}

/// 音乐评论的存储类型
enum TSMusicStoreType {
    /// 正常情况下的，网络请求来的
    case normal
    /// 发送失败的
    case failed
}
