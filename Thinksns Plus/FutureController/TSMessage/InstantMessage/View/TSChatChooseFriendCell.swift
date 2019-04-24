//
//  TSChatChooseFriendCell.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/12.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSChatChooseFriendCellDelegate: class {
    func chatButtonClick(chatbutton: UIButton, userModel: TSUserInfoModel)
}

class TSChatChooseFriendCell: UITableViewCell {

    weak var delegate: TSChatChooseFriendCellDelegate?
    /// 头像
    var avatarImageView: AvatarView!
    /// 昵称
    var nameLabel: UILabel!
    /// 聊天按钮
    var chatButton: UIButton!
    var userIdString: Int? = 0
    var chatUserName: String? = ""
    var userInfo: TSUserInfoModel? = nil
    var currentChooseArray = NSMutableArray()
    var originData = NSMutableArray()
    /// 是否是增删成员 "" 为正常创建聊天 add 为增加成员  delete 为删减成员
    var ischangeGroupMember: String? = ""

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatSubView()
    }

    func creatSubView() {

        chatButton = UIButton(frame: CGRect(x: 15, y: (66 - 15) / 2.0, width: 15, height: 15))
        chatButton.layer.masksToBounds = true
        chatButton.layer.cornerRadius = 15 / 2.0
        chatButton.layer.borderWidth = 1
        chatButton.layer.borderColor = UIColor(hex: 0xededed).cgColor
        chatButton.setImage(UIImage(named: "msg_box_choose_now"), for: UIControlState.selected)
        chatButton.setImage(nil, for: .normal)
        chatButton.addTarget(self, action: #selector(changeButtonStatus), for: UIControlEvents.touchUpInside)
        self.addSubview(chatButton)

        chatButton.isSelected = false

        avatarImageView = AvatarView(frame: CGRect(x: chatButton.right + 15, y: 0, width: 38, height: 38))
        avatarImageView.centerY = chatButton.centerY
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
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.avatar)
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        avatarImageView.avatarInfo = avatarInfo
        // 用户名
        nameLabel.text = model.name
        userIdString = model.userIdentity
        chatUserName = model.name
        chatButton.isSelected = false
        // 设置默认的高亮选中的勾
        chatButton.setImage(UIImage(named: "msg_box_choose_now"), for: UIControlState.selected)
        for (_, model) in currentChooseArray.enumerated() {
            let userinfo: TSUserInfoModel = model as! TSUserInfoModel
            if userinfo.userIdentity == userInfo?.userIdentity {
                chatButton.isSelected = true
                break
            }
        }
        guard ischangeGroupMember == "add" else {
            return
        }
        // 设置特定的选项为不可选中的勾
        for (_, model) in originData.enumerated() {
            let userinfo: TSUserInfoModel = model as! TSUserInfoModel
            if userinfo.userIdentity == userInfo?.userIdentity {
                chatButton.isSelected = true
                chatButton.setImage(UIImage(named: "msg_box_choose_before"), for: UIControlState.selected)
                break
            }
        }
    }

    func changeButtonStatus() {
        delegate?.chatButtonClick(chatbutton: chatButton, userModel: userInfo!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
