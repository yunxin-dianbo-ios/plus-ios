//
//  TSQuoraHelper.swift
//  ThinkSNS +
//
//  Created by 小唐 on 29/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答小助手

import Foundation
import UIKit

class TSQuoraHelper {
    /// 处理答案围观 
    class func processAnswerOutlook(answerId: Int, payComplete: ((_ payResult: Bool, _ answer: TSAnswerDetailModel?) -> Void)?, cancel: (() -> Void)?) -> Void {
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 围观弹窗支付
        let price = TSAppConfig.share.localInfo.quoraOutLookAmount
        let payAlert = TSIndicatorPayAnswerOutlook(price: Double(price))
        payAlert.show(answerId: answerId, success: { (answer) in
            payComplete?(true, answer)
        }, failure: {
            // 进入钱包页
            let vc = IntegrationHomeController.vc()
            if let currentTC = TSRootViewController.share.currentShowViewcontroller as? TSHomeTabBarController {
                currentTC.selectedViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            payComplete?(false, nil)
        }, cancel: {
            if let cancel = cancel {
                cancel()
            }

        })
    }

}
