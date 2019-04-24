//
//  TSMessageRequestProtocol.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation

protocol TSDataRequestProtocol {

    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - complete: 完成后返回的参数
   func dataRequestWithGetUserInformation(userId: String, complete: @escaping (_ responseMessage: String?, _ responseData: Any?, _ error: NSError?) -> Void)

}
