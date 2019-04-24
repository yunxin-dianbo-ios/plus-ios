//
//  TSAdvertViewModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告视图 viewModel 

import UIKit

struct TSAdvertViewModel {

    /// 广告类型
    var type: TSAdvertObject.DataType? = nil

    // 图片
    var imageURL: String?
    // 图片数据
    var image: UIImage?
    // html
    var html: String?

    // 链接
    var link: String?
}

extension TSAdvertViewModel {

    /// 通过 object 来初始化
    init(object: TSAdvertObject) {
        type = TSAdvertObject.DataType(rawValue: object.type)
        link = object.normalImage?.imageLink
        // 如果是图片
        if type == .image {
            if let imageNSData = object.normalImage?.imageData {
                let data = Data(referencing: imageNSData)
                image = UIImage(data: data)
            }
            imageURL = object.normalImage?.imageImage
        }
    }
}
