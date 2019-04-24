//
//  ConcernRankingListTableViewCellTableViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人中心关注列表

import UIKit

class ConcernRankingListTableViewCellTableViewCell: AbstractRankingListTableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?, userInfo: TSUserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, userInfo: userInfo)
        self.rankNumberLable?.isHidden = true
        self.headerImageButton?.buttonForAvatar.setImage(nil, for: .normal)
        self.praiseLabel?.isHidden = true
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
        let likesCount: Int
        if let extra = self.userInfo.extra {
            likesCount = extra.likesCount
        } else {
            likesCount = 0
        }
        self.praiseLabel?.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: ("点赞 ", TSColor.normal.minor, TSFont.SubInfo.footnote.rawValue), second: (TSRankingListTool().conversionPraiseNumber(value: likesCount) as NSString, secondColor: TSColor.main.theme, 14))
        let praiseImg: UIImage?
        if let praiseImgString = userInfo.relationshipWithCurrentUser()?.rawValue {
            praiseImg = UIImage(named: praiseImgString)
        } else {
            praiseImg = nil
        }
//        self.praiseButton?.setImage(praiseImg, for: .normal)
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
