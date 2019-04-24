//
//  TSIndicatorWindowTop.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  窗口上方弹窗
//  样式参见 iOS 设计图中“05_个人中心/标注/9-编辑个人简介-操作反馈_PxCook”

import UIKit

enum LoadingState {
    case success
    case faild
    case loading
}

class TSIndicatorWindowTop: UIView {

    /// 默认的弹窗显示时间
    static let defaultShowTimeInterval = 1
    /// 原始状态栏状态
    var originalStatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.default
    /// 信息状态，为 success 表示成功信息，显示蓝色图标；为 faild 表示失败信息，显示红色图标；为 loading 表示加载中，显示小菊花
    var loadingState: LoadingState = .success
    /// 标题
    var _title: String?
    var title: String? {
        set(newValue) {
            _title = newValue
            if let newValue = newValue {
                set(title: newValue)
            }
        }
        get {
            return _title
        }
    }

    /// 状态图标
    let imageViewForState = UIImageView()
    /// 标题
    let labelForTitle = TSLabel()

    /// 中心位置
    var midY: CGFloat = 0

    init(state: LoadingState, title: String?) {
        super.init(frame: CGRect(x: 0, y: -TSNavigationBarHeight, width: UIScreen.main.bounds.width, height: TSNavigationBarHeight))
        loadingState = state
        setUI()
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface

    /// 设置视图
    func setUI() {
        backgroundColor = UIColor.white
        midY = (frame.height - TSStatusBarHeight) / 2 + TSStatusBarHeight

        // state image
        var imageSize: CGSize = .zero
        switch loadingState {
        case .success: // 成功，显示蓝色图标
            let stateImage = UIImage(named: "IMG_msg_box_succeed")!
            imageSize = stateImage.size
            imageViewForState.image = stateImage
        case .faild: // 失败，显示红色图标
            let stateImage = UIImage(named: "IMG_msg_box_remind")!
            imageSize = stateImage.size
            imageViewForState.image = stateImage
        case .loading: // 加载中，显示小菊花
            var images: [UIImage] = []
            for index in 0...9 {
                let image = UIImage(named: "IMG_default_grey00\(index)")
                imageSize = image!.size
                if let image = image {
                    images.append(image)
                }
            }
            imageViewForState.animationImages = images
            imageViewForState.animationDuration = Double(images.count) / 24.0
            imageViewForState.animationRepeatCount = 0
        }
        imageViewForState.contentMode = .center
        imageViewForState.frame = CGRect(x: 15, y: midY - imageSize.height / 2, width: imageSize.height, height: imageSize.height)

        // title label
        labelForTitle.font = UIFont.systemFont(ofSize: TSFont.Title.indicator.rawValue)
        labelForTitle.numberOfLines = 0
        labelForTitle.textColor = TSColor.normal.content
        // shawdow
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)

        addSubview(imageViewForState)
        addSubview(labelForTitle)
    }

    // MAKR: - Public

    /// 默认动画时间
    private let showAnimationTimeInterval = TimeInterval(1)

    /// 展示显示器
    func show() {
        show(timeInterval: nil)
    }

    func show(timeInterval: Int?, complete: (() -> Void)? = nil) {
        if superview != nil {
            return
        }
        if loadingState == .loading {
            imageViewForState.startAnimating()
        }
        originalStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.isStatusBarHidden = false
        let _ = UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: showAnimationTimeInterval, delay: 0, usingSpringWithDamping: 4, initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }) { (_) in
            self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            if let timeInterval = timeInterval {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timeInterval * 1_000), execute: { [weak self] in
                    if let weakSelf = self {
                        weakSelf.dismiss()
                        complete?()
                    }
                })
            }
        }
    }

    /// 隐藏显示器
    func dismiss() {
        if self.superview == nil {
            return
        }
        UIView.animate(withDuration: TimeInterval(0.4), animations: {
            self.frame = CGRect(x: 0, y: -self.frame.height, width: self.frame.width, height: self.frame.height)
        }) { (_) in
            // 还原原始的栏状态状态
            // 暂时不还原是否隐藏状态栏
            // 如果A页面有状态栏->展示B页面没有状态栏->弹窗，迅速推出B页面，此时B页面的状态栏会被隐藏，很影响页面显示
            // 比如：动态列表-查看图片-保存图片-迅速关闭预览页面，弹窗消失后会导致列表的状态栏被隐藏
            UIApplication.shared.statusBarStyle = self.originalStatusBarStyle
            self.removeFromSuperview()
        }
    }
    /// 显示默认时间的提示
    class func showDefaultTime(state: LoadingState, title: String?) {
        let indicator = TSIndicatorWindowTop(state: state, title: title)
        indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    // MARK: - Private

    /// 设置标题
    func set(title: String) {
        labelForTitle.text = title
        let labelWidth = UIScreen.main.bounds.width - 50
        labelForTitle.sizeToFit()
        labelForTitle.frame = CGRect(x: 40, y: midY - labelForTitle.height / 2, width: labelWidth, height: labelForTitle.height)
    }
}
