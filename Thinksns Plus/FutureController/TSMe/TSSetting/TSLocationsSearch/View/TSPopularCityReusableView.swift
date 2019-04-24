//
//  TSPopularCityReusableView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPopularCityReusableView: UICollectionReusableView {
    /// 头视图标题
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.inconspicuous.background
        self.titleLabel.frame = CGRect(x: 10, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.titleLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = TSColor.normal.minor
        self.addSubview(self.titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 修改方法
    /// 修改头视图显示什么字符串
    func setTitle(text: String) {
        self.titleLabel.text = text
    }
}
