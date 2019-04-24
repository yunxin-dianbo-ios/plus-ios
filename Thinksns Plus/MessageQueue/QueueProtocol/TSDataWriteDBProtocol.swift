//
//  TSMessageWriteDBData.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation

protocol TSDataWriteDBProtocol {

    /// 写入用户信息数据
    ///
    /// - Parameters:
    ///   - responseData: 网络获取的数据
    ///   - userId: 用户Id
    ///   - complete: 返回用户信息模型
    func writeDataWithUserInformation(responseData: Any, userIds: Array<Int>, complete: @escaping (TSUserInfoObject) -> Void)

}
