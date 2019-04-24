//
//  TSTableViewCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  交易明细列表 cell 

import UIKit

class TSTransationCell: UITableViewCell {

    /// cell identifer
    static let cellIdentifier = "TSTransationCell"

    /// 日期
    @IBOutlet weak var labelForDate: TSLabel!
    /// 详情
    @IBOutlet weak var labelForDescription: TSLabel!
    /// 金额
    @IBOutlet weak var labelForMoney: TSLabel!
    /// 操作状态
    @IBOutlet weak var labelForStatus: TSLabel!

    /// 数据模型
    var viewModel: TSTransationCellModel?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        labelForStatus.isHidden = true
    }

    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }

    // MARK: - Public
    func setInfo(object: TSTransationCellModel?) {
        guard let viewModel = object else {
            return
        }
        labelForDate.text = viewModel.dateString
        labelForDescription.text = viewModel.detailString
        labelForStatus.text = viewModel.stateString
        if viewModel.money == 0 {
            labelForMoney.text = viewModel.money.tostring()
        } else if viewModel.money > 0 {
            labelForMoney.text = "+" + viewModel.money.tostring()
        } else {
            labelForMoney.text = viewModel.money.tostring()
        }
        if viewModel.isShowMoney {
            labelForMoney.isHidden = false
            labelForStatus.isHidden = true
        } else {
            labelForMoney.isHidden = true
            labelForStatus.isHidden = false
        }
    }
}
