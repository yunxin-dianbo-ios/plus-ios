//
//  TSPgaeControl.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPgaeControl: UIPageControl {
    /// dot之间的间距 默认 5
    public var dotsSpace: CGFloat = 5
    /// dot的大小 默认 5
    public var dotsWidth: CGFloat = 5

    override func layoutSubviews() {
        super.layoutSubviews()
        for i in 0...self.subviews.count - 1 {
            let dot = self.subviews[i]
            dot.frame = CGRect(x: CGFloat(i) * self.dotsSpace * 2, y: 0, width: self.dotsWidth, height: self.dotsWidth)
            dot.layer.cornerRadius = self.dotsWidth / 2
        }
    }
}
