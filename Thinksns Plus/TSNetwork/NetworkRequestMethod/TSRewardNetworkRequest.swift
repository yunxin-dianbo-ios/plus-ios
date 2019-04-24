//
//  TSRewardNetworkRequest.swift
//  ThinkSNS +
//
//  Created by 小唐 on 19/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  打赏相关的请求

import Foundation
import ObjectMapper

struct TSRewardNetworkRequest {
    /// 动态
    struct Moment {
        /// 打赏列表
        static let rewardList = Request<TSNewsRewardModel>(method: .get, path: "feeds/{feed}/rewards", replacers: ["{feed}"])
        /// 打赏
        static let reward = Request<Empty>(method: .post, path: "feeds/{feed}/new-rewards", replacers: ["{feed}"])

//        打赏动态
//        POST /feeds/{feed}/rewards
//        动态打赏列表
//        GET /feeds/{feed}/rewards
    }

    /// 资讯
    struct News {
        /// 打赏列表
        static let rewardList = Request<TSNewsRewardModel>(method: .get, path: "news/{news}/rewards", replacers: ["{news}"])
        /// 打赏
        static let reward = Request<Empty>(method: .post, path: "news/{news}/rewards", replacers: ["{news}"])
        /// 资讯打赏统计信息
        static let rewardInfo = Request<Empty>(method: .post, path: "news/{news}/rewards/sum", replacers: ["{news}"])

//        打赏资讯
//        POST /news/{news}/rewards
//        资讯打赏列表
//        GET /news/{news}/rewards
//        资讯打赏统计
//        GET /news/{news}/rewards/sum
    }

    /// 答案
    struct Answer {
        /// 打赏列表
        static let rewardList = Request<TSNewsRewardModel>(method: .get, path: "question-answers/:answer/rewarders", replacers: [":answer"])
        /// 打赏
        static let reward = Request<Empty>(method: .post, path: "question-answers/:answer/new-rewards", replacers: [":answer"])

//        打赏一个回答
//        POST /api/v2/question-answers/:answer/rewarders
//        获取回答打赏列表
//        GET /api/v2/question-answers/:answer/rewarders
    }

    /// 用户
    struct User {
        /// 打赏
        static let reward = Request<Empty>(method: .post, path: "user/:user/new-rewards", replacers: [":user"])

        /// 打赏用户
    }

    /// 帖子
    struct  Post {
        /// 打赏列表
        static let rewardList = Request<TSNewsRewardModel>(method: .get, path: "plus-group/group-posts/:post/rewards", replacers: [":post"])
        /// 打赏
        static let reward = Request<Empty>(method: .post, path: "plus-group/group-posts/:post/new-rewards", replacers: [":post"])

//        帖子打赏列表
//        GET plus-group/group-posts/:post/rewards
//        帖子搭赏
//        POST plus-group/group-posts/:post/rewards

    }
}
