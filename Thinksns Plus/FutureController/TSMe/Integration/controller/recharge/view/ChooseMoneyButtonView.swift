//
//  ChooseMoneyButtonView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  选择

import UIKit

class ChooseMoneyButtonView: UIView {

    var array: [String] = [] {
        didSet {
            loadArrayInfo()
        }
    }
    var selectedIndex = -1

    var selectedInfo: String {
        if selectedIndex < array.count {
            return array[selectedIndex]
        } else {
            return ""
        }
    }

    var tapAction: ((String) -> Void)?

    let collection = UICollectionView(frame: .zero, collectionViewLayout: ChooseMoneyCollectionViewLayout())

    init() {
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    func setUI() {
        backgroundColor = .white
        addSubview(collection)
    }

    func loadArrayInfo() {
        // 1.更新 collection 的 frame
        let count = array.count
        var line = count / 3
        line = count % 3 > 0 ? line + 1 : line
        let collectionWidth = UIScreen.main.bounds.width
        let collectionHeight = CGFloat(line * (35 + 15))
        collection.frame = CGRect(origin: .zero, size: CGSize(width: collectionWidth, height: collectionHeight))

        // 2.设置 collection
        collection.register(ChooseMoneyButtonCell.self, forCellWithReuseIdentifier: ChooseMoneyButtonCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .white

        // 3.刷新页面
        frame = CGRect(origin: frame.origin, size: collection.size)
        collection.reloadData()
    }

    func set(tapAction: ((String) -> Void)?) {
        self.tapAction = tapAction
    }

    /// 清空选中状态
    func clearSelectedStatus() {
        selectedIndex = -1
        collection.reloadData()
    }
}

extension ChooseMoneyButtonView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChooseMoneyButtonCell.identifier, for: indexPath) as! ChooseMoneyButtonCell
        cell.set(buttonTitle: array[indexPath.row], isSelected: indexPath.row == selectedIndex)
        return cell
    }
}

extension ChooseMoneyButtonView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        tapAction?(selectedInfo)
        collection.reloadData()
    }
}

class ChooseMoneyCollectionViewLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 1.设置 itemSize
        let buttonWidth = (UIScreen.main.bounds.width - 15 * 4) / 3
        itemSize = CGSize(width: buttonWidth + 15, height: 35 + 15)
        // 2.设置间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        // 3.设置内间距
        sectionInset = UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
    }
}
