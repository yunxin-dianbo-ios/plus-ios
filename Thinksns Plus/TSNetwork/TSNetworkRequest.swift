//
//  TSNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/7/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  网络请求
//  Warning: TSNetworkRequestMethod 已被逐渐废弃,该页面因为历史原因记录请求方式数据,新的网络请求方式添加到 NetworkRequestMethod 文件夹

import UIKit
import Alamofire
import ObjectMapper

struct Request<T: Mappable>: NetworkRequest {
    /// 网络请求路径
    ///
    /// - Warning: 该路径指的只最终发送给服务的路径,不包含根地址
    var urlPath: String!
    /// 网络请求方式
    var method: HTTPMethod
    /// 网络请求参数
    var parameter: [String: Any]?
    /// 相关的响应数据模型
    ///
    /// - Note: 该模型需要实现相对应的解析协议
    typealias ResponseModel = T
    /// 版本路由
    let version: String
    /// 待替换路由
    let path: String
    /// 待替换关键字
    let replacers: [String]

    /// 替换拼接完整的路径
    ///
    /// - Parameter replacers: 替换的关键字
    /// - Returns: 完整的路径
    func fullPathWith(replacers: [String]) -> String {
        if replacers.isEmpty || self.replacers.isEmpty {
            return version + self.path
        }
        // [待办事项] 将路由用 / 进行拆分 然后比较替换
        var path = version + self.path
        for (index, replacer) in self.replacers.enumerated() {
            path = path.replacingOccurrences(of: replacer, with: replacers[index])
        }
        return path
    }

    /// 初始化
    ///
    /// - Parameters:
    ///   - version: 接口版本信息
    ///   - method: 接口请求方式
    ///   - path: 接口路径
    ///   - replacers: 接口路径替换关键字
    /// - Warning: replacers 需要避免传入相同的关键字,会导致替换错误
    init(version: String = "api/v2/", method: HTTPMethod, path: String, replacers: [String]) {
        self.version = version
        self.method = method
        self.path = path
        self.replacers = replacers
    }
}

struct TSNetworkRequestMethod {
    /// 网络请求方式
    var method: HTTPMethod
    /// 版本路由
    let version: String
    /// 待替换路由
    let path: String
    /// 替换关键字
    let replace: String?
    /// 替换关键字组
    let replacers: [String]

    func fullPath() -> String {
        return version + path
    }

    func fullPathWith(replace: String) -> String {
        assert(self.replace != nil, "替换replace值时，self.replace不能为空")
        return fullPath().replacingOccurrences(of: self.replace!, with: "\(replace)")
    }

    func fullPathWith(replacers: [String]) -> String {
        assert(!self.replacers.isEmpty, "替换replacers值时，self.replacers不能为空")
        var path = fullPath()
        for (index, replacer) in self.replacers.enumerated() {
            path = path.replacingOccurrences(of: replacer, with: replacers[index])
        }
        return path
    }

    /// 初始化
    ///
    /// - Parameters:
    ///   - version: 接口版本信息
    ///   - method: 接口请求方式
    ///   - path: 接口路径
    ///   - replace: 接口路径替换关键字
    /// - Warning: 不建议继续使用该方法,建议使用 replacers 初始化方法
    init(version: String = "api/v2/", method: HTTPMethod, path: String, replace: String?) {
        self.version = version
        self.method = method
        self.path = path
        self.replace = replace
        self.replacers = []
    }

    /// 初始化
    ///
    /// - Parameters:
    ///   - version: 接口版本信息
    ///   - method: 接口请求方式
    ///   - path: 接口路径
    ///   - replacers: 接口路径替换关键字
    /// - Warning: replacers 需要避免传入相同的关键字,会导致替换错误
    init(version: String = "api/v2/", method: HTTPMethod, path: String, replacers: [String]) {
        self.version = version
        self.method = method
        self.path = path
        self.replacers = replacers
        self.replace = nil
    }
}

struct TSMusicNetworkRequest {
    /// 专辑列表
    ///
    /// - Parameter:
    ///   - limit: Integer类型，可选，默认值 20 ，获取条数
    ///   - max_id: Integer类型，	可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    let specialList = TSNetworkRequestMethod(method: .get, path: "music/specials", replace: nil)
    /// 当前登录用户的收藏专辑列表
    ///
    /// - Parameter:
    ///   - limit: Integer类型，可选，默认值 20 ，获取条数
    ///   - max_id: Integer类型，	可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    let specialStoreList = TSNetworkRequestMethod(method: .get, path: "music/collections", replace: nil)
    /// 专辑详情
    ///
    /// - Parameter: 无
    let specialDetailInfo = TSNetworkRequestMethod(method: .get, path: "music/specials/{special}", replace: "{special}")
    /// 添加专辑收藏
    let specialAddCollection = TSNetworkRequestMethod(method: .post, path: "music/specials/{special}/collection", replace: "{special}")
    /// 取消专辑收藏
    let specialCancelCollection = TSNetworkRequestMethod(method: .delete, path: "music/specials/{special}/collection", replace: "{special}")
    /// 音乐详情
    ///
    /// - Parameter: 无
    let musicInfo = TSNetworkRequestMethod(method: .get, path: "music/{music}", replace: "{music}")
    /// 音乐添加点赞
    let musicAddDigg = TSNetworkRequestMethod(method: .post, path: "music/{music}/like", replace: "{music}")
    /// 音乐取消点赞
    let musicCancelDigg = TSNetworkRequestMethod(method: .delete, path: "music/{music}/like", replace: "{music}")
    /// 音乐评论列表
    ///
    /// - Parameter: 无
    let musicComments = TSNetworkRequestMethod(method: .get, path: "music/{music}/comments", replace: "{music}")
    /// 专辑评论列表
    ///
    /// - Parameter: 无
    let specialComments = TSNetworkRequestMethod(method: .get, path: "music/specials/{special}/comments", replace: "{special}")
    /// 添加音乐评论
    ///
    /// - Parameter:
    ///    - body: string类型。评论内容
    ///    - reply_user: Integer类型。被回复者，默认为0
    let postMusicComment = TSNetworkRequestMethod(method: .post, path: "music/{music}/comments", replace: "{music}")
    /// 添加专辑评论
    ///
    /// - Parameter:
    ///    - body: string类型。评论内容
    ///    - reply_user: Integer类型。被回复者，默认为0
    let postSpecialComment = TSNetworkRequestMethod(method: .post, path: "music/specials/{special}/comments", replace: "{special}")
    /// 删除音乐评论
    ///
    /// - Parameter:
    ///    - body: string类型。评论内容
    ///    - reply_user: Integer类型。被回复者，默认为0
    let deleteMusicComment = TSNetworkRequestMethod(method: .delete, path: "music/{music}/comments/{comment}", replace: "{music}/comments/{comment}")
    /// 删除专辑评论
    ///
    /// - Parameter:
    ///    - body: string类型。评论内容
    ///    - reply_user: Integer类型。被回复者，默认为0
    // TODO: MusicUpdate - 音乐模块更新中，To be done
    let deleteSpecialComment = TSNetworkRequestMethod(method: .delete, path: "music/specials/{special}/comments/{comment}", replace: "{special}/comments/{comment}")
}

struct TSNetworkRequest {
    /// 用户粉丝列表
    /// 查询多个用户将 replace 替换为标识字符串
    let followersList = TSNetworkRequestMethod(method: .get, path: "users/{user}/followers", replace: "{user}")
    /// 当前认证（登录）用户的粉丝列表
    let authFollowersList = TSNetworkRequestMethod(method: .get, path: "user/followers", replace: nil)
    /// 用户关注列表
    /// 查询多个用户将 replace 替换为标识字符串
    let followingsList = TSNetworkRequestMethod(method: .get, path: "users/{user}/followings", replace: "{user}")
    /// 当前认证（登录）用户的关注列表
    let authFollowingsList = TSNetworkRequestMethod(method: .get, path: "user/followings", replace: nil)
    /// 关注某用户
    let followUser = TSNetworkRequestMethod(method: .put, path: "user/followings/:user", replace: ":user")
    /// 取消关注某用户
    let unfollowUser = TSNetworkRequestMethod(method: .delete, path: "user/followings/:user", replace: ":user")
    /// 搜索好友
    let searchMyFriend = TSNetworkRequestMethod(method: .get, path: "user/follow-mutual", replace: nil)
}

struct TSTopicNetworkRequest {
    /// 话题列表
    let topicList = TSNetworkRequestMethod(method: .get, path: "feed/topics", replace: nil)
    /// 创建话题
    let createTopic = TSNetworkRequestMethod(method: .post, path: "feed/topics", replace: nil)
    /// 关注话题
    let followTopic = TSNetworkRequestMethod(method: .put, path: "user/feed-topics/:topicID", replace: ":topicID")
    /// 取消关注话题
    let unFollowTopic = TSNetworkRequestMethod(method: .delete, path: "user/feed-topics/:topicID", replace: ":topicID")
    /// 编辑话题
    let editTopic = TSNetworkRequestMethod(method: .patch, path: "feed/topics/:topicID", replace: ":topicID")
    /// 话题详情
    let detailTopic = TSNetworkRequestMethod(method: .get, path: "feed/topics/:topicID", replace: ":topicID")
    /// 获取话题下的动态列表
    let topicMomentList = Request<FeedListModel>(method: .get, path: "feed/topics/:topicID/feeds", replacers: [":topicID"])
    /// 举报话题
    let reportTopic = TSNetworkRequestMethod(method: .put, path: "user/report-feed-topics/:topicID", replace: ":topicID")
    /// 获取话题下的参与者
    let topicMenberList = TSNetworkRequestMethod(method: .get, path: "feed/topics/:topicID/participants", replace: ":topicID")
}

struct TSUserlabelRequest {
    /// 获取所有的tags
    let allTagsList = TSNetworkRequestMethod(method: .get, path: "tags", replace: nil)
    /// 获取当前用户的tags
    let authUserTagsList = TSNetworkRequestMethod(method: .get, path: "user/tags", replace: nil)
    /// 增加一个tag给当前用户
    let addAuthUserTag = TSNetworkRequestMethod(method: .put, path: "user/tags/:tag", replace: ":tag")
    /// 删除一个tag给当前用户
    let deleteAuthUserTag = TSNetworkRequestMethod(method: .delete, path: "user/tags/:tag", replace: ":tag")
}

/// 地区搜索相关
struct TSAreaSearchRequest {
    /// 搜索列表
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - name: String. **必传** 位置关键词
    let searchList = TSNetworkRequestMethod(method: .get, path: "locations/search", replace: nil)
    /// 热门城市
    let searchPopularCity = TSNetworkRequestMethod(method: .get, path: "locations/hots", replace: nil)
}

/// 用户打赏相关
struct TSUserRewardNetworkMethod {
    /// 打赏一个用户
    let reward = TSNetworkRequestMethod(method: .post, path: "user/:user/new-rewards", replace: ":user")
}

/// 签到相关
struct TSCheckinRequest {
    /// 获取签到信息
    let getCheckinList = TSNetworkRequestMethod(method: .get, path: "user/checkin", replace: nil)
    /// 点击签到请求
    let checking = TSNetworkRequestMethod(method: .put, path: "user/checkin/currency", replace: nil)

}

/// 资讯投稿相关
struct TSNewsContributeNetworkMethod {
    /// 提交投稿
    let submitNews = TSNetworkRequestMethod(method: .post, path: "news/categories/:category/currency-news", replace: ":category")
    /// 修改投稿
    /// 删除投稿
    /// 申请退款
    /// 获取用户投稿列表

}
/// 资讯评论相关
struct TSNewsCommentNetworkMethod {
    /// 获取指定资讯的评论列表
    let commentList = TSNetworkRequestMethod(method: .get, path: "news/{news}/comments", replace: "{news}")
    /// 评论一条资讯
    let submitComment = TSNetworkRequestMethod(method: .post, path: "news/{news}/comments", replace: "{news}")
    /// 删除一条资讯评论
    let deleteComment = TSNetworkRequestMethod(method: .delete, path: "news/{news}/comments/{comment}", replace: "{news}/comments/{comment}")

    // 资讯评论置顶相关

    /// 申请资讯评论置顶
    let applyCommentTop = TSNetworkRequestMethod(method: .post, path: "news/{news}/comments/{comment}/currency-pinneds", replace: "{news}/comments/{comment}")
    /// 同意评论置顶
    /// 拒绝评论置顶
    /// 查看资讯中申请置顶的评论列表
    /// 取消置顶
}

/// 问答模块 -
struct TSQuoraMethod {

    /// 话题相关
    struct Topic {
        /// 获取全部话题
        let all = TSNetworkRequestMethod(method: .get, path: "question-topics", replace: nil)
        /// 获取认证用户关注的话题或者专家话题
        let userTopics = TSNetworkRequestMethod(method: .get, path: "user/question-topics", replace: nil)
        /// 获取一个话题
        let detail = TSNetworkRequestMethod(method: .get, path: "question-topics/:topic", replace: ":topic")
        /// 关注一个话题，采用新网络请求方式，参见 QuoraNetworkRequest
        /// 取消关注一个话题，采用新网络请求方式，参见 QuoraNetworkRequest
        /// 获取话题下专家列表
        let experts = TSNetworkRequestMethod(method: .get, path: "question-topics/:topic/experts", replace: ":topic")
        /// 批量获取专家列表
        static let expertList = TSNetworkRequestMethod(method: .get, path: "question-experts", replace: nil)
    }

    /// 问题相关
    struct Question {
        /// 发布问题
        static let publish = TSNetworkRequestMethod(method: .post, path: "currency-questions", replace: nil)
        /// 更新问题
        let update = TSNetworkRequestMethod(method: .patch, path: "/questions/:question", replace: ":question")
        /// 设置问题悬赏金额(在没有采纳和邀请且未设置悬赏金额时，问题作者重新设置问题的悬赏)
        let setRewardAmount = TSNetworkRequestMethod(method: .patch, path: "currency-questions/:question/amount", replace: ":question")
        /// 获取所有问题列表
        let allList = TSNetworkRequestMethod(method: .get, path: "questions", replace: nil)
        /// 获取某个话题下的问题列表
        let listInTopic = TSNetworkRequestMethod(method: .get, path: "question-topics/:topic/questions", replace: ":topic")
        /// 获取一个问题详情
        let detail = TSNetworkRequestMethod(method: .get, path: "questions/:question", replace: ":question")
        /// 删除一个问题
        let delete = TSNetworkRequestMethod(method: .delete, path: "currency-questions/:question", replace: ":question")
        /// 管理员删除一个问题
        let managerDelete = TSNetworkRequestMethod(method: .delete, path: "qa/questions/{id}", replace: "{id}")
        /// 获取用户发布的问题列表
        let publishList = TSNetworkRequestMethod(method: .get, path: "user/questions", replace: nil)
    }

    /// 答案相关
    struct Answer {
        /// 获取指定问题下的回答列表  listInQuestion
        let list = TSNetworkRequestMethod(method: .get, path: "questions/:question/answers", replace: ":question")
        /// 获取一个回答详情
        let detail = TSNetworkRequestMethod(method: .get, path: "question-answers/:answer", replace: ":answer")
        /// 回答一个提问
        let reply = TSNetworkRequestMethod(method: .post, path: "currency-questions/:question/answers", replace: ":question")
        /// 采纳一个回答
        let adopt = TSNetworkRequestMethod(method: .put, path: "questions/:question/currency-adoptions/:answer", replace: ":question/adoptions/:answer")
        /// 更新一个回答
        let update = TSNetworkRequestMethod(method: .patch, path: "question-answers/:answer", replace: ":answer")
        /// 删除一个回答
        let delete = TSNetworkRequestMethod(method: .delete, path: "question-answers/:answer", replace: ":answer")
    }

    /// 用户相关
    struct User {
        /// 关注问题
        ///  获取关注的问题列表
        let followedQuoraList = TSNetworkRequestMethod(method: .get, path: "user/question-watches", replace: nil)
        ///  关注一个问题
        let followQuora = TSNetworkRequestMethod(method: .put, path: "user/question-watches/:question", replace: ":question")
        ///  取消关注一个问题
        let unfollowQuora = TSNetworkRequestMethod(method: .delete, path: "user/question-watches/:question", replace: ":question")

        /// 点赞回答
        ///  点赞一个回答
        ///  取消点赞一个回答
        ///  一个回答的点赞列表

        /// 收藏回答
        ///  收藏一个回答
        ///  取消收藏一个回答
        ///  回答收藏列表

        /// 申请问答精选
        let applyQuoraApplication = TSNetworkRequestMethod(method: .post, path: "user/currency-question-application/:question", replace: ":question")
        /// 排行
        ///  获取解答排行
        ///  获取问答达人排行
        ///  获取社区专家排行
    }

    /// 评论相关
    struct Comment {
        /// 获取问题评论列表
        let questionCommentList = TSNetworkRequestMethod(method: .get, path: "questions/:question/comments", replace: ":question")
        /// 获取回答评论列表
        let answerCommentList = TSNetworkRequestMethod(method: .get, path: "question-answers/:answer/comments", replace: ":answer")
        /// 评论问题
        let submitQuestionComment = TSNetworkRequestMethod(method: .post, path: "questions/:question/comments", replace: ":question")
        /// 评论答案
        let submitAnswerComment = TSNetworkRequestMethod(method: .post, path: "question-answers/:answer/comments", replace: ":answer")
        /// 删除问题评论
        let deleteQuestionComment = TSNetworkRequestMethod(method: .delete, path: "questions/:question/comments/:answer", replace: ":question/comments/:answer")
        /// 删除回答评论
        let deleteAnswerComment = TSNetworkRequestMethod(method: .delete, path: "question-answers/:answer/comments/:comment", replace: ":answer/comments/:comment")
    }
}
