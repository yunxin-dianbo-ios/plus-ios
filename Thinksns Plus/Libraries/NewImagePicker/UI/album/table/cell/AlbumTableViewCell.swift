//
//  PhotoTableViewCell.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/22.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewCell: UITableViewCell {

    /// 重用标识
    static let identifier = "AlbumTableViewCell"

    /// 封面图片
    @IBOutlet weak var photoImageView: UIImageView!
    /// 标题
    @IBOutlet weak var labelForTitle: UILabel!
    /// 图片张数
    @IBOutlet weak var labelForCount: UILabel!

    // MAKR: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public
    func setInfo(albumModel model: AlbumModel) {
        // 1.将 album model 装换成 cell model
        let cellModel = AlbumTableCellModel(albumModel: model)

        // 2.设置相册标题
        labelForTitle.text = cellModel.title

        // 3.设置相册的张数
        labelForCount.text = "共\(cellModel.count ?? 0)张"
        guard let imageAsset = cellModel.imageAsset else {
            return
        }

        // 4.设置相册封面
        PhotosDataManager.conver(asset: imageAsset, disPlayWidth: photoImageView.bounds.width) { [weak self] (image) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.photoImageView.image = image
        }
    }

}
