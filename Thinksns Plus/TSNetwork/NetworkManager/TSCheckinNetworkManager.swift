//
//  TSCheckinNetworkManager.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

class TSCheckinNetworkManager: NSObject {

    /// 获取签到信息
    ///
    /// - Parameter compelet: (model，是否成功)
    func getCheckinInformation(compelet: @escaping (_ model: TSCheckinModel?, _ status: Bool) -> Void) -> Void {
        let requestMethod = TSCheckinRequest().getCheckinList
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (response, status) in
            guard status else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                compelet(nil, false)
                return
            }
            let result = Mapper<TSCheckinModel>().map(JSONObject: response)
            compelet(result, true)
        })
    }

    /// 提交签到信息方法
    ///
    /// - Parameter compelet: (msg?, 是否成功)
    ///    - msg: zz
    func putCheckin(compelet: @escaping (_ msg: String?, _ status: Bool) -> Void) -> Void {
        let requestMethod = TSCheckinRequest().checking
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (response, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                compelet(message, false)
                return
            }
            compelet(nil, true)
        })
    }
}
