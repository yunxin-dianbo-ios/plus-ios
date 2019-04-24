//
//  TSPopularCityCollectionView.swift
//  date
//
//  Created by Fiction on 2017/8/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  热门城市数据展示CollectionView

import UIKit

protocol TSPopularCityCollectionViewDelegate: NSObjectProtocol {
    /// 代理，返回给上级页面一个string
    /// - TSPopularCityCollectionViewDelegate
    func stringOfPopularCityCollectionRow(str: String)

    /// 代理，返回collectionview的ContentSizeHight
    /// - TSPopularCityCollectionViewDelegate
    func selfContentSizeHight(hight: CGFloat)
}

class TSPopularCityCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    /// 数据源
    var popularCityDataSource: Array<String> = []

    weak var TSPopularCityCollectionViewDelegate: TSPopularCityCollectionViewDelegate? = nil

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        self.backgroundColor = TSColor.main.white
        self.dataSource = self
        self.delegate = self
        self.register(TSUserInfoCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.register(TSPopularCityReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularCityDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TSUserInfoCollectionViewCell
        let str = popularCityDataSource[indexPath.row]
        let arry = str.components(separatedBy: " ")
        cell?.contentViewLabel.text = arry.last
        let height = self.contentSize.height
        self.TSPopularCityCollectionViewDelegate?.selfContentSizeHight(hight: height)
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! TSPopularCityReusableView
        if indexPath.section == 0 {
            headerView.setTitle(text: "热门城市")
        }
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let str = popularCityDataSource[indexPath.row]
        self.TSPopularCityCollectionViewDelegate?.stringOfPopularCityCollectionRow(str: str)
    }

    /// 外部调用改变数据源方法
    ///
    /// - Parameter data: 传入的数据源
    func changeDataSource(data: Array<String>) {
        self.popularCityDataSource.removeAll()
        self.popularCityDataSource = data
        self.reloadData()
    }
}
