//
//  TSShowsSearchResultsCell.swift
//  date
//
//  Created by Fiction on 2017/7/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 搜索结果tableview的cell

import UIKit

class TSShowsSearchResultsCell: UITableViewCell {
    /// 显示搜索结果显示的label
    let label: UILabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    func setUI() {
        label.font = UIFont.systemFont(ofSize: TSFont.Title.indicator.rawValue)
        label.textColor = TSColor.normal.blackTitle
        label.textAlignment = .left
        self.contentView.addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(74)
            make.right.equalTo(self.contentView).offset(-74)
        }
    }
}
