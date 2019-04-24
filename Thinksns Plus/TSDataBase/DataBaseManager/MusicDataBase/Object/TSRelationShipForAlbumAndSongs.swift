//
//  TSRelationShipForAlbumAndSongs.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSRelationShipForAlbumAndSongs: Object {
    /// 专辑id
    dynamic var albumID: Int = 0
    /// 歌曲id
    dynamic var songID: Int = 0
}
