//
//  MineNetworkRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的XX 网络请求

import UIKit

class MineNetworkRequest: NSObject {

    /// 购买的单曲
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 可选，默认值 20 ，获取条数
    ///    - max_id: 可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    let mySong = Request<TSAlbumMusicModel>(method: .get, path: "music/paids", replacers: [])

    /// 购买的专辑
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 可选，默认值 20 ，获取条数
    ///    - max_id: 可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    let myMusicAlbum = Request<TSAlbumListModel>(method: .get, path: "music-specials/paids", replacers: [])

    /// 我的投稿
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 获取条数，默认 20
    ///    - after: 上次获取列表最小的 ID。默认 0
    ///    - type: 筛选类型 0-已发布 1-待审核 3-被驳回 默认为全部
    let myNews = Request<NewsDetailModel>(method: .get, path: "user/news/contributes", replacers: [])

    /// 我的问答 - 提问
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 数据条数
    ///    - after: 翻页标识
    ///    - type: 数据筛选类型 all-全部 invitation-邀请 reward-悬赏 other-其他 默认全部
    let myQuestions = Request<TSQuoraDetailModel>(method: .get, path: "user/questions", replacers: [])

    /// 获取用户发布的回答列表
    ///
    /// - RouteParameter: None TSAnswerListModel
    /// - RequestParameter:
    ///    - limit: 数据条数
    ///    - after: 翻页标识
    ///    - type: 数据筛选类型 all - 全部，adoption - 被采纳的，invitation - 被邀请的，other - 其他， 默认为全部
    let myAnswers = Request<TSAnswerListModel>(method: .get, path: "user/question-answer", replacers: [])
}
