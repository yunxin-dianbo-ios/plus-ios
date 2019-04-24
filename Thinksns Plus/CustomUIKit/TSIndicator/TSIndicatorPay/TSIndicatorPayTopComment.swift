//
//  TSIndicatorPayTopComment.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/5/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//   置顶评论支付弹窗

import UIKit

class TSIndicatorPayTopComment: TSIndicatorPayBasicView {

    /// 显示置顶评论付费弹窗
    override func show() {
        let titleString = "支付弹窗_置顶评论".localized
        let priceString = price
        let descriptionContent = "支付弹窗_描述开头".localized + price + TSAppConfig.share.localInfo.goldName + "支付弹窗_置顶评论付费描述".localized
        // 设置显示内容
        labelForTitle.text = titleString
        setPrice(content: priceString)
        setDescription(content: descriptionContent, linkWord: "支付弹窗_成为会员".localized)

        // 更新子视图布局
        updateChildViewLayout()

        // 调用父类方法
        super.show()
    }

}
