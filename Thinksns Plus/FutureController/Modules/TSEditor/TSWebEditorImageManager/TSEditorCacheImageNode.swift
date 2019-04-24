//
//  TSEditorCacheImageNode.swift
//  ThinkSNS +
//
//  Created by 小唐 on 05/02/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  编辑器缓存图片节点

import Foundation
import RealmSwift

/// 编辑器缓存图片节点
class TSEditorCacheImageNode {
    var name: String
    var md5: String
    /// fileId列表，注：同一张图片可能产生多个fileId(后台)
    var fileIdList: [Int] = []
    var image: UIImage?

    var filePath: String {
        return TSWebEditorImageManager.default.cachePath + "/" + name
    }

    /// 引用计数(去重管理: 避免单张图片多次使用时每次都存)
    var refrenceCount: Int = 0

    init(name: String, md5: String, image: UIImage, fileIds: [Int] = []) {
        self.name = name
        self.md5 = md5
        self.image = image
        self.fileIdList = fileIds
    }

    init(object: TSEditorCacheImageNodeObject) {
        self.name = object.name
        self.md5 = object.md5
        self.refrenceCount = object.refrenceCount
        for fileId in object.fileIdList {
            self.fileIdList.append(fileId)
        }
        // 从文件中加载图片，待
        //self.image =
    }

    func object() -> TSEditorCacheImageNodeObject {
        let object = TSEditorCacheImageNodeObject()
        object.name = self.name
        object.md5 = self.md5
        object.refrenceCount = self.refrenceCount
        for fileId in self.fileIdList {
            object.fileIdList.append(fileId)
        }
        return object
    }
}
