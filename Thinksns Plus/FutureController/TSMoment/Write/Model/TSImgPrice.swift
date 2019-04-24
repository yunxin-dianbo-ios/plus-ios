//
//  TSImgPrice.swift
//  ThinkSNS +
//
//  Created by lip on 2017/7/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片支付价格结构体

enum ImagePaymentType: Int {
    /// 未设置付费
    case not = 0
    /// 下载收费
    case download
    /// 查看收费
    case read
}

struct TSImgPrice {
    var paymentType: ImagePaymentType
    var sellingPrice: Int
}
