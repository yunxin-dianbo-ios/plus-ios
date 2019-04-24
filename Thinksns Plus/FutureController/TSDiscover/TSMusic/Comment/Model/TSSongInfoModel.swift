//
//  TSSongInfoModel.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  歌曲信息数据模型
// TODO: MusicUpdate - 音乐模块更新中，To be removed

import UIKit
import SwiftyJSON

class TSSongInfoModel: NSObject {
    /// 歌曲id
    var songID: Int? = nil
    /// 歌手
    var singer: String? = nil
    /// 附件id
    var storage: String? = nil
    /// 歌名
    var title: String? = nil

    init(json: [String: Any]) {
        let jsonData = JSON(json).dictionaryValue
        self.songID = jsonData["music_id"]?.int!
        self.singer = jsonData["singer"]?.string!
        self.storage = jsonData["storage"]?.string!
        self.title = jsonData["title"]?.string!
    }
}
