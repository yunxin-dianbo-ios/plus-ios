//
//  TSQuoraNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答模块相关的网络请求
//
//  TODO: - 评论、点赞、收藏、关注、打赏、这种接口应该统一来处理，而不是每处都写一个新的。待完成
//  TODO: - 打赏列表有顺序，之后再统一处理时需要添加该顺序
//  TODO: - 支付也应统一

import Foundation
import ObjectMapper

import Alamofire

class TSQuoraNetworkManager {

}
// MARK: - 发布问答

extension TSQuoraNetworkManager {

    /// 发布问答/发布问题
    class func publishQuora(_ quora: TSQuestionContributeModel, complete: @escaping ((_ question: TSQuestionDetailModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 0. 判断是否可以发布
        if !quora.couldPublish() {
            complete(nil, "问题相关不完整", false)
        }
        // 1. url
        let requestMethod = TSQuoraMethod.Question.publish
        // 2. params
//        subject	字符串	必须，问题主题或者说标题，不能超过 255 字节 ，必须以 ？ 结尾。（不区分全角或者半角）
//        topics	数组	必须，绑定的话题，数组子节点必须符合 { "id": 1 } 的格式。
//        body	字符串	问题描述。
//        anonymity	枚举：0 或者 1	作者是风匿名发布。
//        look	枚举：0 或者 1	是否开启围观，当问题有采纳或者邀请人已回答，则对外部观众自动开启围观。设置围观必须设置悬赏金额。
//        automaticity	枚举：0 或者 1	邀请悬赏自动入账，只邀请一个人的情况下，允许悬赏金额自动入账到被邀请回答者钱包中。
//        invitations	数组	邀请回答，问题邀请回答的人，数组子节点必须符合 { "user": 1 } 的格式，切不能存在自己。
//        amount	数字	问题价值，问题价值，悬赏金额，积分
        var params: [String: Any] = [String: Any]()
        // couldPublish后一定存在的部分
        params.updateValue(quora.title!, forKey: "subject")
        params.updateValue(quora.content!, forKey: "body")
        params.updateValue(quora.content_text!, forKey: "text_body")
        var topicList: [[String: Int]] = [[String: Int]]()
        for topic in quora.topics! {
            let currentTopic: [String: Int] = ["id": topic.id]
            topicList.append(currentTopic)
        }
        params.updateValue(topicList, forKey: "topics")
        // bool状态部分，默认为false
        params.updateValue(quora.isAnonymous ? 1 : 0, forKey: "anonymity")
        // 可能存在，也可能不存在的部分
        if let price = quora.offerRewardPrice {
            params.updateValue(price, forKey: "amount")
            // 开启围观必须设置自动入账
            params.updateValue(quora.isOpenOutlook ? 1 : 0, forKey: "look")
            // 回答自动入账必须开启围观
            params.updateValue(quora.isOpenOutlook ? 1 : 0, forKey: "automaticity")
        }
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                params.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        if let expert = quora.invitationExpert {
            if expert.userIdentity != TSCurrentUserInfo.share.userInfo?.userIdentity {
                var userList: [[String: Int]] = [[String: Int]]()
                userList.append(["user": expert.userIdentity])
                params.updateValue(userList, forKey: "invitations")
            }
        }
        // 3. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: params, complete: { (data, status) in
            var message: String?
            // 3.1 网络请求失败处理
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
                return
            }
            // 3.2 服务器数据异常处理
            guard let dataDic = data as? [String: Any] else {
                message = "服务器数据错误"
                complete(nil, message, false)
                return
            }
            // 3.3 正常数据解析
            message = "发布成功!"
            let model = Mapper<TSQuestionDetailModel>().map(JSONObject: dataDic["question"])
            complete(model, message, status)
        })
    }

    /// 修改指定问题
    ///
    /// - Parameters:
    ///   - questionId: 问题id
    ///   - isUpdateRewardPrice: 是否修改悬赏价格，默认不修改(注：已设置悬赏后，不可再设置悬赏)
    ///   - newQuestion: 新的修改后的问题发布模型
    ///   - complete: 请求结果回调
    class func updateQuestion(_ questionId: Int, isUpdateRewardPrice: Bool = false, newQuestion: TSQuestionContributeModel, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraNetworkRequest.updateQuestion
        request.urlPath = request.fullPathWith(replacers: ["\(questionId)"])
        // 2. param
        var params: [String: Any] = [String: Any]()
        // couldPublish后一定存在的部分
        params.updateValue(newQuestion.title!, forKey: "subject")
        params.updateValue(newQuestion.content!, forKey: "body")
        params.updateValue(newQuestion.content_text!, forKey: "text_body")
        var topicList: [[String: Int]] = [[String: Int]]()
        for topic in newQuestion.topics! {
            let currentTopic: [String: Int] = ["id": topic.id]
            topicList.append(currentTopic)
        }
        params.updateValue(topicList, forKey: "topics")
        params.updateValue(newQuestion.isAnonymous ? 1 : 0, forKey: "anonymity")
        // 判断是否涉及价格悬赏
        if isUpdateRewardPrice, let price = newQuestion.offerRewardPrice, newQuestion.offerRewardPrice! > 0 {
            params.updateValue(price, forKey: "amount")
            if TSAppConfig.share.localInfo.shouldShowPayAlert {
                //Password
                if let inputCode = TSUtil.share().inputCode {
                    params.updateValue(inputCode, forKey: "password")
                    TSUtil.share().inputCode = nil
                }
            }
        }
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }

}

// MARK: - 问答相关/问题相关 常规：增删改查

extension TSQuoraNetworkManager {

    /// 获取所有问题
    ///
    /// - Parameters:
    ///   - subject: 标题搜索关键字
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    ///   - type: 默认值 new, all - 全部、new - 最新、hot - 热门、reward - 悬赏、excellent - 精选 follow - 关注  。
    ///   - complete: 结果
    @discardableResult
    class func getAllQuoras(subject: String?, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, type: String, complete: @escaping ([TSQuoraDetailModel]?, String?, Bool) -> Void) -> DataRequest {
        // 1.请求 url
        let requestMethod = TSQuoraMethod.Question().allList
        // 2.配置参数
        var parameters: [String: Any] = ["type": type, "offset": offset, "limit": limit]
        if let subject = subject {
            parameters.updateValue(subject, forKey: "subject")
        }
        // 3.发送请求
        return try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameters, complete: { (response, status) in
            var message: String?
            // 3.1 网络请求失败处理
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                complete(nil, message, false)
                return
            }
            // 3.2 服务器数据异常处理
            guard let datas = response as? [[String: Any]] else {
                complete(nil, "服务器返回数据异常", false)
                return
            }
            // 3.3 正常数据解析
            let model = Mapper<TSQuoraDetailModel>().mapArray(JSONArray: datas)
            complete(model, nil, true)
        })
    }
    /// 获取相关问题，用于问答发布标题页的输入联想
    @discardableResult
    class func getRelativeQuoras(subject: String, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int = 0, complete: @escaping ((_ searchTtile: String, _ quoraList: [TSQuoraDetailModel]?, _ msg: String?, _ status: Bool) -> Void)) -> DataRequest {
        // 1.请求 url
        let requestMethod = TSQuoraMethod.Question().allList
        // 2.配置参数
        let parameters: [String: Any] = ["type": "all", "offset": offset, "limit": limit, "subject": subject]
        // 3.发送请求
        return try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameters, complete: { (response, status) in
            var message: String?
            if status, let datas = response as? [[String: Any]] {
                // 数据解析
                let modelList = Mapper<TSQuoraDetailModel>().mapArray(JSONArray: datas)
                complete(subject, modelList, nil, true)
                return
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
            }
            complete(subject, nil, message, false)
        })
    }

    /// 获取指定问题详情/问答详情
    /// questionId 问题id
    class func getQuoraDetail(questionId: Int, complete: @escaping ((_ quoraDetail: TSQuoraDetailModel?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Question().detail
        // 2. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(questionId)"), parameter: nil, complete: { (data, status, code) in
                var message: String?
                if status {
                    // 数据解析
                    let quoraDetail = Mapper<TSQuoraDetailModel>().map(JSONObject: data)
                    complete(quoraDetail, message, status, code)
                } else {
                    message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                    complete(nil, message, status, code)
                }
        })
    }

    /// 删除指定问题
    ///
    /// - Parameters:
    ///   - questionId: 指定的问答Id/问题Id
    class func deleteQuora(_ quoraId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Question().delete
        // 2. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(quoraId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                message = "删除成功"
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 管理员删除指定问题
    ///
    /// - Parameters:
    ///   - questionId: 指定的问答Id/问题Id
    class func managerDeleteQuora(_ quoraId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Question().managerDelete
        // 2. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(quoraId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                message = "删除成功"
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 设置指定问题的悬赏价格
    class func setOfferRewardAmount(_ amount: Int, forQuestion questionId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraNetworkRequest.setReward
        request.urlPath = request.fullPathWith(replacers: ["\(questionId)"])
        // 2. params
        var parametars: [String: Any] = ["amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        request.parameter = parametars
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete( "网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(_):
                complete(nil, true)
            }
        }
    }

}

// MARK: - 问答相关/问题相关 用户相关：点赞、收藏、申请精选问答、关注

extension TSQuoraNetworkManager {

    /// MARK: - 问答精选申请

    /// 申请精选问答/为指定问题申请精选
    ///
    /// - Parameters:
    ///   - quoraId: 指定的问答Id/问题Id
    class func applyQuoraApplication(_ quoraId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.User().applyQuoraApplication
        var parametars: [String : Any] = [:]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        // 2. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(quoraId)"), parameter: parametars, complete: { (data, status) in
            var message: String?
            if status {
                message = "支付成功!"
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// MARK: - 关注

    /// 指定问答的关注或取消关注
    ///
    /// - Parameters:
    ///   - followOperate: 关注或取消关注
    ///   - quoraId: 指定问答的id
    class func quoraFollowOperate(_ followOperate: TSFollowOperate, quoraId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. 请求url
        var requestMethod: TSNetworkRequestMethod
        switch followOperate {
        case .follow:
            requestMethod = TSQuoraMethod.User().followQuora
        case .unfollow:
            requestMethod = TSQuoraMethod.User().unfollowQuora
        }
        // 2. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(quoraId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 获取关注的问答列表

    /// MARK: - 答案 点赞

    /// 点赞/取消点赞 一个回答
    class func answerFavorOperate(_ favorOperate: TSFavorOperate, answerId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch favorOperate {
        case .favor:
            request = QuoraAnswerNetworkRequest.favor
        case .unfavor:
            request = QuoraAnswerNetworkRequest.unfavor
        }
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete( "网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(_):
                complete(nil, true)
            }
        }
    }

    /// 一个回答的点赞列表

    /// MARK: - 答案 收藏

    /// 收藏/取消收藏 一个回答
    class func answerCollectOperate(_ collectOperate: TSCollectOperate, answerId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch collectOperate {
        case .collect:
            request = QuoraAnswerNetworkRequest.collect
        case .uncollect:
            request = QuoraAnswerNetworkRequest.uncollect
        }
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete( "网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(_):
                complete(nil, true)
            }
        }
    }

    /// 回答收藏列表
    class func answerCollectionList(afterId: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ answerList: [TSCollectionAnswerModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.collectList
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let success):
                complete(success.models, success.message, true)
            }
        }
    }

    /// MARK: - 排行

}

// MARK: - 答案相关
extension TSQuoraNetworkManager {
    /// 获取指定问题的答案列表
    /// questionId: 问题Id
    /// offset: 偏移量，默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    /// orderType: 排序方式，默认 default, default - 默认排序（按照点赞数）、 time - 按照发布时间倒序。
    /// limit: 获取列表条数，默认 20，修正值 1 - 30。
    class func getAnswerList(questionId: Int, offset: Int = 0, orderType: TSAnserOrderType = .diggCount, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ answerList: [TSAnswerListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Answer().list
        // 2. 请求参数
        let params: [String: Any] = ["limit": limit, "offset": offset, "order_type": orderType.rawValue]
        // 3. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(questionId)"), parameter: params, complete: { (data, status) in
            var message: String?
            if status {
                // 数据解析
                let answerList = Mapper<TSAnswerListModel>().mapArray(JSONObject: data)
                complete(answerList, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
            }
        })
    }

    /// 获取指定答案的详情
    class func getAnswerDetail(_ answerId: Int, complete: @escaping ((_ answerDetail: TSAnswerDetailModel?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.answerDetail
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false, 200)
            case .failure(let failure):
                complete(nil, failure.message, false, failure.statusCode)
            case .success(let data):
                /// 需要判断一下是否是需要围观的回答
                /// 目前需要围观的回答返回的状态是正常的，只是body为空
                if let body = data.model?.body, body.count > 0 {
                    complete(data.model, nil, true, 200)
                } else {
                    complete(data.model, nil, false, 200)
                }
            }
        }
    }

    /// 修改答案
    class func updateAnswer(_ answerId: Int, markdown: String, content: String, isAnonymity: Bool, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.updateAnswer
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        let params: [String: Any] = ["body": markdown, "text_body": content, "anonymity": (isAnonymity ? 1 : 0)]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }

    /// 删除答案
    class func deleteAnswer(_ answerId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.deleteAnswer
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }

    /// 管理员删除答案
    class func managerDeleteAnswer(_ answerId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.managerDeleteAnswer
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }


    /// 采纳答案
    class func adoptAnswer(_ answerId: Int, forQuestion questionId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.adoptAnswer
        request.urlPath = request.fullPathWith(replacers: ["\(questionId)", "\(answerId)"])
        // 2. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }

    // 答案打赏相关

    /// 打赏一个回答
    class func rewardAnswer(_ answerId: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.reward
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        var parametars: [String: Any] = ["amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }

        request.parameter = parametars
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }
    /// 获取回答打赏列表
    class func answerRewardList(_ answerId: Int, offset: Int? = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ rewardList: [TSNewsRewardModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.rewardList
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        /// type	枚举：time、amount	默认值 time, time - 按照打赏时间倒序，amount - 按照金额倒序。
        /// limit	Integer	默认 20 ，获取列表条数，修正值 1 - 30。
        /// offset	integer	默认 0 ，数据偏移量，传递之前通过接口获取的总数。
        var params: [String: Any] = [String: Any]()
        params.updateValue("time", forKey: "type")
        params.updateValue(20, forKey: "limit")
        if let offset = offset {
            params.updateValue(offset, forKey: "offset")
        }
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, data.message, true)
            }
        }
    }

    /// 答案围观支付
    class func answerOutlook(answerId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraAnswerNetworkRequest.outlook
        request.urlPath = request.fullPathWith(replacers: ["\(answerId)"])
        // 2. params
        var parametars: [String : Any] = [:]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        request.parameter = parametars
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }
}

// MARK: - 话题相关

extension TSQuoraNetworkManager {

    /// 获取某个话题的专家列表
    class func getTopicExperts(topicId: Int, after: Int?, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) -> Void {
        // 1.配置路径
        var request = QuoraTopicNetworkRequest().topicExperts
        request.urlPath = request.fullPathWith(replacers: ["\(topicId)"])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 获取某个话题的信息
    class func getTopicInfo(topicId: Int, complete: @escaping (TSQuoraTopicModel?, String?, Bool) -> Void) {
        var request = QuoraTopicNetworkRequest().topicInfo
        request.urlPath = request.fullPathWith(replacers: ["\(topicId)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                if let model = data.model {
                    complete(model, nil, true)
                } else {
                    complete(nil, nil, true)
                }
            }
        }
    }

    /// 获取某个话题下的问题列表
    ///
    /// - Parameters:
    ///   - topicId: 话题 id
    ///   - subject: 标题搜索关键字
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数
    ///   - limit: 默认 20 ，获取列表条数，修正值 1 - 30。
    ///   - type: 默认值 new, all - 全部、new - 最新、hot - 热门、reward - 悬赏、excellent - 精选 。
    ///   - complete: 结果
    class func getTopicQuoras(topicId: Int, subject: String?, offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, type: String, complete: @escaping ([TSQuoraDetailModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        let requestMethod = TSQuoraMethod.Question().listInTopic
        // 2.配置参数
        var parameters: [String: Any] = ["type": type, "offset": offset, "limit": limit]
        if let subject = subject {
            parameters.updateValue("subject", forKey: subject)
        }
        // 3.发送请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(topicId)"), parameter: parameters, complete: { (response, status) in
            var message: String?
            if status, let datas = response as? [[String: Any]] {
                // 数据解析
                let model = Mapper<TSQuoraDetailModel>().mapArray(JSONArray: datas)
                complete(model, nil, true)
                return
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
            }
            complete(nil, message, false)
        })
    }

    /// 获取所有话题列表
    ///
    /// - Parameters:
    ///   - limit: 这次请求获取的条数，默认为 20 条，为了避免过大或者错误查询，设置了一个修正值，最大 50 最小 1 。
    ///   - after: 默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    ///   - shouldGetFollowStatus: 是否检查当前用户是否关注了某话题
    ///   - keyword: 用语搜索话题，传递话题名称关键词。
    ///   - complete: 结果
    @discardableResult
    class func getAllTopics(limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, shouldGetFollowStatus: Bool, keyword: String?, complete: @escaping ([TSQuoraTopicModel]?, String?, Bool) -> Void) -> DataRequest {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Topic().all
        // 2. 请求参数
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "offset")
        }
        if shouldGetFollowStatus {
            parameters.updateValue(1, forKey: "follow")
        }
        if let keyword = keyword {
            parameters.updateValue(keyword, forKey: "name")
        }
        // 3.发送请求
        return try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameters, complete: { (response, status) in
            var message: String?
            if status, let datas = response as? [[String: Any]] {
                // 数据解析
                let model = Mapper<TSQuoraTopicModel>().mapArray(JSONArray: datas)
                complete(model, nil, true)
                return
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
            }
            complete(nil, message, false)
        })
    }

    /// 获取认证用户关注的话题或者专家话题
    ///
    /// - Parameters:
    ///   - limit: 这次请求获取的条数，默认为 20 条，为了避免过大或者错误查询，设置了一个修正值，最大 50 最小 1 。
    ///   - after: 获取 id 之后的数据，要获取某条话题之后的数据，传递该话题 ID。
    ///   - type: 默认值为 follow 代表用户关注的话题列表，如果值为 expert 则获取该用户的专家话题（哪些话题下是专家）。
    ///   - complete: 结果
    class func getUserTopics(limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, type: String = "follow", complete: @escaping ([TSQuoraTopicModel]?, String?, Bool) -> Void) {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Topic().userTopics
        // 2. 请求参数
        var parameters: [String: Any] = ["limit": limit, "type": type]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        // 3.发送请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameters, complete: { (response, status) in
            var message: String?
            if status, let datas = response as? [[String: Any]] {
                // 数据解析
                let model = Mapper<TSQuoraTopicModel>().mapArray(JSONArray: datas)
                complete(model, nil, true)
                return
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
            }
            complete(nil, message, false)
        })
    }

    /// 关注一个话题
    class func follow(topicId: Int, complete: ((String?, Bool) -> Void)?) {
        var request = QuoraTopicNetworkRequest().follow
        request.urlPath = request.fullPathWith(replacers: ["\(topicId)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete?("网络请求错误", false)
            case .failure(let failure):
                complete?(failure.message, false)
            case .success(_):
                complete?(nil, true)
            }
        }
    }

    /// 取消关注一个话题
    class func unFollow(topicId: Int, complete: ((String?, Bool) -> Void)?) {
        var request = QuoraTopicNetworkRequest().unfollow
        request.urlPath = request.fullPathWith(replacers: ["\(topicId)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete?("网络请求错误", false)
            case .failure(let failure):
                complete?(failure.message, false)
            case .success(_):
                complete?(nil, true)
            }
        }
    }

    /// 申请创建一个话题
    class func applyTopic(title: String, content: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request = QuoraTopicNetworkRequest.apply
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        let params = ["name": title, "description": content]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(_):
                complete("已成功提交申请", true)
            }
        }
    }

}

// MARK: - 发布答案(回答一个问题)

extension TSQuoraNetworkManager {

    /// 回答一个提问
    ///
    /// - Parameters:
    ///   - id: 问题 id
    ///   - body: 回答的内容，markdown
    ///   - isAnonymity: 是否匿名。
    ///   - complete: 结果
    class func answer(question id: Int, markdown: String, content: String, isAnonymity: Bool, complete: @escaping (TSAnswerListModel?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = QuoraNetworkRequest().releaseAnswer
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])
        // 2. 配置参数
        let anonymity = isAnonymity ? 1 : 0
        let parametars: [String: Any] = ["body": markdown, "text_body": content, "anonymity": anonymity]
        request.parameter = parametars
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                data.model?.answer?.user = TSCurrentUserInfo.share.userInfo?.convert()
                complete(data.model?.answer, nil, true)
            }
        }
    }
}

// MARK: - Other
// Note： 这里主要是联想搜索：请求需要返回值，回调中需要搜索的关键字

extension TSQuoraNetworkManager {

    /// 根据关键字 + 话题选择 搜索的专家列表
    @discardableResult
    class func getExpertListFor(keyword: String, topicIds: [Int], offset: Int = 0, complete: @escaping ((_ expertList: [TSUserInfoModel]?, _ msg: String?, _ status: Bool) -> Void)) -> DataRequest {
        // 1. 请求url
        let requestMethod = TSQuoraMethod.Topic.expertList
        // 2. 参数
        var params: [String: Any] = [String: Any]()
        params.updateValue(keyword, forKey: "keyword")
        params.updateValue(offset, forKey: "offset")
        if !topicIds.isEmpty {
            params.updateValue(topicIds.convertToString()!, forKey: "topics")
        }
        // 3. 请求
        return try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: params, complete: { (data, status) in
            var message: String?
            if status {
                // 数据解析
                let expertList = Mapper<TSUserInfoModel>().mapArray(JSONObject: data)
                complete(expertList, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
            }
        })
    }

}
