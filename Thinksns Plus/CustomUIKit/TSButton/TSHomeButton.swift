//
//  TSHomeButton.swift
//  ThinkSNS +
//
//  Created by LeonFa on 2017/5/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  自定义按钮

import UIKit

class TSHomeButton: UIButton {

    /// 文字和图片的之间的间距
    let titleWithImageSpace: CGFloat = 2

    // MARK: - Life Cycle
    init(selectedImage: UIImage, normalImage: UIImage, title: String) {
        super.init(frame: CGRect.zero)
        self.adjustsImageWhenHighlighted = false
        self.setTitle(title, for: .normal)
        self.setImage(normalImage, for: .normal)
        self.setImage(selectedImage, for: .selected)
        self.setTitleColor(TSColor.main.barTitle, for: .normal)
        self.imageView?.contentMode = .bottom
        self.setTitleColor(TSColor.main.theme, for: .selected)
        self.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.toolbarTop.rawValue)
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设文字和图片位置
    /// 设置
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect
        rect.origin.x = 0
        rect.origin.y = contentRect.size.height / 2
        rect.size = CGSize(width: rect.size.width, height: rect.origin.y - titleWithImageSpace / 2)
        return rect
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect
        rect.origin = CGPoint(x: 0, y: 5)
        rect.size = CGSize(width: rect.size.width, height: rect.size.height / 2 - titleWithImageSpace / 2)
        return rect
    }
}
