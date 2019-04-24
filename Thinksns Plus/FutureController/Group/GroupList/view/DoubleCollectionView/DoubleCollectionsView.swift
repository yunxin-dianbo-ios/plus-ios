//
//  ScrollowCollectionListView.swift
//  Test111
//
//  Created by GorCat on 2018/1/2.
//  Copyright © 2018年 GorCat. All rights reserved.
//

import UIKit

protocol DoubleCollectionsViewDelegate: class {

    /// 下方集合视图将要显示 cell
    func doubleCollections(_ view: DoubleCollectionsView, bottomCollection: UICollectionView, willDisplay cell: UICollectionViewCell, at indexPath: IndexPath)
}

class DoubleCollectionsView: UIView {

    // 代理
    weak var doubleCollectionsDelegate: DoubleCollectionsViewDelegate?

    // 上方集合视图
    let topCollcetion = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width - 40, height: 44)), collectionViewLayout: TopTagCollectionLayout())
    // 下方集合视图
    var bottomCollcetion = UICollectionView(frame: CGRect(x: 0, y: 46, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 45 - 64), collectionViewLayout: BottomCollectionLayout())
    // 分割线
    let seperatorLine = UIView(frame: CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: 1))
    // 箭头按钮
    let rightButton = UIButton(type: .custom)

    // 上方集合视图的标题数组
    fileprivate var titles: [String] = []

    // 当期显示坐标
    var currentIndex = 0 {
        didSet {
            topCollcetion.reloadData()
        }
    }

    init(origin: CGPoint) {
        super.init(frame: CGRect(origin: origin, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)))
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        backgroundColor = .white

        seperatorLine.backgroundColor = UIColor(hex: 0xededed)

        rightButton.setImage(UIImage(named: "IMG_ico_tools_packup"), for: .normal)
        rightButton.frame = CGRect(x: UIScreen.main.bounds.width - 40, y: 0, width: 40, height: 44)

        topCollcetion.delegate = self
        topCollcetion.dataSource = self
        topCollcetion.backgroundColor = .white
        topCollcetion.register(TagCollectionCell.self, forCellWithReuseIdentifier: TagCollectionCell.identifier)

        bottomCollcetion.backgroundColor = .white
        bottomCollcetion.isPagingEnabled = true
        bottomCollcetion.delegate = self

        addSubview(bottomCollcetion)
        addSubview(topCollcetion)
        addSubview(seperatorLine)
        addSubview(rightButton)
    }

    func set(titles: [String]) {
        self.titles = titles
        topCollcetion.reloadData()
    }

    func setSelected(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        topCollcetion.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        bottomCollcetion.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}

extension DoubleCollectionsView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionCell.identifier, for: indexPath) as! TagCollectionCell
        cell.set(title: titles[indexPath.row], isSelected: indexPath.row == currentIndex)
        return cell
    }

}

extension DoubleCollectionsView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == bottomCollcetion {
            doubleCollectionsDelegate?.doubleCollections(self, bottomCollection: bottomCollcetion, willDisplay: cell, at: indexPath)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == bottomCollcetion else {
            return
        }
        currentIndex = Int(round(scrollView.contentOffset.x / UIScreen.main.bounds.width))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard collectionView == topCollcetion else {
            return
        }
        bottomCollcetion.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

class TopTagCollectionLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 1.设置 item 大小
        itemSize = CGSize(width: 54, height: 44)
        // 2.设置间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        // 3.设置滚动方向
        scrollDirection = .horizontal
    }
}

class BottomCollectionLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 1.设置 item 大小
        itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 45 - 64)
        // 2.设置间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        // 3.设置滚动方向
        scrollDirection = .horizontal
    }
}
