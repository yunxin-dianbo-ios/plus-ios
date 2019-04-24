//
//  TSMarqueeLabel.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  跑马灯文本框

import UIKit

class TSMarqueeLabel: UIView {

    /// 显示的文本
    var text: String? = nil
    /// 字体属性
    var textFontSize: CGFloat = 12
    var textColor: UIColor = UIColor.black
    /// frame
    var LabelFrame: CGRect? {
        set {
            self.frame = newValue!
            layoutView()
        }
        get {
            return self.frame
        }
    }

    /// 滚动的底部视图
    private let moveView: UIView = UIView()
    /// 滚动视图的初始位置
    private var defaultTransform: CGAffineTransform? = nil

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        layoutMoveView()
    }

    // MARK: - UI
    func layoutView() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.moveView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.moveView.backgroundColor = .clear
        self.defaultTransform = self.moveView.transform
        if self.moveView.superview == nil {
            self.addSubview(self.moveView)
        }
    }

    func layoutMoveView() {

        if self.text == nil {
            return
        }
        for view in self.moveView.subviews {
            view.removeFromSuperview()
        }
        removeAnimation()
        // 计算出文本的长度 判断是否超过了主视图的宽度
        let StringWidth = self.widthForText()
        if StringWidth > self.bounds.width {
            self.moveView .addSubview(self.makeLabel(frame: CGRect(x: 0, y: 0, width: StringWidth, height: self.moveView.frame.height), alignmentCenter: NSTextAlignment.left))
            self.moveView.addSubview(self.makeLabel(frame: CGRect(x: StringWidth + 20, y: 0, width: StringWidth, height: self.moveView.frame.height), alignmentCenter: NSTextAlignment.left))

            let time: TimeInterval = 0.05
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                self.addAnimation(textWidth: StringWidth)
            }
        } else {
            self.moveView.addSubview(self.makeLabel(frame: CGRect(x: 0, y: 0, width: self.moveView.frame.width, height:self.moveView.frame.height), alignmentCenter: NSTextAlignment.center))
        }
    }

    func makeLabel(frame: CGRect, alignmentCenter: NSTextAlignment) -> UILabel {
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: self.textFontSize)
        label.textColor = self.textColor
        label.text = self.text
        label.backgroundColor = .clear
        label.textAlignment = alignmentCenter
        label.numberOfLines = 0
        return label
    }

    // MARK: - Public Method
    func reSetTitle(title: String) {
        self.text = title
        layoutMoveView()
    }

    // MARK: - Private Method
    /// 计算文本框将要显示的文本真实长度
    private func widthForText() -> CGFloat {
        let fontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: self.textFontSize)]
        let size = self.text?.size(attributes: fontAttributes)
        return (size?.width)!
    }

    // MARK: animations
    private func addAnimation(textWidth: CGFloat) {
        let moveAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        moveAnimation.keyTimes = [0, 0.191, 0.868, 1.0]
        moveAnimation.duration = Double(textWidth) / 30
        moveAnimation.values = [0, 0, (-textWidth - 20.0)]
        moveAnimation.repeatCount = Float(INT16_MAX)
        moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        moveAnimation.isRemovedOnCompletion = false
        self.moveView.layer.add(moveAnimation, forKey: "move")
    }

    private func removeAnimation() {
        self.moveView.layer.removeAnimation(forKey: "move")
        self.moveView.transform = self.defaultTransform!
    }
}
