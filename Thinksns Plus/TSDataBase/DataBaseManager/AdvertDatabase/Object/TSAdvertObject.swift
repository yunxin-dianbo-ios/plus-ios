//
//  TSAdvertLaunchObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告 数据模型

import RealmSwift

class TSAdvertObject: Object {
    /// 广告数据类型
    public enum DataType: String {
        /// 图片数据
        case image
        /// 动态模拟数据
        case feedAnalog = "feed:analog"
        /// 资讯模拟数据
        case newsAnalog = "news:analog"
    }

    /// 唯一标识
    dynamic var id = -1
    /// 排序
    dynamic var order = -1
    /// 广告位 id
    dynamic var spaceId = -1
    /// 广告数据类型，当前支持的数据类型参见 TSAdvertObject.DataType
    dynamic var type: String = ""
    /// 标题
    dynamic var title = ""
    /// 图片展示时间，默认给5s
    dynamic var imageDuration: Int = 5

    // MARK: - 基础数据类型

    /// 图片数据
    dynamic var normalImage: TSAdvertImageObject?

    // MARK: - Analog 模拟数据

    // 动态模拟数据
    dynamic var analogFeed: TSFeedAnalogObject?

    // 咨询模拟数据
    dynamic var analogNews: TSNewsAnalogObject?

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }

    /// 从服务器提供的图片链接中提取图片的唯一标识
    class func getAnalogImageIdentity(imageURLString: String?) -> Int? {
        if let imgID = imageURLString?.components(separatedBy: "/").last {
            return Int(imgID)
        }
        return nil
    }
}
