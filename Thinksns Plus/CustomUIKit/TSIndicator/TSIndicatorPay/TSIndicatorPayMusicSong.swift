//
//  TSIndicatorPayMusicSong.swift
//  ThinkSNS +
//
//  Created by 小唐 on 03/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  歌曲付费弹窗

import Foundation
import UIKit

class TSIndicatorPayMusicSong: TSIndicatorPayBasicView {
    /// 显示付费弹窗
    func show(song: TSSongModel, success: (() -> Void)?, failure: (() -> Void)? = nil) -> Void {
        guard let storage = song.storage else {
            return
        }
        // 1.设置按钮点击事件
        setActionForBuyButton {
            // 未登录处理
            if !TSCurrentUserInfo.share.isLogin {
                TSRootViewController.share.guestJoinLoginVC()
                self.dissmiss()
                return
            }
            let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "交易中")
            loadingAlert.show()
            self.buttonForBuy.isEnabled = false
            // 1.1 购买付费节点内容
            TSPayNetworkManager.pay(node: storage.paidNode!, complete: { (isSuccess: Bool, message: String?) in
                loadingAlert.dismiss()
                // 结果处理
                if isSuccess {
                    // 修改当前模型
                    song.storage?.paid = true
                    // 更新数据库
                    TSDatabaseManager().music.updateSong(song)
                    // 显示结果
                    let finalAlert = TSIndicatorWindowTop(state: .success, title: "购买成功")
                    finalAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        // 成功回调
                        self.dissmiss()
                        success?()
                        TSUtil.dismissPwdVC()
                    })
                } else {
                    // 购买失败
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        failure?()
                        self.dissmiss()
                    })
                }
            })
        }
        // 2.设置显示内容
        let titleString = "支付弹窗_标题".localized
        let priceNumber = Int(price)
        let descriptionContent = "支付弹窗_歌曲收费描述".localized + "支付弹窗_描述开头".localized + String(priceNumber) + TSAppConfig.share.localInfo.goldName + "支付弹窗_歌曲付费收听描述".localized
        labelForTitle.text = titleString
        setPrice(content: String(priceNumber))
        setDescription(content: descriptionContent, linkWord: nil)
        // 更新子视图布局
        updateChildViewLayout()
        // 调用父类方法
        super.show()
    }

}
