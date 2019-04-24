//
//  IntegrationRecordCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/18.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class IntegrationRecordCell: UITableViewCell {

    static let identifier = "identifier"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func load(model: IntegrationRecordCellModel) {
        titleLabel.text = model.title
        timeLabel.text = model.time
        if model.amount > 0 {
            amountLabel.text = "+\(model.amount)"
        } else {
            amountLabel.text = "\(model.amount)"
        }
        self.titleLabel.textColor = model.titleColor
        self.amountLabel.textColor = model.amountColor
    }
}
