//
//  TSPinnedNetworkRequest.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  置顶相关的请求

import Foundation

struct TSPinnedNetworkRequest {

    struct News {
//        申请资讯置顶
//        查看申请置顶的资讯列表
    }
    struct Post {
        /// 帖子申请置顶列表
        static let pinnedList = Request<ReceivePendingPostTopModel>(method: .get, path: "plus-group/pinned/posts", replacers: [])
        /// 申请帖子置顶
        static let applyPinned = Request<Empty>(method: .post, path: "plus-group/pinned/posts/:post", replacers: [":post"])
        /// 通过帖子置顶
        static let agreePinned = Request<Empty>(method: .patch, path: "plus-group/currency-pinned/posts/:post/accept", replacers: [":post"])
        /// 拒绝帖子置顶
        static let rejectPinned = Request<Empty>(method: .patch, path: "plus-group/currency-pinned/posts/:post/reject", replacers: [":post"])

//        帖子申请置顶列表
//        GET /pinned/posts
//        申请帖子置顶
//        POST /pinned/posts/:post
//        通过帖子置顶
//        PATCH /pinned/posts/:post/accept
//        拒绝帖子置顶
//        PATCH /pinned/posts/:post/reject
    }

    struct Comment {

        struct Moment {
            /// 动态评论置顶审核列表
            static let pinnedList = Request<ReceivePendingFeedCommentTopModel>(method: .get, path: "user/feed-comment-pinneds", replacers: [])
            /// 评论置顶
            static let applyPinned = Request<Empty>(method: .post, path: "feeds/:feed/comments/:comment/pinneds", replacers: [":feed", ":comment"])
            /// 评论置顶审核通过
            static let agreePinned = Request<Empty>(method: .patch, path: "feeds/:feed/comments/:comment/currency-pinneds/:pinned", replacers: [":feed", ":comment", ":pinned"])
            /// 拒绝动态评论置顶申请
            static let rejectPinned = Request<Empty>(method: .delete, path: "user/feed-comment-currency-pinneds/:pinned", replacers: [":pinned"])

//            动态评论置顶审核列表
//            GET /user/feed-comment-pinneds
//            评论置顶
//            POST /feeds/:feed/comments/:comment/pinneds
//            评论置顶审核通过
//            PATCH /feeds/:feed/comments/:comment/pinneds/:pinned
//            拒绝动态评论置顶申请
//            DELETE /user/feed-comment-pinneds/:pinned

//            删除动态置顶评论
//            DELETE /feeds/:feed/comments/:comment/unpinned
        }
        struct News {

            /// 查看申请置顶的评论列表
            static let pinnedList = Request<ReceivePendingNewsCommentTopModel>(method: .get, path: "news/comments/pinneds", replacers: [])
            /// 申请资讯评论置顶
            static let applyPinned = Request<Empty>(method: .post, path: "news/{news}/comments/{comment}/currency-pinneds", replacers: ["{news}", "{comment}"])
            /// 通过审核评论置顶
            static let agreePinned = Request<Empty>(method: .patch, path: "news/{news}/comments/{comment}/currency-pinneds/{pinned}", replacers: ["{news}", "{comment}", "{pinned}"])
            /// 拒绝评论置顶
            static let rejectPinned = Request<Empty>(method: .patch, path: "news/{news}/comments/{comment}/currency-pinneds/{pinned}/reject", replacers: ["{news}", "{comment}", "{pinned}"])

//            查看申请置顶的评论列表
//            GET /news/comments/pinneds
//            申请资讯评论置顶
//            POST /news/{news}/comments/{comment}/pinneds
//            审核评论置顶
//            PATCH /news/{news}/comments/{comment}/pinneds/{pinned}
//            拒绝评论置顶
//            PATCH /news/{news}/comments/{comment}/pinneds/{pinned}/reject

//            取消置顶
//            DELETE /news/{news}/comments/{comment}/pinneds/{pinned}
        }
        struct Post {

            /// 帖子评论申请置顶列表
            static let pinnedList = Request<ReceivePendingPostCommentTopModel>(method: .get, path: "plus-group/pinned/comments", replacers: [])
            /// 帖子评论申请置顶
            static let applyPinned = Request<Empty>(method: .post, path: "plus-group/currency-pinned/comments/:comment", replacers: [":comment"])
            /// 通过帖子评论申请置顶
            static let agreePinned = Request<Empty>(method: .patch, path: "plus-group/currency-pinned/comments/:comment/accept", replacers: [":comment"])
            /// 拒绝帖子评论申请置顶
            static let rejectPinned = Request<Empty>(method: .patch, path: "plus-group/currency-pinned/comments/:comment/reject", replacers: [":comment"])

//            帖子评论申请置顶列表
//            GET /pinned/comments
//            帖子评论申请置顶
//            POST /pinned/comments/:comment
//            通过帖子评论申请置顶
//            PATCH /pinned/comments/:comment/accept
//            拒绝帖子评论申请置顶
//            PATCH /pinned/comments/:comment/reject
        }

    }

}
