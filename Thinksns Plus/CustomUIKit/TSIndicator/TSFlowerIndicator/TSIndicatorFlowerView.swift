//
//  TSIndicatorFlowerView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  旋转的花 活动指示器
//  该活动指示器有 2 中颜色，一种白色，一种灰色
//  这个类内部只设置了动画，布局需要程序员自行设置，原因如下：
//  此类活动指示器一般用于按钮上显示，一个页面上可能存在多个按钮，故有可能有多个 旋转的花 同时显示，且位置不同，故此类值设置其的动画，不对布局进行设置。
//

import UIKit

class TSIndicatorFlowerView: TSImageView {
    // MARK: - Publie

    /// 显示白色花花旋转动画
    ///
    /// - Parameter imageView: 需要展示动画的 ImageView
    func starAnimationForFlowerWhite() {
        self.isHidden = false
        var images: [UIImage] = []
        for index in 0...9 {
            let image = UIImage(named: "default_white000\(index)")
            if let image = image {
                images.append(image)
            }
        }
        setImageViewWith(images)
        self.startAnimating()
    }

    /// 显示灰色花花旋转动画
    ///
    /// - Parameter imageView: 需要展示动画的 ImageView
    func starAnimationForFlowerGrey() {
        self.isHidden = false
        var images: [UIImage] = []
        for index in 0...9 {
            let image = UIImage(named: "IMG_default_grey00\(index)")
            if let image = image {
                images.append(image)
            }
        }
        setImageViewWith(images)
        self.startAnimating()
    }

    /// 停止动画
    ///
    /// - Parameter imageView: 需要停止动画的 ImageView
    func dismiss() {
        self.stopAnimating()
        self.isHidden = true
    }

    // MARK: - Private

    /// 设置活动指示器显示图片
    ///
    /// - Parameters:
    ///   - imageView: 显示动画用的 ImageView
    ///   - images: 图片数组
    private func setImageViewWith(_ images: [UIImage]) {
        self.animationImages = images
        self.animationDuration = Double(images.count) / 24.0
        self.animationRepeatCount = 0
    }

}
