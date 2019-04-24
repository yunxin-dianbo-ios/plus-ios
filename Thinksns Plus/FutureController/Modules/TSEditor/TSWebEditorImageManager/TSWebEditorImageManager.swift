//
//  TSWebEditorImageManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 30/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  Web编辑器的图片管理器

/**
 图片管理器功能分析
 
 
 缓存功能：
    缓存文件夹的创建、
    缓存大小的计算
    缓存的清理
 
 
 图片管理
    保存图片 -> 保存之前的图片重复判断、保存图片文件、保存图片信息、
    获取图片 -> 根据图片的标识获取图片路径
    删除图片 -> 删除图片引用，若引用为0 则删除该图片文件
    修改图片 -> 修改图片文件、引用、路径、名字、标识？？？
    图片去重问题
 
    图片信息的缓存问题
 
    引用问题的不可靠：草稿的直接删除、
 
 
 图片功能分析：
 外界需要的图片功能接口
    插入图片：相册或拍照得到一张图片，然后插入到编辑器中
 
 
    删除图片：点击图片删除 或 使用delete键删除。删除图片时 可能该图片并没有上传成功。
            即，既可以通过name删除，也可以通过fileId来进行删除。
 
    更换图片： 点击图片，选择更换图片。
    该功能暂不需要。通过删除重新插入即可实现。
 
    图片的批量处理
    加载图片：
        草稿中加载、编辑已存在的文章时、 -> 通过fileId进行批量加载处理
        判断该图片是否在缓存中，在则使用url代替，否则去下载图片，保存到缓存中，再使用url代替。
 
    删除图片：
        删除草稿、发布文章成功时、 -> 通过fileId进行批量删除处理
 
 
 图片缓存功能
    缓存大小
    缓存清理 -> 文件夹中所有图片删除、图片相关的数据库也删除
 
 
 
 
 
 
 
 
 **/

/**
 数据库 与 文件不同步 怎么办？暂不考虑，当做始终统一。
 如果不统一且需处理，考虑：自动检测、判断是否存在时不仅判断数据库也判断文件、
 */

import Foundation
import CryptoSwift
import Kingfisher

//TSEditorCacheImageNodeObject

//TSEditorCacheImageNodeRealmManager

/// Web编辑器的图片管理器
class TSWebEditorImageManager {

    /// 单例构造
    static var `default`: TSWebEditorImageManager = TSWebEditorImageManager()
    fileprivate init() {
        self.cachePath = NSHomeDirectory() + "/EditorImage"
        if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            self.cachePath = cachePath + "/EditorImage"
        }
        // 判断该文件夹是否存在，若不存在则创建
        var isDir: ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: self.cachePath, isDirectory: &isDir)
        if !(isExist && isDir.boolValue) {
            try! FileManager.default.createDirectory(atPath: self.cachePath, withIntermediateDirectories: true, attributes: nil)
        }
    }

    /// 缓存位置
    private(set) var cachePath: String
    /// 命名

}

// MARK: - 缓存
extension TSWebEditorImageManager {
    /// 缓存大小计算，返回的是M
    /// 注：当前的文件大小计算方式有问题，需要进行修正
    func cacheSize() -> Float {
        let cacheSize = FileManager.default.fileSize(self.cachePath)
        return Float(cacheSize) / (1_024 * 1_024 * 1.0)
    }

    /// 图片缓存清除
    func cacheClear() -> Void {
        // 1. 删除图片文件夹下的所有文件
        FileManager.default.removeDirChilds(self.cachePath)

        // 2. 删除数据库中的图片节点信息
        TSDatabaseManager().editor.deleteAll()
    }
}

// MARK: - 操作
extension TSWebEditorImageManager {

    /// 查看是否存在
    func isExistImage(fileId: Int) -> Bool {
        return TSDatabaseManager().editor.isExistEditorCacheImage(fileId: fileId)
    }
    func isExistImage(md5: String) -> Bool {
        return TSDatabaseManager().editor.isExistEditorCacheImage(md5: md5)
    }

    /// 获取，通过fileId获取，主要用于编辑已存在的文章时
    func getImageNode(fileId: Int) -> TSEditorCacheImageNode? {
        // 判断是否存在
        guard let imageNode = TSDatabaseManager().editor.getEditorCacheImage(fileId: fileId) else {
            return nil
        }
        // 从缓存文件中获取图片
        let imagePath = self.cachePath + "/" + imageNode.name
        imageNode.image = UIImage(contentsOfFile: imagePath)
        return imageNode
    }

    /// 增
    func addImage(_ image: UIImage) -> TSEditorCacheImageNode {
        // 注：暂使用图片的base64编码来获取md5摘要，也可考虑使用图片数据本身的 md5摘要
        let data = UIImageJPEGRepresentation(image, 1.0)
        let md5: String = data?.base64EncodedString().md5() ?? ""
        // 判断是否存在
        let imageNode = TSDatabaseManager().editor.getEditorCacheImage(md5: md5)
        if let imageNode = imageNode {
            // 存在，则修正引用计数，加1
            imageNode.refrenceCount += 1
            TSDatabaseManager().editor.updateEditorCacheImage(imageNode)
            print("图片引用计数加1，imageName: " + imageNode.name)
            return imageNode
        } else {
            // 不存在，
            // 1. 构建缓存图片节点
            let name = String(format: "%lf.jpeg", Date().timeIntervalSince1970)
            let imageNode = TSEditorCacheImageNode(name: name, md5: md5, image: image)
            // 2. 保存图片到文件
            if let imageData = UIImageJPEGRepresentation(image, 1.0) as NSData? {
                let fullPath = self.cachePath + "/" + name
                imageData.write(toFile: fullPath, atomically: true)
                print("保存图片到文件成功，imagePath: " + fullPath)
                print("图片的md5摘要，md5: " + md5)
            }
            // 3. 数据库增加图片节点信息
            imageNode.refrenceCount = 1
            TSDatabaseManager().editor.addEditorCacheImage(imageNode)

            return imageNode
        }
    }

    /// 删除
    func deleteImage(fileId: Int) -> Void {
        if let imageNode = TSDatabaseManager().editor.getEditorCacheImage(fileId: fileId) {
            self.deleteImage(imageNode: imageNode)
        }
    }
    func deleteImage(md5: String) -> Void {
        if let imageNode = TSDatabaseManager().editor.getEditorCacheImage(md5: md5) {
            self.deleteImage(imageNode: imageNode)
        }
    }
    func deleteImage(name: String) -> Void {
        if let imageNode = TSDatabaseManager().editor.getEditorCacheImage(name: name) {
            self.deleteImage(imageNode: imageNode)
        }
    }
    fileprivate func deleteImage(imageNode: TSEditorCacheImageNode) -> Void {
        // 引用计数减1
        imageNode.refrenceCount -= 1
        if imageNode.refrenceCount >= 1 {
            // 更新引用计数
            TSDatabaseManager().editor.updateEditorCacheImage(imageNode)
            print("图片引用计数减1，imageName: " + imageNode.name)
        } else {
            // 删除图片文件
            let fullPath = self.cachePath + "/" + imageNode.name
            try! FileManager.default.removeItem(atPath: fullPath)
            print("图片文件删除，imagePath: " + fullPath)
            // 删除缓存图片信息
            TSDatabaseManager().editor.deleteEditorCacheImage(imageNode: imageNode)
        }
    }

    /// 改
    /// 图片上传成功，修正fileId
    func uploadImageSuccess(name: String, fileId: Int) -> Void {
        guard let imageNode = TSDatabaseManager().editor.getEditorCacheImage(name: name) else {
            return
        }
        imageNode.fileIdList.append(fileId)
        TSDatabaseManager().editor.updateEditorCacheImage(imageNode)
    }

    /// 批量处理
    /// 通过fileId列表进行批量删除，用于发布成功后的删除 或 单个草稿的删除
    func deleteImages(fileIds: [Int]) -> Void {
        for fileId in fileIds {
            self.deleteImage(fileId: fileId)
        }
    }

}

extension TSWebEditorImageManager {
    /// 下载图片管理
    /// Note：下载失败没做任何处理
    func downloadImages(fileIds: [Int], complete: @escaping(() -> Void)) -> Void {
        // 1. fileId去重
        let fileIdList: [Int] = Array<Int>(Set(fileIds))
        let group = DispatchGroup()
        // 2. 查看是否有该fileId的图片文件，没有则去下载
        for fileId in fileIdList {
            if !self.isExistImage(fileId: fileId) {
                // 根据fileId构建图片url进行下载
                let strurl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue + "/\(fileId)"
                if let url: URL = URL(string: strurl) {
                    KingfisherManager.shared.downloader.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, url, _) in
                        if let image = image {
                            // 保存图片到文件中
                            let imagenode = self.addImage(image)
                            self.uploadImageSuccess(name: imagenode.name, fileId: fileId)
                        }
                    })
                }
            }
        }
        // 3. 全部下载完毕
        group.notify(queue: DispatchQueue.main) {
            complete()
        }
    }

}
