//
//  DynamicLikeCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态点赞排行榜

import UIKit

class MomentLikeCell: AbstractRankingListTableViewCell {

    /// 头像相对于上面的距离
    let headerImageViewTop: CGFloat = 15

    override init(style: UITableViewCellStyle, reuseIdentifier: String?, userInfo: TSUserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, userInfo: userInfo)
        self.headerImageButton?.snp.updateConstraints({ make in
            make.top.equalTo(self.contentView.snp.top).offset(headerImageViewTop)
        })

        self.headerImageButton?.buttonForAvatar.setImage(nil, for: .normal)
        self.rankNumberLable?.isHidden = true
        self.praiseLabel?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.userInfo.userIdentity == (TSCurrentUserInfo.share.userInfo?.userIdentity)! {
            praiseButton?.isHidden = true
        }
        let praiseTitle: String?
        if let praiseTitleS = userInfo.relationshipTextWithCurrentUser()?.rawValue {
            praiseTitle = praiseTitleS
            self.praiseButton?.isHidden = false
            if praiseTitleS == "已关注" || praiseTitleS == "互相关注" {
                self.praiseButton?.setTitleColor(TSColor.main.theme, for: .normal)
                self.praiseButton?.backgroundColor = UIColor.white
                self.praiseButton?.layer.borderColor = TSColor.main.theme.cgColor
                self.praiseButton?.layer.borderWidth = 0.5
            } else if praiseTitleS == "+ 关注" {
                self.praiseButton?.setTitleColor(UIColor.white, for: .normal)
                self.praiseButton?.backgroundColor = TSColor.main.theme
            } else {
                self.praiseButton?.isHidden = true
            }
        } else {
            praiseTitle = nil
            self.praiseButton?.isHidden = true
        }
        self.praiseButton?.setTitle(praiseTitle, for: .normal)
        self.headerImageButton?.avatarInfo.type = .normal(userId: self.userInfo.userIdentity)
        self.nickNameLabel?.text = self.userInfo.name
        self.contentLabel?.text = self.userInfo.shortDesc()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
