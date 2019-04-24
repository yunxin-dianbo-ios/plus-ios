//
//  AllKindsOfPopView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  
//  各种警告弹窗
//  使用方法:用自定义构造函数初始化后直接调用 itsShowTime 就可以了
//  还可以调用变量 time 来修改显示持续时间

private enum ShowImageName: String {
    case SuccessImageName = "IMG_msg_box_succeed"
    case failImageName = "IMG_msg_box_remind"
}

private let intervalBetweenPictureAndText: CGFloat = 5.0

private let lrMarginOffset: CGFloat = 20.0

private let udMarginOffset: CGFloat = 15.0

private let corner: CGFloat = 10.0

import UIKit

class TSAllKindsOfPopView: UIView, CAAnimationDelegate {
    private var imageName: ShowImageName!
    private var complete: () -> Void!
    /// 维持显示的时间 不设置默认1.5秒
    public var time = 1.5

    // MARK: - Lifecycle
    /// 自定义构造器
    ///
    /// - Parameters:
    ///   - title: 提示的信息
    ///   - isFail: 是否是失败(失败图片就传true)
    ///   - superVC: 承载视图
    ///   - complete: 显示完成后如果有后续操作请在此闭包调用
    init(title: String, isFail: Bool, complete: @escaping () -> Void ) {
        self.complete = complete
        super.init(frame: TSRootViewController.share.view.bounds)
         self.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.8)
        imageName = isFail ? .failImageName : .SuccessImageName
        setUI(title: title)
    }

    /// 展示View
    func itsShowTime() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = 0.3
        let aAnimation = NSNumber(value: 0.9)
        let bAnimation = NSNumber(value: 1.1)
        let cAnimation = NSNumber(value: 0.8)
        let dAnimation = NSNumber(value: 1.0)
        animation.values = [aAnimation, bAnimation, cAnimation, dAnimation]
        animation.delegate = self
        self.layer.add(animation, forKey: nil)
    }

    // MARK: - 关键帧动画完成后的后续动画
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        UIView.animate(withDuration: 0.5, delay: time, options: .curveLinear, animations: {
            self.alpha = 0
        }) { _ in
            self.complete()
            self.removeFromSuperview()
        }
    }

    // MARK: - UI
    private func setUI(title: String) {
        TSRootViewController.share.view.addSubview(self)
        let image: UIImage = UIImage(named: imageName.rawValue)!
        let width = image.size.width + intervalBetweenPictureAndText + stringWidth(title: title) + (lrMarginOffset * 2)
        let height = image.size.height + udMarginOffset * 2
        self.snp.makeConstraints { make in
            make.center.equalTo(TSRootViewController.share.view)
            make.size.equalTo(CGSize(width: width, height: height))
        }

        let msgBoxImageView = UIImageView(image: image)
        msgBoxImageView.center = CGPoint(x: lrMarginOffset + image.size.width / 2, y: height / 2)
        msgBoxImageView.bounds = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        self.addSubview(msgBoxImageView)

        let titleLabel = UILabel()
        let pointx = lrMarginOffset + image.size.width + intervalBetweenPictureAndText
        titleLabel.center = CGPoint(x: pointx + stringWidth(title: title) / 2, y: height / 2)
        titleLabel.bounds = CGRect(x: 0.0, y: 0.0, width: stringWidth(title: title), height: TSFont.ContentText.text.rawValue + 2)
        titleLabel.text = title
        titleLabel.textColor = TSColor.normal.blackTitle
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.addSubview(titleLabel)
        self.backgroundColor = UIColor.white

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private  func stringWidth(title: String) -> CGFloat {

        let size = title.heightWithConstrainedWidth(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, font: UIFont.systemFont(ofSize: 16))

        return size.width
    }

    /// 实现圆角
    ///
    /// - Parameter rect: 尺寸
    internal override func draw(_ rect: CGRect) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: corner)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
