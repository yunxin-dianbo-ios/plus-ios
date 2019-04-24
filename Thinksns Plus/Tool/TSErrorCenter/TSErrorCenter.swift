//
//  TSErrorCenter.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/20.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  错误码中心
//

import UIKit
public let errorNetworkInfo = "网络请求错误"

enum TSErrorCode: Int {
    /// 空的参数
    case emptyParameter = 0
    /// 未正常初始化
    case Uninitialized = 1
    /// 网络错误
    ///
    /// - Note: 数据格式错误,类型错误等底层错误
    case networkError = 999
    /// 失去了网络连接
    case lostNetWork = 10_000
    /// 不被识别的数据
    case unrecognizedData = 10_001
    /// 非法请求
    case illegalRequest = 10_002
    /// 登录超时
    case overTime = 20_000
    /// 发送消息,响应超时
    case imResponseOverTime = 20_001
    /// 聊天核心失去了服务器链接
    case imLostNetWork = 20_002
}

class TSErrorCenter: NSObject {

    class func create(With errorCode: TSErrorCode) -> (NSError) {
        switch errorCode {
            case .emptyParameter:
                return NSError(domain: "TSNormalErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "空的参数"])
            case .Uninitialized:
                return NSError(domain: "TSNormalErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "未正常初始化"])
            case .networkError:
                return NSError(domain: "TSNormalErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "网络错误"])
            case .lostNetWork:
                return NSError(domain: "TSNetworkErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "失去了网络连接"])
            case .unrecognizedData:
                return NSError(domain: "TSNetworkErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "不被识别的数据"])
            case .illegalRequest:
                return NSError(domain: "TSNetworkErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "非法请求"])
            case .overTime:
                return NSError(domain: "TSIMErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "登录超时"])
            case .imResponseOverTime:
                return NSError(domain: "TSIMErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "消息发送响应超时"])
            case .imLostNetWork:
                return NSError(domain: "TSIMErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription": "聊天核心失去了服务器链接"])
        }
    }
}
