//
//  TSFriendListCell.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSFriendListCellDelegate: class {
    func cell(userId: Int, chatName: String)
}

class TSFriendListCell: UITableViewCell {

    static let identifier = "TSFriendListCell"

    weak var delegate: TSFriendListCellDelegate?

    var userIdString: Int? = 0
    var chatUserName: String? = ""

    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 关注按钮
    @IBOutlet weak var buttonForFollow: UIButton!
    /// 用户名
    @IBOutlet weak var labelForName: UILabel!
    /// 简介
    @IBOutlet weak var labelForIntro: UILabel!

    // MARK: - Public
    func setInfo(model: TSUserInfoModel) {
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.avatar)
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        buttonForAvatar.avatarInfo = avatarInfo
        // 聊天按钮
        buttonForFollow.setImage(#imageLiteral(resourceName: "ico_chat"), for: .normal)
        // 用户名
        labelForName.text = model.name
        // 简介
        labelForIntro.text = model.shortDesc()
        userIdString = model.userIdentity
        chatUserName = model.name
    }

    // MARK: - IBAction

    /// 点击了关注按钮
    @IBAction func followButtonTaped() {
        delegate?.cell(userId: userIdString!, chatName: chatUserName!)
    }
}
