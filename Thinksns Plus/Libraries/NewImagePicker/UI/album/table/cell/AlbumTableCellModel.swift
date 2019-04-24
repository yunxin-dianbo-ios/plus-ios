//
//  TSPhotoTableCellModel.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/22.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class AlbumTableCellModel: NSObject {

    /// 相册标题
    var title: String?
    /// 相册数量
    var count: Int?
    /// 相册封面数据
    var imageAsset: PHAsset?

    // MARK: - Lifecycle

    /// 初始化
    init(albumModel: AlbumModel) {
        title = albumModel.title
        count = albumModel.imageAssets?.count
        imageAsset = albumModel.imageAssets?.firstObject
    }

}
