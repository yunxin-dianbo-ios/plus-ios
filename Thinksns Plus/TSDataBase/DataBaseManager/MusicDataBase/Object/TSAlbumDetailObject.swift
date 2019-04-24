//
//  TSAlbumDetailObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  专辑列表详情数据库模型

import Foundation
import RealmSwift

class TSAlbumDetailObject: Object {
    /// 专辑id
    dynamic var id: Int = -1
    /// 专辑名
    dynamic var title: String = ""
    /// 专辑简介
    dynamic var intro: String = ""
    /// 创建时间
    dynamic var createDate: String = ""
    /// 上传时间
    dynamic var updateDate: String = ""
    /// 封面图片附件id
    dynamic var storage: TSMusicImageObject?
    /// 播放数
    dynamic var tasteCount: Int = 0
    /// 分享数
    dynamic var shareCount: Int = 0
    /// 评论数
    dynamic var commentCount: Int = 0
    /// 收藏数
    dynamic var collectCount: Int = 0
    /// 是否收藏 0: 未收藏， 1: 已收藏
    dynamic var isCollectd: Bool = false
    // 付费节点  为null则是免费
    dynamic var paidNode: TSAlbumPaidNodeObject?

    // 音乐列表
//    dynamic var musics: [TSAlbumMusicObject]?
    var musics = List<TSAlbumMusicObject>()

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
