//
//  TSIndicatorPayAnswerOutlook.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案围观支付

import Foundation
import UIKit

class TSIndicatorPayAnswerOutlook: TSIndicatorPayBasicView {

    /// 显示付费弹窗
    func show(answerId: Int, success: ((_ answer: TSAnswerDetailModel?) -> Void)?, failure: (() -> Void)? = nil, cancel: (() -> Void)?) {
        // 1.设置按钮点击事件
        setActionForBuyButton {
            // 未登录处理
            if !TSCurrentUserInfo.share.isLogin {
                TSRootViewController.share.guestJoinLoginVC()
                self.dissmiss()
                return
            }
            let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_支付中".localized)
            loadingAlert.show()
            self.buttonForBuy.isEnabled = false
            // 1.1 围观支付请求
            TSQuoraNetworkManager.answerOutlook(answerId: answerId, complete: { (message, status) in
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
                    // 重新请求答案详情
                    TSQuoraNetworkManager.getAnswerDetail(answerId, complete: { (answer, msg, status, code) in
                        var title = "提示信息_支付成功".localized
                        if status, let answer = answer {
                            // 显示结果
                            let finalAlert = TSIndicatorWindowTop(state: .success, title: title)
                            finalAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                                success?(answer)
                            })
                        } else {
                            title += ", 但答案详情请求失败，请刷新"
                            // 显示结果
                            let finalAlert = TSIndicatorWindowTop(state: .success, title: title)
                            finalAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                                success?(nil)
                            })
                        }
                    })
                } else {
                    // 失败
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_支付失败".localized, message ?? ""))
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        failure?()
                    })
                }
            })
        }
        setActionForBackButton {
            self.dissmiss()
            if let cancel = cancel {
                cancel()
            }
        }
        // 2.设置显示内容
        let titleString = "支付弹窗_围观_标题".localized
        let priceString = String(Int(price))
        let descriptionContent =  "支付弹窗_围观_描述开头".localized + priceString + TSAppConfig.share.localInfo.goldName + "支付弹窗_围观_描述结尾".localized
        labelForTitle.text = titleString
        setPrice(content: priceString)
        setDescription(content: descriptionContent, linkWord: nil)
        // 更新子视图布局
        updateChildViewLayout()
        // 调用父类方法
        super.show()
    }

}
