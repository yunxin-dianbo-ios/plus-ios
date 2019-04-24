//
//  QuoraNetworkRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/30.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

/// 问答话题相关
struct QuoraTopicNetworkRequest {

    /// 获取某个话题的专家列表
    ///
    /// - RouteParameter:
    ///    - topicId: 话题 Id
    /// - RequestParameter: None
    let topicExperts = Request<TSUserInfoModel>(method: .get, path: "question-topics/:topic/experts", replacers: [":topic"])

    /// 获取某个话题的信息
    ///
    /// - RouteParameter:
    ///    - topicId: 话题 Id
    /// - RequestParameter: None
    let topicInfo = Request<TSQuoraTopicModel>(method: .get, path: "question-topics/:topic", replacers: [":topic"])

    /// 关注一个话题
    ///
    /// - RouteParameter: 
    ///    - topicId: 话题 Id
    /// - RequestParameter: None
    let follow = Request<Empty>(method: .put, path: "user/question-topics/:topic", replacers: [":topic"])

    /// 取消关注一个话题
    ///
    /// - RouteParameter:
    ///    - topicId: 话题 Id
    /// - RequestParameter: None
    let unfollow = Request<Empty>(method: .delete, path: "user/question-topics/:topic", replacers: [":topic"])

    /// 申请创建一个话题
    static let apply = Request<Empty>(method: .post, path: "user/question-topics/application", replacers: [])
}

// MARK: - 问答相关
struct QuoraNetworkRequest {
    /// 回答一个提问
    ///
    /// - RouteParameter:
    ///    - question: 问题 Id
    /// - RequestParameter:
    ///    - body: String；必须，回答的内容，markdown。
    ///    - anonymity: Enum 0，1； 是否匿名。
    let releaseAnswer = Request<TSQuoraAnswerNetworkAnalysisModel>(method: .post, path: "currency-questions/:question/answers", replacers: [":question"])

    /// 设置问题悬赏
    static let setReward = Request<Empty>(method: .patch, path: "currency-questions/:question/amount", replacers: [":question"])
    /// 更新问题
    static let updateQuestion = Request<Empty>(method: .patch, path: "currency-questions/:question", replacers: [":question"])
}

// MARK: - 问答答案
struct QuoraAnswerNetworkRequest {
    /// 获取一个回答详情
    static let answerDetail = Request<TSAnswerDetailModel>(method: .get, path: "question-answers/:answer", replacers: [":answer"])
    /// 更新一个回答
    static let updateAnswer = Request<Empty>(method: .patch, path: "question-answers/:answer", replacers: [":answer"])
    /// 采纳一个回答
    static let adoptAnswer = Request<Empty>(method: .put, path: "questions/:question/currency-adoptions/:answer", replacers: [":question", ":answer"])
    /// 删除一个回答
    static let deleteAnswer = Request<Empty>(method: .delete, path: "question-answers/:answer", replacers: [":answer"])
    /// 管理员删除一个回答
    static let managerDeleteAnswer = Request<Empty>(method: .delete, path: "qa/answers/{id}", replacers: ["{id}"])

    /// 答案的评论列表
    static let commentList = Request<TSCommentModel>(method: .get, path: "question-answers/:answer/comments", replacers: [":answer"])
    /// 提交答案的评论
    static let submitComment = Request<Empty>(method: .post, path: "question-answers/:answer/comments", replacers: [":answer"])
    /// 删除答案的评论
    static let deleteComment = Request<Empty>(method: .delete, path: "question-answers/:answer/comments/:comment", replacers: [":answer", ":comment"])

    // 答案点赞

    /// 点赞一个回答
    static let favor = Request<Empty>(method: .post, path: "question-answers/:answer/likes", replacers: [":answer"])
    /// 取消点赞一个回答
    static let unfavor = Request<Empty>(method: .delete, path: "question-answers/:answer/likes", replacers: [":answer"])
    /// 一个回答的点赞列表
    static let favorList = Request<Empty>(method: .get, path: "question-answers/:answer/likes", replacers: [":answer"])

    /// 答案收藏

    /// 收藏一个回答
    static let collect = Request<Empty>(method: .post, path: "user/question-answer/collections/:answer", replacers: [":answer"])
    /// 取消收藏一个回答
    static let uncollect = Request<Empty>(method: .delete, path: "user/question-answer/collections/:answer", replacers: [":answer"])
    /// 回答收藏列表
    static let collectList = Request<TSCollectionAnswerModel>(method: .get, path: "user/question-answer/collections", replacers: [""])

    // 答案打赏

    /// 打赏一个回答
    static let reward = Request<Empty>(method: .post, path: "question-answers/:answer/new-rewards", replacers: [":answer"])
    /// 获取回答打赏列表
    static let rewardList = Request<TSNewsRewardModel>(method: .get, path: "question-answers/:answer/rewarders", replacers: [":answer"])

    /// 答案围观
    static let outlook = Request<Empty>(method: .post, path: "question-answers/:answer/currency-onlookers", replacers: [":answer"])
}
