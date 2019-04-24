//
//  TSToolBarButtonItem.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  工具栏的 item 类

import UIKit

/// 工具栏 item 配置信息：参见 TS+ 设计文档 1.0 版第二部分，第三页(动态列表样式)和最后一页(详情页导航栏)
private struct TSToolBarButtonItemUX {
    /// 图片长宽
    static let imageLenth: CGFloat = 16.0
    /// 图片和文字之间的间距
    static let imageSpacing: CGFloat = 5.0
    /// 标题颜色
    static let titleColor = TSColor.normal.secondary

    /// left 图片位于文字左边 - 动态列表样式
    /// 标题 label 的长度
    static let titleLenthForLeft: CGFloat = 50.0
    /// 标题 label 字体大小
    static let titleFontForLeft = TSFont.Button.toolbarLeft.rawValue

    /// top 图片位于文字上边 - 详情页导航栏
    /// 标题 label 字体大小
    static let titleFontForTop = TSFont.Button.toolbarTop.rawValue
    static let titleHeightForTop: CGFloat = 13.0
}

/// 工具栏 item 代理事件
protocol TSToolBarButtonItemDelegate: class {
    /// item 被点击
    func toolbarDidSelectedItemAt(index: Int)
}

class TSToolBarButtonItem: UIView {

    /// item 数据模型
    private var model: TSToolbarItemModel? = nil
    /// 工具栏类型
    private var type: TSToolbarView.ToolBarRelativeType
    /*
     为了方便以后做动画，将 touch button 和 imgae、label 拆开了
     */
    /// touch button 负者 item 点击事件按钮
    let button = TSToolbarItemTouchButton(type: .custom)
    /// 图标
    private let imageView = UIImageView()
    /// 标题
    private let titleLabel = UILabel()

    /// 代理
    weak var delegate: TSToolBarButtonItemDelegate? = nil

    /// 字体颜色
    var titleColor = TSColor.normal.secondary

    // MARK: - Lifecycle
    /// 自定义初始化方法
    ///
    /// - Parameter type: 描述按钮中图片和标题的相对位置
    init(frame: CGRect, model: TSToolbarItemModel, type: TSToolbarView.ToolBarRelativeType) {
        self.type = type
        super.init(frame: frame)
        self.model = model
        self.setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Custom user interface
    // 视图相关
    func setUI() {
        self.backgroundColor = UIColor.clear
        updateChildView()
        // touch button
        button.frame = self.bounds
        button.addTarget(self, action: #selector(buttonTaped), for: .touchUpInside)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(button)
    }

    // 刷新 item 的布局
    func updateChildView() {
        let imageWidth = TSToolBarButtonItemUX.imageLenth
        let centerX = self.bounds.width / 2

        // 设置 image view 共有配置
        imageView.image = UIImage(named: model!.image!)
        imageView.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth)

        /*
         由于动态列表样式的工具栏中，最右边的按钮比较特殊，没有文字，只有一张“...”图片，并且在相同 item 大小下，这张图片是位于 item 的最右方的，与其前面“图左字右”的样式不同；
         这里是针对动态列表样式工具栏最右的特殊按钮进行了特殊处理
         */
        if model?.index == 3 && type == .left {
            imageView.frame = CGRect(x: self.bounds.width - imageWidth - 15, y: (self.bounds.height - imageWidth) / 2, width: imageWidth, height: imageWidth)
            return
        }

        // 设置 title label 共有配置
        titleLabel.text = model!.title!
        titleLabel.textColor = titleColor

        // 设置 image view 和 title label 的位置和特殊配置
        switch type {
        case .left: // 当图片在左，文字在右时
            titleLabel.font = UIFont.systemFont(ofSize: TSToolBarButtonItemUX.titleFontForLeft)
            titleLabel.frame = CGRect(x: imageWidth + TSToolBarButtonItemUX.imageSpacing, y: (self.bounds.height - imageWidth) / 2, width: self.bounds.width - imageWidth - TSToolBarButtonItemUX.imageSpacing, height: imageWidth)
            imageView.frame = CGRect(x: 0, y: (self.bounds.height - imageWidth) / 2, width: imageWidth, height: imageWidth)
        case .top: // 当图片在上，文字在下时
            let topSpace = (self.bounds.height - imageWidth - TSToolBarButtonItemUX.titleHeightForTop - TSToolBarButtonItemUX.imageSpacing) / 2
            titleLabel.font = UIFont.systemFont(ofSize: TSToolBarButtonItemUX.titleFontForTop)
            titleLabel.frame = CGRect(x: 0.0, y: topSpace + imageWidth + TSToolBarButtonItemUX.imageSpacing, width: self.bounds.size.width, height: TSToolBarButtonItemUX.titleHeightForTop)
            titleLabel.textAlignment = .center
            imageView.center = CGPoint(x: centerX, y: topSpace + imageWidth / 2)
        }
    }

    // MARK: - Public
    public func setTitleTextColor(_ color: UIColor) {
        titleColor = color
        titleLabel.textColor = color
    }

    public func setItemWithNewModel(_ newModel: TSToolbarItemModel) {
        model = newModel
        updateChildView()
    }

    // MARK: - Button click
    // button 的点击事件
    func buttonTaped() {
        if let delegate = delegate {
            delegate.toolbarDidSelectedItemAt(index: (model?.index)!)
        }
    }

}

class TSToolbarItemTouchButton: TSTouchButton {
    // 这个类为以后点击效果留着
}
