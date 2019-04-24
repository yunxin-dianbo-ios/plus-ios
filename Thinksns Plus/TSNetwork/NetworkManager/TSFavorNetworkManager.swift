//
//  TSFavorNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  点赞相关的网络请求
/// 目前可点赞的对象：用户、问答话题...

import Foundation

/// 点赞操作
typealias TSDiggOperate = TSFavorOperate
typealias TSLikeOperate = TSFavorOperate
enum TSFavorOperate {
    /// 点赞
    case favor
    /// 取消点赞
    case unfavor
}

/// 点赞对象 de 类型
typealias TSDiggTargetType = TSFavorTargetType
typealias TSLikeTargetType = TSFavorTargetType
enum TSFavorTargetType {
    /// 动态
    case moment
    /// 资讯
    case news
    /// 答案
    case answer
    /// 帖子
    case post
}

class TSFavorNetworkManager {

    /// 获取点赞列表
    ///
    /// - Parameters:
    ///   - targetId: 点赞对象id
    ///   - targetType: 点赞对象的类型
    ///   - afterId: 请求指定id之后的数据，可传0
    ///   - limit: 获取条数限制
    ///   - complete: 请求结果回调
    class func favorList(targetId: Int, targetType: TSFavorTargetType, afterId: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping((_ favorList: [TSFavorListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<TSFavorListModel>
        switch targetType {
        case .moment:
            request = TSFavorNetworkRequest.Moment.favorlist
        case .news:
            request = TSFavorNetworkRequest.News.favorlist
        case .answer:
            request = TSFavorNetworkRequest.Answer.favorlist
        case .post:
            request = TSFavorNetworkRequest.Post.favorlist
        }
        request.urlPath = request.fullPathWith(replacers: ["\(targetId)"])
        // 2. params
        let params: [String: Any] = ["limit": limit, "after": afterId]
        request.parameter = params
        // 3. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                complete(response.models, nil, true)
            }
        }
    }

    /// 点赞相关操作
    ///
    /// - Parameters:
    ///   - targetId: 点赞对象的id
    ///   - targetType: 点赞对象的类型
    ///   - favorOperate: 操作(点赞/取消赞)
    ///   - complete: 请求结果回调
    class func favorOperate(targetId: Int, targetType: TSFavorTargetType, favorOperate: TSFavorOperate, complete: @escaping((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request: Request<Empty>
        switch favorOperate {
        case .favor:
            switch targetType {
            case .moment:
                request = TSFavorNetworkRequest.Moment.favor
            case .news:
                request = TSFavorNetworkRequest.News.favor
            case .answer:
                request = TSFavorNetworkRequest.Answer.favor
            case .post:
                request = TSFavorNetworkRequest.Post.favor
            }
        case .unfavor:
            switch targetType {
            case .moment:
                request = TSFavorNetworkRequest.Moment.unfavor
            case .news:
                request = TSFavorNetworkRequest.News.unfavor
            case .answer:
                request = TSFavorNetworkRequest.Answer.unfavor
            case .post:
                request = TSFavorNetworkRequest.Post.unfavor
            }
        }
        request.urlPath = request.fullPathWith(replacers: ["\(targetId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

}
