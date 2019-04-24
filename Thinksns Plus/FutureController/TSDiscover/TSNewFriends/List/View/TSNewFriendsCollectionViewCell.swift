//
//  TSNewFriendsCollectionViewCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/6/21.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSNewFriendsCollectionViewCell: UICollectionViewCell {
    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 用户名
    @IBOutlet weak var lableForName: UILabel!
    /// 粉丝
    @IBOutlet weak var labelForFuns: UILabel!
    func setInfo(model: TSUserInfoModel) {
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.avatar)
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        buttonForAvatar.avatarInfo = avatarInfo
        // 用户名
       lableForName.text = model.name
       //粉丝
        labelForFuns.text = "粉丝: " + TSAppConfig.share.pageViewsString(number:model.extra?.followersCount ?? 0)
    }
    func setFriendInfo(model: TSUserInfoModel) {
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.avatar)
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        buttonForAvatar.avatarInfo = avatarInfo
        // 用户名
        lableForName.text = model.name
        //粉丝
        labelForFuns.text = "粉丝: " + TSAppConfig.share.pageViewsString(number:model.extra?.followersCount ?? 0)
    }
}
