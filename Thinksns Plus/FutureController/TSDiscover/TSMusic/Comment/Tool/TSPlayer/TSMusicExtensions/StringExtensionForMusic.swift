//
//  StringExtensionForMusic.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/1.
//  Copyright © 2017年 Lius. All rights reserved.
//

import Foundation

extension String {
    /// 音乐临时文件路径
    static func musicTempFilePath() -> String {
        return NSHomeDirectory().appending("/tmp").appending("/tsMusicTemp.mp4")
    }
    /// 缓存文件路径
    static func musicCacheFolderPath() -> String {
        return NSHomeDirectory().appending("/Library").appending("/MusicCaches/")
    }
    /// 获取网址中的文件名
    static func musicfileNameWithURL(url: URL) -> String {
        return url.path.components(separatedBy: "/").last!
    }
}
