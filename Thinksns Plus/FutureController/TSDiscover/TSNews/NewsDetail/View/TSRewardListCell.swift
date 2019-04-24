//
//  TSRewardListCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSRewardListCell: UITableViewCell {

    static let identifier = "TSRewardListCell"
    var rewardType: TSRewardType = .moment
    @IBOutlet weak var labelForTime: UILabel!
    @IBOutlet weak var labelForContent: UILabel!
    @IBOutlet weak var buttonForAvatar: AvatarView!

    func set(model: TSNewsRewardModel) {
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.user.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.user.avatar)
        avatarInfo.verifiedIcon = model.user.verified?.icon ?? ""
        avatarInfo.verifiedType = model.user.verified?.type ?? ""
        avatarInfo.type = .normal(userId: model.userId)
        buttonForAvatar.avatarInfo = avatarInfo
        // 内容
        var contentString = NSMutableAttributedString()
        switch self.rewardType {
        case .moment:
            contentString = NSMutableAttributedString(string: "\(model.user.name) 打赏了动态")
        case .news:
            contentString = NSMutableAttributedString(string: "\(model.user.name) 打赏了资讯")
        case .user:
            contentString = NSMutableAttributedString(string: "\(model.user.name) 打赏了用户")
        case .answer:
            contentString = NSMutableAttributedString(string: "\(model.user.name) 打赏了回答")
        case .post:
            contentString = NSMutableAttributedString(string: "\(model.user.name) 打赏了帖子")
        default:
            contentString = NSMutableAttributedString(string: "\(model.user.name) 打赏了动态")
        }
        let nameLenth = model.user.name.count
        contentString.addAttributes([NSForegroundColorAttributeName: TSColor.main.content], range: NSRange(location: 0, length: nameLenth))
        labelForContent.attributedText = contentString
        // 时间 // TODO: 替换时间
        labelForTime.text = TSDate().dateString(.normal, nsDate: model.createdDate)
    }

}
