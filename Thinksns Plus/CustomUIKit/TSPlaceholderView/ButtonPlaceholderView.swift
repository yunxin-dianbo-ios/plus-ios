//
//  ButtonPlaceholderView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  带有一个按钮的占位图

import UIKit

class ButtonPlaceholderView: UIView {

    /// 按钮
    let button = TSColorLumpButton()
    /// 提示信息 label
    let label = UILabel()

    /// 按钮点击事件
    var buttonAction: (() -> Void)? = nil

    init(frame: CGRect, buttonAction action: (() -> Void)?) {
        super.init(frame: frame)
        buttonAction = action
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = TSColor.inconspicuous.background
        // 按钮
        button.sizeType = .large
        button.addTarget(self, action: #selector(buttonTaped), for: .touchUpInside)
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 200, height: 40))
        }
        // 提示信息 label
        label.textColor = TSColor.normal.minor
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.topMargin.equalTo(button).offset(-34)
        }
    }

    /// 设置按钮和 label 的内容
    func set(buttonTitle: String, labelText: String) {
        button.setTitle(buttonTitle, for: .normal)
        label.text = labelText
    }

    /// 按钮点击事件
    func buttonTaped() {
        buttonAction?()
    }

}
