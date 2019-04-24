//
//  TSCommonNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 01/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  网络请求通用部分

import Foundation

/// 排序类型：升序还是降序
enum TSOrderType: String {
    /// ascending 升序
    case ascending = "asc"
    /// descending 降序
    case descending = "desc"
}

/// 关注操作
/// 目前可关注的对象：用户、问答话题...
enum TSFollowOperate {
    /// 关注
    case follow
    /// 取消关注
    case unfollow
}

/// 列表数据加载操作/加载方式
typealias TSListDataLoadOperate = TSListDataLoadType
enum TSListDataLoadType: Int {
    /// 初始化
    case initial = 0
    /// 下拉刷新
    case refresh
    /// 上拉加载更多
    case loadmore
    /// 重新加载——等同于初始化
    //    case reload
}

/// 列表数据加载的协议
protocol TSListDataLoadProtocol: class {
    func requestData(_ type: TSListDataLoadType) -> Void
}

/// 带参数的方法，子类的扩展中不能重写，故采用协议来实现。。。
extension TSListDataLoadProtocol {
//    func initialDataSource() -> Void {
////        self.requestData(.initial)
//    }
//    func loadMore() -> Void {
////        self.requestData(.loadmore)
//    }
//    func refresh() -> Void {
////        self.requestData(.refresh)
//    }
}

class TSCommonNetworkManager {

    /// 网络请求失败时，根据data获取错误信息
    ///
    /// - Note: 该方法用于兼容旧的网络请求数据解析,逐渐在废弃中
    class func getNetworkErrorMessage(with data: Any?) -> String? {
        // 新的处理方案，具体请参考RequestNetworkData.swift
        var message: String? = nil
        let serverResponseInfoKey: String = "message"

        if let responseInfo = data as? String {
            // json -> "message info"
            message = responseInfo
        } else if let responseInfoDic = data as? Dictionary<String, Array<String>>, let messages = responseInfoDic[serverResponseInfoKey] {
            // json -> ["message": ["value1", "value2"...]]
            message = messages.first
        } else if let responseInfoDic = data as? Dictionary<String, String> {
            // josn -> ["message": "value"]
            message = responseInfoDic[serverResponseInfoKey]
        } else if let responseInfoDic = data as? Dictionary<String, Dictionary<String, Any>>, let messageDic = responseInfoDic[serverResponseInfoKey] {
            // json -> ["message": ["key1": "value1", "key2": "value2"...]]
            message = messageDic.first?.value as! String?
        } else if let responseInfoDic = data as? [String: Any] {
            if let errorInfo = responseInfoDic["errors"] as? Dictionary<String, Array<String>> {
                // json -> ["message":"value", "errors":["key1":"value1", "key2":"value2"]]
                message = errorInfo.first?.value.first
            } else if let responseInfo = responseInfoDic as? Dictionary<String, Array<String>> {
                // json -> ["key":["value"], "key2":["value1", "value2"]]
                message = responseInfo.first?.value.first
            } else if let responseInfo = responseInfoDic[serverResponseInfoKey] as? String {
                // json -> ["message": "value", other...]
                message = responseInfo
            }
        } else if let networkError = data as? NetworkError {
            if networkError == NetworkError.networkErrorFailing {
                message = "网络错误，请稍后再试。"
            }
            if networkError == NetworkError.networkTimedOut {
                message = "网络请求超时，请稍后再试。"
            }
        }
        // 关于解析失败，或者没有原因时，是否添加下面默认语句，待确定
//        if message == nil {
//            message = "网络请求失败"
//        }
        return message
    }

    /// 网络请求成功时，根据data获取提示信息
    class func getNetworkSuccessMessage(with data: Any?) -> String? {
        // 一般都是message字段
        var message: String?
        let serverResponseInfoKey: String = "message"
        if let responseInfo = data as? String {
            message = responseInfo
        } else if let responseInfoDic = data as? [String: Any] {
            if let serverMsg = responseInfoDic[serverResponseInfoKey] as? String {
                message = serverMsg
            } else if let msgList = responseInfoDic[serverResponseInfoKey] as? [String] {
                message = msgList.first
            }
        }
        return message
    }

}
