//
//  TSGroupNewOwnerCell.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSGroupNewOwnerCell: UITableViewCell {

    /// 头像
    var avatarImageView: AvatarView!
    /// 昵称
    var nameLabel: UILabel!
    var userIdString: Int? = 0
    var chatUserName: String? = ""

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.creatSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func creatSubView() {
        avatarImageView = AvatarView(frame: CGRect(x: 10, y: 14.5, width: 38, height: 38))
        self.addSubview(avatarImageView)

        nameLabel = UILabel(frame: CGRect(x: avatarImageView.right + 15, y: 0, width: ScreenWidth - avatarImageView.right - 15, height: 67))
        nameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.list.rawValue)
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.textAlignment = NSTextAlignment.left
        self.addSubview(nameLabel)

        let lineView = UIView(frame: CGRect(x: 0, y: 67, width: ScreenWidth, height: 0.5))
        lineView.backgroundColor = UIColor(hex: 0xededed)
        self.addSubview(lineView)
    }

    func setUserInfoData(model: TSUserInfoModel) {
        avatarImageView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.avatar)
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        avatarImageView.avatarInfo = avatarInfo
        // 用户名
        nameLabel.text = model.name
        // 简介
        userIdString = model.userIdentity
        chatUserName = model.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
