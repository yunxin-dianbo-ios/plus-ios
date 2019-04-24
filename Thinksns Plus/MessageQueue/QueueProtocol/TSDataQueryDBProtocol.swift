//
//  TSMessageFindDBProtocol.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation

protocol TSDataQueryDBProtocol {

    /// 查询用户信息系
    ///
    /// - Parameter userId: 用户ID
    /// - Returns: 返回用户数据
    func queryDBDataWithUserInformation(userIds: Array<Int>, complete: @escaping (_ results: Array<TSUserInfoObject>?) -> Void)

    /// 获取粉丝/关注列表
    ///
    /// - Parameters:
    ///   - relationType: 列表类型
    ///   - userId: 用户Id
    ///   - complete: 完成后
    func queryDBDataWithUserRelationList(relationType: TSUserRelationType, userId: String, complete: @escaping (_ results: TSUserRelationObject?) -> Void)

}
