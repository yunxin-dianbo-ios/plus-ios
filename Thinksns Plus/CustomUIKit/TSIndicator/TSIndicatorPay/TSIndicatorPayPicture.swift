//
//  TSIndicatorPay.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/5/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片付费弹窗

import UIKit

class TSIndicatorPayPicture: TSIndicatorPayBasicView {

    /// 显示图片付费弹窗
    ///
    /// - Parameter isRead: true 查看付费，false 下载付费
    func show(isRead: Bool) {
        let goldName = TSAppConfig.share.localInfo.goldName
        let isReadString = isRead ? goldName + "支付弹窗_图片查看付费描述".localized : goldName + "支付弹窗_图片下载付费描述".localized

        let titleString = "支付弹窗_标题".localized
        let goldNumber = Int(price)
        let priceString = "\(goldNumber)"
        let descriptionContent = "支付弹窗_描述开头".localized + priceString + isReadString
        // 设置显示内容
        labelForTitle.text = titleString
        setPrice(content: priceString)
        setDescription(content: descriptionContent, linkWord: nil)

        // 更新子视图布局
        updateChildViewLayout()

        // 调用父类方法
        super.show()
    }

}
