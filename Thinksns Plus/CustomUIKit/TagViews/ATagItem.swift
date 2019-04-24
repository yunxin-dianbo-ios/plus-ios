//
//  ATagItem.swift
//  RealmTest
//
//  Created by GorCat on 2017/9/7.
//  Copyright © 2017年 GorCat. All rights reserved.
//
//  一个标签

import UIKit
import SnapKit

class ATagItem: UIView {

    /// 内边距
    var tagPadding = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8) {
        didSet {
            updateContainerSize()
        }
    }
    /// 圆角
    var tagRadius: CGFloat = 4 {
        didSet {
            layer.cornerRadius = tagRadius
            clipsToBounds = true
        }
    }
    /// 标签显示内容
    var tagText = "" {
        didSet {
            setLabel(text: tagText)
            updateContainerSize()
        }
    }
    /// 标签字体
    var tagFont: CGFloat = 10 {
        didSet {
            setLabel(font: tagFont)
            updateContainerSize()
        }
    }
    /// 标签文字颜色
    var tagTextColor: UIColor = UIColor.white {
        didSet {
            label.textColor = tagTextColor
        }
    }

    /// tag 的最大宽度，超过该宽度的内容用 ... 代替，默认为 tagView 去掉内边距的宽度
    var tagMaxWidth: CGFloat = 0

    /// 标签
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - UI

    func setUI() {
        backgroundColor = UIColor.white
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 1

        addSubview(label)
    }

    // 设置 label 的 font 
    internal func setLabel(font: CGFloat) {
        label.font = UIFont.systemFont(ofSize: font)
        label.sizeToFit()
    }

    // 设置 label 的内容
    internal func setLabel(text: String) {
        label.text = text
        label.sizeToFit()
    }

    /// 更新 frame
    internal func updateContainerSize() {
        if label.frame.width > tagMaxWidth {
            label.frame.size.width = tagMaxWidth - tagPadding.left - tagPadding.right
            print(label)
        }
        let containerSize = CGSize(width: label.frame.width + tagPadding.left + tagPadding.right, height: label.frame.height + tagPadding.top + tagPadding.bottom)
        frame = CGRect(origin: frame.origin, size: containerSize)
        label.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(label.frame.size)
        }
    }
}
