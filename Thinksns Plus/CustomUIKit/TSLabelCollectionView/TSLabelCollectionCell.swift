//
//  TSLabelCollectionCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  标签滚动视图的 cell

import UIKit

class TSLabelCollectionCell: UICollectionViewCell {

    static let identifier = "TSLabelCollectionCell"

    func setInfo(view: UIView) {
        contentView.removeAllSubViews()
        contentView.addSubview(view)
    }
}
