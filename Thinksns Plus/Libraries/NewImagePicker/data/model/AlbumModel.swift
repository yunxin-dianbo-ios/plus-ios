//
//  PhotoModel.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/23.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class AlbumModel: NSObject {

    // 相册标题
    var title: String?
    // 图片信息
    var imageAssets: PHFetchResult<PHAsset>?
    // 相册标识
    var identifier: String?

    // MARK: - Lifecycle
    init(AllPhotos collection: PHAssetCollection) {
        // 1.将 collection 转换成 asset
        let assets = PHAsset.fetchAssets(in: collection, options: nil)

        // 2.保存相册信息
        imageAssets = assets
        title = collection.localizedTitle
        identifier = collection.localIdentifier

        // 3.获取本机语言
        let language = NSLocale.current.languageCode
        if language == "zh" { // 如果是中文，将 title 手动设置一下
            title = "所有图片"
        }
    }

    /// 初始化
    init?(collection: PHAssetCollection) {
        // 1.将 collection 转换成 asset
        let assets = PHAsset.fetchAssets(in: collection, options: nil)

        // 2.如果 asset 数量为 0，表示该相册的图片数量为 0，则返回 nil
        guard assets.count > 0 else {
            return nil
        }

        // 3.如果 asset 数量不为 0，保存相册信息
        imageAssets = assets
        title = collection.localizedTitle
        identifier = collection.localIdentifier
    }
}
