//
//  TSImageViewExtension.swift
//  ThinkSNS +
//
//  Created by GorCat on 17/4/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

extension UIImageView {

    // 毛玻璃效果
    func blur() {
        let blurViewTag = 500
        var blurView = viewWithTag(blurViewTag) as? UIVisualEffectView
        if blurView == nil {
            let blureffect = UIBlurEffect(style: .light)
            blurView = UIVisualEffectView(effect: blureffect)
            blurView?.tag = blurViewTag
            blurView?.frame.size = self.frame.size
            self.addSubview(blurView!)
        }
    }

}

extension UIImageView {
    // 带圆角的图片视图(可附加边框border)
    convenience init(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) {
        self.init(frame: CGRect.zero)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        // 图片拉伸样式设置
        self.contentMode = .scaleAspectFill
    }
}
