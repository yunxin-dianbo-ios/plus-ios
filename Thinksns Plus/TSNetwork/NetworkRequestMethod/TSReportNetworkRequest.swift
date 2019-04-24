//
//  ReportNetworkRequest.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报相关的网络请求

import Foundation

struct TSReportNetworkRequest {
    /// 举报帖子
    static let post = Request<Empty>(method: .post, path: "plus-group/reports/posts/:post", replacers: [":post"])
    /// 举报圈子
    static let group = Request<Empty>(method: .post, path: "plus-group/groups/:group/reports", replacers: [":group"])
    /// 举报用户
    static let user = Request<Empty>(method: .post, path: "report/users/:user", replacers: [":user"])
    /// 举报动态
    static let moment = Request<Empty>(method: .post, path: "feeds/:feed/reports", replacers: [":feed"])
    /// 举报资讯
    static let news = Request<Empty>(method: .post, path: "news/:news/reports", replacers: [":news"])
    /// 举报问题
    static let question = Request<Empty>(method: .post, path: "questions/:question/reports", replacers: [":question"])
    /// 举报答案
    static let answer = Request<Empty>(method: .post, path: "question-answers/:answer/reports", replacers: [":answer"])
    /// 举报话题
    static let topic = Request<Empty>(method: .put, path: "user/report-feed-topics/:topicID", replacers: [":topicID"])
    /// 举报评论
    struct Comment {
        /// 帖子的评论举报
        static let post = Request<Empty>(method: .post, path: "plus-group/reports/comments/:comment", replacers: [":comment"])
        /// 其他评论的举报
        static let other = Request<Empty>(method: .post, path: "report/comments/:comment", replacers: [":comment"])
    }

    /// 圈子中的举报管理
    struct Group {
        /// 举报列表
        static let list = Request<GroupReportModel>(method: .get, path: "plus-group/reports", replacers: [])
        /// 举报通过
        static let accept = Request<Empty>(method: .patch, path: "plus-group/reports/:report/accept", replacers: [":report"])
        /// 举报拒绝
        static let reject = Request<Empty>(method: .patch, path: "plus-group/reports/:report/reject", replacers: [":report"])
    }

}
