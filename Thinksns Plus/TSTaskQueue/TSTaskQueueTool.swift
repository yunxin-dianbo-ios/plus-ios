//
//  TSTaskQueueTool.swift
//  Thinksns Plus
//
//  Created by lip on 2017/3/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  任务队列公用工具

import UIKit
import RealmSwift

class TSDataQueueTool: NSObject {
    /// 拼接url
    ///
    /// - Parameters:
    ///   - currentUrl: 当前请求链接
    ///   - stitchFirstString: 第一段需要拼接的字段
    ///   - stitchSecondString: 第二段需要拼接的字段（没有第二段就传nil或者空字符串）
    /// - Returns: 返回拼接好的字段
    class func handleCharacterStitching(currentUrl: String, stitchFirstId: Int) -> String {
        let str = currentUrl + "/" + "\(stitchFirstId)"
        return str
    }
}

class TSTaskQueueTool {

    /// 获取用户信息并且存储
    ///
    /// 任务队列中,所有使用到新的用户信息的地方,统一从服务器获取并且写入数据库,完成更新逻辑.只有在显示旧数据时,旧数据的显示处决定是否加载旧数据.
    /// (例如: 在显示动态时,如果该动态是新的不是本地的,那么就从服务器同时获取并且更新用户信息,再写入数据库.如果该动态是本地的旧数据,那么额外处理)
    ///
    /// - Parameters:
    ///   - userIdentities: 用户标识数组
    ///   - complete: 结果,返回的用户信息会依据传入的用户信息组装成字典返回
    class func getAndSave(userInfo userIdentities: [Int], complete: @escaping ((_ responseInfo: Any?, _ userInfoObjectDic: [Int: TSUserInfoObject]?, _ error: NSError?) -> Void)) {
        assert(!userIdentities.isEmpty)
        TSUserNetworkingManager().getUserInfo(userIdentities) { (responseInfo, userinfoModels, error) in
            if error != nil {
                complete(nil, nil, error)
                return
            }
            if responseInfo == nil {
                assert(false, "服务器返回数据错误")
            }
            guard let userinfoModels = userinfoModels else {
                print("用户数据为空")
                return
            }
            if userinfoModels.isEmpty {
                print("用户数据为空")
                return
            }
            let datas = TSTaskQueueTool.save(userInfoModels: userinfoModels)
            complete(responseInfo, datas, nil)
        }
    }
    /// 重载getAndSave
    class func getAndSave(userIds: [Int], userNames: [String] = [], complete: @escaping ((_ userList: [TSUserInfoModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSUserNetworkingManager().getUsersInfo(usersId: userIds, userNames: userNames) { (userList, msg, status) in
            guard status, let userList = userList else {
                complete(nil, msg, status)
                return
            }
            // 数据库保存请求的用户信息
            TSDatabaseManager().user.saveUsersInfo(userList)
            // 回调
            complete(userList, msg, status)
        }
    }
    // MAKR: - Private
    /// 处理用户信息
    private class func save(userInfoModels datas: [TSUserInfoModel]) -> [Int: TSUserInfoObject] {
        var userInfoObjectDic: [Int: TSUserInfoObject] = [:]
        var userInfoObjectArray: [TSUserInfoObject] = []
        for data in datas {
            let userInfoObject = data.object()
            userInfoObjectArray.append(userInfoObject)
            userInfoObjectDic.updateValue(userInfoObject, forKey: userInfoObject.userIdentity)
        }
        // 储存用户信息
        TSDatabaseManager().user.save(usersInfo: userInfoObjectArray)
        return userInfoObjectDic
    }

}
