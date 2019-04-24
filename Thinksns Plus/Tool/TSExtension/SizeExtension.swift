//
//  SizeExtension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 27/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import Foundation

extension CGSize {

    static var maxSize: CGSize {
        return CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
    }

    /// 判断当前 size 是否在长图的尺寸范围
    ///
    /// - Returns: true，是长图尺寸；false，不是长图尺寸
    func isLongPictureSize() -> Bool {
        let screenRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        let picRatio = self.height / self.width
        return picRatio / screenRatio > 3
    }
}
