//
//  SingleTagChooseCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class SingleTagChooseCell: UICollectionViewCell {

    static let identifier = "SingleTagChooseCell"

    let tagLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        contentView.addSubview(tagLabel)
    }

    func set(titile: String, isSelected: Bool) {
        if isSelected {
            tagLabel.backgroundColor = UIColor(hex: 0xd9eef6)
        } else {
            tagLabel.backgroundColor = UIColor(hex: 0xf4f5f5)
        }

        tagLabel.layer.cornerRadius = 4
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.font = UIFont.systemFont(ofSize: 14)
        tagLabel.textColor = UIColor(hex: 0x333333)

        let tagSize = CGSize(width: (UIScreen.main.bounds.width - 15) / 4 - 15, height: 30)
        tagLabel.frame = CGRect(origin: CGPoint(x: 7.5, y: 7.5), size: tagSize)

        tagLabel.text = titile
    }

}
