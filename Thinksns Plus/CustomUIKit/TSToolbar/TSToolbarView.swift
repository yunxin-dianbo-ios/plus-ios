//
//  TSToolbarView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  工具栏
//  这里工具栏有两种类型，一种是动态列表上的样式(简称 left 样式: 图片左，标题右)，一种是动态详情页上的样式(简称 top 样式: 图片上，标题下)

import UIKit

/// 工具栏代理事件
protocol TSToolbarViewDelegate: class {
    /// item 被点击
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int)
}

class TSToolbarView: UIView, TSToolBarButtonItemDelegate {

    /// 图片和标题的相对位置
    ///
    /// - left: 图片左，标题右
    /// - top: 图片上，标题下
    public enum ToolBarRelativeType {
        case left
        case top
    }

    /// 描述图片和标题的相对位置
    let relativeType: ToolBarRelativeType
    /// 工具栏按钮的主题色
    private var itemTintColor: UIColor = TSColor.normal.secondary

    /// 代理
    weak var delegate: TSToolbarViewDelegate? = nil

    /// item 数据模型
    var itemModels: [TSToolbarItemModel]? = nil
    /// item 的基础 tag 值
    private let tagNumberForItem = 200

    // MARK: - Lifecycle
    init(type: ToolBarRelativeType) {
        relativeType = type
        super.init(frame: .zero)
    }

    /// 自定义初始化方法
    ///
    /// - Parameters:
    ///   - frame: toolbar 的位置信息
    ///   - items: item 的配置信息
    init(frame: CGRect, type: ToolBarRelativeType, items: [TSToolbarItemModel]) {
        self.relativeType = type
        super.init(frame: frame)
        self.itemModels = items
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Custom user interface 
    func set(items: [TSToolbarItemModel], frame: CGRect) {
        self.itemModels = items
        self.frame = frame
        setUI()
    }

    // 设置视图
    func setUI() {
        self.backgroundColor = UIColor.white
        // 设置 items 的 frame
        for model in itemModels! {
            // 固定高度
            var height: CGFloat = self.bounds.height
            if TSUserInterfacePrinciples.share.isiphoneX() == true {
                height = 48.0
            }
            var width: CGFloat = 0
            var x: CGFloat = 0
            switch relativeType {
            case .left: // item 图片在左文字在右时
                width = CGFloat(16.0 + 2.0 + 50.0) // 这里 width 的值是根据设计图配置的
                if model.index == 3 {
                    x = self.bounds.width - width
                } else {
                    x = width * CGFloat(model.index)
                }
            case .top: // item 图片在上文字在下时
                width = UIScreen.main.bounds.size.width / CGFloat((itemModels?.count)!)
                x = CGFloat(model.index) * width
            }
            let itemFrame = CGRect(x: x, y: 0, width: width, height: height)
            let item = TSToolBarButtonItem(frame: itemFrame, model: model, type: relativeType)
            item.delegate = self
            item.tag = tagNumberForItem + model.index
            self.addSubview(item)
        }
    }

    // MARK: - Private
    /// 通过 index 获取 item
    private func getItemAt(_ index: Int) -> TSToolBarButtonItem {
        return (self.viewWithTag(index + tagNumberForItem) as? TSToolBarButtonItem)!
    }

    // MARK: - Public
    /// 设置 item 的文字颜色
    ///
    /// - Parameters:
    ///   - color: 新的颜色
    ///   - index: item 的坐标
    public func setTitleColor(_ newColor: UIColor, At index: Int) {
        let item = getItemAt(index)
        item.setTitleTextColor(newColor)
    }

    /// 设置 item 是否响应点击事件
    public func set(isUserInteractionEnabled enable: Bool, at index: Int) {
        let item = getItemAt(index)
        item.button.isUserInteractionEnabled = enable
    }

    /// 设置 item 的标题文字
    ///
    /// - Parameters:
    ///   - newTitle: 新的标题
    ///   - index: item 的坐标
    public func setTitle(_ newTitle: String, At index: Int) {
        let item = getItemAt(index)
        let model = itemModels?[index]
        model?.title = newTitle
        itemModels?[index] = model!
        item.setItemWithNewModel(model!)
    }

    /// 设置 item 的图片
    ///
    /// - Parameters:
    ///   - newImage: 新的图片
    ///   - index: item 的坐标
    public func setImage(_ newImage: String, At index: Int) {
        let item = getItemAt(index)
        let model = itemModels?[index]
        model?.image = newImage
        itemModels?[index] = model!
        item.setItemWithNewModel(model!)
    }

    /// 设置工具栏按钮的主题色
    ///
    /// - Parameter color: 主题色颜色
    public func setItemTintColor(_ color: UIColor) {
        itemTintColor = color
        for model in itemModels! {
            let item = (viewWithTag(tagNumberForItem + model.index) as? TSToolBarButtonItem)!
            item.setTitleTextColor(itemTintColor)
        }
    }

    /// 隐藏工具栏按钮
    public func item(isHidden: Bool, at index: Int) {
        let item = getItemAt(index)
        item.isHidden = isHidden
    }

    // MARK: - Delegate
    // MARK: TSToolBarButtonItemDelegate
    /// item 点击触发事件
    func toolbarDidSelectedItemAt(index: Int) {
        if let delegate = delegate {
            delegate.toolbar(self, DidSelectedItemAt: index)
        }
    }

}
