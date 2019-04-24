//
// Created by lip on 2017/9/18.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//
// 收到的待审核网络请求

import Foundation

struct ReceivePendingNetworkRequest {
    /// 动态评论置顶
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: Integer, 获取条数，默认 20
    ///    - after: Integer, 上次请求列表倒叙最后一条 ID
    let feedCommentList = Request<ReceivePendingFeedCommentTopModel>(method: .get, path: "user/feed-comment-pinneds", replacers: [])
    /// 资讯评论置顶
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: Integer, 获取条数，默认 20
    ///    - after: Integer, 上次请求列表倒叙最后一条 ID
    let newsCommentList = Request<ReceivePendingNewsCommentTopModel>(method: .get, path: "news/comments/pinneds", replacers: [])

    /// 动态评论置顶审核和拒绝都使用的旧版接口

    /// 审核-同意 资讯评论置顶
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    ///    - comment: 评论标识
    ///    - pinned: 申请操作标识
    /// - RequestParameter: None
    let agreeNewsCommentToTop = Request<Empty>(method: .patch, path: "news/{news}/comments/{comment}/currency-pinneds/{pinned}", replacers: ["{news}", "{comment}", "{pinned}"])
    /// 审核-拒绝 资讯评论置顶
    ///
    /// - RouteParameter:
    ///    - news: 资讯标识
    ///    - comment: 评论标识
    ///    - pinned: 申请操作标识
    /// - RequestParameter: None
    let denyNewsCommentToTop = Request<Empty>(method: .patch, path: "news/{news}/comments/{comment}/currency-pinneds/{pinned}/reject", replacers: ["{news}", "{comment}", "{pinned}"])
}
