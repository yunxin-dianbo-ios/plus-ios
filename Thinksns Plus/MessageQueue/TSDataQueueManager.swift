//
//  TSMessageQueueManager.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDataQueueManager: NSObject {
    static let share = TSDataQueueManager()
    private override init() {
        super.init()
    }

    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - isFirst: 是否需要先获取数据库信息
    ///   - isMust: 是否是必须的
    ///   - complete: 返回用户信息
    func userInformationRequest(userIds: Array<Int>, isQueryDB: Bool, isMust: Bool, complete: @escaping (Array<TSUserInfoObject>?, NSError?) -> Void) {

        if isQueryDB {
            TSDataQueryDB().queryDBDataWithUserInformation(userIds: userIds) { (results) in
                if let result = results {
                    // 第一次更新界面
                    complete(result, nil)
                }
            }
        }

        TSDataQueueHandle().userInformationRequestHandle(userIds: userIds, maxRequestCount:20, isMust: isMust) { (responseData, error) in

            switch error {
            case nil:
                var userDatas: [TSUserInfoObject] = Array()
                TSDataWriteDB().writeDataWithUserInformation(responseData: responseData!, userIds: userIds, complete: { (object) in
                    userDatas.append(object)
                })
            default:
                if isMust {
                    complete(nil, error)
                }
            }
        }
    }

    /// 获取用户粉丝关注列表
    ///
    /// - Parameters:
    ///   - relationType: 关注类型
    ///   - userId: 用户id
    ///   - max_id: 上页最大ID
    ///   - isQueryDB: 是否需要展示数据库的数据
    func getRelationListData(relationType: TSUserRelationType, userId: String, max_id: String?, isQueryDB: Bool) {
        // 查询数据库成功
        var relationList: Array<Any> = Array()

        if isQueryDB {
            TSDataQueryDB().queryDBDataWithUserRelationList(relationType: relationType, userId: userId, complete: { (relationObject) in
                if let result = relationObject {

                }
            })
        }
        // 网络请求
        TSDataQueueHandle().relationListDataRequestHandle(userId: userId, maxId: max_id, relationType: relationType, maxRequestCount: 20) { (_, _, _) in

        }
    }

}
