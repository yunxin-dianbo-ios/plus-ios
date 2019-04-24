//
//  TSMessagePopCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSMessagePopCell: TSTableViewCell {
    @IBOutlet weak var headerButton: AvatarView!
    @IBOutlet weak var nameLabel: TSLabel!
    var currentIndex: Int = 0
    var avatarInfo: AvatarInfo!

    var verifiedIcon: String?
    var verifiedType: String?
    var avatar: String?
    private var _isnewUser: Bool?
    var isnewUser: Bool? {
        set {
            _isnewUser = newValue
        }
        get {
            return _isnewUser
        }
    }
    private var _avatarSizeType: AvatarType?
    var avatarSizeType: AvatarType? {
        set {
            _avatarSizeType = newValue
            headerButton.showBoardLine = false
            headerButton.frame.size = newValue?.size ?? .zero
        }
        get {
            return _avatarSizeType
        }
    }

    /// 会话信息
    private var _conversationInfo: TSConversationObject?
    var conversationInfo: TSConversationObject? {
        set {
            _conversationInfo = newValue
            guard let realConversationInfo = newValue else {
                return
            }
            nameLabel.text = realConversationInfo.incomingUserName
        }
        get {
            return _conversationInfo
        }
    }

    /// 环信会话
    private var _hyConversation: EMConversation?
    var hyConversation: EMConversation? {
        set {
            _hyConversation = newValue
            guard let realHyConversationInfo = newValue else {
                return
            }
            /// 判断下是不是小助手
            let idSt: String = (self.hyConversation?.conversationId)!
            let idInt: Int = Int(idSt)!
            var tsHelper: Bool = false
            if TSAppConfig.share.localInfo.imHelper == idInt {
                tsHelper = true
                return
            }
            if self.isnewUser! {
                if self.hyConversation?.conversationId != "admin" && self.hyConversation?.type == EMConversationTypeChat {
                    let idInt: Int = Int((self.hyConversation?.conversationId)!)!
                    TSUserNetworkingManager().getUsersInfo(usersId: [idInt], complete: { (usermodel, textString, succuce) in
                        if succuce && usermodel?.count != nil {
                            let userInfo: TSUserInfoModel = usermodel![0]
                            self.avatar = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
                            self.verifiedIcon = userInfo.verified?.icon
                            self.verifiedType = userInfo.verified?.type
                            self.nameLabel.text = userInfo.name
                            TSDatabaseManager().user.saveUserInfo(userInfo)
                        }
                    })
                } else {
                    if self.avatar == nil || self.avatar == "" {
                        self.headerButton.buttonForAvatar.setImage(UIImage(named: "ico_ts_assistant"), for: .normal)
                    } else {
                        self.headerButton.buttonForAvatar.kf.setImage(with: URL(string: self.avatar!), for: .normal, placeholder: UIImage(named: "ico_ts_assistant"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                }
            } else {
                if self.hyConversation?.conversationId != "admin" && self.hyConversation?.type == EMConversationTypeChat {
                    self.headerButton.avatarInfo = self.avatarInfo
                } else {
                    if self.avatarInfo.avatarURL == nil || self.avatarInfo.avatarURL == "" {
                        self.headerButton.buttonForAvatar.setImage(UIImage(named: "ico_ts_assistant"), for: .normal)
                    } else {
                        self.headerButton.buttonForAvatar.kf.setImage(with: URL(string: self.avatarInfo.avatarURL!), for: .normal, placeholder: UIImage(named: "ico_ts_assistant"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                }
            }
        }
        get {
            return _hyConversation
        }
    }

    static let cellReuseIdentifier = "TSMessagePopCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func customUI() {
        nameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.navigation.rawValue)
        nameLabel.textColor = TSColor.main.content
        nameLabel.lineBreakMode = .byTruncatingMiddle
    }

    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }

}
