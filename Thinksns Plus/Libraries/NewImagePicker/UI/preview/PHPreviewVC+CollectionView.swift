//
//  PhotoPreviewVC+CollectionView.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/26.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

extension PHPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource {

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
        return assetDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: PreviewCollectionCell.identifier, for: indexPath) as! PreviewCollectionCell
        // 获取 cell 数据
        let asset = assetDataSource[indexPath.item]
        cell.set(image: asset)

        // 设置 cell 的选中状态
        if let nav = nav() {
            let isSelected = nav.selectedImages.filter { $0.localIdentifier == asset.localIdentifier }
            cell.isImageSelected = !isSelected.isEmpty
        }

        return cell
    }
}

class PHPreviewCollectionLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()

        // 1.设置item的宽度和高度
        let collectionSize = collectionView!.frame.size
        itemSize = CGSize(width: collectionSize.width, height: collectionSize.height)

        // 2.设置其他属性
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}
