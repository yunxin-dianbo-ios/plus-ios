//
//  TSFileHandle.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/1.
//  Copyright © 2017年 Lius. All rights reserved.
//

import UIKit

class TSFileHandle: NSObject {

    var writeFileHandle: FileHandle? = nil
    var readFileHandle: FileHandle? = nil
    /// 创建临时文件
    class func createTempFile() -> Bool {
        let manager = FileManager.default
        let path = String.musicTempFilePath()
        if manager.fileExists(atPath: path) {
            try? manager.removeItem(atPath: path)
        }
        return manager.createFile(atPath: path, contents: nil, attributes: nil)
    }
    /// 往临时文件写入数据
    class func writeTempFileData(data: Data) {
        // TODO: - 正在播放歌曲时，回到专辑详情页或进入别的专辑详情页切换歌曲播放，则会发生崩溃，且崩溃点就是这里，待确认并解决。
//        let hanlde = FileHandle(forReadingAtPath: String.musicTempFilePath())
        let hanlde = FileHandle(forWritingAtPath: String.musicTempFilePath())
        hanlde?.seekToEndOfFile()

        hanlde?.write(data)
    }
    /// 读取临时文件数据
    class func readTempFileData(WithOffset offset: UInt64, lenght: Int) -> Data {
        let hanlde = FileHandle(forReadingAtPath: String.musicTempFilePath())
        hanlde?.seek(toFileOffset: offset)
        return (hanlde?.readData(ofLength: lenght))!
    }
    /// 保存临时文件到缓存文件夹
    class func cacheTempFile(WithFileName name: String) {

        let manager = FileManager.default
        let cacheFolderPath = String.musicCacheFolderPath()
        print(cacheFolderPath)
        if !manager.fileExists(atPath: cacheFolderPath) {
            try? manager.createDirectory(atPath: cacheFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
        let cacheFilePath = cacheFolderPath + name
        try? manager.copyItem(atPath: String.musicTempFilePath(), toPath: cacheFilePath)
    }
    /// 是否存在缓存文件 存在：返回文件路径 不存在：返回 "" 空字符串
    class func cacheFileExists(WithURL URL: URL) -> String {
        let cacheFilePath = String.musicCacheFolderPath() + String.musicfileNameWithURL(url: URL)
        if FileManager.default.fileExists(atPath: cacheFilePath) {
            return cacheFilePath
        }
        return ""
    }
    /// 清除缓存文件
    class func clearCache() -> Bool {
        let manager = FileManager.default
        return ((try? manager.removeItem(atPath: String.musicCacheFolderPath())) != nil)
    }
}
