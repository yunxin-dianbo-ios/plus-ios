//
//  TopNetworkRequest.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/5/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

struct TopNetworkRequest {
    /// 动态置顶价格
    let feedPrice = Request<FeedTopPriceModel>(method: .get, path: "feeds/average", replacers: [])
    /// 资讯置顶价格
    let newsPrice = Request<NewsTopPriceModel>(method: .get, path: "news/average", replacers: [])
    /// 圈子置顶价格
    let groupPrice = Request<GroupTopPriceModel>(method: .get, path: "plus-group/average", replacers: [])
}

struct FeedTopPriceModel: Mappable {
    var feed: Int = 0
    var feedComment: Int = 0
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        feed <- map["feed"]
        feed <- map["feed_comment"]
    }
}

struct NewsTopPriceModel: Mappable {
    var news: Int = 0
    var newsComment: Int = 0
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        news <- map["news"]
        newsComment <- map["news_comment"]
    }
}

struct GroupTopPriceModel: Mappable {
    var post: Int = 0
    var postComment: Int = 0
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        post <- map["post"]
        postComment <- map["post_comment"]
    }
}
