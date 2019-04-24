//
//  CustomPHPreViewVC+Collection.swift
//  ImagePicker
//
//  Created by GorCat on 2017/7/8.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

extension CustomPHPreViewVC: UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - UI
    func setCollcetionUI() {
        let height = view.frame.height - TSImagePickerUX.toolBarHeight - 64
        collection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: height))
        collection.delegate = self
        collection.dataSource = self
        collection.register(PreviewCollectionCell.self, forCellWithReuseIdentifier: PreviewCollectionCell.identifier)

        if collection.superview == nil {
            view.addSubview(collection)
        }
    }

    // MARK: - Delegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: PreviewCollectionCell.identifier, for: indexPath) as! PreviewCollectionCell
        // 获取 cell 数据
        let asset = allAssets[indexPath.item]
        cell.set(image: asset)

        // 设置 cell 的选中状态
        let isSelected = selectedAssets.filter { $0.localIdentifier == asset.localIdentifier }
        cell.isImageSelected = !isSelected.isEmpty

        return cell
    }
}
