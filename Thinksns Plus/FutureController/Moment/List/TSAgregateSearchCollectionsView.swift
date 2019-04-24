//
//  TSAgregateSearchCollectionsView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol TSAgregateSearchCollectionsViewDelegate: class {
    /// 标签滚动视图点击了某个按钮
    @objc optional func view(_ view: TSAgregateSearchCollectionsView, didSelected labelButton: UIButton, at index: Int)
    /// 标签滚动视图将要滑动到某个页面
    ///
    /// - Parameters:
    ///   - view: 标签滚动视图
    ///   - index: 将要出现的页面的位置下标
    /// - Returns: 返回 false，标签滚动视图就停止滚动到 index 对应的页面；返回 true，标签滚动视图就继续滚动到 index 对应的页面
    @objc optional func view(_ view: TSAgregateSearchCollectionsView, willScrollowTo index: Int) -> Bool
}

class TSAgregateSearchCollectionsView: UIView {

    /// 滚动视图
    var collection: UICollectionView!
    /// 标签视图
    var labelsView: UIScrollView!
    /// 标签视图上的按钮
    var labels: [UIButton] = []
    /// 底部蓝线
    var blueLines: [UIView] = []
    var titleButtonWidth: CGFloat = 70 * ScreenWidth / 375.0
    var blueLineWidth: CGFloat = 55.0 / 2.0
    weak var delegate: TSAgregateSearchCollectionsViewDelegate?
    /// 子视图
    var childViews: [UIView] = []
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
        labelsView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: labelsHeight))
        labelsView.backgroundColor = UIColor.white
        labelsView.contentSize = CGSize(width: (titleButtonWidth * count) > ScreenWidth ? (titleButtonWidth * count) : ScreenWidth, height: labelsHeight)
        labelsView.showsHorizontalScrollIndicator = false
        addSubview(labelsView)
        labelsView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(labelsHeight)
        }
        // 标签视图上的按钮
        for index in 0..<titles.count {
            let title = titles[index]
            let button = UIButton(type: .custom)
            let blueBottomLine = UIView()
            labelsView.addSubview(button)
            labelsView.addSubview(blueBottomLine)
            blueLineWidth = titles[0].sizeOfString(usingFont: UIFont.systemFont(ofSize: 15)).width + 15
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(0)
                make.leftMargin.equalTo(titleButtonWidth * CGFloat(index))
                make.width.equalTo(titleButtonWidth)
                make.height.equalTo(labelsHeight)
            })
            blueBottomLine.snp.makeConstraints({ (make) in
                make.topMargin.equalTo(labelsHeight - 2)
                make.centerX.equalTo(button.snp.centerX)
                make.width.equalTo(blueLineWidth)
                make.height.equalTo(2)
            })
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(TSColor.main.content, for: .selected)
            button.setTitleColor(TSColor.normal.minor, for: .normal)
            button.backgroundColor = UIColor.white
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
            blueBottomLine.backgroundColor = TSColor.main.theme
            labels.append(button)
            blueLines.append(blueBottomLine)
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
        collection = UICollectionView(frame: CGRect(x: 0, y: labelsHeight + 1, width: frame.width, height: frame.height - labelsHeight), collectionViewLayout: TSAgregateSearchCollectionsViewLayout())
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
        for (index, item) in blueLines.enumerated() {
            if index == 0 {
                item.isHidden = false
            } else {
                item.isHidden = true
            }
        }
    }
    /// 更新标签视图
    func setLabelsSelected(at index: Int) {
        let _ = labels.map { $0.isSelected = false }
        labels[index].isSelected = true
        for (viewIndex, item) in blueLines.enumerated() {
            if index == viewIndex {
                item.isHidden = false
            } else {
                item.isHidden = true
            }
        }
        if labels[index].right > ScreenWidth {
            if index < labels.count - 1 {
                labelsView.contentOffset = CGPoint(x: labels[index].right - ScreenWidth + titleButtonWidth / 2.0, y: 0)
            } else {
                labelsView.contentOffset = CGPoint(x: labels[index].right - ScreenWidth, y: 0)
            }
        }
        if labels[index].right < ScreenWidth {
            labelsView.contentOffset = CGPoint(x: 0, y: 0)
        }
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
extension TSAgregateSearchCollectionsView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1.刷新界面控件显示
        setLabelsSelected(at: Int(selected))
        TSKeyboardToolbar.share.keyboarddisappear()
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
        for (viewIndex, item) in blueLines.enumerated() {
            if Int(index) == viewIndex {
                item.isHidden = false
            } else {
                item.isHidden = true
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TSAgregateSearchCollectionsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childViews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TSLabelCollectionCell.identifier, for: indexPath) as! TSLabelCollectionCell
        cell.setInfo(view: childViews[indexPath.row])
        return cell
    }
}

class TSAgregateSearchCollectionsViewLayout: UICollectionViewFlowLayout {
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
