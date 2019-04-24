//
//  PhotoCollectionVC+Toolbar.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/26.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

extension AlbumCollectionVC {

    func setToolbarUI(isToolbarShow: Bool) {
        if !isToolbarShow {
            return
        }

        toolbar = AlbumCollectionToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - TSImagePickerUX.toolBarHeight - 64, width: UIScreen.main.bounds.width, height: TSImagePickerUX.toolBarHeight))
        toolbar?.buttonForFinish.addTarget(self, action: #selector(finishButtonTaped), for: .touchUpInside)
        toolbar?.buttonForPreview.addTarget(self, action: #selector(previewButtonTaped), for: .touchUpInside)
        // 更新工具栏完成按钮的标题
        updataToolbarFinishButtonTitle()

        if toolbar?.superview == nil {
            view.addSubview(toolbar!)
        }
    }

    // MARK: - Button click

    /// 点击了预览按钮
    func previewButtonTaped() {
        guard let nav = nav(), nav.selectedImages.isEmpty == false else {
            return
        }
        let preview = PHPreviewVC(currentIndex: 0, assets: nav.selectedImages)
        preview.setFinish(operation: finishBlock)
        navigationController?.delegate = animationManager
        navigationController?.pushViewController(preview, animated: true)
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
