//
//  FeedRequestNetwork.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态网络请求

import UIKit

struct FeedNetworkRequest {

    /// 批量获取动态
    let feeds = Request<FeedListResultsModel>(method: .get, path: "feeds", replacers: [])

    /// 收藏动态
    let collect = Request<Empty>(method: .post, path: "feeds/:feed/collections", replacers: [":feed"])
    /// 取消收藏
    let uncollect = Request<Empty>(method: .delete, path: "feeds/:feed/uncollect", replacers: [":feed"])
    /// 收藏列表
    let collection = Request<FeedListModel>(method: .get, path: "feeds/collections", replacers: [])

    /// 点赞动态
    let digg = Request<Empty>(method: .post, path: "feeds/:feed/like", replacers: [":feed"])
    /// 取消点赞
    let undigg = Request<Empty>(method: .delete, path: "feeds/:feed/unlike", replacers: [":feed"])

    /// 删除动态
    let delete = Request<Empty>(method: .delete, path: "feeds/:feed/currency", replacers: [":feed"])
}

// TODO: 旧版动态遗留接口
struct TSFeedsNetworkRequest {
    // MARK: - 赞
    /// 获取资讯点赞列表
    ///
    /// - RouteParameter:
    ///    - feed: 资讯标识
    /// - RequestParameter:
    ///    - limit: Integer. 获取条数，默认 20
    ///    - after: Integer. 资讯id,传入后获取该id之后数据，默认 0
    let likesList = TSNetworkRequestMethod(method: .get, path: "feeds/:feed/likes", replace: ":feed")
}
