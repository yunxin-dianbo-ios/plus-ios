//
//  TSAlbumListModel.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  专辑列表数据模型

import UIKit
import SwiftyJSON
import ObjectMapper

class TSAlbumListModel: Mappable {
    /// 专辑id
    var id: Int = -1
    /// 专辑名
    var title: String = ""
    /// 专辑简介
    var intro: String = ""
    /// 创建时间
    var createDate: String = ""
    /// 上传时间
    var updateDate: String = ""
    /// 封面图片附件id
    var storage: TSMusicImageModel?
    /// 播放数
    var tasteCount: Int = 0
    /// 分享数
    var shareCount: Int = 0
    /// 评论数
    var commentCount: Int = 0
    /// 收藏数
    var collectCount: Int = 0
    /// 是否收藏 0: 未收藏， 1: 已收藏
    var isCollectd: Bool = false
    // 付费节点  为null则是免费
    var paidNode: TSAlbumPaidNodeModel?

    // MARK: - Mappable

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        title <- map["title"]
        intro <- map["intro"]
        storage <- map["storage"]
        tasteCount <- map["taste_count"]
        shareCount <- map["share_count"]
        commentCount <- map["comment_count"]
        collectCount <- map["collect_count"]
        isCollectd <- map["has_collect"]
        paidNode <- map["paid_node"]
    }

    // MARK: - DB

    init(object: TSAlbumListObject) {
        self.id = object.id
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.title = object.title
        self.intro = object.intro
        self.tasteCount = object.tasteCount
        self.shareCount = object.shareCount
        self.commentCount = object.commentCount
        self.collectCount = object.collectCount
        self.isCollectd = object.isCollectd
        self.storage = (nil == object.storage) ? nil : TSMusicImageModel(object: object.storage!)
        self.paidNode = (nil == object.paidNode) ? nil : TSAlbumPaidNodeModel(object: object.paidNode!)
    }
    func object() -> TSAlbumListObject {
        let object = TSAlbumListObject()
        object.id = self.id
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.title = self.title
        object.intro = self.intro
        object.tasteCount = self.tasteCount
        object.shareCount = self.shareCount
        object.commentCount = self.commentCount
        object.collectCount = self.collectCount
        object.isCollectd = self.isCollectd
        object.storage = self.storage?.object()
        object.paidNode = self.paidNode?.object()
        return object
    }

}
