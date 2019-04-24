//
//  TSLocationsSearchNetworkManager.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

import ObjectMapper

class TSLocationsSearchNetworkManager: NSObject {
    /// 获取地区搜索结果
    ///
    /// - Parameters:
    ///   - searchStr: 关键字
    ///   - compelet: 搜索结果: 地区名称组,例如 ["中国,四川,成都,高新区"]
    func getLocationsSearchResult(searchStr: String, compelet: @escaping (_ array: Array<String>) -> Void) {
        let requestMethod = TSAreaSearchRequest().searchList
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: ["name": searchStr], complete: { (networkResponse, _) in
            guard let networkResponse = networkResponse else {
                compelet([String]())
                return
            }
            guard let result = Mapper<TSSAreaSearchModel>().mapArray(JSONObject: networkResponse) else {
                assert(false, "服务器响应了不能解析的数据")
                compelet([String]())
                return
            }
            var array: Array<String> = []
            for model in result {
                array += model.conversionData()
            }
            compelet(array)
        })
    }

    /// 获取热门城市
    ///
    /// - Parameter compelet:["中国 四川 成都",]
    func getPopularCity(compelet: @escaping ((_ array: Array<String>, _ status: Bool) -> Void)) {
        let requestMethod = TSAreaSearchRequest().searchPopularCity
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (response, status) in
            var result: Array<String> = []
            if status {
                result = (response as? Array<String>)!
                compelet(result, true)
            } else {
                compelet(result, false)
            }
        })
    }
}
