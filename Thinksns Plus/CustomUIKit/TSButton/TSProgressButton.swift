//
//  ProgressButton.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 下载进度按钮

import UIKit
import SnapKit
import Kingfisher

/// 下载图片的协议
protocol TSProgressButtonWithImageView {

    init(sourceImageView: UIImageView, url: URL, superView: UIView)
}
/// 下载按钮的协议
protocol TSProgressButtonWithButton {
    init(sourceButton: UIButton, url: URL, superView: UIView)

}

private let corner: CGFloat = 5.0
private let bottomMargin: CGFloat = 40.0
private let buttonWidth: CGFloat = 76.0
private let buttonHeight: CGFloat = 26.0
typealias ProgressButtonFailClosure = () -> Void

class TSProgressButton: TSButton, TSProgressButtonWithImageView, TSProgressButtonWithButton {
    private var sourceButton: UIButton?
    private var sourceImageView: UIImageView?
    private var progress: String = "0%"
    private var url: URL?
    private var superView: UIView?
    public var failclosure: ProgressButtonFailClosure?

    /// 初始化方法
    ///
    /// - Parameters:
    ///   - sourceImageView: 图片
    ///   - url: 链接
    /// - Note: 调用该方法,默认将视图添加调用者视图上
    required init(sourceImageView: UIImageView, url: URL, superView: UIView) {
        self.url = url
        self.superView = superView
        self.sourceImageView = sourceImageView
        super.init(frame: TSRootViewController.share.view.bounds)
        setProgressButtonState()
    }

    /// 初始化方法
    ///
    /// - Parameters:
    ///   - sourceButton: 按钮
    ///   - url: 链接
    required init(sourceButton: UIButton, url: URL, superView: UIView) {
        self.url = url
        self.superView = superView
        self.sourceButton = sourceButton
        super.init(frame: TSRootViewController.share.view.bounds)
        setProgressButtonState()
    }

    private func setProgressButtonState() {

        self.setTitle("显示_查看原图".localized, for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.layer.cornerRadius = corner
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor(hex: 0xffffff, alpha: 0.4).cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.2)
        self.addTarget(self, action: #selector(downloadImage), for: .touchUpInside)
        showSourceImageButton()
    }

    /// 显示按钮
    private func showSourceImageButton() {
        self.superView?.addSubview(self)
        self.snp.makeConstraints { make in
            make.centerX.equalTo(self.superView!)
            make.bottom.equalTo(self.superView!).offset(-40)
            make.size.equalTo(CGSize(width: buttonWidth, height: buttonHeight))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func downloadImage() {
        self.isUserInteractionEnabled = false
        if self.url == nil {
            assert(false, "\(TSProgressButton.self)url不能为空")
        }
        if let imageView = self.sourceImageView {
            self.downloadImageWithImageView(imageView: imageView)
        }

        if let button = self.sourceButton {
            self.downloadImageWithButton(button: button)
        }
    }

    private func downloadImageWithButton(button: UIButton) {
        self.setTitle("0%", for: .normal)
        guard let realURL = url else {
            assert(false, "下载图片时,链接设置错误")
            return
        }
        let reasource = ImageResource(downloadURL: realURL, cacheKey: realURL.absoluteString)

        button.kf.ts_setImage(with: reasource, for: .normal, placeholder: button.image(for: .normal), progressBlock: {[weak self] (currentValue, sourceValue) in
            self?.progress = String(format: "%.0f", Float(currentValue) / Float(sourceValue) * 100)
            self?.setTitle((self?.progress)! + "%", for: .normal)
            }, completionHandler: {[weak self] (image, error, _, _) in
                if error == nil {
                    self?.setTitle("显示_已完成".localized, for: .normal)
                    UIView.animate(withDuration: 0.2, delay: 1, animations: {
                        self?.alpha = 0.2
                    }, completion: { (_) in
                        self?.removeFromSuperview()
                    })
                     return
                }
                self?.isUserInteractionEnabled = true
                self?.setTitle("提示信息_下载失败".localized, for: .normal)
                if let failclosure = self?.failclosure {
                    failclosure()
                }
        })
    }

    private func downloadImageWithImageView(imageView: UIImageView) {
        self.setTitle("0%", for: .normal)
        guard let realURL = url else {
            assert(false, "下载图片时,链接设置错误")
            return
        }
        let reasource = ImageResource(downloadURL: realURL, cacheKey: realURL.absoluteString)

        imageView.kf.ts_setImage(with: reasource, placeholder: imageView.image, progressBlock: {[weak self] (currentValue, sourceValue) in
            self?.progress = String(format: "%.0f", Float(currentValue) / Float(sourceValue) * 100)
            self?.setTitle((self?.progress)! + "%", for: .normal)
        }) {[weak self] (image, error, _, _) in
            if error == nil {
                self?.setTitle("显示_已完成".localized, for: .normal)
                UIView.animate(withDuration: 0.2, delay: 1, animations: {
                    self?.alpha = 0.2
                }, completion: { (_) in
                    self?.removeFromSuperview()
                })
                return
            }
            self?.isUserInteractionEnabled = true
            self?.setTitle("提示信息_下载失败".localized, for: .normal)
            if let failclosure = self?.failclosure {
                failclosure()
            }
        }
    }
}
