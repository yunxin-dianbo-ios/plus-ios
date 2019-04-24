//
//  TSIconNameTitleControl.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  标题Control: 带Icon和Name
/**
 iOS11开始的 导航栏titleView，可以使用布局来实现。
 iOS11以下的 导航栏titleView，都是使用frame/bounds来布局实现。
 **/

import Foundation

import UIKit

class TSIconNameTitleControl: UIControl {

    var title: String? {
        didSet {
            self.titleLabel.text = title
            guard #available(iOS 11, *) else {
                let size = self.bounds.size
                let fixedWidth = self.horMargin * 3.0 + self.iconWH
                let titleWidth = title?.size(maxSize: CGSize.maxSize, font: UIFont.systemFont(ofSize: 17)).width ?? 0
                self.bounds = CGRect(x: 0, y: 0, width: titleWidth + fixedWidth, height: size.height)
                return
            }
        }
    }

    /// 标题
    let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 17), textColor: TSColor.main.content)
    /// 图标
    let iconView = AvatarView(type: AvatarType.width26(showBorderLine: false))

    fileprivate let horMargin: CGFloat = 5
    fileprivate let iconWH: CGFloat = 26

    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
        // 宽度先随便乱写的，之后根据需要更新
        self.bounds = CGRect(x: 0, y: 0, width: 100, height: 44)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func initialUI() -> Void {
        // 1. titleImage
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(horMargin)
            make.width.height.equalTo(iconWH)
        }
        // 2. titleLabel
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(iconView.snp.trailing).offset(horMargin)
            make.trailing.equalTo(self).offset(-horMargin)
            make.top.bottom.equalTo(self)
            make.height.equalTo(44)
        }
    }

}
