//
//  TSAlbumInfoModel.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  专辑信息模型
// TODO: MusicUpdate - 音乐模块更新中，To be removed

import UIKit
import SwiftyJSON

class TSAlbumInfoModel: NSObject {
    /// 专辑id （专辑详情接口不返回，由上个界面传入）
    var albumID: Int = -1
    /// 专辑名 （专辑详情接口不返回，由上个界面传入）
    var albumTitle: String = ""
    /// 简介
    var info: String? = nil
    /// 播放数
    var tasteCount: Int = 0
    /// 分享数
    var shareCount: Int = 0
    /// 评论数
    var commentCount: Int = 0
    /// 收藏数
    var collectCount: Int = 0
    /// 歌曲列表
    var songList: [TSSongInfoModel] = []

    /// 通过服务器返回数据初始化
    init(json: [String: Any], albumID: Int, albumTitle: String) {
        super.init()
        let jsonData = JSON(json).dictionaryValue
        self.albumID = albumID
        self.albumTitle = albumTitle
        self.info = jsonData["info"]!.string!
        self.tasteCount = jsonData["taste_count"]!.int!
        self.shareCount = jsonData["share_count"]!.int!
        self.commentCount = jsonData["comment_count"]!.int!
        self.collectCount = jsonData["collect_count"]!.int!

        let songListData = jsonData["music"]?.arrayObject
        for songInfo in songListData! {
            let songData = TSSongInfoModel(json: (songInfo as? [String : Any])!)
            self.songList.append(songData)
        }
    }
}
