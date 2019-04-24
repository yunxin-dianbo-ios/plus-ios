//
//  TSMessageFindDB.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDataQueryDB: NSObject, TSDataQueryDBProtocol {

    /// 查询用户信息系
    ///
    /// - Parameter userId: 用户ID
    /// - Returns: 返回用户数据
    internal func queryDBDataWithUserInformation(userIds: Array<Int>, complete: @escaping (Array<TSUserInfoObject>?) -> Void) {

        var userInfos: Array<TSUserInfoObject> = Array()
        for item in userIds {
            let userInfo = TSDataBaseManager.share.user.getUserInfoObject(item)

            guard let info = userInfo else {
                continue
            }
            userInfos.append(info)
        }
        complete(userInfos)
    }

    /// 获取粉丝/关注列表
    ///
    /// - Parameters:
    ///   - relationType: 列表类型
    ///   - userId: 用户ID
    ///   - complete: 完成后返回的数据
    internal func queryDBDataWithUserRelationList(relationType: TSUserRelationType, userId: String, complete: @escaping (TSUserRelationObject?) -> Void) {
        let userRelation = TSDataBaseManager.share.user.getUserFansAndFollowList(Int(userId)!, Of: relationType)

        if let relation = userRelation {
            for item in relation {
                complete(item)
            }
        } else {
            complete(nil)
        }
    }
}
