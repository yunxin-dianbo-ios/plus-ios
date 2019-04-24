//
//  TSDownloadNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 20/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  下载管理器

import Foundation
import Kingfisher

class TSDownloadNetworkNanger {

    static let share = TSDownloadNetworkNanger()
    private init() {

    }

    /// 根据图片文件id获取图片链接
    func imageUrlStringWithImageFileId(_ fileId: Int) -> String {
        let strPrefixUrl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
        let strUrl = String(format: "%@/%d", strPrefixUrl, fileId)
        return strUrl
    }

    /// 下载单张图片
    /// Note：下载失败没做任何处理
    func downloadImage(with imageUrl: String, complete: (() -> Void)? ) -> Void {
        // 查看缓存中是否有图片
        let chacheResult = ImageCache.default.isImageCached(forKey: imageUrl)
        //let chacheResult = KingfisherManager.shared.cache.isImageCached(forKey: imageUrl)
        var image: UIImage?
        if chacheResult.cached, let chacheTye = chacheResult.cacheType {
            switch chacheTye {
            case .memory:
                image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageUrl)
                //image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: imageUrl)
            case .disk:
                image = ImageCache.default.retrieveImageInDiskCache(forKey: imageUrl)
                //image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: imageUrl)
            default:
                break
            }
        }
        if !chacheResult.cached || nil == image {
            // 请求图片
            if let url: URL = URL(string: imageUrl) {
                KingfisherManager.shared.downloader.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, url, _) in
                    if let image = image {
                        KingfisherManager.shared.cache.store(image, forKey: imageUrl)
                        ImageCache.default.store(image, forKey: imageUrl)
                    }
                    complete?()
                })
            } else {
                complete?()
            }
        } else {
            // 有图片，则不需要请求
            complete?()
        }
    }
    /// 下载多张图片
    /// Note：下载失败没做任何处理
    func downloadImages(with urls: [String], complete: @escaping(() -> Void)) -> Void {
        // 1. url 去重
        let imageUrlList: [String] = Array<String>(Set(urls))
        let group = DispatchGroup()
        // 2. 查看缓存中是否有该key的图片，没有则去下载
        for imageUrl in imageUrlList {
            group.enter()
            self.downloadImage(with: imageUrl, complete: {
                group.leave()
            })
        }
        // 3. 全部下载完毕
        group.notify(queue: DispatchQueue.main) {
            complete()
        }
    }
}
