//
//  RankListPreviewColletionCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行版总览 cell 上的 collection 的 cell

import UIKit

class RankListPreviewColletionCell: UICollectionViewCell {
    static let identifier = "RankListPreviewColletionCell"

    /// 头像
    var avatar: AvatarView = {
        // 头像之间的间距
        let cellSize = RankListPreviewColletionUX.avatarSize
        let avatar = AvatarView(type: AvatarType.custom(avatarWidth: cellSize.width, showBorderLine: false))
        return avatar
    }()
    /// 姓名
    var labelForName = UILabel()

    /// 数据
    var cellModel: TSUserInfoModel?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MAKR: - UI
    func setUI() {
        // 头像
        contentView.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.size.equalTo(RankListPreviewColletionUX.avatarSize)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        // 姓名
        labelForName.font = UIFont.systemFont(ofSize: 12)
        labelForName.textColor = UIColor(hex: 0x666666)
        labelForName.numberOfLines = 1
        labelForName.textAlignment = .center
        contentView.addSubview(labelForName)
        labelForName.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatar.snp.bottom).offset(10)
            make.height.equalTo(RankListPreviewColletionUX.nameLabelHeight)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
        }
    }

    func setInfo(model: TSUserInfoModel) {
        cellModel = model
        // 1.头像
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = model.avatar?.url
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        avatar.avatarInfo = avatarInfo

        // 2.标题
        labelForName.text = model.name
    }
}
