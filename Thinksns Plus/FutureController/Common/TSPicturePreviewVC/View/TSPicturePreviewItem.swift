//
//  TSPicturePreviewCell.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import AssetsLibrary

/// cell 的代理方法
protocol TSPicturePreviewItemDelegate: class {
    /// 单击了 cell
    func itemDidSingleTaped(_ item: TSPicturePreviewItem)
    /// 长按 cell
    func itemDidLongPressed(_ item: TSPicturePreviewItem)
    /// 保存图片操作完成
    func item(_ item: TSPicturePreviewItem, didSaveImage error: Error?)
    /// 购买了某张图
    func itemFinishPaid(_ item: TSPicturePreviewItem)
    /// 保存图片
    func itemSaveImage(item: TSPicturePreviewItem)
}

struct ImageIndicator: Indicator {
    let imageView: UIImageView = UIImageView()
    func startAnimatingView() {
        view.isHidden = false
        imageView.frame = view.bounds
        // 适配长图
        let screenCenterY = UIScreen.main.bounds.height / 2
        if viewCenter.y > screenCenterY {
            imageView.frame = CGRect(x: 0, y: screenCenterY - viewCenter.y, width: view.bounds.width, height: view.bounds.height)
        }
        imageView.startAnimating()
    }

    func stopAnimatingView() {
        view.isHidden = true
        imageView.stopAnimating()
    }

    var view: IndicatorView = UIView()

    init() {
        view.frame.size = CGSize(width: 40, height: 40)
        var images: [UIImage] = []
        for index in 0...9 {
            let image = UIImage(named: "default_white0\(index)")
            if let image = image {
                images.append(image)
            }
        }
        for index in 0...9 {
            let image = UIImage(named: "default_white\(index)")
            if let image = image {
                images.append(image)
            }
        }
        imageView.animationImages = images
        imageView.animationDuration = Double(images.count * 4) / 30.0
        imageView.animationRepeatCount = 0
        imageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40 * 0.5
        view.addSubview(imageView)
    }
}

class TSPicturePreviewItem: UIView, UIScrollViewDelegate {
    weak var superVC: TSPicturePreviewVC?
    /// 图片数据模型
    var imageObject: TSImageObject?
    /// 滚动视图
    private var scrollView = UIScrollView()
    private var imageContainerView = UIView()
    var progressButton: TSProgressButton?
    /// 购买按钮
    var buttonForBuyRead: TSColorLumpButton = {
        let button = TSColorLumpButton.initWith(sizeType: .large)
        button.setTitle("购买查看", for: .normal)
        return button
    }()
    /// 成为会员按钮
    var buttonForVIP: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    /// 图片视图
    var imageView = UIImageView()
    /// 图片的位置
    var imageViewFrame: CGRect {
        return imageContainerView.frame
    }

    /// 保存图片的开关
    var canBeSave = false

    /// 代理
    weak var delegate: TSPicturePreviewItemDelegate?

    /// 占位图
    var placeholder: UIImage?
    /// 重绘大小的配置
    internal var resizeProcessor: ResizingImageProcessor {
        let scale = UIScreen.main.scale
        let pictureSize = CGSize(width: imageView.frame.width * scale, height: imageView.frame.height * scale)
        return ResizingImageProcessor(referenceSize: pictureSize, mode: .aspectFill)
    }

    // 加载图片的网络请求头
    internal let modifier = AnyModifier { request in
        var r = request
        if let authorization = TSCurrentUserInfo.share.accountToken?.token {
            r.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
        }
        return r
    }

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUI()
    }

    // MARK: - Custom user interface
    private func setUI() {
        // scrollview
        scrollView.frame = self.bounds
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 2.5
        scrollView.isMultipleTouchEnabled = true
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.alwaysBounceVertical = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }

        // imageContainer
        imageContainerView.clipsToBounds = true
        imageContainerView.backgroundColor = UIColor.white

        // imageview
        imageView.clipsToBounds = true

        // 购买按钮
        buttonForBuyRead.frame = CGRect(x: (UIScreen.main.bounds.width - 100) / 2, y: UIScreen.main.bounds.height - 35 - 65, width: 100, height: 35)
        buttonForBuyRead.addTarget(self, action: #selector(buyButtonTaped(_:)), for: .touchUpInside)
        buttonForBuyRead.isHidden = true

        // 成为会员按钮
        buttonForVIP.frame = CGRect(x: (UIScreen.main.bounds.width - 190) / 2, y: buttonForBuyRead.frame.maxY + 15, width: 190, height: 17)
        buttonForVIP.addTarget(self, action: #selector(VIPButtonTaped(_:)), for: .touchUpInside)
        buttonForVIP.isHidden = true

        // gesture
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress.minimumPressDuration = 0.3
        longPress.require(toFail: doubleTap)
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
        addGestureRecognizer(longPress)

        addSubview(scrollView)
        addSubview(buttonForBuyRead)
        addSubview(buttonForVIP)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
    }

    // MARK: - Public
    /// 加载视图
    func setInfo(_ object: TSImageObject, smallImage: UIImage?, loadGif: Bool = false) {
        /// 1.刷新布局
        imageContainerView.frame = CGRect(x:0, y:0, width: frame.width, height: imageContainerView.bounds.height)
        let imageWidth = smallImage?.size.width ?? object.width
        let imageHeight = smallImage?.size.height ?? object.height
        if imageHeight / imageWidth > UIScreen.main.bounds.height / UIScreen.main.bounds.width {
            let height = floor(imageHeight / (imageWidth / UIScreen.main.bounds.width))
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
        } else {
            var height = imageHeight / imageWidth * frame.width
            if height < 1 || height.isNaN {
                height = frame.height
            }
            height = floor(height)
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
            imageContainerView.center = CGPoint(x:self.imageContainerView.center.x, y:self.bounds.height / 2)
        }

        if imageContainerView.frame.height > frame.height && imageContainerView.frame.height - frame.height <= 1 {
            var originFrame = imageContainerView.frame
            originFrame.size.height = frame.height
            imageContainerView.frame = originFrame
        }

        scrollView.contentSize = CGSize(width: frame.width, height: max(imageContainerView.frame.height, frame.height))
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.frame.height > frame.height
        imageView.frame = imageContainerView.bounds
        // 2.加载图片
        imageObject = object
        canBeSave = false
        loadImage(placeholder: smallImage, loadGif: loadGif)

        // 1.判断图片是否需要付费

        // 2.1 查看收费（下载收费，在长按后点击了“保存到手机相册”时，进行拦截）
        if object.type == "read" && object.paid.value == false {
            // 隐藏查看大图按钮
            progressButton?.isHidden = true
            // 关闭保存图片的操作
            canBeSave = false
            // 显示购买按钮
            buttonForBuyRead.isHidden = false
            // 显示成为会员按钮
            buttonForBuyRead.isHidden = false
        }
        // 兼容处理
        // 如果只有图片，没有TSImageObject而是直接通过Image展示的情况，比如聊天列表查看大图
        if object.storageIdentity == 0 {
            self.canBeSave = true
        }
    }

    /// 保存图片
    func saveImage() {
        DispatchQueue.main.async {
            // 2. 如果不是下载付费，保存图片
            guard let imageObject = self.imageObject else {
                return
            }
            // 1. 判断图片是否为下载付费
            if imageObject.type == "download" && imageObject.paid.value == false {
                self.paidImage(isRead: false, payType: "download")
                return
            }
            // 如果是cacheKey 需要额外从缓存中读取
            if imageObject.cacheKey.isEmpty == false {
                let webpCacheSerializer = WebpCacheSerializer()
                var tempData: Data = Data()
                if imageObject.mimeType == "image/jpeg" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: imageObject.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
                        tempData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: imageObject.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
                        tempData = data
                    }
                } else if imageObject.mimeType == "image/gif" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        tempData = data
                        let library = ALAssetsLibrary()
                        let metadata = ["UTI": kUTTypeGIF as! String]
                        library.writeImageData(toSavedPhotosAlbum: data, metadata: metadata, completionBlock: { (URLString, error) in
                            self.gifImageDidFinishSavingWithError(error: error)
                        })
                        return
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        tempData = data
                    }
                } else if imageObject.mimeType == "image/png" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        tempData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.pngRepresentation() {
                        tempData = data
                    }
                }
                let image = UIImage(data: tempData)
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                if imageObject.locCacheKey.isEmpty, let placeholder = self.placeholder {
                    /// 直接保存placeHolder
                    UIImageWriteToSavedPhotosAlbum(placeholder, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    return
                }
                let webpCacheSerializer = WebpCacheSerializer()
                let imageCacheKey = imageObject.locCacheKey
                ImageCache.default.retrieveImage(forKey: imageCacheKey, options: [.cacheSerializer(webpCacheSerializer)], completionHandler: { (image, _) in
                    if imageObject.mimeType == "image/gif" {
                        if let imageData = image?.kf.gifRepresentation() {
                            let library = ALAssetsLibrary()
                            let metadata = ["UTI": kUTTypeGIF as! String]
                            library.writeImageData(toSavedPhotosAlbum: imageData, metadata: metadata, completionBlock: { (URLString, error) in
                                self.gifImageDidFinishSavingWithError(error: error)
                            })
                        } else {
                            let indicator = TSIndicatorWindowTop(state: .loading, title: "请返回后重试!")
                            indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                        }
                    } else if imageObject.mimeType == "image/jpeg" {
                        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else if imageObject.mimeType == "image/png" {
                        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                })
            }
        }
    }

    // MARK: - Private

    /// 加载图片
    func loadImage(placeholder: UIImage?, forceToRefresh: Bool = false, loadGif: Bool = false) {
        self.placeholder = placeholder

        guard let imageObject = self.imageObject else {
            return
        }
        // 原图链接
        var url = imageObject.storageIdentity.imageUrl()
        if imageObject.storageIdentity == 0 {
            /// 直接显示的图片，就不要拼接url
            /// url为空的时候，保存本地直接保存placeHolder的图片（直接传入的图片）
            url = ""
        }

        // 检查是否有原图链接
        let have100Pic = ImageCache.default.imageCachedType(forKey: url).cached
        // 如果没有原图的缓存，就显示查看大图按钮
        if !have100Pic && imageObject.storageIdentity > 0 && progressButton == nil {
            progressButton = TSProgressButton(sourceImageView: imageView, url: URL(string: url)!, superView: self)
            progressButton?.alpha = 0
        }
        if imageObject.mimeType == "image/gif" {
            progressButton?.isHidden = true
        }
        if imageObject.isLongPic() {
            progressButton?.isHidden = true
        }
        // 拼接 url
        let originalSize = CGSize(width: imageObject.width, height: imageObject.height)
        var imageUrl: String
        if imageObject.paid.value == true {
            imageUrl = url.smallPicUrl(showingSize: imageView.frame.size, originalSize: originalSize)
        } else {
            // 付费图片加载原图
            imageUrl = url.smallPicUrl(showingSize: .zero, originalSize: originalSize)
        }
        // gif图片加载原图
        if imageObject.mimeType == "image/gif" {
            imageUrl = url.smallPicUrl(showingSize: .zero, originalSize: originalSize)
        }
        if imageObject.isLongPic() {
            imageUrl = url.smallPicUrl(showingSize: .zero, originalSize: originalSize)
        }
        /// 如果url是空的，说明当前时直接显示传入的image对象，就不去下载
        if url.isEmpty {
            imageUrl = ""
        }
        if (imageObject.locCacheKey.isEmpty && imageObject.cacheKey.isEmpty) || forceToRefresh == true {
            downloadImage(imageUrl: imageUrl, forceToRefresh: forceToRefresh, loadGif: loadGif)
        } else {
            // 如果是cacheKey 需要额外从缓存中读取
            if imageObject.cacheKey.isEmpty == false {
                let webpCacheSerializer = WebpCacheSerializer()
                var tempData: Data = Data()
                if imageObject.mimeType == "image/jpeg" {
                    // 如果不是GIF的图片，就压缩一下,原始的二进制流不能直接上传，非iOS/macOS系统打不开
                    // 但是100%的转换图片会很大
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: imageObject.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
                        tempData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: imageObject.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
                        tempData = data
                    }
                } else if imageObject.mimeType == "image/gif" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        let image = UIImage.sd_tz_animatedGIF(with: data)
                        self.imageView.image = image
                        return
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        tempData = data
                    }
                } else if imageObject.mimeType == "image/png" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        tempData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: imageObject.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.pngRepresentation() {
                        tempData = data
                    }
                }
                let showImage = UIImage(data: tempData)
                self.imageView.image = showImage
            } else {
                let webpCacheSerializer = WebpCacheSerializer()
                ImageCache.default.retrieveImage(forKey: imageObject.locCacheKey, options: [.cacheSerializer(webpCacheSerializer)], completionHandler: { (image, _) in
                    if imageObject.mimeType == "image/gif" {
                        let imageData = image?.kf.gifRepresentation()
                        let image = UIImage.sd_tz_animatedGIF(with: imageData)
                        self.imageView.image = image
                    } else if imageObject.mimeType == "image/jpeg" {
                        self.imageView.image = image
                    } else if imageObject.mimeType == "image/png" {
                        self.imageView.image = image
                    }
                })
            }
        }
    }

    func downloadImage(imageUrl url: String, forceToRefresh: Bool = false, loadGif: Bool = false) {
        guard let imageUrl = URL(string: url) else {
            imageView.image = placeholder
            return
        }
        var options: KingfisherOptionsInfo = [.requestModifier(modifier)]
        if forceToRefresh {
            options.append(.forceRefresh)
        }
        if !loadGif {
            options.append(.onlyLoadFirstFrame)
            imageView.kf.indicatorType = .custom(indicator: ImageIndicator())
        } else {
            imageView.kf.indicatorType = .none
        }

        imageView.kf.setImage(with: imageUrl, placeholder: placeholder, options: options, progressBlock: nil) { [weak self] (image, error, type, aUrl) in
            guard let weakself = self else {
                return
            }
            if let image = image {
               self?.changePictureFrame(image: image)
            }
            weakself.imageObject?.locCacheKey = url
            weakself.canBeSave = true
        }
    }
    func changePictureFrame(image: UIImage?) {
        imageContainerView.frame = CGRect(x:0, y:0, width: frame.width, height: imageContainerView.bounds.height)
        let imageWidth = image!.size.width
        let imageHeight = image!.size.height
        if imageHeight / imageWidth > UIScreen.main.bounds.height / UIScreen.main.bounds.width {
            let height = floor(imageHeight / (imageWidth / UIScreen.main.bounds.width))
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
        } else {
            var height = imageHeight / imageWidth * frame.width
            if height < 1 || height.isNaN {
                height = frame.height
            }
            height = floor(height)
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
            imageContainerView.center = CGPoint(x:self.imageContainerView.center.x, y:self.bounds.height / 2)
        }
        if imageContainerView.frame.height > frame.height && imageContainerView.frame.height - frame.height <= 1 {
            var originFrame = imageContainerView.frame
            originFrame.size.height = frame.height
            imageContainerView.frame = originFrame
        }
        scrollView.contentSize = CGSize(width: frame.width, height: max(imageContainerView.frame.height, frame.height))
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.frame.height > frame.height
        imageView.frame = imageContainerView.bounds
    }

    /// 发起图片购买的操作
    func paidImage(isRead: Bool, payType: NSString) {
        guard let imageObject = imageObject else {
            return
        }
        TSPayTaskQueue.showImagePayAlertWith(imageObject: imageObject) { [weak self] (isSuccess, _) in
            guard let weakSelf = self else {
                return
            }
            guard isSuccess else {
                weakSelf.superVC?.dismiss()
                return
            }
            if payType == "download" {
                // 下载付费的类型，付费后直接保存
                if weakSelf.canBeSave == true && weakSelf.delegate != nil {
                    if weakSelf.canBeSave {
                        weakSelf.delegate!.itemSaveImage(item: weakSelf)
                    }
                }
            } else if payType == "read" {
                weakSelf.buttonForVIP.isHidden = true
                weakSelf.buttonForBuyRead.isHidden = true
                weakSelf.progressButton?.isHidden = false
                // 清理本地模糊的图片缓存
                ImageCache.default.removeImage(forKey: imageObject.cacheKey)
                // 更新界面
                weakSelf.loadImage(placeholder: UIImage.create(with: TSColor.inconspicuous.disabled, size: weakSelf.imageView.frame.size), forceToRefresh: true)
            }
            weakSelf.delegate?.itemFinishPaid(weakSelf)
        }
    }

    /// 完成了保存图片
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let delegate = delegate {
            delegate.item(self, didSaveImage: error)
        }
    }

    // GIF保存结果
    func gifImageDidFinishSavingWithError(error: Error?) {
        if let delegate = delegate {
            delegate.item(self, didSaveImage: error)
        }
    }

    // MARK: - Button click
    /// 单击 cell
    func singleTap(_ gusture: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.itemDidSingleTaped(self)
        }
    }

    /// 双击 cell
    func doubleTap(_ gusture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            // 状态还原
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = gusture.location(in: imageView)
            let newZoomScale = scrollView.maximumZoomScale
            let xsize = frame.size.width / newZoomScale
            let ysize = frame.size.height / newZoomScale

            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize / 2, y: touchPoint.y - ysize / 2, width: xsize, height: ysize), animated: true)
        }
    }

    /// 长按 cell
    func longPress(_ gusture: UILongPressGestureRecognizer) {
        if gusture.state == .began {
            if let delegate = delegate {
                if canBeSave {
                    delegate.itemDidLongPressed(self)
                }
            }
        }
    }

    /// 点击了购买按钮
    func buyButtonTaped(_ sender: TSColorLumpButton) {
        guard let imageObject = self.imageObject else {
            return
        }
        self.paidImage(isRead: true, payType: imageObject.type! as NSString)
    }

    /// 点击了成为会员按钮
    func VIPButtonTaped(_ sender: UIButton) {
        // [长期注释] 成为会员
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageContainerView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }

}
