//
//  PHAsset+TSMoment.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/10.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import Foundation
var MomentPHAssetPayInfoKey = 100_000
var MomentUIImageGIFKey = 100_001

extension PHAsset {
    // 给图片绑定支付信息
    var payInfo: TSImgPrice {
        set {
            objc_setAssociatedObject(self, &MomentPHAssetPayInfoKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &MomentPHAssetPayInfoKey) as? TSImgPrice {
                return rs
            }
            return TSImgPrice(paymentType: .not, sellingPrice: 0)
        }
    }
}

extension UIImage {
    // 默认设置为kUTTypeJPEG
    var TSImageMIMEType: String {
        set {
            objc_setAssociatedObject(self, &MomentUIImageGIFKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &MomentUIImageGIFKey) as? String {
                return rs
            }
            return kUTTypeJPEG as String
        }
    }
}
