//
//  StackSeperatorCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 分割线 cell

import UIKit
import SnapKit

class StackSeperatorCell: UITableViewCell {

    /// 底部分割线
    let seperatorLine = UIView(frame: .zero)

    /// 是否已经更新了约束
    var didSetupConstraints = false

    /// 数据
    var model: StackSeperatorCellModel! {
        didSet {
            setInfo()
        }
    }

    static let identifier = "StackSeperatorCell"

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: StackSeperatorCellModel) -> StackSeperatorCell {
        let cell = table.dequeueReusableCell(withIdentifier: StackSeperatorCell.identifier, for: indexPath) as! StackSeperatorCell
        cell.model = data
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(seperatorLine)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(seperatorLine)
    }

    func setInfo() {
        let screenWidth = UIScreen.main.bounds.width
        seperatorLine.backgroundColor = model.lineColor
        seperatorLine.frame = CGRect(x: model.left, y: model.top, width: screenWidth - model.left - model.right, height: model.height)
    }
}
