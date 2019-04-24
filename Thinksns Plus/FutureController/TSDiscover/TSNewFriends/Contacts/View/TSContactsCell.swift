//
//  TSContactsCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  通讯录 联系人邀请 cell

import UIKit

protocol TSContactsCellDelegate: class {
    func cell(_ cell: TSContactsCell, didSelectedInviteButton: UIButton)
}

class TSContactsCell: UITableViewCell {

    static let identifier = "TSContactsCell"

    weak var delegate: TSContactsCellDelegate?

    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 用户名
    @IBOutlet weak var labelForName: UILabel!
    /// 邀请按钮
    @IBOutlet weak var buttonForInvite: UIButton!

    // MARK: - Public
    func setInfo(model: TSContactModel) {
        // 头像
        buttonForAvatar.avatarInfo = AvatarInfo()
        let avatarImage = model.avatar == nil ? UIImage(named: "IMG_pic_default_secret")! : model.avatar!
        buttonForAvatar.buttonForAvatar.setImage(avatarImage, for: .normal)
        // 用户名
        labelForName.text = model.name
        // 邀请按钮
        buttonForInvite.layer.borderColor = TSColor.main.theme.cgColor
        /// 设置为主题色
        buttonForInvite.setTitleColor(TSColor.main.theme, for: .normal)
        buttonForInvite.setTitleColor(TSColor.main.theme, for: .selected)
    }

    // MARK: - IBAction

    /// 邀请按钮点击事件
    @IBAction func inviteButtonTaped() {
        delegate?.cell(self, didSelectedInviteButton: buttonForInvite)
    }
}
