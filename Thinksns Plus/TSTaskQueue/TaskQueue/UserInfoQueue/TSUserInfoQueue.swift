//
//  TSUserInfoQueue.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 用户队列

import UIKit

class TSUserInfoQueue: NSObject {
    enum UpLoadImageType: String {
        case header = "storage_task_id"
        case background = "cover_storage_task_id"
    }

    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - isFirst: 是否需要先获取数据库信息
    ///   - isMust: 是否是需要重复请求或保存任务（true表示为不重复请求并且不保存任务）
    ///   - complete: 返回用户信息
    /// - Note: 调用该方法后,便会更新用户信息,如果传入参数
    @available(*, deprecated, message: "该接口已被逐渐弃用")
    func getData(userIds: Array<Int>, isQueryDB: Bool, isMust: Bool, complete: @escaping (Array<TSUserInfoObject>?, NSError?) -> Void) {

        if isQueryDB { // 该逻辑可以考虑删除,需要用户信息时,直接从数据库自己获取,数据库信息刷新后,通过realm通知回调即可
            let results = TSDatabaseManager().user.get(infoFrom: userIds)
            if !results.isEmpty {
                // 第一次更新界面
                complete(results, nil)
            }
        }

        TSUserInfoQueueHandle().request(userIds: userIds, maxRequestCount: 3, isMust: isMust) { (userInfoObjectDic, error) in
            if error != nil {
                complete(nil, error)
                return
            }

            var userInfoObjects = [TSUserInfoObject]()
            for index in 0..<userIds.count {
                let userId = userIds[index]
                let userInfoObject = userInfoObjectDic![userId]
                assert(userInfoObject != nil, "查询到的用户信息数据错误!")
                userInfoObjects.append(userInfoObject!)
            }
            complete(userInfoObjects, nil)
        }
    }

}

// MARK: - New API

extension TSUserInfoQueue {

    /// 获取当前用户信息
    ///
    /// - Parameters:
    ///   - isQueryDB: 是否需要先获取数据库信息
    ///   - complete: 返回用户信息
    /// - Note: 调用该方法后,便会更新用户信息,如果传入参数
    func getCurrentUserInfo(isQueryDB: Bool, complete: @escaping ((_ userInfo: TSCurrentUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 该逻辑可以考虑删除,需要用户信息时,直接从数据库自己获取,数据库信息刷新后,通过realm通知回调即可
        if isQueryDB {
            if let result = TSDatabaseManager().user.getCurrentUser() {
                complete(result, nil, true)
            }
        }
        // 网络请求
        TSUserNetworkingManager().getCurrentUserInfo { (userModel, msg, status) in
            if status, let userModel = userModel {
                // 储存用户信息
                TSDatabaseManager().user.saveCurrentUser(userModel)
            }
            complete(userModel, msg, status)
        }
    }

    /// 获取指定用户信息
    func getUserInfo(userId: Int, isQueryDB: Bool, complete: @escaping ((_ userInfo: TSUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        if isQueryDB {
            if let result = TSDatabaseManager().user.getUserInfo(userId: userId) {
                complete(result, "", true)
            }
        }
        // 网络请求
        TSUserNetworkingManager().getUserInfo(userId: userId) { (userModel, msg, status) in
            if status, let userModel = userModel {
                // 储存用户信息
                TSDatabaseManager().user.saveUserInfo(userModel)
            }
            complete(userModel, msg, status)
        }
    }

    /// 获取指定的用户列表的信息
    func getUsersInfo(usersId: [Int], isQueryDB: Bool, complete: @escaping ((_ usersInfo: [TSUserInfoModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        if isQueryDB {
            let result = TSDatabaseManager().user.getUsersInfo(usersId: usersId)
            complete(result, "", true)
        }
        // 网络请求
        TSUserNetworkingManager().getUsersInfo(usersId: usersId) { (modelList, msg, status) in
            if status, let modelList = modelList {
                // 储存用户信息
                TSDatabaseManager().user.saveUsersInfo(modelList)
            }
            complete(modelList, msg, status)
        }
    }

}

// MARK: - 修改用户信息

extension TSUserInfoQueue {
    func updateUserBaseInfo(name: String, sex: String, bio: String, location: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        // 请求修改当前用户信息
        TSUserNetworkingManager().updateUserBaseInfo(name: name, sex: sex, bio: bio, location: location, complete: complete)
    }
}
