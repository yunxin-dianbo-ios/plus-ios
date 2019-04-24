//
//  OccupiedView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 占位图类型
enum PlaceholderViewType {
    /// 网络请求失败
    case network
    /// 数据为空
    case empty
}

class NormalPlaceholderView {

    /// 返回一个带占位图片的 imageView
    ///
    /// - Parameter name: 占位图片的名称
    /// - Returns: 带占位图片的 imageView
    class func imageView(name: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: name))
        imageView.backgroundColor = TSColor.inconspicuous.background
        imageView.contentMode = .center
        return imageView
    }
}
