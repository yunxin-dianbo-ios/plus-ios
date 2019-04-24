//
//  TSLabelCollectionView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  标签滚动视图
//  
//  用于处理标签视图和滚动视图之间的交互事件。比如，点击标签视图上的第一个按钮，滚动视图自动滚到最左边；再比如，将滚动视图滚动到最右边，标签视图将最后一个按钮切换到选中状态。
//
//
/*
 使用示例：
 
 // 1.初始化标签滚动视图，并设置 frame
 let labelCollection = TSLabelCollectionView(frame: view.bounds)
 
 // 2.设置视图相关
 labelCollection.shouldShowBlueLine = true
 labelCollection.leadingAndTralling = 32
 
 // 3.最!后!设置标签内容 titles（因为设置 titles 才会让标签滚动视图刷新视图）
 labelCollection.titles = ["用户", "问答", "动态", "资讯"]
 
 view.addSubview(labelCollection)
 
 */

import UIKit
import SnapKit

@objc protocol TSLabelCollectionViewDelegate: class {

    /// 标签滚动视图点击了某个按钮
    @objc optional func view(_ view: TSLabelCollectionView, didSelected labelButton: UIButton, at index: Int)

    /// 标签滚动视图将要滑动到某个页面
    ///
    /// - Parameters:
    ///   - view: 标签滚动视图
    ///   - index: 将要出现的页面的位置下标
    /// - Returns: 返回 false，标签滚动视图就停止滚动到 index 对应的页面；返回 true，标签滚动视图就继续滚动到 index 对应的页面
    @objc optional func view(_ view: TSLabelCollectionView, willScrollowTo index: Int) -> Bool

}

class TSLabelCollectionView: UIView {

    /// 滚动视图
    var collection: UICollectionView!
    /// 标签视图
    var labelsView: UIView!
    /// 标签视图上的按钮
    var labels: [UIButton] = []
    /// 底部蓝线
    var blueLine = UIView()

    weak var delegate: TSLabelCollectionViewDelegate?

    /// 子视图
    var childViews: [UIView] = []
    /// 标签视图据左右边距的距离
    var leadingAndTralling: CGFloat = 50
    /// 是否显示蓝色的底部线
    var shouldShowBlueLine = false {
        didSet {
            if shouldShowBlueLine {
                guard blueLine.superview == nil else {
                    return
                }
                addSubview(blueLine)
            } else {
                blueLine.removeFromSuperview()
            }
        }
    }
    /// 蓝线初始位置与左边边距的距离
    var blueLineLeading: CGFloat = 0

    /// 设置选中某个页面
    var selected: Int {
        set(newValue) {
            setSelectedIndex(at: newValue, animated: false)
        }
        get {
            var index = collection.contentOffset.x / collection.frame.width
            if index < 0 {
                index = CGFloat(0)
            }
            if Int(index) > titles.count {
                index = CGFloat(titles.count)
            }
            let i = round(index)
            return Int(i)
        }
    }

    /// 分割线
    var seperaterLine: UIView = {
        let line = UIView()
        line.backgroundColor = TSColor.inconspicuous.background
        return line
    }()

    /// 标题数组
    var titles: [String] = [] {
        didSet {
            // 移除旧的标签视图
            let _ = labels.map { $0.removeFromSuperview() }
            labels = []
            // 更新 UI
            setUI()
        }
    }

    /// 标签视图高度，默认 82px
    var labelsHeight: CGFloat = 40

    // MARK: Custom user interface

    /// 更新视图
    func setUI() {
        guard !titles.isEmpty else {
            return
        }
        let count = CGFloat(titles.count)
        // 标签视图
        labelsView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: labelsHeight))
        labelsView.backgroundColor = UIColor.white
        addSubview(labelsView)
        labelsView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(labelsHeight)
        }
        // 标签视图上的按钮
        let labelWidth = (frame.width - leadingAndTralling * 2) / count
        for index in 0..<titles.count {
            let title = titles[index]
            let button = UIButton(type: .custom)
            labelsView.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(0)
                make.leftMargin.equalTo(leadingAndTralling + labelWidth * CGFloat(index))
                make.width.equalTo(labelWidth)
                make.height.equalTo(labelsHeight)
            })
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(TSColor.main.content, for: .selected)
            button.setTitleColor(TSColor.normal.minor, for: .normal)
            button.backgroundColor = UIColor.white
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
            labels.append(button)
        }
        // 默认选中第一个
        labels[0].isSelected = true
        // 分割线
        if seperaterLine.superview == nil {
            addSubview(seperaterLine)
        }
        seperaterLine.snp.makeConstraints { (make) in
            make.topMargin.equalTo(labelsHeight)
            make.leftMargin.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        // 滚动视图
        collection = UICollectionView(frame: CGRect(x: 0, y: labelsHeight + 1, width: frame.width, height: frame.height - labelsHeight), collectionViewLayout: TSLabelCollectionViewLayout())
        collection.register(TSLabelCollectionCell.self, forCellWithReuseIdentifier: TSLabelCollectionCell.identifier)
        collection.isPagingEnabled = true
        collection.bounces = false
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = UIColor.white
        if collection.superview == nil {
            addSubview(collection)
        }
        collection.snp.makeConstraints { (make) in
            make.topMargin.equalTo(labelsHeight + 1)
            make.leftMargin.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-labelsHeight - 1)
        }
        collection.dataSource = self
        collection.delegate = self
        // 装饰蓝线
        let blueLineWidth = titles[0].sizeOfString(usingFont: UIFont.systemFont(ofSize: 15)).width + 15
        blueLineLeading = (labelWidth - blueLineWidth) / 2
        blueLine.backgroundColor = TSColor.main.theme
        blueLine.frame = CGRect(origin: CGPoint(x: blueLineLeading + leadingAndTralling, y: labelsHeight - 2), size: CGSize(width: blueLineWidth, height: 2))
        bringSubview(toFront: blueLine)
    }

    /// 更新标签视图
    func setLabelsSelected(at index: Int) {
        let _ = labels.map { $0.isSelected = false }
        labels[index].isSelected = true
    }

    // MARK: Button click
    func buttonTaped(sender: UIButton) {
        // 1.获取点击按钮的下标
        let index = Int(labels.index(of: sender)!)
        delegate?.view?(self, didSelected: sender, at: index)
        // 2.判断是否可以滚动到该下标对应的位置
        if delegate?.view?(self, willScrollowTo: index) == false {
            return
        }
        // 3.更新显示视图
        selected = index
    }

    // MARK: Public

    /// 添加子视图到滚动视图上
    func addChildViews(_ views: [UIView]) {
        childViews = views
        collection.reloadData()
    }

    /// 添加子视图
    func add(childView: UIView, at index: Int) {
        childViews[index] = childView
        collection.reloadData()
    }

    /// 设置显示视图
    func setSelectedIndex(at index: Int, animated: Bool) {
        collection.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: animated)
    }

}

// MARK: - UIScrollViewDelegate
extension TSLabelCollectionView {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1.刷新界面控件显示
        setLabelsSelected(at: Int(selected))
        TSKeyboardToolbar.share.keyboarddisappear()
        // 更新蓝线的位置
        if shouldShowBlueLine {
            updateBlueLineFrame()
        }
        // 2.判断是否可以滚动到该下标对应的位置
        let currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        var willShowIndex = 0
        if currentIndex < selected {
            willShowIndex = currentIndex
        } else if currentIndex == selected {
            let borderX = Int(CGFloat(currentIndex) * scrollView.frame.width)
            if Int(scrollView.contentOffset.x) > borderX {
                willShowIndex = currentIndex + 1
            } else {
                willShowIndex = currentIndex
            }
        }
        if delegate?.view?(self, willScrollowTo: willShowIndex) == false {
            setSelectedIndex(at: selected, animated: false)
        }
    }

    func updateBlueLineFrame() {
        var index = collection.contentOffset.x / collection.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > titles.count {
            index = CGFloat(titles.count)
        }
        blueLine.frame.origin = CGPoint(x: CGFloat(index) * (frame.width - leadingAndTralling * 2) / CGFloat(titles.count) + blueLineLeading + leadingAndTralling, y: labelsHeight - 2)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TSLabelCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childViews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TSLabelCollectionCell.identifier, for: indexPath) as! TSLabelCollectionCell
        cell.setInfo(view: childViews[indexPath.row])
        return cell
    }

}

class TSLabelCollectionViewLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 1.设置 item 大小
        itemSize = collectionView!.frame.size
        // 2.设置间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        // 3.设置滚动方向
        scrollDirection = .horizontal
    }

}
