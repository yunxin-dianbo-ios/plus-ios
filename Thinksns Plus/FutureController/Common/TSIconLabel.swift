//
//  TSIconLabel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 30/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  带图标的Label
//  如：悬赏、围观这类左侧有图标，跟着展示短文字的Label。其完全可使用Button替代

import Foundation
import UIKit

class TSIconLabel: UIView {

    // MARK: - Internal Property
    var text: String? {
        didSet {
            self.textLabel.text = text
            self.layoutIfNeeded()
        }
    }
    var textFont: UIFont = UIFont.systemFont(ofSize: 13) {
        didSet {
            self.textLabel.font = textFont
        }
    }
    var textColor: UIColor = UIColor(hex: 0xfca308) {
        didSet {
            self.textLabel.textColor = textColor
        }
    }

    private(set) var iconView: UIImageView!
    private(set) var textLabel: UILabel!

    // MARK: - Internal Function

    // MARK: - Private Property
    fileprivate var iconWH: CGFloat

    // MARK: - Initialize Function
    init(iconWH: CGFloat = 15, iconName: String, text: String?, font: UIFont = UIFont.systemFont(ofSize: 13), textColor: UIColor = UIColor(hex: 0xfca308)) {
        self.iconWH = iconWH
        super.init(frame: CGRect.zero)
        self.initialUI()
        self.textFont = font
        self.textColor = textColor
        self.text = text
        self.iconView.image = UIImage(named: iconName)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        let imageView = UIImageView(cornerRadius: 0)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.leading.equalTo(self)
            //make.centerY.equalTo(self)
            make.top.bottom.equalTo(self)
//            make.centerY.equalTo(self)
//            make.top.greaterThanOrEqualTo(self).offset(0)
//            make.bottom.lessThanOrEqualTo(self).offset(0)
        }
        self.iconView = imageView

        let label = UILabel(text: self.text, font: self.textFont, textColor: self.textColor)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(0)
        }
        self.textLabel = label
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
