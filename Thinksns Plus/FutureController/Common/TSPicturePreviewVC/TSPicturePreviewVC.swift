//
//  TSPicturePreviewVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

class TSPicturePreviewVC: TSViewController, UIScrollViewDelegate, TSPicturePreviewItemDelegate, TSCustomAcionSheetDelegate {

    /// 判断是否有图片查看器正在显示
    static var isShowing = false

    /// 图片数据
    var imageObjects: [TSImageObject] = []
    /// 图片位置
    var smallImagesFrame: [CGRect] = []
    /// 图片
    var smallImages: [UIImage?] = []

    /// 当前页数
    var currentPage: Int = 0
    /// 图片 item 的 tag
    let tagForScrollowItem = 200

    /// scroll view
    let scrollow = UIScrollView()
    /// 分页控制器
    let pageControl = UIPageControl(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 6))
    /// 保存图片弹窗
    var alert: TSCustomActionsheetView?
    /// 动画 ImageView
    let animationImageView = UIImageView()
    var previewItem: TSPicturePreviewItem?

    // 补丁属性，在视图 dismiss 的时候回调
    var dismissBlock: (() -> Void)?
    /// 购买了图片的回调
    var paidBlock: ((Int) -> Void)?
    /// 原app是否隐藏
    var isAppHiddenStatusbar = false
    /// 是否显示动画
    var isEnableAnimation = true

    // MARK: - Lifecycle
    init(objects: [TSImageObject], imageFrames: [CGRect], images: [UIImage?], At index: Int) {
        super.init(nibName: nil, bundle: nil)
        imageObjects = objects
        smallImages = images
        smallImagesFrame = imageFrames
        currentPage = index
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollow.backgroundColor = UIColor.red
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollow.setContentOffset(CGPoint(x: CGFloat(currentPage) * self.view.bounds.width, y: 0), animated: false)
        isAppHiddenStatusbar = UIApplication.shared.isStatusBarHidden
        /// 默认不显示状态栏
        UIApplication.shared.setStatusBarHidden(true, with: .none)
    }

    // MARK: - Custom user interface
    func setUI() {
        // 限制图片显示的数量
        let imageCount = imageObjects.count

        self.automaticallyAdjustsScrollViewInsets = false
        scrollow.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        scrollow.backgroundColor = UIColor.black
        scrollow.showsHorizontalScrollIndicator = false
        scrollow.contentOffset = CGPoint.zero
        scrollow.delegate = self
        scrollow.bounces = false
        scrollow.isPagingEnabled = true
        scrollow.contentSize = CGSize(width: self.view.bounds.width * CGFloat(imageCount), height: self.view.bounds.height)
        for index in 0..<imageCount {
            previewItem = TSPicturePreviewItem(frame: CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            previewItem!.delegate = self
            previewItem?.superVC = self
            previewItem!.tag = tagForScrollowItem + index
            if smallImages.count > 0, smallImages.count > index, let smallImage = smallImages[index] {
                if currentPage == index {
                    previewItem!.setInfo(imageObjects[index], smallImage: smallImage, loadGif: true)
                } else {
                    previewItem!.setInfo(imageObjects[index], smallImage: smallImage)
                }
            } else {
                if currentPage == index {
                    previewItem!.setInfo(imageObjects[index], smallImage: nil, loadGif: true)
                } else {
                    previewItem!.setInfo(imageObjects[index], smallImage: nil)
                }
            }
            scrollow.addSubview(previewItem!)
        }
        // page control
        pageControl.numberOfPages = imageObjects.count
        pageControl.currentPage = currentPage
    }

    /// 设置显示的动画视图
    func setShowAnimationUX() {
        view.backgroundColor = UIColor.clear
        if smallImagesFrame.count > 0 && smallImages.count > 0 {
            animationImageView.frame = smallImagesFrame[currentPage]
            animationImageView.image = smallImages[currentPage]
            animationImageView.isHidden = false
        } else {
            animationImageView.image = nil
            animationImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            animationImageView.isHidden = true
        }
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.backgroundColor = TSColor.inconspicuous.disabled
        view.addSubview(animationImageView)
    }

    /// 设置隐藏的动画视图
    func setDismissAnimationUX() {
        let item = getPicturePreviewItem(at: currentPage)
        let imageViewFrame = item.imageViewFrame
        animationImageView.frame = imageViewFrame
        animationImageView.image = item.imageView.image
        view.backgroundColor = UIColor.black
        view.addSubview(animationImageView)
        scrollow.removeFromSuperview()
        pageControl.removeFromSuperview()
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        currentPage = Int(round(offset.x / self.view.bounds.width))
        pageControl.currentPage = currentPage
        print("\(currentPage)")

        let preview = scrollow.viewWithTag(currentPage + tagForScrollowItem) as? TSPicturePreviewItem
        let value = offset.x / self.view.bounds.width - CGFloat((preview!.tag - tagForScrollowItem))
            if value != 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    preview?.progressButton?.alpha = 0
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    preview?.progressButton?.alpha = 1
                })
            }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        currentPage = Int(round(offset.x / self.view.bounds.width))
        pageControl.currentPage = currentPage
        ImageCache.default.clearMemoryCache()
        for index in 0..<imageObjects.count {
            imageObjects[index].locCacheKey = ""
            imageObjects[index].set(shouldChangeCache: true)
            if let preview = scrollow.viewWithTag(index + tagForScrollowItem) as? TSPicturePreviewItem {
                if smallImages.count > 0, smallImages.count > index, let smallImage = smallImages[index] {
                    if pageControl.currentPage == index {
                        preview.setInfo(imageObjects[index], smallImage: smallImage, loadGif: true)
                    } else {
                        preview.setInfo(imageObjects[index], smallImage: smallImage)
                    }
                } else {
                    if pageControl.currentPage == index {
                        preview.setInfo(imageObjects[index], smallImage: nil, loadGif: true)
                    } else {
                        preview.setInfo(imageObjects[index], smallImage: nil)
                    }
                }
            }
        }
    }

    // MARK: TSPicturePreviewItemDelegate
    /// 单击 cell
    func itemDidSingleTaped(_ cell: TSPicturePreviewItem) {
        dismiss()
    }

    /// 长按 cell
    func itemDidLongPressed(_ cell: TSPicturePreviewItem) {
        guard alert?.superview == nil else {
            return
        }
        alert = TSCustomActionsheetView(titles: ["保存至相册"])
        alert!.delegate = self
        alert!.show()
    }

    /// 完成了保存图片
    func item(_ item: TSPicturePreviewItem, didSaveImage error: Error?) {
        let indicator = TSIndicatorWindowTop(state: error == nil ? .success : .faild, title: error == nil ? "提示信息_图片保存成功".localized : "提示信息_图片保存失败".localized)
        indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    /// 购买了某张图片
    func itemFinishPaid(_ item: TSPicturePreviewItem) {
        paidBlock?(currentPage)
    }

    /// 代理直接执行保存图片
    func itemSaveImage(item: TSPicturePreviewItem) {
        self.saveImage()
    }

    /// 执行保存图片
    func saveImage() {
        // 检查写入相册的授权
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        if photoStatus == .authorized {
            toSaveImage()
            return
        }
        if photoStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ [weak self] (newState) in
                guard newState == .authorized else {
                    return
                }
                self?.toSaveImage()
            })
            return
        }

        if photoStatus == .denied || photoStatus == .restricted {
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
        }
    }

    // MARK: TSCustomAcionSheetDelegate
    /// 点击 "保存图片"
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if index == 0 {
            self.saveImage()
        }
    }

    func toSaveImage() {
        if let item = scrollow.viewWithTag(tagForScrollowItem + currentPage) as? TSPicturePreviewItem {
            item.saveImage()
        }
    }

    // MARK: - Public

    /// 过渡动画的时间
    let transitionAnimationTimeInterval: TimeInterval = 0.3

    /// 显示图片查看器
    func show() {
        if TSPicturePreviewVC.isShowing {
            return
        }
        TSPicturePreviewVC.isShowing = true
        self.view.frame = UIScreen.main.bounds
        UIApplication.topViewController()?.addChildViewController(self)
        UIApplication.topViewController()?.view.addSubview(self.view)
        setShowAnimationUX()
        let item = getPicturePreviewItem(at: currentPage)
        item.progressButton?.alpha = 1
        /// ST Todo
        if isEnableAnimation {
            UIView.animate(withDuration: transitionAnimationTimeInterval, animations: {
                self.animationImageView.frame = item.imageViewFrame
                self.view.backgroundColor = UIColor.black
            }) { (_) in
                self.view.addSubview(self.scrollow)
                if self.imageObjects.count > 1 {
                    self.view.addSubview(self.pageControl)
                }
                self.animationImageView.removeFromSuperview()
            }
        } else {
            self.animationImageView.frame = CGRect(x: ScreenWidth / 4, y: ScreenHeight / 4, width: ScreenWidth / 2, height: ScreenHeight / 2)
            UIView.animate(withDuration: transitionAnimationTimeInterval, animations: {
                self.animationImageView.frame = item.imageViewFrame
                self.view.backgroundColor = UIColor.black
            }) { (_) in
                self.view.addSubview(self.scrollow)
                if self.imageObjects.count > 1 {
                    self.view.addSubview(self.pageControl)
                }
                self.animationImageView.removeFromSuperview()
            }
        }
    }

    /// 隐藏图片查看器
    func dismiss() {
        UIApplication.shared.setStatusBarHidden(isAppHiddenStatusbar, with: .none)
        
        TSPicturePreviewVC.isShowing = false
        setDismissAnimationUX()
        if isEnableAnimation {
            UIView.animate(withDuration: transitionAnimationTimeInterval, animations: {
                if self.smallImagesFrame.count > 0, self.smallImagesFrame.count > self.currentPage {
                    self.animationImageView.frame = self.smallImagesFrame[self.currentPage]
                } else {
                    self.animationImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
                }
                self.view.backgroundColor = UIColor.clear
                self.animationImageView.alpha = 0.3
            }) { (_) in
                self.dismissBlock?()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        } else {
            UIView.animate(withDuration: transitionAnimationTimeInterval, animations: {
                self.animationImageView.frame = CGRect(x: ScreenWidth / 4, y: ScreenHeight / 4, width: ScreenWidth / 2, height: ScreenHeight / 2)
                self.view.backgroundColor = UIColor.clear
                self.animationImageView.alpha = 0.9
            }) { (_) in
                self.dismissBlock?()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }
    }

    // MARK: - Private

    /// 获取图片查看器的图片位置
    func getPicturePreviewItem(at index: Int) -> TSPicturePreviewItem {
        let item = (scrollow.viewWithTag(tagForScrollowItem + currentPage) as? TSPicturePreviewItem)!
        return item
    }
}
