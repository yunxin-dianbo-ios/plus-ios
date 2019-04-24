//
//  NewsModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

///  资讯列表中的资讯数据模型
class NewsModel: Mappable {
    /// 数据标识
    var id: Int!
    /// 标题
    var title: String!
    /// 副标题
    var subject: String?
    /// 来源
    var from: String!
    /// 作者
    var author:	String!
    /// 发布者id
    var authorId: Int!
    /// 点击量
    var hits: Int!
    /// 当前用户是否已收藏
    var isCollected: Bool!
    /// 创建时间
    var createdDate: Date!
    /// 更新时间
    var updatedDate: Date!
    // 当前用户是否已点赞
    var isLike: Bool!
    /// 所属分类信息
    var categoryInfo: NewsCategoryModel!
    /// 封面图信息
    var coverInfos: [NewsImageModel]?
    /// 单图的封面
    private var coverInfo: NewsImageModel?
    // 自定义字段，不属于服务器返回字段。
    /// 广告标记，是否是广告。在通过广告Object构造时需将其设置为ture
    var isAd: Bool = false
    /// 广告链接
    var adUrl: String?

    // MARK: - lifecycle
    required init?(map: Map) {
    }

    init() {
    }

    init(object: Int) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        subject <- map["subject"]
        from <- map["from"]
        author <- map["author"]
        authorId <- map["user_id"]
        hits <- map["hits"]
        isCollected <- map["has_collect"]
        isLike <- map["has_like"]
        categoryInfo <- map["category"]
        coverInfos <- map["images"]
        //3张图y及以上才使用三张图显示效果，否则显示一张，一张图应该先显示封面
        if (coverInfos == nil || (coverInfos?.count)! < 3) {
            coverInfo <- map["image"]
            if coverInfo != nil {
                coverInfos = []
                coverInfos?.append(coverInfo!)
            }
        }
        createdDate <- (map["created_at"], TSDateTransfrom())
        updatedDate <- (map["updated_at"], TSDateTransfrom())
    }

    init(advertObject: TSAdvertObject) {
        self.title = advertObject.analogNews?.title
        self.from = advertObject.analogNews?.from
        self.createdDate = advertObject.analogNews?.time! as! Date
        let categoryInfo = NewsCategoryModel()
        categoryInfo.id = -99
        categoryInfo.name = "广告"
        self.categoryInfo = categoryInfo
        let coverInfo = NewsImageModel()
        coverInfo.id = TSAdvertObject.getAnalogImageIdentity(imageURLString: advertObject.analogNews?.image)
        /// 固定的图片尺寸,用于将服务器的图片数据渲染该指定大小的画布上
        coverInfo.size = CGSize(width: TSNewsListCellUX.imageWidth, height: TSNewsListCellUX.imageHeight)
        self.coverInfos = [coverInfo]
        self.isAd = true
        self.adUrl = advertObject.analogNews?.link
        // 注：不能这样使用，不然可能导致崩溃bug
        //self.id = advertObject.id
    }
}

///  资讯列表中的置顶资讯数据模型
class TopNewsModel: NewsModel {
}

class NewsCategoryModel: Mappable {
    /// 标识
    ///
    /// 广告的分类标识: -99 客户端自定义的
    var id: Int!
    /// 名称
    var name: String!
    /// 所属分类排序
    var rank: Int!

    required init?(map: Map) {
    }

    init() {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        rank <- map["rank"]
    }
}

class NewsImageModel: Mappable {
    /// 资讯封面附件id
    var id: Int!
    /// 宽度
    private var width: CGFloat!
    /// 高度
    private var height: CGFloat!
    /// 类型
    var mime: String!
    /// 尺寸(兼容原来的单图尺寸)
    var size: CGSize!

    required init?(map: Map) {
    }

    init() {
    }

    func mapping(map: Map) {
        id <- map["id"]
        width <- map["width"]
        height <- map["height"]
        size <- (map["size"], CGSizeTransform())
        if size == nil, width != nil, height != nil {
            size = CGSize(width: width, height: height)
        }
        mime <- map["mime"]
    }
}
