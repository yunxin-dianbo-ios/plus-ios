//
//  RankListRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜

import UIKit

class RankListRequest: NSObject {

    /// 全站粉丝排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    let fans = Request<TSUserInfoModel>(method: .get, path: "ranks/followers", replacers: [])

    /// 财富达人排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    let wealth = Request<TSUserInfoModel>(method: .get, path: "ranks/balance", replacers: [])

    /// 收入达人排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    let income = Request<TSUserInfoModel>(method: .get, path: "ranks/income", replacers: [])

    /// 社区签到排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 查询数据条数
    ///    - offset: 偏移量 默认为0
    let attendance = Request<TSUserInfoModel>(method: .get, path: "checkin-ranks", replacers: [])

    /// 社区专家排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    let communityExperts = Request<TSUserInfoModel>(method: .get, path: "question-ranks/experts", replacers: [])

    /// 问答达人排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    let quoraExperts = Request<TSUserInfoModel>(method: .get, path: "question-ranks/likes", replacers: [])

    /// 今日/一周/本月解答排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - type: 筛选类型 day - 日排行 week - 周排行 month - 月排行
    ///    - offset: 偏移量 默认为0
    let answers = Request<TSUserInfoModel>(method: .get, path: "question-ranks/answers", replacers: [])

    /// 今日/一周/本月动态排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - type: 筛选类型 day - 日排行 week - 周排行 month - 月排行
    ///    - offset: 偏移量 默认为0
    let feeds = Request<TSUserInfoModel>(method: .get, path: "feeds/ranks", replacers: [])

    /// 今日/一周/本月资讯排行榜
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据返回条数 默认10条
    ///    - type: 筛选类型 day - 日排行 week - 周排行 month - 月排行
    ///    - offset: 偏移量 默认为0
    let news = Request<TSUserInfoModel>(method: .get, path: "news/ranks", replacers: [])
}
