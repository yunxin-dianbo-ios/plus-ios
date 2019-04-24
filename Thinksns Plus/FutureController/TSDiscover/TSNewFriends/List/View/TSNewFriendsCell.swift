//
//  TSNewFriendsCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  找人列表 关注按钮 cell

import UIKit

protocol TSNewFriendsCellDelegate: class {
    func cell(_ cell: TSNewFriendsCell, didSelectedFollowButton button: UIButton)
}

class TSNewFriendsCell: UITableViewCell {

    static let identifier = "TSNewFriendsCell"

    weak var delegate: TSNewFriendsCellDelegate?

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
        // 关注按钮
        self.buttonForFollow?.layer.cornerRadius = 3
        let praiseTitle: String?
        if let praiseTitleS = model.relationshipTextWithCurrentUser()?.rawValue {
            praiseTitle = praiseTitleS
            self.buttonForFollow?.isHidden = false
            if praiseTitleS == "已关注" || praiseTitleS == "互相关注" {
                self.buttonForFollow?.setTitleColor(TSColor.main.theme, for: .normal)
                self.buttonForFollow?.backgroundColor = UIColor.white
                self.buttonForFollow?.layer.borderColor = TSColor.main.theme.cgColor
                self.buttonForFollow?.layer.borderWidth = 0.5
            } else if praiseTitleS == "+ 关注" {
                self.buttonForFollow?.setTitleColor(UIColor.white, for: .normal)
                self.buttonForFollow?.backgroundColor = TSColor.main.theme
            } else {
                self.buttonForFollow?.isHidden = true
            }
        } else {
            praiseTitle = nil
            self.buttonForFollow?.isHidden = true
        }
        self.buttonForFollow?.setTitle(praiseTitle, for: .normal)
        // 用户名
        labelForName.text = model.name
        // 简介
        labelForIntro.text = model.shortDesc()
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
        // 聊天按钮
        buttonForFollow.setImage(#imageLiteral(resourceName: "ico_chat"), for: .normal)
        // 用户名
        labelForName.text = model.name
        // 简介
        labelForIntro.text = model.shortDesc()
    }

    // MARK: - IBAction

    /// 点击了关注按钮
    @IBAction func followButtonTaped() {
        delegate?.cell(self, didSelectedFollowButton: buttonForFollow)
    }
}
