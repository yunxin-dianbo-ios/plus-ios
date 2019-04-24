//
//  TSBindingOrUnbindTableViewCell.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSBindingOrUnbindTableViewCell: UITableViewCell {
    /// 绑定/解绑项
    let itemNameLabel = UILabel()
    /// >
    var accessoryImageView = UIImageView(image: #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey"))
    /// 底线
    let separatorLine: TSSeparatorView = TSSeparatorView()
    /// 是否绑定 - 文字
    let bindingOrUnbindLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        itemNameLabel.textColor = TSColor.main.content
        itemNameLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        bindingOrUnbindLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        accessoryImageView.contentMode = .scaleAspectFill

        self.contentView.addSubview(itemNameLabel)
        self.contentView.addSubview(bindingOrUnbindLabel)
        self.contentView.addSubview(accessoryImageView)
        self.contentView.addSubview(separatorLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        itemNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(13.5)
            make.centerY.equalTo(self.contentView)
        }
        bindingOrUnbindLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(accessoryImageView.snp.left).offset(-9.5)
        }
        accessoryImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-19)
            make.width.equalTo(7)
            make.height.equalTo(12)
        }
        separatorLine.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView.snp.bottom).offset(-0.5)
        }
    }

    func isBinding(_ bool: Bool) {
        if bool {
            bindingOrUnbindLabel.text = "已绑定"
            bindingOrUnbindLabel.textColor = TSColor.normal.minor
        } else {
            bindingOrUnbindLabel.text = "未绑定"
            bindingOrUnbindLabel.textColor = TSColor.small.topLogo
        }
    }
}
