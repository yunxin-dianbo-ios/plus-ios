//
//  TSDataQueueHandleProtocol.swift
//  Thinksns Plus
//
//  Created by 法正磊 on 2017/2/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation

protocol TSDataQueueHandleProtocol {

    func userInformationRequestHandle(userId: String, maxRequestCount: Int, complete: @escaping (String?, Any?, NSError?) -> Void)

    /// 获取用户信息的请求
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - maxRequestCount: 最大重复请求次数
    ///   - complete: 完成后回传的数据
    func userInformationRequestHandle(userIds: Array<Int>, maxRequestCount: Int, isMust: Bool, complete: @escaping (Any?, NSError?) -> Void)

    /// 获取用户关系列表
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - maxId: 分页查询Id
    ///   - maxRequestCount: 最大重复请求次数
    ///   - complete: 回传的数据
    func relationListDataRequestHandle(userId: String, maxId: String?, relationType: TSUserRelationType, maxRequestCount: Int, complete: @escaping (String?, Any?, NSError?) -> Void)

}
