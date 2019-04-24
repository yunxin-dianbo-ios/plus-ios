//
//  TSIndicatorPayNewsContributeView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 17/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯投稿时的支付视图
/**
 注：该页面只是显示，实际上不需要支付操作，由服务器进行统一支付处理
 */

import UIKit

class TSIndicatorPayNewsContributeView: TSIndicatorPayBasicView {
    /// 显示付费弹窗
    func show(payAction: (() -> Void)?) -> Void {
        // 1.设置按钮点击事件
        setActionForBuyButton {
//            // 未登录处理
//            if !TSCurrentUserInfo.share.isLogin {
//                TSRootViewController.share.guestJoinLoginVC()
//                return
//            }
            self.dissmiss()
            payAction?()
        }

        // 2.设置显示内容
        let titleString = "支付弹窗_标题_投稿".localized
//        let goldNumber = TSWalletConfigModel.getGold(fromFen: Int(price))
        let priceString = "\(Int(price))"
//            goldNumber.tostring()
        let descriptionContent = "支付弹窗_投稿_支付描述".localized + priceString + TSAppConfig.share.localInfo.goldName + "支付弹窗_投稿_支付确认".localized
        labelForTitle.text = titleString
        setPrice(content: priceString)
        setDescription(content: descriptionContent, linkWord: nil)
        // 按钮配置
        self.buttonForBuy.setTitle("支付弹窗_投稿_支付按钮标题".localized, for:.normal)
        self.buttonForBack.setTitle("支付弹窗_投稿_取消按钮标题".localized, for: .normal)

        // 更新子视图布局
        updateChildViewLayout()

        // 调用父类方法
        super.show()
    }
}
