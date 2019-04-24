//
//  TSUIButtonExtension.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

var TSButtonExtensionKayTopEdge = "TSButtonExtensionKayTopEdge"
var TSButtonExtensionKayRightEdge = "TSButtonExtensionKayRightEdge"
var TSButtonExtensionKayBottomEdge = "TSButtonExtensionKayBottomEdge"
var TSButtonExtensionKayLeftEdge = "TSButtonExtensionKayLeftEdge"

extension UIButton {
    // 将按钮的图片和标题居中
    func centerVerticallyWithPadding(padding: CGFloat) {
        let imageSize = self.imageView?.frame.size
        let titleSize = self.titleLabel?.text?.sizeOfString(usingFont: (titleLabel?.font)!)

        if let imageSize = imageSize, let titleSize = titleSize {
            let totalHeight = imageSize.height + titleSize.height + padding
            self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0.0, bottom: 0.0, right: -titleSize.width)
            self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0.0)
            self.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: titleSize.height, right: 0.0)
        }
    }
}

extension UIButton {
    // 带圆角的图片视图(可附加边框border)
    convenience init(font: UIFont? = nil, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) {
        self.init(type: .custom)
        self.set(font: font, cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
    }
    convenience init(font: UIFont) {
        self.init(type: .custom)
        self.titleLabel?.font = font
    }
    convenience init(cornerRadius: CGFloat) {
        self.init(type: .custom)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}

extension UIButton {

    func set(title: String?, titleColor: UIColor, image: UIImage? = nil, bgImage: UIImage? = nil, for state: UIControlState) -> Void {
        self.setTitle(title, for: state)
        self.setTitleColor(titleColor, for: state)
        self.setImage(image, for: state)
        self.setBackgroundImage(bgImage, for: state)
        //let attTitle = NSAttributedString
        //self.setAttributedTitle(attTitle, for: state)
        //let shadowColor: UIColor
        //self.setTitleShadowColor(shadowColor, for: sate)
    }

    func set(font: UIFont?, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) -> Void {
        if let font = font {
            self.titleLabel?.font = font
        }
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        // 图片拉伸样式设置
        self.contentMode = .scaleAspectFill
    }
}
// MARK: - 扩大按钮的响应区域
/*
 SOT: 综合网友提供的基于Runtime的实现方式编写
 */
extension UIButton {
    /// 设置按钮扩大的响应区域
    /// 上、左、下、右均相同的距离
    func setEnlargeResponseAreaEdge(size: Float) {
        objc_setAssociatedObject(self, &TSButtonExtensionKayTopEdge, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &TSButtonExtensionKayRightEdge, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &TSButtonExtensionKayBottomEdge, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &TSButtonExtensionKayLeftEdge, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    /// 设置按钮扩大的响应区域
    /// 上、左、下、右单独设置
    func setEnlargeResponseAreaEdge(top: Float, left: Float, bottom: Float, right: Float) {
        objc_setAssociatedObject(self, &TSButtonExtensionKayTopEdge, NSNumber(value: top), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &TSButtonExtensionKayLeftEdge, NSNumber(value: left), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &TSButtonExtensionKayBottomEdge, NSNumber(value: bottom), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &TSButtonExtensionKayRightEdge, NSNumber(value: right), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    /// 获取扩展后的响应区域Rect
    func enlargedResponseAreaRect() -> CGRect {
        let topEdge = objc_getAssociatedObject(self, &TSButtonExtensionKayTopEdge) as? NSNumber
        let leftEdge = objc_getAssociatedObject(self, &TSButtonExtensionKayLeftEdge) as? NSNumber
        let rightEdge = objc_getAssociatedObject(self, &TSButtonExtensionKayRightEdge) as? NSNumber
        let bottomEdge = objc_getAssociatedObject(self, &TSButtonExtensionKayBottomEdge) as? NSNumber
        if topEdge != nil && leftEdge != nil && bottomEdge != nil && rightEdge != nil {
            let topEdgeFloat = CGFloat((topEdge?.floatValue)!)
            let leftEdgeFloat = CGFloat((leftEdge?.floatValue)!)
            let bottomEdgeFloat = CGFloat((bottomEdge?.floatValue)!)
            let rightEdgeFloat = CGFloat((rightEdge?.floatValue)!)
            return CGRect(x: self.bounds.origin.x - leftEdgeFloat, y: self.bounds.origin.y - topEdgeFloat, width: self.bounds.size.width + leftEdgeFloat + rightEdgeFloat, height: self.bounds.size.height + topEdgeFloat + bottomEdgeFloat)
        } else {
            return self.bounds
        }
    }
    /// 计算当前区域是否需要响应当前事件
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let curentRect = self.enlargedResponseAreaRect()
        if curentRect == self.bounds {
            return super.point(inside: point, with: event)
        } else {
            return curentRect.contains(point)
        }
    }
}
