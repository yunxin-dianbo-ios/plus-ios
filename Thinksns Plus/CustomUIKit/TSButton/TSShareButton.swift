//
//  TSShareButton.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片在上，文字在下的按钮

import UIKit

class TSShareButton: UIButton {

    /// 文字和图片的之间的间距
    var titleWithImageSpace: CGFloat = 10.0
    /// 文字高度
    var titleHeight: CGFloat = 12.0

    /// 构造器一
    /// - 可以后续跟着setInit配合食用
    init() {
        super.init(frame: CGRect.zero)
    }

    /// 构造器二
    /// - 在初始化时便设置好
    ///
    /// - Parameters:
    ///   - normalImage: 图片
    ///   - title: 文字
    init(normalImage: UIImage, title: String) {
        super.init(frame: CGRect.zero)
        self.setImage(normalImage, for: .normal)
        self.imageView?.contentMode = .top
        self.setTitle(title, for: .normal)
        self.setTitleColor(TSColor.normal.minor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.toolbarTop.rawValue)
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }

    /// 构造器三
    /// - 专用于发布页
    /// - Parameters:
    ///   - normalImage: 图片
    ///   - title: 文字
    ///   - titleFont: 文字大小
    ///   - titleColor: 文字颜色
    init(normalImage: UIImage, title: String, titleFont: CGFloat, titleColor: UIColor) {
        super.init(frame: CGRect.zero)
        self.setImage(normalImage, for: .normal)
        self.imageView?.contentMode = .top
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: titleFont)
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 设置文字和图片位置
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect
        rect.origin.x = 0
        rect.origin.y = contentRect.size.height - titleHeight
        rect.size = CGSize(width: rect.size.width, height: titleHeight)
        return rect
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect
        rect.origin = CGPoint(x: 0, y: 0)
        rect.size = CGSize(width: rect.size.width, height: rect.size.height - titleHeight - titleWithImageSpace)
        return rect
    }

    /// 外部更改文字和图片显示位置
    ///
    /// - Parameters:
    ///   - space: 文字和图片的间距
    ///   - height: 文字的高度
    public func setTitleWithImageSpaceAndTitleHeight(space: CGFloat, height: CGFloat) {
        titleWithImageSpace = space
        titleHeight = height
    }

    /// 外部更改初始化内容，配合init()食用
    ///
    /// - Parameters:
    ///   - normalImage: 图片
    ///   - title: 文字
    public func setInit(normalImage: UIImage, title: String) {
        self.setImage(normalImage, for: .normal)
        self.imageView?.contentMode = .top
        self.setTitle(title, for: .normal)
        self.setTitleColor(TSColor.normal.minor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.toolbarTop.rawValue)
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }
}
