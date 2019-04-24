//
//  LikeRankingListTableViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人中心点赞排行榜

import UIKit

class LikeRankingListTableViewCell: AbstractRankingListTableViewCell {
    /// 内容文本相对于右边的位置
    let LRcontentLabelRight: CGFloat = -30

    override init(style: UITableViewCellStyle, reuseIdentifier: String?, userInfo: TSUserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, userInfo: userInfo)
        self.praiseButton?.isHidden = true
        self.contentLabel?.snp.updateConstraints({ make in
            make.right.equalTo(self.contentView.snp.right).offset(LRcontentLabelRight)
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.rankNumberLable?.text = "\(self.indexPathRow + 1)"
        self.nickNameLabel?.text = self.userInfo.name
        let likesCount = userInfo.extra?.likesCount ?? 0

        self.praiseLabel?.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: ("点赞 ", TSColor.normal.minor, TSFont.SubInfo.footnote.rawValue), second: (TSRankingListTool().conversionPraiseNumber(value: likesCount) as NSString, secondColor: TSColor.main.theme, 14))
        self.contentLabel?.text = self.userInfo.shortDesc()
        self.headerImageButton?.avatarInfo.type = .normal(userId: self.userInfo.userIdentity)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
