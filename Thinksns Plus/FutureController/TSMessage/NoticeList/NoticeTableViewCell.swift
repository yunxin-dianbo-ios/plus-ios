//
//  NoticeTableViewCell.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

class NoticeTableViewCell: UITableViewCell {
    /// 内容标签
    weak var contentLabel: UILabel!
    /// 时间标签
    weak var createdDateLabel: UILabel!
    let line: UIView = UIView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let contentLbel = UILabel()
        contentLbel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        contentLbel.numberOfLines = 0
        contentLbel.contentMode = .left
        contentLbel.textColor = TSColor.normal.blackTitle
        self.contentLabel = contentLbel

        let createdDateLabel = UILabel()
        createdDateLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        createdDateLabel.contentMode = .right
        createdDateLabel.textColor = TSColor.normal.disabled
        self.createdDateLabel = createdDateLabel

        self.contentView.addSubview(createdDateLabel)
        self.contentView.addSubview(contentLbel)
        self.contentView.addSubview(line)

        contentLbel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(15)
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-66)
            make.bottom.equalTo(contentView).offset(-15)
        }

        createdDateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.5)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(12)
        }

        line.backgroundColor = UIColor(hex: 0xebebeb)
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持从xib创建")
    }

}
