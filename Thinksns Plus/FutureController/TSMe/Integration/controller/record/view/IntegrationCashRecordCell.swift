//
//  IntegrationCashRecordCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  提现记录 cell

import UIKit

class IntegrationCashRecordCell: UITableViewCell {

    static let identifier = "IntegrationCashRecordCell"

    // 时间
    @IBOutlet weak var timeLabel: UILabel!
    // 信息
    @IBOutlet weak var messageLabel: UILabel!
    // 积分
    @IBOutlet weak var amountLabel: UILabel!

    func load(model: IntegrationCashRecordCellModel) {
        messageLabel.text = model.message
        timeLabel.text = model.time
        // 金额数
        if model.amount == 0 {
            amountLabel.text = "0\(TSAppConfig.share.localInfo.goldName)"
        } else if model.amount > 0 {
            amountLabel.text = "+\(model.amount)" + TSAppConfig.share.localInfo.goldName
        } else {
            amountLabel.text = "-\(model.amount)" + TSAppConfig.share.localInfo.goldName
        }
        // 根据交易状态加载不同的 UI 效果
        switch model.statusType {
        case .unknow:
            amountLabel.textColor = .white
            messageLabel.textColor = .white
        case .ongoing:
            amountLabel.textColor = UIColor(hex: 0xff9400)
            messageLabel.textColor = UIColor(hex: 0x333333)
        case .success:
            amountLabel.textColor = UIColor(hex: 0xff9400)
            messageLabel.textColor = UIColor(hex: 0x333333)
        case .faild:
            amountLabel.textColor = UIColor(hex: 0x999999)
            messageLabel.textColor = UIColor(hex: 0xb2b2b2)
        }
    }
}
