//
//  TSPHAssetExtension.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {

    // 图片文件名
    var originalFilename: String? {
        var fname: String?
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = "\(arc4random() % 10_000)" + resource.originalFilename
            }
        }
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = self.value(forKey: "filename") as? String
            guard let name = fname else {
                fname = "\(arc4random() % 10_000)"
                return fname
            }
            fname = "\(arc4random() % 10_000)" + name
        }
        return fname
    }
}
