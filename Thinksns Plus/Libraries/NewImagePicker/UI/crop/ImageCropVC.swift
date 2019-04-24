//
//  ImageCropVC.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/28.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

class ImageCropVC: UIViewController, UIScrollViewDelegate {

    /// 裁切的蒙层
    let cropView: CropOverView = {
        let view = CropOverView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }()

    // 图片显示
    var imageView = UIImageView(frame: .zero)

    // 滚动视图
    var scroll: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 3.0
        scroll.clipsToBounds = false
        return scroll
    }()

    /// 图片裁切类型
    var type: ImagePickerCropType!

    /// 结束裁切后的操作
    public var finishBlock: ((UIImage) -> Void)?

    // MARK: - Lifecycle
    init(type: ImagePickerCropType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Custom user interface
    /// 设置视图
    func setUI() {
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false

        cropView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 64)
        cropView.setCrop(type: type)

        scroll.frame = cropView.cropRect!
        scroll.frame.origin.y += 0
        scroll.delegate = self

        imageView.contentMode = .scaleAspectFill

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(cropImage))

        scroll.addSubview(imageView)
        view.addSubview(scroll)
        view.addSubview(cropView)
    }

    /// 裁切图片
    func cropImage() {
        guard let image = imageView.image else {
            CGLog(message: "没有图片可以裁切")
            return
        }
        let cropRect = processCropRect()
        let cropImage = image.cropImage(rect: cropRect)
        finishBlock?(cropImage!)
    }

    // MARK: - Public

    /// 设置完成裁切的操作
    public func setFinish(operation: ((UIImage) -> Void)?) {
        finishBlock = operation
    }

    /// 设置图片
    public func setImage(image: UIImage) {
        // 1.显示图片
        imageView.image = image

        // 2.计算 imageView 和 scrollView 的布局
        let initialWidth = scroll.frame.width
        let initialHeight = scroll.frame.height

        let(imageViewSize, _, _, _) = processImageViewLayout(minimunWidth: initialWidth, minimunHeight: initialHeight, withImageSize: image.size)

        imageView.frame = CGRect(origin: CGPoint.zero, size: imageViewSize)
        scroll.contentSize = imageView.frame.size

        // 3.缩放图片，显示成 UI 图上的样子
        let zoomWidth = cropView.frame.width
        let zoomHeight = cropView.cropRect!.height + 60
        let (_, _, _, zoomScale) = processImageViewLayout(minimunWidth: zoomWidth, minimunHeight: zoomHeight, withImageSize: image.size)

        scroll.setZoomScale(zoomScale, animated: false)
        scroll.setContentOffset(CGPoint(x: (imageView.frame.width - cropView.cropRect!.width) / 2, y: (imageView.frame.height - cropView.cropRect!.height) / 2), animated: false)
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

extension ImageCropVC {

    // MARK: - 相关计算方法

    /// 计算裁切的 rect
    func processCropRect() -> CGRect {
        let offset = scroll.contentOffset
        let imageViewSize = imageView.frame.size
        let imageSize = imageView.image!.size

        var cropX: CGFloat!
        var cropY: CGFloat!
        var cropWidth: CGFloat!
        var cropHeight: CGFloat!

        if imageSize.width > imageViewSize.width {
            // 是大图
            let scaleW = imageSize.width / imageViewSize.width
            let scaleH = imageSize.height / imageViewSize.height
            cropWidth = cropView.cropRect!.width * scaleW
            cropHeight = cropView.cropRect!.height * scaleH
            cropX = offset.x * scaleW
            cropY = offset.y * scaleH
        } else {
            // 是小图
            let scaleW = imageViewSize.width / imageSize.width
            let scaleH = imageViewSize.height / imageSize.height
            cropWidth = cropView.cropRect!.width / scaleW
            cropHeight = cropView.cropRect!.height / scaleH
            cropX = offset.x / scaleW
            cropY = offset.y / scaleH
        }

        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        return cropRect
    }

    /// 根据 图片大小 计算 scrollView 和 imageView 的布局
    ///
    /// - Parameters:
    ///   - width: Ｉ型图的最小宽度
    ///   - height: 一 型图的最小高度
    ///   - imageSize: 图片大小
    /// - Returns: (imageView size, x 方向上中心偏移量, y 方向上中心偏移量, image view 与 scroll 的 zoom scale)
    func processImageViewLayout(minimunWidth width: CGFloat, minimunHeight height: CGFloat, withImageSize imageSize: CGSize) -> (CGSize, CGFloat, CGFloat, CGFloat) {

        var imageViewWidth: CGFloat
        var imageViewHeight: CGFloat
        var centerOffsetX: CGFloat = 0
        var centerOffsetY: CGFloat = 0
        var zoomScale: CGFloat = 0

        if imageSize.width > imageSize.height {
            // 一 型图
            let scaleWH = imageSize.width / imageSize.height
            // 超长的 一 型图
            imageViewHeight = height + 20
            imageViewWidth = scaleWH * imageViewHeight
            zoomScale = imageViewWidth / cropView.cropRect!.width

            // 短短的 一 型图
            if imageViewWidth < UIScreen.main.bounds.width {
                imageViewWidth = UIScreen.main.bounds.width
                imageViewHeight = imageViewWidth / scaleWH
//                zoomScale = imageViewHeight / cropView.cropRect!.height
            }
            centerOffsetX = (imageViewWidth - scroll.frame.width) / 2 * zoomScale
            centerOffsetY = (imageViewHeight - cropView.cropRect!.height) / 2 * zoomScale
        } else {
            // Ｉ型图
            let scaleHW = imageSize.height / imageSize.width
            imageViewWidth = width
            imageViewHeight = scaleHW * imageViewWidth
            centerOffsetX = (imageViewWidth - scroll.frame.width) / 2
            centerOffsetY = (imageViewHeight - scroll.frame.height) / 2
            zoomScale = cropView.frame.width / cropView.cropRect!.width
        }
        let imageViewSize = CGSize(width: imageViewWidth, height: imageViewHeight)
        return (imageViewSize, centerOffsetX, centerOffsetY, zoomScale)
    }
}
