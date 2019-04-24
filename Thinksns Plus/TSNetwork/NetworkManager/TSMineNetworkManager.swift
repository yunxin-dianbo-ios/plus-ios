//
//  TSMineNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的XX 网络请求管理类

import UIKit

class TSMineNetworkManager: NSObject {

    /// 已购买的单曲
    ///
    /// - Parameters:
    ///    - limit: 可选，默认值 20 ，获取条数
    ///    - max_id: 可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    class func getMySongs(limit: Int = TSAppConfig.share.localInfo.limit, maxID: Int?, complete: @escaping ([TSAlbumMusicModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = MineNetworkRequest().mySong
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let maxID = maxID {
            parameters.updateValue(maxID, forKey: "max_id")
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

    /// 已购买的专辑
    ///
    /// - Parameters:
    ///    - limit: 可选，默认值 20 ，获取条数
    ///    - max_id: 可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    class func getMyMusicAlbums(limit: Int = TSAppConfig.share.localInfo.limit, maxID: Int?, complete: @escaping ([TSAlbumListModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = MineNetworkRequest().myMusicAlbum
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let maxID = maxID {
            parameters.updateValue(maxID, forKey: "max_id")
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

    /// 我的回答
    ///
    /// - Parameters:
    ///    - limit: 数据条数
    ///    - after: 翻页标识
    ///    - type: 数据筛选类型 all - 全部，adoption - 被采纳的，invitation - 被邀请的，other - 其他， 默认为全部
    class func getMyAnswers(type: String, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping ([TSAnswerListModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = MineNetworkRequest().myAnswers
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit, "type": type]
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

    /// 我的问答 - 提问
    ///
    /// - Parameters:
    ///   - type: 数据筛选类型 all-全部 invitation-邀请 reward-悬赏 other-其他 默认全部
    ///   - limit: 获取条数，默认 20
    ///   - after: 上次获取列表最后一个的 ID。默认 0    ///   - complete: 结果
    class func getMyQuestions(type: String, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping ([TSQuoraDetailModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = MineNetworkRequest().myQuestions
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit, "type": type]
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

    /// 我的投稿
    ///
    /// - Parameters:
    ///   - type: 筛选类型 0-已发布 1-待审核 3-被驳回 默认为全部
    ///   - limit: 获取条数，默认 20
    ///   - after: 上次获取列表最后一个的 ID。默认 0
    ///   - complete: 结果
    class func getMyNews(type: Int, limit: Int = TSAppConfig.share.localInfo.limit, after: Int?, complete: @escaping ([NewsDetailModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = MineNetworkRequest().myNews
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit, "type": type]
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
}
