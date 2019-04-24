//
//  TSUserInfoCollectionViewCell.swift
//  date
//
//  Created by Fiction on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 修改用户信息页面 - 用户标签的cell

import UIKit

class TSUserInfoCollectionViewCell: UICollectionViewCell {
    /// 展示的标签的label
    let contentViewLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = TSColor.inconspicuous.background

        contentViewLabel.font = UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)
        contentViewLabel.textColor = TSColor.normal.content
        contentViewLabel.textAlignment = .center

        self.contentView.addSubview(contentViewLabel)

        contentViewLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
