//
//  TSMessagePopNewChatCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSMessagePopNewChatCell: UITableViewCell {

    /// 头像
    var avatarImageView: AvatarView!
    /// 昵称
    var nameLabel: UILabel!
    var userIdString: Int? = 0
    var chatUserName: String? = ""
    var userInfo: TSUserInfoModel? = nil

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatSubView()
    }

    func creatSubView() {

        avatarImageView = AvatarView(frame: CGRect(x: 15, y: (66 - 38) / 2.0, width: 38, height: 38))
        self.addSubview(avatarImageView)

        nameLabel = UILabel(frame: CGRect(x: avatarImageView.right + 15, y: 0, width: ScreenWidth - avatarImageView.right - 15, height: 66))
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.list.rawValue)
        nameLabel.textAlignment = NSTextAlignment.left
        self.addSubview(nameLabel)

        let lineView = UIView(frame: CGRect(x: 0, y: 66, width: ScreenWidth, height: 0.5))
        lineView.backgroundColor = UIColor(hex: 0xededed)
        self.addSubview(lineView)
    }

    func setUserInfoData(model: TSUserInfoModel) {
        userInfo = model
        avatarImageView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:model.avatar)
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        avatarImageView.avatarInfo = avatarInfo
        // 用户名
        nameLabel.text = model.name
        userIdString = model.userIdentity
        chatUserName = model.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
