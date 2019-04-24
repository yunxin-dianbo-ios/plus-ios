//
//  PhotosDataManager.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/22.
//  Copyright © 2017年 GorCat. All rights reserved.
//
//  相册数据管理类

import UIKit
import Photos

class PhotosDataManager: NSObject {

    /// 相册列表数组
    var albums: [AlbumModel]?

    override init() {
        super.init()
    }

    deinit {
    }

    /// 更新相册数据
    func updateAlbumListData() {
        albums = []
        // 1.获取全部图片
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        for i in 0 ..< smartAlbums.count {
            let collection = smartAlbums[i]
            let allPhotosAlbumModel = AlbumModel(AllPhotos: collection)
            albums?.append(allPhotosAlbumModel)
        }

        // 2.获取用户相册
        let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0 ..< userAlbums.count {
            guard let userCollection = userAlbums[i] as? PHAssetCollection else {
                continue
            }
            if let albumModel = AlbumModel(collection: userCollection) {
                albums!.append(albumModel)
            }
        }
    }

    /// 获取相册列表
    ///
    /// - Returns: 结果
    func getAlbumList() -> [AlbumModel] {
        if let albums = albums {
            return albums
        }
        updateAlbumListData()
        return albums!
    }

}

extension PhotosDataManager {

    /// 将 asset 按顺序转换成 image
    internal class func convert(assets: [PHAsset], finishImages: [UIImage], recordIndex index: Int, disPlayWidth width: CGFloat, complete: @escaping([UIImage]) -> Void) {
        // 如果是空数据，返回空数组
        if assets.isEmpty {
            complete([])
        }
        // 获取单张图片
        var finishImages = finishImages

        PhotosDataManager.conver(asset: assets[index], disPlayWidth: width, complete: { (aImage) in
            guard let image = aImage else {
                return
            }
            finishImages.append(image)
            // 判断图片是否转换完成
            if finishImages.count < assets.count {
                // 如果没有，继续转换
                PhotosDataManager.convert(assets: assets, finishImages: finishImages, recordIndex: index + 1, disPlayWidth: width, complete: complete)
            } else {
                // 如果有，返回所有图片
                complete(finishImages)
            }
        })
    }

    /// 将 [PHAsset] 转换成 [UIImage]
    ///
    /// - Note: 该方法 complete 只返回一次
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - width: 图片需要展示的宽度
    ///   - complete: 结果
    class func cover(assets: [PHAsset], disPlayWidth width: CGFloat, complete: @escaping([UIImage]) -> Void) {
        if assets.isEmpty {
            complete([])
            return
        }
        PhotosDataManager.convert(assets: assets, finishImages: [], recordIndex: 0, disPlayWidth: width, complete: complete)
    }

    /// 将 asset 转换成指定大小的 image
    ///
    /// - Note: 该方法 complete 返回 2 次，第一次返回模糊图，第二次返回高清图
    ///
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - width: 图片需要展示的宽度
    ///   - complete: 结果
    class func conver(asset: PHAsset, disPlayWidth width: CGFloat, complete: @escaping(UIImage?) -> Void) {

        // 1.获取屏幕的像素比例
        let retinaMultiplier = UIScreen.main.scale

        // 2.计算图片的实际像素
        let scaleHW = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
        let imageWidth = width * retinaMultiplier
        let imageHeight = width * scaleHW * retinaMultiplier
        let size = CGSize(width:imageWidth, height: imageHeight) //

        // 3.设置图片 resize 的模式
        let imageOptions = PHImageRequestOptions()
        imageOptions.resizeMode = .exact
        imageOptions.isSynchronous = true

        // 4.设置 contentMode
        /*
         这里设定，大于屏幕二分之一宽的图为大图。
         
         如果是大图，使用 fit；如果是小图，使用 fill。

         这里区分大小图，是为了平衡 图片的清晰度和显示速度。
         */
        let bigImageWidth = UIScreen.main.bounds.width / 2
        let contentMode: PHImageContentMode = width > bigImageWidth ? .aspectFit : .aspectFill

        // 5.将 asset 装换成 image
        PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: contentMode, options: imageOptions, resultHandler: { (image, info) -> Void in
            guard let image = image else {
                CGLog(message: info)
                return
            }
            complete(image)
        })
    }
}
