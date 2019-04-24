//
//  TSIndicatorPayQuoraApplication.swift
//  ThinkSNS +
//
//  Created by 小唐 on 31/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答精选支付

import UIKit

class TSIndicatorPayQuoraApplication: TSIndicatorPayBasicView {

    /// 显示付费弹窗
    func show(quoraId: Int, success: (() -> Void)?, failure: (() -> Void)? = nil) -> Void {
        // 1.设置按钮点击事件
        setActionForBuyButton {
            // 未登录处理
            if !TSCurrentUserInfo.share.isLogin {
                TSRootViewController.share.guestJoinLoginVC()
                self.dissmiss()
                return
            }
            let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_申请中".localized)
            loadingAlert.show()
            self.buttonForBuy.isEnabled = false
            // 1.1 申请问答精选
            TSQuoraNetworkManager.applyQuoraApplication(quoraId, complete: { (message, status) in
                loadingAlert.dismiss()
                self.dissmiss()
                /// 支付需要密码弹窗
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    if status {
                        TSUtil.dismissPwdVC()
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                        return
                    }
                }
                // 结果处理
                if status {
                    // 显示结果
                    let finalAlert = TSIndicatorWindowTop(state: .success, title: "提示信息_申请请求成功".localized)
                    finalAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        success?()
                    })
                } else {
                    // 申请精选失败
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        failure?()

                    })
                }
            })
        }
        // 2.设置显示内容
        let titleString = "支付弹窗_问答精选_标题".localized
        let priceString = String(Int(price))
        let descriptionContent =  "支付弹窗_问答精选_支付描述_金额前".localized + priceString + TSAppConfig.share.localInfo.goldName + "支付弹窗_问答精选_支付描述_金额后".localized
        labelForTitle.text = titleString
        setPrice(content: priceString)
        setDescription(content: descriptionContent, linkWord: nil)
        // 更新子视图布局
        updateChildViewLayout()
        // 调用父类方法
        super.show()
    }

}
