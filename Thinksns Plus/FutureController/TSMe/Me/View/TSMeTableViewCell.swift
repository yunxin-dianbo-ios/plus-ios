//
//  TSMeTableViewCell.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSMeTableViewCell: UITableViewCell {
    /// 跳转vc的图标
    var vcImage: UIImageView = UIImageView()
    /// 跳转vc的名字
    var vcName: UILabel = UILabel()
    /// >
    var accessory = UIImageView()
    /// 分割线
    var separator: UIView = UIView()
    /// 钱包金额
    var moenylabel: UILabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    func setUI() {
        vcImage.contentMode = .scaleAspectFill
        vcName.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        vcName.textColor = TSColor.main.content
        moenylabel.textColor = TSColor.normal.minor
        moenylabel.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        moenylabel.textAlignment = .right
        accessory.contentMode = .scaleAspectFill
        separator.backgroundColor = TSColor.inconspicuous.disabled

        self.contentView.addSubview(vcImage)
        self.contentView.addSubview(vcName)
        self.contentView.addSubview(moenylabel)
        self.contentView.addSubview(accessory)
        self.contentView.addSubview(separator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        vcImage.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(17)
            make.left.equalTo(self.contentView).offset(18)
            make.width.equalTo(18)
            make.height.equalTo(17.5)
        }

        vcName.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(18)
            make.left.equalTo(vcImage.snp.right).offset(9)
            make.height.equalTo(15.5)
            make.width.equalTo(100)
        }

        moenylabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(18)
            make.height.equalTo(15.5)
            make.width.equalTo(100)
            make.right.equalTo(accessory.snp.left).offset(-10)
        }

        accessory.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-16)
            make.width.equalTo(10)
            make.height.equalTo(20)
        }

        separator.snp.remakeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-1)
            make.height.equalTo(0.5)
            make.left.equalTo(self.contentView).offset(12)
            make.right.equalTo(self.contentView).offset(-12)
        }
    }
}
