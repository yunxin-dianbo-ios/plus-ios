//
//  PostcapabilityCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class PostcapabilityCell: UITableViewCell {

    static let identifier = "PostcapabilityCell"

    /// 标题
    @IBOutlet weak var titleLabel: UILabel!
    /// 选中按钮
    @IBOutlet weak var rightButon: UIButton!

    func set(title: String, isSelected: Bool) {
        titleLabel.text = title
        rightButon.isSelected = isSelected
    }
}
