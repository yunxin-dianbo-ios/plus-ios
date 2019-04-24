//
//  CommentNetworkRequest.swift
//  ThinkSNS +
//
//  Created by 小唐 on 06/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论相关的网络请求

import Foundation
import ObjectMapper

/**
 注1：评论列表获取的数据解析有2种情况：
    动态、资讯、帖子的评论列表使用pinned字段和comments字段分别包装。"pinned": + "comments":
    圈子动态、音乐模块、问答模块的评论列表直接返回列表，没有字段包装。
 注2：发送评论成功时，会通过comment字段返回当前发送的评论
 */
struct CommentNetworkRequest {

    /// 动态
    struct Moment {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "feeds/:feed/comments", replacers: [":feed"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "feeds/:feed/comments", replacers: [":feed"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "feeds/:feed/comments/:comment", replacers: [":feed", ":comment"])

        //        Send comment
        //        POST /feeds/:feed/comments
        //        Get all comments
        //        GET /feeds/:feed/comments
        //        Delete comment
        //        DELETE /feeds/:feed/comments/:comment
    }

    /// 帖子 - 新版的圈子动态
    struct Post {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "plus-group/group-posts/:post/comments", replacers: [":post"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "plus-group/group-posts/:post/comments", replacers: [":post"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "plus-group/group-posts/:post/comments/:comment", replacers: [":post", ":comment"])

//        帖子评论列表
//        get plus-group/group-posts/:post/comments
//        评论帖子 #
//        POST plus-group/group-posts/:post/comments
//        删除评论 #
//        DELETE plus-group/group-posts/:post/comments/:comment
    }

    /// 资讯
    struct News {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "news/{news}/comments", replacers: ["{news}"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "news/{news}/comments", replacers: ["{news}"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "news/{news}/comments/{comment}", replacers: ["{news}", "{comment}"])

        //        评论一条资讯
        //        POST /news/{news}/comments
        //        获取一条资讯的评论列表
        //        GET /news/{news}/comments
        //        删除一条资讯评论
        //        DELETE /news/{news}/comments/{comment}
    }

    /// 音乐-专辑
    struct Album {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "music/specials/{special_id}/comments", replacers: ["{special_id}"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "music/specials/{special_id}/comments", replacers: ["{special_id}"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "music/specials/{special_id}/comments/{comment_id}", replacers: ["{special_id}", "{comment_id}"])

        // 文档有误
        //        评论专辑
        //        /api/v2/music/specail/{special_id}/comment
        //        专辑评论列表
        //        /api/v2/music/special/{special_id}/comment
        //        删除评论
        //        /api/v2/music/comment/{comment_id}
    }

    /// 音乐-歌曲
    struct Song {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "music/{music_id}/comments", replacers: ["{music_id}"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "music/{music_id}/comments", replacers: ["{music_id}"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "music/{music_id}/comments/{comment_id}", replacers: ["{music_id}", "{comment_id}"])

        // 文档有误
        //        评论歌曲
        //        /api/v2/music/{music_id}/comment
        //        歌曲评论列表
        //        /api/v2/music/{music_id}/comment
        //        删除评论
        //        /api/v2/music/comment/{comment_id}
    }

    /// 问答-问题
    struct Question {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "questions/:question/comments", replacers: [":question"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "questions/:question/comments", replacers: [":question"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "questions/:question/comments/:comment", replacers: [":question", ":comment"])

        //        获取问题评论列表
        //        GET /questions/:question/comments
        //        评论问题
        //        POST /questions/:question/comments
        //        删除问题评论
        //        DELETE /questions/:question/comments/:comment
    }

    /// 问答-答案
    struct Answer {
        /// 评论列表
        static let commentList = Request<TSCommentModel>(method: .get, path: "question-answers/:answer/comments", replacers: [":answer"])
        /// 发送评论
        static let sendComment = Request<TSCommentModel>(method: .post, path: "question-answers/:answer/comments", replacers: [":answer"])
        /// 删除评论
        static let deleteComment = Request<Empty>(method: .delete, path: "question-answers/:answer/comments/:comment", replacers: [":answer", ":comment"])

        //        获取回答评论列表
        //        GET /question-answers/:answer/comments
        //        评论答案
        //        POST /question-answers/:answer/comments
        //        删除回答评论
        //        DELETE /question-answers/:answer/comments/:comment
    }
}
