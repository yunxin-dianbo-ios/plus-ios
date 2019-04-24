//
//  BlackListCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/4/19.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class BlackListCell: AbstractRankingListTableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?, userInfo: TSUserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, userInfo: userInfo)
        self.rankNumberLable?.isHidden = true
        self.headerImageButton?.buttonForAvatar.setImage(nil, for: .normal)
        self.praiseLabel?.isHidden = true
        self.praiseButton?.layer.cornerRadius = 10
        self.praiseButton?.layer.borderColor = UIColor(red: 89.0 / 255.0, green: 182.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0).cgColor
        self.praiseButton?.layer.borderWidth = 0.5
        self.praiseButton?.setTitle("移除", for: .normal)
        self.praiseButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.praiseButton?.setTitleColor(UIColor(red: 89.0 / 255.0, green: 182.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0), for: .normal)
        self.praiseButton?.snp.remakeConstraints({ (make) in
            make.right.equalTo(self.contentView.snp.right).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 50, height: 20))
        })
    }

    override func followTouch(_ btn: TSButton) {
        self.delegate?.cell(self, operateBtn: self.praiseButton!, indexPathRow: self.indexPathRow)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.userInfo.userIdentity == (TSCurrentUserInfo.share.userInfo?.userIdentity)! {
            praiseButton?.isHidden = true
        } else {
            praiseButton?.isHidden = false
        }
        self.headerImageButton?.avatarInfo.type = .normal(userId: self.userInfo.userIdentity)
        self.nickNameLabel?.text = self.userInfo.name
        self.contentLabel?.text = self.userInfo.shortDesc()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
