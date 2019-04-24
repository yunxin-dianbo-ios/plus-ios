//
//  LoadingView.swift
//  Thinksns Plus
//
//  Created by GorCat on 2017/8/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  页面加载视图
//
/*
 
 示例代码：
 
 0.让需要显示加载视图的类遵守 LoadingViewDelegate 协议。
 class TableVC: UIViewController, LoadingViewDelegate {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 // 1.在 viewDidLoad 中调用 loading() 显示加载视图。
 loading()
 }
 
 // MARK: - LoadingViewDelegate
 
 /// 2.实现加载视图代理事件，返回按钮点击事件。
 func loadingBackButtonTaped() {
 navigationController?.popViewController(animated: true)
 }
 
 /// 3.实现加载视图代理事件，重新加载按钮点击事件。
 func reloadingButtonTaped() {
 }
 }
 
 4.在数据加载结束后，调用 endLoading() 移除加载视图，或者使用 loadFaild(type:) 方法展示加载失败的状态。
 
 */

import UIKit

// MARK: - loading view 的主要调用接口方法
extension LoadingViewDelegate where Self: UIViewController {

    /// 正在加载
    func loading(showBackButton: Bool = true) {
        LoadingView.share.animationStartTime = Date(timeIntervalSinceNow: 0)
        LoadingView.share.delegate = self
        LoadingView.share.backButton.isHidden = !showBackButton
        LoadingView.share.pushAnimation()
    }

    /// 结束加载，移除加载视图
    func endLoading() {
        if LoadingView.share.animationStartTime != nil {
            let timeDurtion = Date(timeIntervalSinceNow: 0).timeIntervalSince(LoadingView.share.animationStartTime)
            if timeDurtion >= LoadingView.share.minAnimationTimeMs {
                LoadingView.share.dismiss()
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (LoadingView.share.minAnimationTimeMs - timeDurtion) / 1_000.0) {
                    LoadingView.share.dismiss()
                }
            }
        } else {
            LoadingView.share.dismiss()
        }
    }

    /// 加载失败，显示失败状态按钮
    func loadFaild(type: LoadingView.FaildType) {
        if LoadingView.share.animationStartTime != nil {
            let timeDurtion = Date(timeIntervalSinceNow: 0).timeIntervalSince(LoadingView.share.animationStartTime)
            if timeDurtion >= LoadingView.share.minAnimationTimeMs {
                LoadingView.share.faild(with: type)
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (LoadingView.share.minAnimationTimeMs - timeDurtion) / 1_000.0) {
                    LoadingView.share.faild(with: type)
                }
            }
        } else {
            LoadingView.share.faild(with: type)
        }
    }
}

@objc protocol LoadingViewDelegate: class {

    // 点击了重新加载视图
    @objc optional func reloadingButtonTaped()
    // 点击了返回按钮
    @objc optional func loadingBackButtonTaped()
    // 视图消失
    @objc optional func loadingDismiss()
}

class LoadingView: UIView {
    static let share = LoadingView()

    enum FaildType: String {
        /// 网络请求失败
        case network = "IMG_img_default_internet"
        /// 内容已被删除
        case delete = "IMG_img_default_delete"
        /// 没有找到人
        case nobody = "IMG_img_default_nobody"
    }

    /// 动画视图
    internal let imageView = UIImageView()
    /// 加载失败图片按钮
    internal let reloadButton = UIButton(type: .custom)
    /// 返回按钮
    internal let backButton = UIButton(frame: CGRect(x: 15, y: TSStatusBarHeight + 5, width: 0, height: 0))

    /// 代理
    weak var delegate: LoadingViewDelegate?
    /// 最小显示时间默认250ms
    var minAnimationTimeMs: TimeInterval = 0.25 * 1_000
    /// 动画开始时间
    var animationStartTime: Date!
    // MARK: - Lifecycle
    init() {
        super.init(frame: UIScreen.main.bounds)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface

    /// 加载视图
    internal func setUI() {
        backgroundColor = TSColor.inconspicuous.disabled
        /// 动画视图
        imageView.frame = bounds
        imageView.contentMode = .center
        var animationImages: [UIImage] = []
        for index in 0..<30 {
            let image = UIImage(named: "IMG_default_center_000\(index)")!
            animationImages.append(image)
        }
        imageView.animationImages = animationImages
        // 结果按钮
        let faildImage = UIImage(named: "IMG_img_default_internet")!
        reloadButton.frame = CGRect(x: (UIScreen.main.bounds.width - faildImage.size.width) / 2, y: (UIScreen.main.bounds.height - faildImage.size.height) / 2, width: faildImage.size.width, height: faildImage.size.height)
        reloadButton.setImage(faildImage, for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadButtonClicked), for: .touchUpInside)
        // 返回按钮
        backButton.setImage(UIImage(named: "IMG_topbar_back"), for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backButtonTaped), for: .touchUpInside)

        addSubview(imageView)
        addSubview(reloadButton)
        addSubview(backButton)
    }

    // MARK: - Button click

    /// 点击了重新加载按钮
    internal func reloadButtonClicked() {
        // 显示加载中动画
        loading()
        delegate?.reloadingButtonTaped?()
    }

    /// 点击了返回按钮
    internal func backButtonTaped() {
        popAnimation()
        delegate?.loadingBackButtonTaped?()
    }

    /// 模仿 push 动画
    internal func pushAnimation() {
        if superview != nil {
            return
        }
        loading()
        let topWindow = UIApplication.shared.keyWindow
        topWindow?.addSubview(self)
        frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveLinear, animations: {
            self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }, completion: nil)
    }

    /// 模仿 pop 动画
    internal func popAnimation() {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }) { (_) in
            self.dismiss()
        }
    }

    /// 显示加载状态
    internal func loading() {
        imageView.isHidden = false
        reloadButton.isHidden = true
        imageView.startAnimating()
    }

    /// 移除加载视图
    internal func dismiss() {
        if superview == nil {
            return
        }
        self.delegate?.loadingDismiss?()
        self.removeFromSuperview()
    }

    /// 显示失败状态
    internal func faild(with type: FaildType) {
        reloadButton.setImage(UIImage(named: type.rawValue), for: .normal)
        imageView.stopAnimating()
        reloadButton.isHidden = false
        imageView.isHidden = true
    }
}
