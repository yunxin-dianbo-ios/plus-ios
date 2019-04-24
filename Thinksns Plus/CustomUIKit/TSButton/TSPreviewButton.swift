//
//  TSPreviewButton.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片预览按钮
//  可以加载图片，设置了占位图和背景颜色
//  使用位置：动态列表九宫格、动态详情中的图片按钮

import UIKit
import Kingfisher
import RealmSwift

extension UIControl {
    /// 重绘大小的配置
    internal var resizeProcessor: ResizingImageProcessor {
        let scale = UIScreen.main.scale
        let pictureSize = CGSize(width: frame.width * scale, height: frame.height * scale)
        return ResizingImageProcessor(referenceSize: pictureSize, mode: .aspectFill)
    }

}

class TSPreviewButton: UIButton {
    /// 显示头像用户唯一标识
    ///
    /// - Note: 设置用户ID后,会根据ID显示用户头像
    var imageObject: TSImageObject? {
        didSet {
            setImage()
        }
    }

    /// 是否显示长图标识
    var showLongIcon: Bool = false {
        didSet {
            setLongIcon()
        }
    }

    /// 长图标识
    private let longIcon = UIImageView()

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
        setUI()
        setNotification()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PaidImage.buyPic, object: nil)
    }

    // MARK: - Custom user interface 
    func setUI() {
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
        imageView?.contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    /// 设置长图标识显示
    func setLongIcon() {
        if showLongIcon, longIcon.superview == nil {
            let image = UIImage(named: "IMG_pic_longpic")
            longIcon.image = image
            longIcon.sizeToFit()
            let iconX = frame.width - longIcon.width
            let iconY = frame.height - longIcon.height
            longIcon.frame = CGRect(origin: CGPoint(x: iconX, y: iconY), size: longIcon.size)
            addSubview(longIcon)
            bringSubview(toFront: longIcon)
        }
        if showLongIcon == false {
            longIcon.removeFromSuperview()
        }
    }

    /// 设置图片加载
    func setImage(forceToRefresh: Bool = false) {
        guard let imageObject = imageObject else {
            return
        }
        // 1. 拼接 url
        let originalSize = CGSize(width: imageObject.width, height: imageObject.height)
        let url = imageObject.storageIdentity.imageUrl()
        let imageUrl: String
        if imageObject.paid.value == true {
            imageUrl = url.smallPicUrl(showingSize: frame.size, originalSize: originalSize)
        } else {
            // 付费图片加载原图
            imageUrl = url.smallPicUrl(showingSize: .zero, originalSize: originalSize)
        }
        downloadImage(imageUrl: imageUrl, forceToRefresh: forceToRefresh)
    }

    /// 更新监听的 token
    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(forceRefreshImage(notification:)), name: NSNotification.Name.PaidImage.buyPic, object: nil)
    }

    func forceRefreshImage(notification: Notification) {
        guard let userInfo = notification.userInfo, let url = userInfo["url"] as? String, let imageObject = imageObject else {
            return
        }
        if url == imageObject.storageIdentity.imageUrl() {
            setImage(forceToRefresh: true)
        }
    }

    // MARK: - 下载

    /// 下载图片
    func downloadImage(imageUrl url: String, forceToRefresh: Bool) {
        guard let imageUrl = URL(string: url) else {
            return
        }
        var options: KingfisherOptionsInfo = [.requestModifier(modifier), .processor(resizeProcessor)]
        if forceToRefresh {
            options.append(.forceRefresh)
        }
        self.kf.setImage(with: imageUrl, for: .normal, placeholder: placeholderImage, options: options, progressBlock: nil, completionHandler: nil)
    }

    // MARK: - 其他

    /// 获取占位图
    var placeholderImage: UIImage? {
        /*  一般情况下，占位图是一张灰色的图片
            但对于刚刚发布的带图的动态，是可以获取本地的图片，来作为占位图的 */
        // 1. 创建一张灰色的图片
        var placeholderImage = UIImage.create(with: TSColor.inconspicuous.disabled, size: frame.size)
        // 2. 检查有没有本地资源图片
        if let cacheKey = imageObject?.cacheKey {
            // 2.1. 取出本地资源的图片
            let sourceImage = ImageCache.default.retrieveImageInDiskCache(forKey: cacheKey, options: nil)
            guard let loacalImage = sourceImage else {
                return placeholderImage
            }
            placeholderImage = loacalImage
        }
        return placeholderImage
    }

}
