//
//  TSAdvertNormal.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSAdvertNormal: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    /// 广告视图
    var collection: UICollectionView!
    /// 广告数量
    var itemCount = 0 {
        didSet {
            frame = getFrameWith(itemCount: itemCount)
        }
    }

    /// 广告视图数据
    var dataSource: [TSAdvertViewModel] = []

    // MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        // 默认先隐藏
        self.isHidden = true
    }

    init(itemCount count: Int) {
        super.init(frame: .zero)
        // 默认先隐藏
        self.isHidden = true
        frame = getFrameWith(itemCount: count)
        itemCount = count
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 默认先隐藏
        self.isHidden = true
    }

    func set(itemCount count: Int) {
        // 有内容才显示
        self.isHidden = count <= 0
        frame = getFrameWith(itemCount: count)
        itemCount = count
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = UIColor.white
        // collection
        collection = UICollectionView(frame: bounds, collectionViewLayout: TSAdvertNormalLayout(itemsCount: itemCount))
        collection.backgroundColor = UIColor.white
        collection.delegate = self
        collection.dataSource = self
        collection.bounces = false
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isScrollEnabled = false
        collection.register(UINib(nibName: "TSAdvertNormalItem", bundle: nil), forCellWithReuseIdentifier: TSAdvertNormalItem.identifier)

        if collection.superview == nil {
            addSubview(collection)
        }
        let grayView = UIView()
        grayView.frame = CGRect(x: 0, y: collection.bottom, width: ScreenWidth, height: 5)
        grayView.backgroundColor = TSColor.inconspicuous.background
        addSubview(grayView)
    }

    func getFrameWith(itemCount: Int) -> CGRect {
        return CGRect(origin: .zero, size: CGSize(width: ScreenWidth, height: TSAdvertHelper.share.getAdvertHeight(advertType: .normal, Advertwith: ScreenWidth, itemCount: itemCount)))
    }

    // MARK: - Public
    func set(models: [TSAdvertViewModel]) {
        // 有内容才显示
        self.isHidden = models.isEmpty
        dataSource = models
        collection.reloadData()
    }

    // MARK: - Delegate

    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TSAdvertNormalItem.identifier, for: indexPath) as! TSAdvertNormalItem
        cell.set(info: dataSource[indexPath.row])
        return cell
    }
}

class TSAdvertNormalLayout: UICollectionViewFlowLayout {

    var itemCount = 0

    init(itemsCount count: Int) {
        itemCount = count
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepare() {
        super.prepare()
        let spacing = TSAdvertHelper.share.getSpacing(advertType: .normal)
        let itemSpacing = TSAdvertHelper.share.getItemSpacing(advertType: .normal)
        itemSize = TSAdvertHelper.share.getAdvertItemSize(advertType: .normal, Advertwith: (collectionView?.width)!, itemCount: itemCount)
        // 3.设置其他属性
        minimumInteritemSpacing = itemSpacing
        minimumLineSpacing = itemSpacing
        // 4.设置内边距
        sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
