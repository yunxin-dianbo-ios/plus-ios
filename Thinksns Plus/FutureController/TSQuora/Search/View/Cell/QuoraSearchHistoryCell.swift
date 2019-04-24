//
//  QuoraSearchHistoryCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答搜索历史记录 cell

import UIKit

protocol QuoraSearchHistoryCellDeleagate: class {
    /// 点击了历史记录 cell 的关闭按钮
    func cell(_ cell: QuoraSearchHistoryCell, didSelected closeButton: UIButton)
}

class QuoraSearchHistoryCell: UITableViewCell {

    static let identifier = "QuoraSearchHistoryCell"

    weak var delegate: QuoraSearchHistoryCellDeleagate?

    /// 历史记录 text label
    @IBOutlet weak var labelForHistory: UILabel!

    /// 点击了 x 按钮
    @IBAction func closeButtonTaped(_ sender: UIButton) {
        delegate?.cell(self, didSelected: sender)
    }

}
