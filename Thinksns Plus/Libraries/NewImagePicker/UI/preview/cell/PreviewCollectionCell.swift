//
//  PreviewCollectionCell.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/25.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import  Photos

class PreviewCollectionCell: UICollectionViewCell, UIScrollViewDelegate {

    /// 重用标识
    static let identifier = "PreviewCollectionCell"

    /// 是否已经被选中
    var isImageSelected = false

    /// 滚动视图
    var scrollow: UIScrollView = {
        let scrollowView = UIScrollView()
        scrollowView.backgroundColor = UIColor.white
        scrollowView.maximumZoomScale = 3.0
        scrollowView.minimumZoomScale = 0.5
        return scrollowView
    }()

    /// 图片视图
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Custom user interface
    func setUI() {
        scrollow.delegate = self
        scrollow.frame = CGRect(origin: CGPoint.zero, size: contentView.frame.size)
        contentView.backgroundColor = UIColor.white
        scrollow.addSubview(imageView)
        contentView.addSubview(scrollow)
    }

    // 重置视图
    func resetViews() {
        scrollow.contentSize = CGSize.zero
        scrollow.contentInset = UIEdgeInsets.zero
        imageView.transform = .identity
    }

    // MARK: - Public

    /// 设置图片
    func set(image asset: PHAsset?) {
        resetViews()
        guard let asset = asset else {
            return
        }
        // 判断是不是GIF
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        manager.requestImageData(for: asset, options: option) { (imageData, type, orientation, info) in
            DispatchQueue.main.async {
                self.imageView.image = nil
                if type == kUTTypeGIF as String {
                    let image = UIImage.sd_tz_animatedGIF(with: imageData)
                    self.imageView.image = image
                } else {
                    // 原图显示，会占用很大的内存
                    let image = UIImage.init(data: imageData!)
                    self.imageView.image = image
                }
                // 2.设置 imageView
                let scaleHW = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
                let width = self.frame.width
                let height = width * scaleHW
                let imageViewSize = CGSize(width: width, height: height)
                self.imageView.frame = CGRect(origin: CGPoint.zero, size: imageViewSize)
    
                // 3.判断是长图还是短图
                let scrollowHeight = self.scrollow.frame.height
                if height > scrollowHeight {
                    // 长图，不需要居中
                    self.scrollow.contentSize = imageViewSize
                } else {
                    // 短图，居中
                    let offSetY = (scrollowHeight - height) * 0.5
                    self.scrollow.contentInset = UIEdgeInsets(top: offSetY, left: 0, bottom: offSetY, right: 0)
                }
            }
        }

//        // 1.将 asset 转化成 image
//        PhotosDataManager.conver(asset: asset, disPlayWidth: frame.width) { [weak self] (image) in
//
//            guard let image = image, let weakSelf = self else {
//                return
//            }
//
//            // 2.设置 imageView
//            let scaleHW = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
//            let width = weakSelf.frame.width
//            let height = width * scaleHW
//            let imageViewSize = CGSize(width: width, height: height)
//            weakSelf.imageView.frame = CGRect(origin: CGPoint.zero, size: imageViewSize)
//            weakSelf.imageView.image = image
//
//            // 3.判断是长图还是短图
//            let scrollowHeight = weakSelf.scrollow.frame.height
//            if height > scrollowHeight {
//                // 长图，不需要居中
//                weakSelf.scrollow.contentSize = imageViewSize
//            } else {
//                // 短图，居中
//                let offSetY = (scrollowHeight - height) * 0.5
//                weakSelf.scrollow.contentInset = UIEdgeInsets(top: offSetY, left: 0, bottom: offSetY, right: 0)
//            }
//
//        }
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // 设置 imageView 进行缩放
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 1.计算 inset
        let viewSize = frame.size
        let imageViewSize = imageView.frame.size

        var offsetX = (viewSize.width - imageViewSize.width) / 2
        var offsetY = (viewSize.height - imageViewSize.height) / 2

        offsetX = offsetX < 0 ? 0 : offsetX
        offsetY = offsetY < 0 ? 0 : offsetY

        // 2.通过 contentInset 调整
        scrollow.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
