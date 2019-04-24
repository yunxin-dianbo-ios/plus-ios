//
//  TSImagePickerCell.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/15.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

protocol AlbumCollectionCellDelegate: class {
    func cell(_ cell: AlbumCollectionCell, didClickSelectButton selectButton: UIButton)
}

class AlbumCollectionCell: UICollectionViewCell {

    /// 代理
    weak var delegate: AlbumCollectionCellDelegate?

    @IBOutlet weak var imageForPhoto: UIImageView!
    /// 数据
    @IBOutlet weak var buttonForSelect: UIButton!
    var model: PHAsset?

    static let identifer = "AlbumCollectionCell"

    override func awakeFromNib() {
        buttonForSelect.addTarget(self, action: #selector(selectButtonTaped(_:)), for: .touchUpInside)
    }

    /// 选择按钮点击事件
    func selectButtonTaped(_ sender: UIButton) {
        delegate?.cell(self, didClickSelectButton: sender)
    }

    // MARK: - Public

    /// 设置 model 信息
    func setInfo(_ model: PHAsset) {
        self.model = model

        // 加载 model 的信息
        PhotosDataManager.conver(asset: model, disPlayWidth: imageForPhoto.bounds.width) { [weak self] (image: UIImage?) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.imageForPhoto.image = image
        }
    }
}
