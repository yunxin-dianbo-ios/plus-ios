//
//  TSPayTaskQueue.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPayTaskQueue: NSObject {

    class func showImagePayAlertWith(imageObject object: TSImageObject, compelet finish: @escaping (Bool, String?) -> Void) {
        guard let type = object.type, let price = object.amount.value, let node = object.node.value else {
            return
        }
        // 判断是查看付费还是下载付费 决定了弹窗显示的提示文字
        let isRead = type == "read"

        let alert = TSIndicatorPayPicture(price: Double(price))
        alert.buyError = {
            finish(false, nil)
        }
        alert.setActionForBuyButton {
            let indicator = TSIndicatorWindowTop(state: .loading, title: "正在支付")
            alert.buttonForBuy.isEnabled = true
            indicator.show()
            TSPayNetworkManager.pay(node: node, complete: { (isSuccess: Bool, message: String?) in
                indicator.dismiss()
                alert.buttonForBuy.isEnabled = true
                if isSuccess {
                    TSDatabaseManager().moment.change(paidImage: object)

                    let imageUrl = object.storageIdentity.imageUrl()
                    NotificationCenter.default.post(name: NSNotification.Name.PaidImage.buyPic, object: nil, userInfo: ["url": imageUrl])
                    object.set(shouldChangeCache: true)
                    alert.dissmiss()
                    finish(isSuccess, message)
                }
                if let message = message {
                    if TSAppConfig.share.localInfo.shouldShowPayAlert && isSuccess == false {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message])
                    } else {
                        let resultIndicator = TSIndicatorWindowTop(state: isSuccess ? .success : .faild, title: message)
                        resultIndicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    }
                }
                if TSAppConfig.share.localInfo.shouldShowPayAlert && isSuccess {
                    TSUtil.dismissPwdVC()
                }
            })
        }
        alert.show(isRead: isRead)
    }
}
