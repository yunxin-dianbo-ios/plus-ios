//
//  TSNewsNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  资讯网络请求方式

import UIKit

struct TSNewsNetworkRequest {
    // MARK: - 资讯栏目
    /// 订阅分类资讯
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - follows: string,**yes**,订阅的资讯分类 多个以逗号隔开
    let followsCategor = Request<Empty>(method: .patch, path: "news/categories/follows", replacers: [])
    // MARK: - 获取资讯
    /// 获取资讯列表
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit:     数据返回条数 默认为20
    ///    - after:     数据翻页标识
    ///    - key:       搜索关键字
    ///    - cate_id:   分类id
    ///    - recommend: 推荐筛选，如果设置为 1 只返回筛选后的推荐资讯列表
    let getNews = TSNetworkRequestMethod(method: .get, path: "news", replace: nil)
    /// 获取置顶资讯
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - cate_id:   咨询分类标识
    let getTopNews = TSNetworkRequestMethod(method: .get, path: "news/categories/pinneds", replace: nil)
    /// 获取资讯详情
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter: None
    let newsDetail = TSNetworkRequestMethod(method: .get, path: "news/{news}", replace: "{news}")
    /// 相关资讯
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter:
    ///    - limit: int. 返回关联数据条数
    let newsCorrelative = TSNetworkRequestMethod(method: .get, path: "news/{news}/correlations", replacers: ["{news}"])
    /// 申请资讯置顶
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter:
    ///    - day: int,必传. 申请置顶天数
    ///    - amout: int,必传. 申请置顶金额
    let newsApplyTop = TSNetworkRequestMethod(method: .post, path: "news/{news}/currency-pinneds", replacers: ["{news}"])
    // MARK: - 投稿
    /// 投稿
    ///
    /// - RouteParameter: 
    ///    - category: 稿件分类标识
    /// - RequestParameter:
    ///    - title:   String  **必须** 标题，最长 20 个字。
    ///    - subject: String  **必须** 主题，副标题，概述，最长 200 个字。
    ///    - content: String  **必须** 内容。
    ///    - image:   Integer **必须** 缩略图。
    ///    - from:    String          资讯来源。
    ///    - author:  String          作者
    let postNews = TSNetworkRequestMethod(method: .post, path: "news/categories/:category/currency-news", replace: ":category")
    /// 修改投稿内容
    ///
    /// - RouteParameter:
    ///    - category: 稿件分类标识
    /// - RequestParameter:
    ///    - title:   String  **必须** 标题，最长 20 个字。
    ///    - subject: String  **必须** 主题，副标题，概述，最长 200 个字。
    ///    - content: String  **必须** 内容。
    ///    - image:   Integer **必须** 缩略图。
    ///    - from:    String          资讯来源。
    ///    - author:  String          作者
    static let updateNews = Request<Empty>(method: .patch, path: "news/categories/:category/news/:news", replacers: [":category", ":news"])
    /// 删除投稿
    ///
    /// - RouteParameter:
    ///    - category:  稿件分类标识
    ///    - news:      稿件标识
    /// - RequestParameter: None
    let deletePostNews = TSNetworkRequestMethod(method: .delete, path: "news/categories/:category/news/:news", replace: ":category/news/:news")
    /// 管理员删除投稿
    ///
    /// - RouteParameter:
    ///    - category:  稿件分类标识
    ///    - news:      稿件标识
    /// - RequestParameter: None
    let managerDeletePostNews = TSNetworkRequestMethod(method: .delete, path: "news/posts/{id}", replace: "{id}")
    /// 申请退款
    ///
    /// - RouteParameter:
    ///    - category:  稿件分类标识
    ///    - news:      稿件标识
    /// - RequestParameter: None
    let applyForRefund = TSNetworkRequestMethod(method: .put, path: "news/categories/:category/news/:news", replace: ":category/news/:news")
    /// 投稿列表
    ///
    /// - RouteParameter: none
    /// - RequestParameter:
    ///    - limit: Integer 获取条数，默认 20
    ///    - after: Integer 上次获取列表最小的ID。默认 0
    let postList = TSNetworkRequestMethod(method: .get, path: "user/news/contributes", replace: nil)
    // MARK: - 打赏
    /// 打赏资讯
    ///
    /// - Parameter:
    ///    - amount: int类型。必传。打赏金额
    let reward = TSNetworkRequestMethod(method: .post, path: "news/{news}/new-rewards", replace: "{news}")
    /// 资讯的打赏列表
    ///
    /// - Parameter:
    ///    - limit: int类型。非必须。列表返回数据条数
    ///    - since: int类型。非必须。翻页标识 时间排序时为数据id 金额排序时为打赏金额amount
    ///    - order: string类型。非必须。正序-asc 倒序desc
    ///    - order_type: string类型。非必须。排序规则 date-按时间 amount-按金额
    let rewardList = TSNetworkRequestMethod(method: .get, path: "news/{news}/rewards", replace: "{news}")
    /// 资讯的打赏信息统计
    ///
    /// - Parameter: 无
    let rewardsCount = TSNetworkRequestMethod(method: .get, path: "news/{news}/rewards/sum", replace: "{news}")
    // MARK: - 收藏
    /// 获取收藏资讯列表
    ///
    /// - RouteParameter: none
    /// - RequestParameter:
    ///    - limit: int.数据返回条数
    ///    - after: int.数据翻页标识
    let collectionList = TSNetworkRequestMethod(method: .get, path: "news/collections", replace: nil)
    /// 收藏某条资讯
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter: None
    let collection = TSNetworkRequestMethod(method: .post, path: "news/{news}/collections", replace: "{news}")
    /// 取消收藏某条资讯
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter: None
    let cancelCollection = TSNetworkRequestMethod(method: .delete, path: "news/{news}/collections", replace: "{news}")
    // MARK: - 点赞
    /// 点赞列表
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter: None
    let likeList = TSNetworkRequestMethod(method: .get, path: "news/{news}/likes", replacers: ["{news}"])
    /// 点赞
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter: None
    let like = TSNetworkRequestMethod(method: .post, path: "news/{news}/likes", replacers: ["{news}"])
    /// 取消点赞
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    /// - RequestParameter: None
    let unLike = TSNetworkRequestMethod(method: .delete, path: "news/{news}/likes", replacers: ["{news}"])
}
