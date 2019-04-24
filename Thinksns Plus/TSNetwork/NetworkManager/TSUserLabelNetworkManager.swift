//
//  TSUserLabelNetworkManager.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

import ObjectMapper

class TSUserLabelNetworkManager {

    /// 获取用户标签
    class func get(userTags userId: Int, complete: @escaping([TSTagModel]?, String?) -> Void) {
        // 1. url
        var request = UserNetworkRequest().userTags
        request.urlPath = request.fullPathWith(replacers: ["\(userId)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(nil, "网络请求错误")
            case .failure(let failure):
                complete(nil, failure.message)
            case .success(let data):
                complete(data.models, nil)
            }
        }
    }

    /// 获取服务器所有标签数据
    ///
    /// - Parameter complete: （model数组， msg, 状态）
    func getAllTags(complete: @escaping ((_ tags: [TSCategoryTagModel]?, _ message: String?, _ status: Bool) -> Void)) {
        let requestMethod = TSUserlabelRequest().allTagsList
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (networkResponse, result) in
            var message: String?
            if result {
                let arry = Mapper<TSCategoryTagModel>().mapArray(JSONObject: networkResponse)
                complete(arry, nil, result)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                complete(nil, message, result)
            }
        })
    }

    /// 添加用户标签
    ///
    /// - Parameters:
    ///   - tag: 标签的id
    ///   - complete: (状态， 消息)
    func add(tag: Int, complete: @escaping ((_ status: Bool, _ message: String?) -> Void)) {
        let requestMethod = TSUserlabelRequest().addAuthUserTag
        let fullPath = requestMethod.fullPath().replacingOccurrences(of: requestMethod.replace!, with: "\(tag)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (NetworkResponse, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: NetworkResponse)
                complete(status, message)
                return
            }
            complete(status, nil)
        })
    }

    /// 删除用户标签
    ///
    /// - Parameters:
    ///   - tag: 标签的id
    ///   - complete: (状态， 消息)
    func delete(tag: Int, complete: @escaping ((_ status: Bool, _ message: String?) -> Void)) {
        let requestMethod = TSUserlabelRequest().deleteAuthUserTag
        let fullPath = requestMethod.fullPath().replacingOccurrences(of: requestMethod.replace!, with: "\(tag)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (NetworkResponse, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: NetworkResponse)
                complete(status, message)
                return
            }
            complete(status, nil)
        })
    }

    /// 获取当前用户的所有标签
    ///
    /// - Parameter complete: 一个数组model
    func getAuthUserTags(complete: @escaping ((_ AuthUserTags: [TSCategoryIdTagModel]?) -> Void)) {
        let requestMethod = TSUserlabelRequest().authUserTagsList
        try!RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (NetworkResponse, status) in
            guard status else {
                complete(nil)
                return
            }
            let arry = Mapper<TSCategoryIdTagModel>().mapArray(JSONObject: NetworkResponse)
            complete(arry)
        })
    }

    /// 设置用户标签
    /// 呵呵
    /// 服务器不支持多个标签的设置，而前端体验需要优化，采用将所有的请求放置到最后来处理
    /// 目前某一个标签请求出错，不予处理
    class func setUserTags(addTags: [Int], deleteTags: [Int], complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        if addTags.isEmpty && deleteTags.isEmpty {
            complete("标签设置完成", true)
            return
        }
        let group = DispatchGroup()
        var isRequestError: Bool = false
        var message: String? = nil
        /// 标签添加
        for addTag in addTags {
            group.enter()
            TSUserLabelNetworkManager().add(tag: addTag, complete: { (status, msg) in
                if !status && !isRequestError {
                    isRequestError = status
                    message = msg
                }
                group.leave()
            })
        }
        /// 标签移除
        for deleteTag in deleteTags {
            group.enter()
            TSUserLabelNetworkManager().delete(tag: deleteTag, complete: { (status, msg) in
                if !status && !isRequestError {
                    isRequestError = status
                    message = msg
                }
                group.leave()
            })
        }
        /// 全部请求完成
        group.notify(queue: DispatchQueue.main) {
            let status: Bool = !isRequestError
            let msg: String? = isRequestError ? message : "标签设置完成"
            complete(msg, status)
        }
    }

}
