//
//  TSCertificatePreviewImageCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSCertificatePreviewImageCell: UICollectionViewCell {

    static let identifier = "TSCertificatePreviewImageCell"

    // 图片
    @IBOutlet weak var imageView: UIImageView!

    func set(image imageId: Int?) {
        let imageURL = TSURLPath.imageV2URLPath(storageIdentity: imageId, compressionRatio: nil, cgSize: frame.size)
        imageView.kf.setImage(with: imageURL)
    }
}
