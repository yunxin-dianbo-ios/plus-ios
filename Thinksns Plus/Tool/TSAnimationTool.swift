//
//  TSAnimationTool.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2019/3/15.
//  Copyright © 2019年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSAnimationTool: NSObject, AnimatedImageViewDelegate {
    static let animationManager = TSAnimationTool()
    let gifPicture = AnimatedImageView()
    private override init() {
        super.init()
        gifPicture.runLoopMode = RunLoopMode.defaultRunLoopMode
        gifPicture.delegate = self
        gifPicture.contentScaleFactor = UIScreen.main.scale
        gifPicture.contentMode = .scaleAspectFill
        gifPicture.autoresizingMask = UIViewAutoresizing.flexibleHeight
        gifPicture.clipsToBounds = true
        gifPicture.repeatCount = .once
    }
    /// 当前图片容器信息
    internal var _currentPictureControl: PicturesTrellisView?
    var currentTable: PicturesTrellisView?
    /// 详情页顶部视图控件
    var detailHeaderView: TSMomentDetailHeaderView?
    /// 整个屏幕view（就是存放列表table的view）
    var allSuperView: UIView?
    /// 整个图片显示区域的图片下标
    var currentIndexGif: Int = 0
    /// 检索整个图片数组之后组装的h符合播放GIF条件的gifz数组的下标
    var gifCurrentIndex: Int = 0
    /// 存放满足播放条件的图片控件在整个图片容器里面的下标
    var gifModelIndexArr: [Int] = []
    
    // 加载图片的网络请求头
    internal let modifier = AnyModifier { request in
        var r = request
        if let authorization = TSCurrentUserInfo.share.accountToken?.token {
            r.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
        }
        return r
    }
    var options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem]()

    /// 列表
    func getGifPictures() {
         self.stopGifAnimation()
        currentIndexGif = 0
        gifCurrentIndex = 0
        gifModelIndexArr.removeAll()
        options = [.requestModifier(modifier)]
        if let trellisView = currentTable, trellisView.models.count > 0 {
            /// 判断是否有动图
            var hasGif = false
            for index in 0..<trellisView.models.count {
                if trellisView.models[index].mimeType == "image/gif" {
                    if trellisView.models[index].paidInfo?.type == .pictureSee {
                        /// 需要付费的不处理（没有付费的）
                    } else {
                        if let superView = allSuperView {
                            let coverPoint = trellisView.pictureViews[index].convert(CGPoint(x: 0, y: 0), to: superView)
                            if coverPoint.y < 0 {
                                if coverPoint.y + trellisView.pictureViews[index].frame.size.height * 0.2 >= 0 {
                                    gifModelIndexArr.append(index)
                                }
                            } else {
                                if coverPoint.y + trellisView.pictureViews[index].frame.size.height * 0.8 <= superView.frame.size.height {
                                    gifModelIndexArr.append(index)
                                }
                            }
                        }
                    }
                }
            }
            if gifModelIndexArr.count <= 0 {
                return
            }
            currentIndexGif = gifModelIndexArr[gifCurrentIndex]
            if trellisView.models[currentIndexGif] != nil {
                trellisView.addSubview(gifPicture)
                gifPicture.frame = trellisView.pictureViews[currentIndexGif].frame
                gifPicture.kf.setImage(with: URL(string: trellisView.models[currentIndexGif].url ?? ""), placeholder: trellisView.pictureViews[currentIndexGif].pictureView.image, options: options, progressBlock: nil) { (image, error, cacheType, imageURL) in
                    if trellisView.models[self.currentIndexGif].mimeType == "image/gif" {
                        if let image = image {
                            self.gifPicture.image = image.images?.last
                            self.gifPicture.image = image
                            ImageCache.default.clearMemoryCache()
                        } else {
                            self.gifPicture.image = nil
                        }
                    } else {
                        self.gifPicture.image = nil
                    }
                }
            }
        }
    }

    /// 详情页
    func getDetailGifPictures() {
        self.stopGifAnimation()
        currentIndexGif = 0
        gifCurrentIndex = 0
        gifModelIndexArr.removeAll()
        options = [.requestModifier(modifier)]
        if let trellisView = detailHeaderView {
            /// 判断是否有动图
            let images = trellisView.object.pictures.filter { (object) -> Bool in
                return object.width > 0 && object.height > 0
            }
            var hasGif = false
            for index in 0..<images.count {
                if images[index].mimeType == "image/gif" {
                    if images[index].payType == 2 {
                        /// 需要付费的不处理（没有付费的）
                    } else {
                        if let superView = allSuperView {
                            if let detailImageButton = trellisView.viewWithTag(trellisView.tagForImageButton + index) {
                                let coverPoint = detailImageButton.convert(CGPoint(x: 0, y: 0), to: superView)
                                if coverPoint.y < 0 {
                                    if coverPoint.y + detailImageButton.frame.size.height * 0.2 >= 0 {
                                        gifModelIndexArr.append(index)
                                    }
                                } else {
                                    if coverPoint.y + detailImageButton.frame.size.height * 0.8 <= superView.frame.size.height {
                                        gifModelIndexArr.append(index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if gifModelIndexArr.count <= 0 {
                return
            }
            currentIndexGif = gifModelIndexArr[gifCurrentIndex]
            if images[currentIndexGif] != nil {
                trellisView.addSubview(gifPicture)
                if let detailImageButton = trellisView.viewWithTag(trellisView.tagForImageButton + currentIndexGif) {
                    gifPicture.frame = detailImageButton.frame
                    gifPicture.kf.setImage(with: URL(string: images[currentIndexGif].storageIdentity.imageUrl()), placeholder: nil, options: options, progressBlock: nil) { (image, error, cacheType, imageURL) in
                        if images[self.currentIndexGif].mimeType == "image/gif" {
                            if let image = image {
                                self.gifPicture.image = image.images?.last
                                self.gifPicture.image = image
                                ImageCache.default.clearMemoryCache()
                            } else {
                                self.gifPicture.image = nil
                            }
                        } else {
                            self.gifPicture.image = nil
                        }
                    }
                }
            }
        }
    }

    func animatedImageView(_ imageView: AnimatedImageView, didPlayAnimationLoops count: UInt) {
    }

    func animatedImageViewDidFinishAnimating(_ imageView: AnimatedImageView) {
        if let trellisView = currentTable {
            if gifModelIndexArr.count > 0 {
                if gifModelIndexArr.count == 1 {
                    self.stopGifAnimation()
                } else {
                    if gifCurrentIndex >= gifModelIndexArr.count - 1 {
                        gifCurrentIndex = 0
                    } else {
                        gifCurrentIndex = gifCurrentIndex + 1
                    }
                    currentIndexGif = gifModelIndexArr[gifCurrentIndex]
                }
                if trellisView.models[currentIndexGif] != nil {
                    gifPicture.frame = trellisView.pictureViews[currentIndexGif].frame
                    gifPicture.kf.setImage(with: URL(string: trellisView.models[currentIndexGif].url ?? ""), placeholder: trellisView.pictureViews[currentIndexGif].pictureView.image, options: options, progressBlock: nil) { (image, error, cacheType, imageURL) in
                        if trellisView.models[self.currentIndexGif].mimeType == "image/gif" {
                            if let image = image {
                                self.gifPicture.image = image.images?.last
                                self.gifPicture.image = image
                                ImageCache.default.clearMemoryCache()
                            } else {
                                self.gifPicture.image = nil
                            }
                        } else {
                            self.gifPicture.image = nil
                        }
                    }
                }
            }
        } else if let trellisView = detailHeaderView {
            if gifModelIndexArr.count > 0 {
                if gifModelIndexArr.count == 1 {
                    self.stopGifAnimation()
                } else {
                    if gifCurrentIndex >= gifModelIndexArr.count - 1 {
                        gifCurrentIndex = 0
                    } else {
                        gifCurrentIndex = gifCurrentIndex + 1
                    }
                    currentIndexGif = gifModelIndexArr[gifCurrentIndex]
                }
                let images = trellisView.object.pictures.filter { (object) -> Bool in
                    return object.width > 0 && object.height > 0
                }
                if images[currentIndexGif] != nil {
                    if let detailImageButton = trellisView.viewWithTag(trellisView.tagForImageButton + currentIndexGif) {
                        gifPicture.frame = detailImageButton.frame
                        gifPicture.kf.setImage(with: URL(string: images[currentIndexGif].storageIdentity.imageUrl()), placeholder: nil, options: options, progressBlock: nil) { (image, error, cacheType, imageURL) in
                            if images[self.currentIndexGif].mimeType == "image/gif" {
                                if let image = image {
                                    self.gifPicture.image = image.images?.last
                                    self.gifPicture.image = image
                                    ImageCache.default.clearMemoryCache()
                                } else {
                                    self.gifPicture.image = nil
                                }
                            } else {
                                self.gifPicture.image = nil
                            }
                        }
                    }
                }
            }
        }
    }

    func stopGifAnimation() {
        if self.gifPicture.image == nil {
            return
        }
        self.gifPicture.image = nil
    }

    /// 置空两种类型的图片容器
    func resetGifSuperView() {
        if currentTable != nil {
            currentTable = nil
        }
        if detailHeaderView != nil {
            detailHeaderView = nil
        }
    }

    /// 优化单列停止动画的逻辑 *不知道这里应不应该销毁这个 gifPicture 单列应该不占内存吧
    func stopCurrentAnimation() {
        if let _ = gifPicture.superview {
            gifPicture.image = nil
            gifPicture.removeFromSuperview()
        }
    }
}
