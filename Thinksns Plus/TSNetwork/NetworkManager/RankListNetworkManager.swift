//
//  RankListNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜 网络请求
//  排行榜需使用类型进行统一优化处理

import UIKit

class RankListNetworkManager: NSObject {

    /// 全站粉丝排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getFansRank(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().fans
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
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

    /// 财富达人排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getWealthRank(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().wealth
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
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

    /// 收入达人排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getIncomeRank(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().income
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
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

    /// 社区签到排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getAttendanceRank(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().attendance
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
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

    /// 社区专家排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getCommunityExpertsRank(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().communityExperts
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
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

    /// 问答达人排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getQuoraExpertsRank(limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().quoraExperts
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
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

    /// 今日/一周/本月解答排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - type: 筛选类型 day - 日排行 week - 周排行 month - 月排行
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getAnswersRank(limit: Int = TSAppConfig.share.localInfo.limit, type: String, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().answers
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit, "type": type]
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

    /// 今日/一周/本月动态排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - type: 筛选类型 day - 日排行 week - 周排行 month - 月排行
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getFeedsRank(limit: Int = TSAppConfig.share.localInfo.limit, type: String, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().feeds
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit, "type": type]
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

    /// 今日/一周/本月资讯排行榜
    ///
    /// - Parameters:
    ///    - limit: 数据返回条数 默认10条
    ///    - type: 筛选类型 day - 日排行 week - 周排行 month - 月排行
    ///    - offset: 偏移量 默认为0
    ///   - complete: 结果
    class func getNewsRank(limit: Int = TSAppConfig.share.localInfo.limit, type: String, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = RankListRequest().news
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit, "type": type]
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
}
