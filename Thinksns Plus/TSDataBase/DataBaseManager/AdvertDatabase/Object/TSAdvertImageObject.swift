//
//  TSAdvertImageObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片数据

import RealmSwift

class TSAdvertImageObject: Object {

    /// 图片 urlString
    dynamic var imageImage: String?
    /// 图片的 data，用于保存下载好的图片（启动图需要提前下载好图片）
    dynamic var imageData: NSData?
    /// 图片广告链接
    dynamic var imageLink: String?
    /// 图片展示时间，默认5s
    dynamic var duration: Int = 5
    dynamic var width: Int = 260
    dynamic var height: Int = 130
}
