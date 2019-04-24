//
//  TSFavorNetworkRequest.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  所有点赞相关的网络请求

import Foundation

typealias TSLikeNetworkRequest = TSFavorNetworkRequest
struct TSFavorNetworkRequest {

    /// 动态
    struct Moment {
        /// 点赞列表
        static let favorlist = Request<TSLikeUserModel>(method: .get, path: "feeds/:feed/likes", replacers: [":feed"])
        /// 点赞
        static let favor = Request<Empty>(method: .post, path: "feeds/:feed/like", replacers: [":feed"])
        /// 取消赞
        static let unfavor = Request<Empty>(method: .delete, path: "feeds/:feed/unlike", replacers: [":feed"])

        //    动态赞的人列表
        //    GET /feeds/:feed/likes
        //    动态点赞
        //    POST /feeds/:feed/like
        //    动态取消赞
        //    DELETE /feeds/:feed/unlike
    }

    /// 资讯
    struct News {
        /// 点赞列表
        static let favorlist = Request<TSLikeUserModel>(method: .get, path: "news/{news}/likes", replacers: ["{news}"])
        /// 点赞
        static let favor = Request<Empty>(method: .post, path: "news/{news}/likes", replacers: ["{news}"])
        /// 取消赞
        static let unfavor = Request<Empty>(method: .delete, path: "news/{news}/likes", replacers: ["{news}"])

        //    资讯点赞列表
        //    GET /news/{news}/likes
        //    点赞资讯
        //    POST /news/{news}/likes
        //    取消点赞资讯
        //    DELETE /news/{news}/likes
    }

    /// 答案
    struct Answer {
        /// 点赞列表
        static let favorlist = Request<TSLikeUserModel>(method: .get, path: "question-answers/:answer/likes", replacers: [":answer"])
        /// 点赞
        static let favor = Request<Empty>(method: .post, path: "question-answers/:answer/likes", replacers: [":answer"])
        /// 取消赞
        static let unfavor = Request<Empty>(method: .delete, path: "question-answers/:answer/likes", replacers: [":answer"])

        //    一个回答的点赞列表
        //    GET /api/v2/question-answers/:answer/likes
        //    点赞一个回答
        //    POST /api/v2/question-answers/:answer/likes
        //    取消点赞一个回答
        //    DELETE /api/v2/question-answers/:answer/likes
    }

    /// 帖子
    struct Post {
        /// 点赞列表
        static let favorlist = Request<TSLikeUserModel>(method: .get, path: "plus-group/group-posts/:post/likes", replacers: [":post"])
        /// 点赞
        static let favor = Request<Empty>(method: .post, path: "plus-group/group-posts/:post/likes", replacers: [":post"])
        /// 取消点赞
        static let unfavor = Request<Empty>(method: .delete, path: "plus-group/group-posts/:post/likes", replacers: [":post"])

        //        帖子点赞列表
        //        GET plus-group/group-posts/:post/likes
        //        帖子点赞
        //        POST plus-group/group-posts/:post/likes
        //        帖子取消点赞
        //        DELETE plus-group/group-posts/:post/likes
    }

}
