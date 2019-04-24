//
//  TSTitleSelectControl.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  标题选择Control
//  用于导航栏标题的使用，右侧有个下拉图标。
//  建议更名为TSSelectControlTitle 或 TSSelectTitleControl
/**
 iOS11开始的 导航栏titleView，可以使用布局来实现。
 iOS11以下的 导航栏titleView，都是使用frame/bounds来布局实现。
 **/

import UIKit

class TSTitleSelectControl: UIControl {

    var title: String? {
        didSet {
            self.titleLabel.text = title
            guard #available(iOS 11, *) else {
                let size = self.bounds.size
                let fixedWidth = icon.size.width + 2 + 2 * 2
                let titleWidth = title?.size(maxSize: CGSize.maxSize, font: UIFont.systemFont(ofSize: 18)).width ?? 0
                self.bounds = CGRect(x: 0, y: 0, width: titleWidth + fixedWidth, height: size.height)
                return
            }
        }
    }

    /// 标题
    fileprivate let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18), textColor: TSColor.main.content)
    /// 图标
    fileprivate let iconView = UIImageView(image: #imageLiteral(resourceName: "IMG_ico_detail_arrowdown"))
    fileprivate let icon = #imageLiteral(resourceName: "IMG_ico_detail_arrowdown")

    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
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
        let iconW = icon.size.width
        // 1. titleLabel
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self).offset(-iconW * 0.5 - 1)

            if #available(iOS 11, *) {
                make.top.bottom.equalTo(self)
                make.height.equalTo(44)
                make.leading.equalTo(self).offset(2)
            }
        }
        // 2. titleImage
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
            make.size.equalTo(icon.size)

            if #available(iOS 11, *) {
                make.trailing.equalTo(self).offset(-2)
            }
        }
    }

}
