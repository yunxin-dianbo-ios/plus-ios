//
//  TSDetailRewardListViewCellCollectionViewCell.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDetailRewardListViewCellCollectionViewCell: UICollectionViewCell {
    var avatar: AvatarView!
    var user: TSUserInfoModel! {
        didSet {
            reloadUser()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        let avatar = AvatarView(type: AvatarType.width20(showBorderLine: false))
        avatar.isUserInteractionEnabled = false
        self.avatar = avatar
        self.addSubview(avatar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.frame = self.bounds
    }

    func reloadUser() {
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: user.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: self.user.avatar)
        avatarInfo.verifiedIcon = self.user.verified?.icon ?? ""
        avatarInfo.verifiedType = self.user.verified?.type ?? ""
        self.avatar.avatarInfo = avatarInfo
    }
}
