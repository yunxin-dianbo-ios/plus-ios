//
//  TSAdvertModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import ObjectMapper

struct TSAdvertModel: Mappable {
    /// 唯一标识
    var id = -1
    /// 排序
    var order = -1
    /// 广告位 id
    var spaceId = -1
    /// 广告数据类型，当前支持的数据类型参见 TSAdvertObject.DataType
    var type: String = ""
    /// 广告标题
    var title = ""

    // MARK: - image 图片数据

    /// 图片 urlString
    var imageImage: String?
    /// 图片的 data，用于保存下载好的图片（启动图需要提前下载好图片）
    var imageData: NSData?
    /// 图片广告链接
    var imageLink: String?
    /// 图片展示时间，默认给5s
    var imageDuration: Int = 5
    /// 图片宽高
    var imageSize: CGSize = CGSize.zero

    // MARK: - Analog 模拟数据

    // MARK: feedAnalog 动态模拟数据

    /// 动态模拟数据 头像
    var feedAnalogAvatar: String = ""
    /// 动态模拟数据 用户名
    var feedAnalogName: String = ""
    /// 动态模拟数据 内容
    var feedAnalogContent: String = ""
    /// 动态模拟数据 图片
    var feedAnalogImage: String = ""
    /// 动态模拟数据 时间
    var feedAnalogTime: Date = Date()
    /// 动态模拟数据 链接
    var feedAnalogLink: String = ""

    // MARK: newAnalog 咨询模拟数据

    /// 资讯模拟数据 标题
    var newAnalogTitle: String = ""
    /// 资讯模拟数据 图片
    var newAnalogImage: String = ""
    /// 资讯模拟数据 来源
    var newAnalogFrom: String = ""
    /// 资讯模拟数据 时间
    var newAnalogTime: Date = Date()
    /// 资讯模拟数据 链接
    var newAnalogLink: String = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        order <- map["sort"]
        spaceId <- map["space_id"]
        type <- map["type"]
        title <- map["title"]
        // 1.如果是图片数据
        if type == TSAdvertObject.DataType.image.rawValue {
            imageImage <- map["data.image"]
            imageLink <- map["data.link"]
            imageDuration <- map["data.duration"]
            imageSize <- (map["data.size"], CGSizeTransform())
        }
        // 2.如果是模拟数据
        // 2.1 动态模拟数据
        if type == TSAdvertObject.DataType.feedAnalog.rawValue {
            feedAnalogAvatar <- map["data.avatar"]
            feedAnalogName <- map["data.name"]
            feedAnalogContent <- map["data.content"]
            feedAnalogImage <- map["data.image"]
            feedAnalogTime <- (map["data.time"], TSDateTransfrom())
            feedAnalogLink <- map["data.link"]
        }
        // 2.2 资讯模拟数据
        if type == TSAdvertObject.DataType.newsAnalog.rawValue {
            newAnalogTitle <- map["data.title"]
            newAnalogImage <- map["data.image"]
            newAnalogFrom <- map["data.from"]
            newAnalogTime <- (map["data.time"], TSDateTransfrom())
            newAnalogLink <- map["data.link"]
        }
    }

    /// 将 model 转换成 object
    func object() -> TSAdvertObject {
        let object = TSAdvertObject()
        object.id = id
        object.order = order
        object.spaceId = spaceId
        object.type = type
        object.title = title
        object.imageDuration = self.imageDuration
        // 1.如果是图片数据
        if type == TSAdvertObject.DataType.image.rawValue {
            let imageObject = TSAdvertImageObject()
            imageObject.imageImage = imageImage
            imageObject.imageLink = imageLink
            imageObject.duration = self.imageDuration
            if self.imageSize != CGSize.zero {
                imageObject.width = Int(self.imageSize.width)
                imageObject.height = Int(self.imageSize.height)
            }
            object.normalImage = imageObject
        }
        // 2.如果是模拟数据
        // 2.1 动态模拟数据
        if type == TSAdvertObject.DataType.feedAnalog.rawValue {
            let feedAnalog = TSFeedAnalogObject()
            feedAnalog.avatar = feedAnalogAvatar
            feedAnalog.name = feedAnalogName
            feedAnalog.content = feedAnalogContent
            feedAnalog.image = feedAnalogImage
            feedAnalog.time = feedAnalogTime as NSDate
            feedAnalog.link = feedAnalogLink
            object.analogFeed = feedAnalog
        }
        // 2.2 资讯模拟数据
        if type == TSAdvertObject.DataType.newsAnalog.rawValue {
            let newsAnalog = TSNewsAnalogObject()
            newsAnalog.title = title
            newsAnalog.image = newAnalogImage
            newsAnalog.from = newAnalogFrom
            newsAnalog.time = newAnalogTime as NSDate
            newsAnalog.link = newAnalogLink
            object.analogNews = newsAnalog
        }
        return object
    }
}
