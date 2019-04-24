//
//  ATagsController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  tags 选择视图控制器

import UIKit

class ATagsController: UIViewController, LoadingViewDelegate {

    // 列表
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 5 * 15) / 4, height: 30)
       return UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64), collectionViewLayout: layout)
    }()

    /// 数据
    var datas: [ATagModel] = []

    /// tag 点击事件
    var tapAction: ((ATagModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        view.backgroundColor = .white

        // 1.collection
        collection.backgroundColor = .white
        collection.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collection.register(TSNewsTagSelectCell.self, forCellWithReuseIdentifier: "TSNewsTagSelectCell")
        collection.delegate = self
        collection.dataSource = self
        view.addSubview(collection)
    }

}

extension ATagsController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "TSNewsTagSelectCell", for: indexPath) as! TSNewsTagSelectCell
        cell.title = datas[indexPath.row].name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapAction?(datas[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}
