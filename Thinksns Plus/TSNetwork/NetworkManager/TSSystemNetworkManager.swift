//
//  TSSystemNetworkManager.swift
//  ThinkSNS +
//
//  Created by lip on 2017/5/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  处理系统相关的网络请求

import UIKit
import ObjectMapper

class TSSystemNetworkManager: NSObject {
    /// 获取服务器响应的启动信息
    ///
    /// - Parameter complete:
    ///   - info: 响应的数据,无数据时返回 nil
    ///   - result: 是否响应正常的数据
    class func getLaunchInfo(_ complete: @escaping (_ info: Dictionary<String, Any>?, _ result: Bool) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.System.bootstrappers.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil) { (response, result) in
            guard result == true else {
                return
            }
            var responseData = response as? Dictionary<String, Any>
            TSSystemNetworkManager.getQuestionConfig(complete: { (rule) in
                responseData!["question:anonymity_rule"] = rule
                complete(responseData, result)
            })
        }
    }

    /// 获取问答的配置信息
    class func getQuestionConfig(complete: @escaping(_ rule: String) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Question.configs.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil) { (response, result) in
            guard result == true else {
                return
            }
            let responseData = response as? Dictionary<String, Any>
            complete(responseData!["anonymity_rule"] as! String)
        }
    }

    /// 获取版本数组
    class func getVersionData(complete: @escaping(_ versionData: [AppVersionCheckModel]?, _ result: Bool) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.AppVersion.appVersion.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (response, result) in
            if result, let datas = response as? [[String: Any]] {
                // 数据解析
                let model = Mapper<AppVersionCheckModel>().mapArray(JSONArray: datas)
                complete(model, true)
                return
            } else {
                complete(nil, false)
            }
        })
    }
}
