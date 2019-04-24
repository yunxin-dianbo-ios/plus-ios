//
//  TSConversationTableViewCell.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  聊天会话列表 cell

import UIKit
import Kingfisher

let kTSConversationTableViewCellDefaltHeight: CGFloat = 67

protocol TSConversationTableViewCellDelegate: class {
    /// 用户的头像被点击
    func headButtonDidPress(for userId: Int)
}

class TSConversationTableViewCell: TSTableViewCell {
    @IBOutlet weak var namewith: NSLayoutConstraint!
    @IBOutlet weak var headerButton: AvatarView!
    @IBOutlet weak var nameLabel: TSLabel!
    @IBOutlet weak var contentLabel: TSLabel!
    @IBOutlet weak var timeLabel: TSLabel!
    weak var delegate: TSConversationTableViewCellDelegate?
    let countButtton = TSButton(type: .custom)
    var statusIcon = UIImageView()
    var screenGroup = UIImageView()
    var currentIndex: Int = 0
    var hidScreenGroup: Bool = true
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
            contentLabel.text = realConversationInfo.latestMessage
            countButtton.isHidden = realConversationInfo.unreadCount == 0 ? true : false
            let unreadCount = realConversationInfo.unreadCount > 99 ? 99 : realConversationInfo.unreadCount
            updateButtonFrame(unreadCount: unreadCount)
            if let latestMessageDate = realConversationInfo.latestMessageDate {
                timeLabel.isHidden = false
                timeLabel.text = TSDate().dateString(.normal, nsDate: latestMessageDate)
            } else {
                timeLabel.isHidden = true
            }
            if realConversationInfo.isSendingLatestMessage.value == false {
                // 如果最新一条消息发送失败
                contentLabel.text = "提示信息_消息发送失败".localized
            }
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
            let lastMsg = realHyConversationInfo.latestMessage
            var lastMsgTitle: String = "消息内容_清空后显示".localized
            let messageBody = lastMsg?.body
            switch messageBody?.type {
            case EMMessageBodyTypeImage?:
                lastMsgTitle = "[图片]"
                if lastMsg?.ext != nil {
                    if lastMsg?.ext["is_card"] != nil {
                        lastMsgTitle = "[名片]"
                    }
                    if lastMsg?.ext["address"] != nil {
                        lastMsgTitle = "[位置]"
                    }
                }
                break
            case EMMessageBodyTypeText?:
                let textBody: EMTextMessageBody = lastMsg!.body as! EMTextMessageBody
                let didReceiveText: String = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: textBody.text)
                lastMsgTitle = didReceiveText
                if lastMsg?.ext != nil {
                    if let letterType = lastMsg?.ext["letter"] as? String {
                        // 转发的卡片
                        if letterType == "dynamic" {
                            lastMsgTitle = "[动态]"
                        } else if letterType == "info" {
                            lastMsgTitle = "[资讯]"
                        } else if letterType == "circle" {
                            lastMsgTitle = "[圈子]"
                        } else if letterType == "post" {
                            lastMsgTitle = "[帖子]"
                        } else if letterType == "questions" {
                            lastMsgTitle = "[问题]"
                        } else if letterType == "question-answers" {
                            lastMsgTitle = "[回答]"
                        }
                    }
                    guard (lastMsg?.ext["callRecord"]) != nil else {
                        break
                    }
                    let typeString: String = lastMsg?.ext["callType"] as! String
                    var str: String = ""
                    if typeString == "voice" {
                        str = "[语音通话]"
                    } else if typeString == "video" {
                        str = "[视频通话]"
                    }
                    lastMsgTitle = "\(str)\(lastMsgTitle)"
                }
                break
            case EMMessageBodyTypeVoice?:
                lastMsgTitle = "[语音]"
                break
            case EMMessageBodyTypeLocation?:
                lastMsgTitle = "[位置]"
                break
            case EMMessageBodyTypeVideo?:
                lastMsgTitle = "[视频]"
                break
            case EMMessageBodyTypeFile?:
                lastMsgTitle = "[文件]"
                break
            default:
                break
            }
            if lastMsg?.status == EMMessageStatusFailed {
                statusIcon.isHidden = false
                contentLabel.text = "     \(lastMsgTitle)"
                contentView.addSubview(statusIcon)
            } else {
                contentLabel.text = lastMsgTitle
                statusIcon.isHidden = true
            }
            countButtton.isHidden = realHyConversationInfo.unreadMessagesCount == 0 ? true : false
            let unreadCount = realHyConversationInfo.unreadMessagesCount > 99 ? 99 : realHyConversationInfo.unreadMessagesCount
            updateButtonFrame(unreadCount: Int(unreadCount))
            if realHyConversationInfo.latestMessage == nil {
                // 可能是小助手被清空聊天消息的情况
                // 需要显示默认内容并隐藏时间
                timeLabel.isHidden = true
            } else {
                let timeInterval: TimeInterval?
                if realHyConversationInfo.latestMessage.timestamp > 140_000_000_000 as UInt64 {
                    timeInterval = TimeInterval(realHyConversationInfo.latestMessage.timestamp / 1_000)
                } else {
                    timeInterval = TimeInterval(realHyConversationInfo.latestMessage.timestamp)
                }
                let date = NSDate(timeIntervalSince1970: timeInterval!)
                timeLabel.text = TSDate().dateString(.normal, nsDate: date)
                timeLabel.isHidden = false
            }
            let timeWith = timeLabel.text?.size(maxSize: CGSize(width: ScreenWidth, height: 17), font: UIFont.systemFont(ofSize: 17)).width
            namewith.constant = ScreenWidth - timeWith! - 15 - headerButton.right - 15
            nameLabel.updateConstraints()
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
                            self.avatar = TSUtil.praseTSNetFileUrl(netFile:userInfo.avatar)
                            self.verifiedIcon = userInfo.verified?.icon
                            self.verifiedType = userInfo.verified?.type
                            self.nameLabel.text = userInfo.name
                            TSDatabaseManager().user.saveUserInfo(userInfo)
                        }
                    })
                } else {
                    /// 群
                    if hidScreenGroup {
                        screenGroup.isHidden = true
                    } else {
                        screenGroup.isHidden = false
                        screenGroup.centerY = self.nameLabel.centerY
                        contentView.addSubview(screenGroup)
                    }

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
                    /// 群
                    if hidScreenGroup {
                        screenGroup.isHidden = true
                        screenGroup.centerY = self.nameLabel.centerY
                    } else {
                        screenGroup.isHidden = false
                        contentView.addSubview(screenGroup)
                    }
                    if self.avatarInfo.avatarURL == nil || self.avatarInfo.avatarURL == "" {
                        self.headerButton.buttonForAvatar.setImage(UIImage(named: "ico_ts_assistant"), for: .normal)
                    } else {
                        self.headerButton.buttonForAvatar.kf.setImage(with: URL(string: self.avatarInfo.avatarURL!), for: .normal, placeholder: UIImage(named: "ico_ts_assistant"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                }
            }
            headerButton.buttonForAvatar.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
        }
        get {
            return _hyConversation
        }
    }

    static let cellReuseIdentifier = "TSConversationTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let unreadCount = Int(countButtton.titleLabel?.text ?? "") ?? 0
        let width: CGFloat = unreadCount > 9 ? 22 : 15
        countButtton.frame = CGRect(x: (UIScreen.main.bounds.width - 25.5 - width / 2), y: 38, width: width, height: 15)
        countButtton.layer.cornerRadius = countButtton.frame.size.height * 0.5
        statusIcon.frame = CGRect(x: 63, y: 40, width: 14, height: 14)//UIImageView.init(frame: CGRect.init(x: 63, y: 40, width: 14, height: 14))
        statusIcon.image = UIImage(named: "msg_box_remind")
        statusIcon.layer.masksToBounds = true
        statusIcon.layer.cornerRadius = 7
        screenGroup.frame = CGRect(x: ScreenWidth - 14 - 15, y: 40, width: 14, height: 14)
        screenGroup.image = UIImage(named: "ico_newslist_shield")
    }

    private func customUI() {
        headerButton.buttonForAvatar.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)

        nameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.navigation.rawValue)
        nameLabel.textColor = TSColor.main.content
        nameLabel.lineBreakMode = .byTruncatingMiddle

        contentLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.listPulse.rawValue)
        contentLabel.textColor = TSColor.normal.minor

        timeLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        timeLabel.textColor = TSColor.normal.disabled
    }

    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }

    func headerButtonAction() {
        //修改头像点击事件，会话列表页点击头像也是跳转到聊天室，并不是跳到个人主页
        self.delegate?.headButtonDidPress(for: currentIndex)
    }

    func updateButtonFrame(unreadCount: Int) {
        countButtton.setTitle(String(unreadCount), for: .normal)
        countButtton.sizeToFit()
        if countButtton.superview == nil {
            countButtton.isUserInteractionEnabled = false
            countButtton.backgroundColor = TSColor.main.warn
            countButtton.clipsToBounds = true
            countButtton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
            countButtton.titleLabel?.textColor = TSColor.main.white
            contentView.addSubview(countButtton)
        }
        countButtton.centerY = contentLabel.centerY
    }

}
