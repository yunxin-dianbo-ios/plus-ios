//
//  JoinedGroupListCell.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/13.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class JoinedGroupListCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var gruopTagButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        // 3. 角色标识 不可响应，便于控制内边距
        gruopTagButton.setTitle("群主", for: .normal)
        gruopTagButton.layer.cornerRadius = 8
        gruopTagButton.isUserInteractionEnabled = false
        gruopTagButton.setTitleColor(UIColor.white, for: .normal)
        gruopTagButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        gruopTagButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        gruopTagButton.backgroundColor = UIColor(hex: 0xfca308)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
