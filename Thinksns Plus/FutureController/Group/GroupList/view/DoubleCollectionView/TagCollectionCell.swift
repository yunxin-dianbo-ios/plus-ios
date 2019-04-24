//
//  TagCollectionCell.swift
//  Test111
//
//  Created by GorCat on 2018/1/8.
//  Copyright © 2018年 GorCat. All rights reserved.
//

import UIKit

class TagCollectionCell: UICollectionViewCell {

    static let identifier = "TagCollectionCell"
    /// tag 标签
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        contentView.addSubview(titleLabel)
    }

    func set(title: String, isSelected: Bool) {
        if isSelected {
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.textColor = UIColor(hex: 0x333333)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.textColor = UIColor(hex: 0x999999)
        }
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.frame = CGRect(origin: .zero, size: CGSize(width: 54, height: 44))
    }
}
