//
//  TSPayNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPayNetworkManager: NSObject {

    /// 支付节点付费
    class func pay(node: Int, complete: @escaping (Bool, String?) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Wallet.purchases.rawValue + "/\(node)"
        var parameter: [String: Any] = [:]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parameter.updateValue(inputCode, forKey: "password")
                 TSUtil.share().inputCode = nil
            }
        }
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameter, complete: { (data: NetworkResponse?, status: Bool) in
            var message: String?
            if status {
                // 支付成功
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: data)
            } else {
                // 支付失败
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(status, message)
        })
    }
}
