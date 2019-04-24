//
//  TSCommonNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  网络请求通用部分

import Foundation
import AiLiToolbox

class TSCommonNetworkManager {

    /// 网络请求失败时，根据data获取错误信息
    class func getNetworkErrorMessage(with data: Any?) -> String {
        var message: String = "网络请求失败"
        if let dataDic = data as? [String : [String]] {
            // 这里的错误信息，既可能是message字段，也可能是出错的字段
            message = dataDic.values.first?.first ?? "服务器返回数据格式错误"
        } else if let networkError = data as? NetworkError {
            if networkError == NetworkError.networkErrorFailing {
                message = "网络错误，请稍后再试。"
            }
            if networkError == NetworkError.networkTimedOut {
                message = "网络请求超时，请稍后再试。"
            }
        }
        return message
    }
}
