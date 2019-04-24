//
//  MoreTableViewCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    static let identifier = "MoreTableViewCell"

    /// 数据
    var model = MoreTableViewCellModel() {
        didSet {
            load(model: model)
        }
    }

    /// 标题 label
    @IBOutlet weak var titleLabel: UILabel!
    /// 图标
    @IBOutlet weak var iconImageView: UIImageView!
    /// 详情 label
    @IBOutlet weak var detailLabel: UILabel!

    /// 加载 model 显示在视图上
    func load(model: MoreTableViewCellModel) {
        titleLabel.text = model.title
        iconImageView.image = UIImage(named: model.iconImage)
        detailLabel.text = model.detailText
    }

}
