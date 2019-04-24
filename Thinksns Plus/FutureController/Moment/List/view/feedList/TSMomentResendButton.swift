//
//  TSMomentResendView.swift
//  ThinkSNS +
//
//  Created by LeonFa on 2017/4/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  重发按钮

import UIKit

class TSMomentResendButton: TSButton {
    /// 按钮抬头
    var title: String?
    // MARK: - 自定义初始化方法
    /// 初始化方法
    init(title: String) {
        super.init(frame: CGRect.zero)
        self.title = title
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setUI
    func setUI() {
        self.setTitle(self.title, for: .normal)
        self.setTitleColor(TSColor.normal.minor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)
        let image = UIImage(named: "IMG_msg_box_remind")
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0 )
        self.backgroundColor = TSColor.inconspicuous.background
        let width = self.title?.heightWithConstrainedWidth(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT), font: UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)).width
        self.bounds.size = CGSize(width: (image?.size.width)! + width! + 5 + 10 * 2, height: (image?.size.height)! + 5 * 2)
    }

    override func draw(_ rect: CGRect) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.width)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
