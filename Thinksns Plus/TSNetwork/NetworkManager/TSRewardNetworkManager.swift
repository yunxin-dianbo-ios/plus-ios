//
//  TSRewardNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 19/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  打赏相关的网络请求
/*****
 注：打赏类型参考TSRewardType，有Moment、News、Answer、User
    打赏类型请求的数据模型：暂时使用的是TSNewsRewardModel，之后待修正为通用的打赏列表模型
    打赏列表中，User打赏是没有打赏列表的；
    打赏信息的获取：User打赏是没有相关信息获取的；Answer打赏和Moment打赏是在对应详情中；News打赏是打赏列表和打赏总金额两个接口加起来
    打赏相关信息，可考虑使用一个通用模型来处理。待完成。
    打赏相关的信息的请求，暂未完成。采用兼容之前的方案，另外打赏成功后直接回调处理，而不是请求处理即可。
 
 **/

import Foundation
import ObjectMapper

/// 打赏排序字段
enum TSRewardOrderField: String {
    /// date 和 time 表达意思都是一样的，但请求要求传入的不一样。
    /// 打赏时间
    case date
    /// 打赏时间
    case time
    /// 打赏金额
    case amount
}

class TSRewardNetworkManger {
    /// 获取打赏列表
    class func getRewardList(type: TSRewardType, sourceId: Int, offset: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ rewardList: [TSNewsRewardModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<TSNewsRewardModel>
        switch type {
        case .moment:
            request = TSRewardNetworkRequest.Moment.rewardList
        case .news:
            request = TSRewardNetworkRequest.News.rewardList
        case .answer:
            request = TSRewardNetworkRequest.Answer.rewardList
        case .user:
            // 用户打赏类型暂没有打赏列表
            fatalError("TSRewardNetworkManger.getRewardList 暂不支持User类型的打赏列表请求")
        case .post:
            request = TSRewardNetworkRequest.Post.rewardList
        }
        request.urlPath = request.fullPathWith(replacers: ["\(sourceId)"])
        // 2. params
        var orderField: TSRewardOrderField = TSRewardOrderField.date
        let orderType: TSOrderType = TSOrderType.descending
        var params: [String: Any] = ["limit": limit, "offset": offset]
        switch type {
        case .answer:
            // 答案的排序字段为: time 和 amount
            orderField = (orderField == TSRewardOrderField.date) ? .time : orderField
            params.updateValue("type", forKey: orderField.rawValue)
        case .moment:
            fallthrough
        case .post:
            fallthrough
        case .news:
            // 动态 和 资讯 和 帖子 的排序字段为: date 和 amount
            params.updateValue("order_type", forKey: orderField.rawValue)
            params.updateValue("order", forKey: orderType.rawValue)
        case .user:
            break
        }
        request.parameter = params
        // 3. requeest
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

    /// 打赏的网络请求
    class func reward(type: TSRewardType, sourceId: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var request: Request<Empty>
        switch type {
        case .moment:
            request = TSRewardNetworkRequest.Moment.reward
        case .news:
            request = TSRewardNetworkRequest.News.reward
        case .answer:
            request = TSRewardNetworkRequest.Answer.reward
        case .user:
            request = TSRewardNetworkRequest.User.reward
        case .post:
            request = TSRewardNetworkRequest.Post.reward
        }
        request.urlPath = request.fullPathWith(replacers: ["\(sourceId)"])
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
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }
}

extension TSRewardNetworkManger {

    /// 获取打赏相关信息
    class func getRerwardInfo(type: TSRewardType, sourceId: Int, complete: @escaping (() -> Void)) -> Void {
        switch type {
        case .answer:
            fallthrough
        case .user:
            fatalError("当前这种方式还不支持User和Answer类型获取打赏相关信息")
        default:
            break
        }

        fatalError("该方法未完成，之前的方式可以兼容，就无需再额外处理了。")

    }

}
