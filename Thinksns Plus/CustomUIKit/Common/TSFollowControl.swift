//
//  TSFollowControl.swift
//  ThinkSNS +
//
//  Created by 小唐 on 02/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  关注按钮

import UIKit

class TSFollowControl: UIControl {
    // MARK: - Internal Property

    let defaultH: CGFloat = 25
    let minW: CGFloat = 65

    /// 关注状态
    var isFollow: Bool = false {
        didSet {
            self.isSelected = isFollow
        }
    }
    override var isSelected: Bool {
        didSet {
            self.titleLabel.text = isSelected ? "已关注" : "关注"
            self.iconView.image = isSelected ? UIImage(named: "IMG_channel_ico_added") : UIImage(named: "IMG_channel_ico_add_blue")
            self.titleLabel.textColor = isSelected ? UIColor(hex: 0xcccccc) : TSColor.main.theme
            self.layer.borderColor = isSelected ? UIColor(hex: 0xcccccc).cgColor : TSColor.main.theme.cgColor
        }
    }

    // MARK: - Private Property
    private weak var titleLabel: UILabel!
    private weak var iconView: UIImageView!

    // MARK: - Private UI
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    /// 界面布局
    private func initialUI() -> Void {
        let iconWH: CGFloat = 10
        let centerMargin: CGFloat = 3
        let lrMinMargin: CGFloat = 5
        // 0. self
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = TSColor.main.theme.cgColor
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemMediumFont(ofSize: 14), textColor: TSColor.main.theme)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self).offset(centerMargin * 0.5 + iconWH * 0.5)
            make.trailing.lessThanOrEqualTo(self).offset(-lrMinMargin)
        }
        self.titleLabel = titleLabel
        // 2. iconView
        let iconView = UIImageView()
        self.addSubview(iconView)
        iconView.contentMode = .center
        iconView.clipsToBounds = true
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.centerY.equalTo(self)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-centerMargin)
            make.leading.greaterThanOrEqualTo(self).offset(lrMinMargin)
        }
        self.iconView = iconView
        // 3. default
        titleLabel.text = "关注"
        iconView.image = UIImage(named: "IMG_channel_ico_add_blue")
    }

}
