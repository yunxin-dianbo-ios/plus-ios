//
//  PhotoPreviewVC+Toolbar.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/26.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

extension PHPreviewVC {

    func setToolbarUI() {
        view.addSubview(toolbar)
        toolbar.buttonForChoose.addTarget(self, action: #selector(selectedButtonTaped(_:)), for: .touchUpInside)
        toolbar.buttonForFinish.addTarget(self, action: #selector(finishButtonTaped), for: .touchUpInside)
    }

    // MARK: - Button click

    /// 点击了选择按钮
    func selectedButtonTaped(_ sender: UIButton) {
        guard let nav = nav() else {
            return
        }
        let selectedCell = collection.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PreviewCollectionCell
        guard let cell = selectedCell, (nav.selectedImages.count < nav.maxSelectedCount || cell.isImageSelected == true) else {
            CGLog(message: "已经选择了\(nav.selectedImages.count)张")
            return
        }
        // 更新按钮状态
        cell.isImageSelected = !cell.isImageSelected
        if cell.isImageSelected {
            // 保存图片
            nav.selectedImages.append(assetDataSource[currentIndex])

        } else {
            // 移除图片
            let index = nav.selectedImages.index(of: assetDataSource[currentIndex])
            nav.selectedImages.remove(at: index!)
        }
        updateToolbar()
    }

    /// 点击了完成按钮
    func finishButtonTaped() {
        guard let nav = nav() else {
            return
        }
        PhotosDataManager.cover(assets: nav.selectedImages, disPlayWidth: UIScreen.main.bounds.width) { [weak self] (images: [UIImage]) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.finishBlock?(images, nav.selectedImages)
            weakSelf.dismiss(animated: true, completion: nil)
        }
    }
}
