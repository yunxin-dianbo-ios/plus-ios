//
//  FindFriendTaskQueue.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  找人的任务队列

import UIKit

class FindFriendTaskQueue: NSObject {

    /// 获取找人列表
    ///
    ///
    func getNewFriends(type: TSNewFriendsVC.UserType, latitude: String?, longitude: String?, offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        if type == .hot {
            // 1.如果是热门
            TSNewFriendsNetworkManager.getHotUsers(offset: offset, complete: complete)
        } else if type == .new {
            // 2.如果是最新
            TSNewFriendsNetworkManager.getNewUsers(offset: offset, complete: complete)
        } else if type == .recommend {
            // 3.如果是推荐
            self.getRecommedUsers(offset: offset, complete: complete)
        } else if type == .nearby {
            // 4.如果是附近
            let page = offset / limit + 1
            TSNewFriendsNetworkManager.getNearbyUsers(latitude: latitude, longitude: longitude, page: page, limit: limit, complete: complete)
        }
    }

    /// 当前已经获取到的后台推荐的人的总数
    var serverRecommedUsersCount = 0

    /// 获取推荐用户
    func getRecommedUsers(offset: Int, complete aComplete: @escaping([TSUserInfoModel]?, String?, Bool) -> Void) {
        /*
         这里的推荐用户包含两种类型：后台推荐用户和标签推荐用户。

         逻辑如下：
         a.下拉刷新时，加载一页标签推荐用户，加载所有的后台推荐用户。
         b.上拉加载更多时，加载标签推荐用户
         */
        // 1.如果 offset 为 0，就认为是在下拉刷新
        let isRefresh = offset == 0
        // 如果是下拉刷新，清空后台推荐人数的记录
        if isRefresh {
            serverRecommedUsersCount = 0
        }

        // 2.创建一个组
        let group = DispatchGroup()
        var allUsers: [String: [TSUserInfoModel]?] = [:] // 用户数据容器
        var allMessage: [String: String?] = [:] // 错误信息容器
        var allStatus: [Bool] = [] // 网络请求返回状态容器

        // 3.请求标签推荐用户
        group.enter()
        // 标签推荐用户的真实偏移量，应该是请求偏移量减去后台推荐用户的总个数
        let tagUserOffset = offset - serverRecommedUsersCount
        TSNewFriendsNetworkManager.getTagRecommendsUsers(offset: tagUserOffset) { (models: [TSUserInfoModel]?, message: String?, status: Bool) in
            allUsers.updateValue(models, forKey: "tag")
            allMessage.updateValue(message, forKey: "tag")
            allStatus.append(status)
            group.leave()
        }

        // 4.如果是下拉刷新，需要同时请求后台推荐用户
        if isRefresh {
            group.enter()
            TSNewFriendsNetworkManager.getRecommendsUsers(complete: { [weak self] (models: [TSUserInfoModel]?, message: String?, status: Bool) in
                allUsers.updateValue(models, forKey: "server")
                allMessage.updateValue(message, forKey: "server")
                allStatus.append(status)
                // 后台推荐用户请求成功，保存一下后台推荐用户的总人数
                if let models = models {
                    self?.serverRecommedUsersCount = models.count
                }
                group.leave()
            })
        }

        // 5.在所有网络请求完成后台，处理网络请求返回数据
        group.notify(queue: DispatchQueue.main) {
            // 5.1 遍历网络返回状态，检查是否所有请求都获取成功
            var isRequestSuccess = true
            for status in allStatus {
                if !status {
                    isRequestSuccess = false
                }
            }
            if isRequestSuccess {
                // 5.2 如果所有数据获取成功，取出数据
                var users: [TSUserInfoModel] = []
                if let serverUsers = allUsers["server"] {
                    users += serverUsers ?? []
                }
                if let tagUsers = allUsers["tag"] {
                    users += tagUsers ?? []
                }
                aComplete(users, nil, true)
            } else {
                // 5.3 如果数据获取失败，取出错误信息
                var message = "未知原因"
                if let tagMessage = allMessage["tag"] {
                    message = tagMessage ?? message
                }
                if let serverMessage = allMessage["server"] {
                    message = serverMessage ?? message
                }
                aComplete(nil, message, false)
            }
        }
    }

}
