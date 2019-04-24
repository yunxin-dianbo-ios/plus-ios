//
//  TSMessageRequestCreate.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDataRequestCreate: NSObject, TSDataRequestProtocol {

    static let share = TSDataRequestCreate()
    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - complete: 完成后返回的参数
    internal func dataRequestWithGetUserInformation(userId: String, complete: @escaping (String?, Any?, NSError?) -> Void) {

        let path = TSDataQueueTool.handleCharacterStitching(currentUrl: TSURLPath.UserInfo.user.rawValue, stitchFirstString: userId, stitchSecondString: nil)

        TSNetwork.sharedInstance.textRequest(method: .get, path: path, parameter: nil) { (responseMessage, responseData, error) in
            complete(responseMessage, responseData, error)
        }
    }
}
