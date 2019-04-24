//
//  TSNewsLikedUsersView.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞用户视图

import UIKit
import SnapKit

class TSLikedUsersView: UIControl {
    /// 用户头像组
    var avatars: [AvatarView] = []
    /// 用户数量标签
    weak var usersCountLabel: UILabel!
    /// 数据,资讯数据和点赞用户数据
    var data: (likeCount: Int, users: [TSUserInfoModel])? {
        didSet {
            updateData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // avatar
        for _ in 0...5 {
            let button = AvatarView(type: AvatarType.width26(showBorderLine: true))
            button.isUserInteractionEnabled = false
            avatars.append(button)
        }
        for btn in avatars.reversed() {
            addSubview(btn)
        }
        for (index, btn) in avatars.enumerated() {
            btn.snp.makeConstraints({ (mark) in
                mark.size.equalTo(CGSize(width: 26, height: 26))
                mark.centerY.equalToSuperview()
                mark.left.equalToSuperview().offset(index * 16)
            })
        }
        // usersCount
        let usersCountLabel = UILabel()
        usersCountLabel.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue)
        usersCountLabel.textColor = TSColor.main.theme
        self.usersCountLabel = usersCountLabel

        self.addSubview(usersCountLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("暂时不支持xib使用")
    }

    func updateData() {
        guard let data = data else {
            return
        }
        if data.1.isEmpty || data.0 < 0 {
            self.isHidden = true
            self.isEnabled = false
            return
        }
        self.isHidden = false
        self.isEnabled = true
        let users = data.1
        let count = users.count > 5 ? 5 : users.count
        for btn in avatars {
            btn.isHidden = true
        }
        for index in 0..<count {
            let avatarButton = avatars[index]
            avatarButton.isHidden = false
            avatarButton.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: users[index].sex)
            //avatarButton.userIdentity = users[index].userIdentity
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:users[index].avatar)
            avatarButton.avatarInfo = avatarInfo
        }
        usersCountLabel.text = String(format: "%d人点赞", data.likeCount)
        usersCountLabel.sizeToFit()

        usersCountLabel.snp.remakeConstraints { (mark) in
            mark.centerY.equalToSuperview()
            mark.left.equalToSuperview().offset((count + 1) * 16 + 5)
        }
    }
}
