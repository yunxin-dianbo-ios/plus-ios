//
//  UIView+Extension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    /// 带背景色的初始化
    convenience init(bgColor: UIColor) {
        self.init(frame: CGRect.zero)
        self.backgroundColor = bgColor
    }

    /// 带圆角的普通视图(可附加边框border)
    convenience init(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) {
        self.init(frame: CGRect.zero)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

extension UIView {
    /// 移除所有子控件
    func removeAllSubViews() -> Void {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
}

extension UIView {

    /// 获取付费占位图
    func getPayLockedImage() -> UIImage? {
        let isSquare = frame.width == frame.height
        let lockImage = UIImage(named: "IMG_ico_lock")!
        let backImage = UIImage(named: isSquare ? "IMG_pic_locked_square_bg" : "IMG_pic_locked_bg")!

        let scale = UIScreen.main.scale
        let size = CGSize(width: frame.width * scale, height: frame.height * scale)
        UIGraphicsBeginImageContext(size)
        backImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
        lockImage.draw(in: CGRect(origin: CGPoint(x: (size.width - lockImage.size.width * scale) / 2, y: (size.height - lockImage.size.height * scale) / 2), size: CGSize(width: lockImage.size.width * scale, height: lockImage.size.height * scale)))
        let mixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mixedImage
    }
}

// MARK: - 四周线条的简便添加

public enum LineViewSide {
    // in 内侧
    case inBottom   // 内底(线条在view内的底部)
    case inTop      // 内顶
    case inLeft     // 内左
    case inRight    // 内右
    // out 外侧
    case outBottom  // 外底(线条在view外的底部)
    case outTop     // 外顶
    case outLeft    // 外左
    case outRight   // 外右
}

public extension UIView {
    /**
     给视图添加线条
     
     - parameter side:      线条在视图的哪侧(内外 + 上下左右)
     - parameter color:     线条颜色
     - parameter thickness: 线条厚度(水平方向为高度，竖直方向为宽度)
     - parameter margin1:   水平方向表示左侧间距，竖直方向表示顶部间距
     - parameter margin2:             右侧间距            底部间距
     */
    @discardableResult
    public func addLineWithSide(_ side: LineViewSide, color: UIColor, thickness: CGFloat, margin1: CGFloat, margin2: CGFloat) -> UIView {
        let lineView = UIView()
        self.addSubview(lineView)
        // 配置
        lineView.backgroundColor = color
        lineView.snp.makeConstraints { (make) in
            var horizontalFlag = true    // 线条方向标记
            switch side {
            // 线条为水平方向
            case .inBottom:
                make.bottom.equalTo(self)
                break
            case .inTop:
                make.top.equalTo(self)
                break
            case .outBottom:
                make.top.equalTo(self.snp.bottom)
                break
            case .outTop:
                make.bottom.equalTo(self.snp.bottom)
                break
            // 线条方向为竖直方向
            case .inLeft:
                horizontalFlag = false
                make.left.equalTo(self)
                break
            case .inRight:
                horizontalFlag = false
                make.right.equalTo(self)
                break
            case .outLeft:
                horizontalFlag = false
                make.right.equalTo(self.snp.left)
                break
            case .outRight:
                horizontalFlag = false
                make.left.equalTo(self.snp.right)
                break
            }
            // 约束
            if horizontalFlag   // 线条方向 为 水平方向
            {
                make.left.equalTo(self).offset(margin1)
                make.right.equalTo(self).offset(-margin2)
                make.height.equalTo(thickness)
            } else                // 线条方向 为 竖直方向
            {
                make.top.equalTo(self).offset(margin1)
                make.bottom.equalTo(self).offset(-margin2)
                make.width.equalTo(thickness)
            }
        }
        return lineView
    }

}
