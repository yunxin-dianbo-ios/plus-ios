//
//  TSKingfisherExtension.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Kingfisher

extension Kingfisher where Base: UIButton {

    public func ts_setImage(with resource: Resource?,
                            for state: UIControlState,
                            placeholder: UIImage? = nil,
                            progressBlock: DownloadProgressBlock? = nil,
                            completionHandler: CompletionHandler? = nil) {
        // 设置图片的网络请求头
        let modifier = AnyModifier { request in
            var r = request
            if let authorization = TSCurrentUserInfo.share.accountToken?.token {
                r.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
            }
            return r
        }
        setImage(with: resource, for: state, placeholder: placeholder, options: [.requestModifier(modifier)], progressBlock: progressBlock, completionHandler: completionHandler)
    }
}

extension Kingfisher where Base: ImageView {

    public func ts_setImage(with resource: Resource?, placeholder: Image? = nil, progressBlock: DownloadProgressBlock? = nil, completionHandler: CompletionHandler? = nil) {
        // 设置图片的网络请求头
        let modifier = AnyModifier { request in
            var r = request
            if let authorization = TSCurrentUserInfo.share.accountToken?.token {
                r.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
            }
            return r
        }
        setImage(with: resource, placeholder: placeholder, options: [.requestModifier(modifier)], progressBlock: progressBlock, completionHandler: completionHandler)
    }
}
