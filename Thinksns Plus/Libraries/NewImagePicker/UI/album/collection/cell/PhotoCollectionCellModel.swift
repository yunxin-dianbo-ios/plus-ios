//
//  PhotoCollectionCellModel.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/23.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionCellModel: NSObject {

    /// 图片
    var imageAsset: PHAsset?

//    /// 是否已选中
//    var isSelected = false
//    /// 是否显示选择框
//    var shouldShowSelectBox = true

    // MARK: - Lifecycle

    init(imageAsset: PHAsset) {
        super.init()
        self.imageAsset = imageAsset
    }
}
