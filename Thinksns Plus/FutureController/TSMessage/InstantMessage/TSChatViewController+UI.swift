//
//  TSChatViewController+UI.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import SwiftDate
import MJRefresh
import JSQMessagesViewController

extension TSChatViewController {
    func refresh() {
        guard collectionView.mj_header.isHidden == false else {
            return
        }
        collectionView?.mj_header.beginRefreshing()
        let messages = TSDatabaseManager().chat.getMessages(with: conversationObject!.identity, messageDate: oldestMessageDate)
        process(messages: messages)
        collectionView?.mj_header.endRefreshing()
        collectionView?.reloadData()
    }

    func setupHeaderImage() {
        setupIncomingHeaderImage(incomingUserIdentity!)
        setupCurrentUserHeaderImage(TSCurrentUserInfo.share.userInfo!.userIdentity)
    }

    private func setupIncomingHeaderImage(_ incomingUserIdentity: Int) {
        let incomingUserInfoObject = TSDatabaseManager().user.get(incomingUserIdentity)
        guard let incomingAvatarUrl = TSUtil.praseTSNetFileUrl(netFile: incomingUserInfoObject?.avatar) else {
            incomingAvatar = placeholderHeaderImage
            if incomingUserInfoObject?.sex == 1 {
                incomingAvatar = UIImage(named: "IMG_pic_default_man")
            } else if incomingUserInfoObject?.sex == 2 {
                incomingAvatar = UIImage(named: "IMG_pic_default_woman")
            } else {
                incomingAvatar = UIImage(named: "IMG_pic_default_secret")
            }
            return
        }
        if ImageCache.default.isImageCached(forKey: incomingAvatarUrl).cached {
            self.incomingAvatar = ImageCache.default.retrieveImageInDiskCache(forKey: incomingAvatarUrl)
        } else {
            incomingAvatar = placeholderHeaderImage
            if incomingUserInfoObject?.sex == 1 {
                incomingAvatar = UIImage(named: "IMG_pic_default_man")
            } else if incomingUserInfoObject?.sex == 2 {
                incomingAvatar = UIImage(named: "IMG_pic_default_woman")
            } else {
                incomingAvatar = UIImage(named: "IMG_pic_default_secret")
            }
            ImageDownloader.default.downloadImage(with: URL(string: incomingAvatarUrl)!, completionHandler: { [weak self] (image, error, _, _) in
                if let image = image {
                    ImageCache.default.store(image, forKey: incomingAvatarUrl)
                    self?.incomingAvatar = image
                    return
                }
                TSLogCenter.log.debug(error.debugDescription)
            })
        }
    }

    private func setupCurrentUserHeaderImage(_ currentUserIdentity: Int) {
        let incomingUserInfoObject = TSDatabaseManager().user.get(currentUserIdentity)
        guard let currentUserAvatarUrl = TSUtil.praseTSNetFileUrl(netFile: incomingUserInfoObject?.avatar) else {
            currentUserAvatar = placeholderHeaderImage
            if incomingUserInfoObject?.sex == 1 {
                currentUserAvatar = UIImage(named: "IMG_pic_default_man")
            } else if incomingUserInfoObject?.sex == 2 {
                currentUserAvatar = UIImage(named: "IMG_pic_default_woman")
            } else {
                currentUserAvatar = UIImage(named: "IMG_pic_default_secret")
            }
            return
        }
        guard ImageCache.default.isImageCached(forKey: currentUserAvatarUrl).cached == false else {
            currentUserAvatar = ImageCache.default.retrieveImageInDiskCache(forKey: currentUserAvatarUrl)
            return
        }
        currentUserAvatar = placeholderHeaderImage
        if incomingUserInfoObject?.sex == 1 {
            currentUserAvatar = UIImage(named: "IMG_pic_default_man")
        } else if incomingUserInfoObject?.sex == 2 {
            currentUserAvatar = UIImage(named: "IMG_pic_default_woman")
        } else {
            currentUserAvatar = UIImage(named: "IMG_pic_default_secret")
        }
        ImageDownloader.default.downloadImage(with: URL(string: currentUserAvatarUrl)!, completionHandler: { [weak self] (image, error, _, _) in
            if let image = image {
                ImageCache.default.store(image, forKey: currentUserAvatarUrl)
                self?.currentUserAvatar = image
                return
            }
            TSLogCenter.log.debug(error.debugDescription)
        })
    }

    func textFiledDidChanged(notification: Notification) {
        if let textField = notification.object as? UITextView {
            // 输入框文字字数上限
            let stringCountLimit = 255
            let maximumWordLimit = 200
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
            if textField.text.count <= maximumWordLimit {
                self.inputTextnumber.isHidden = true
                self.inputTextnumber.removeFromSuperview()
                return
            }

            // textNumberLabel
            self.inputTextnumber.textAlignment = .center
            // 此处计算处理来自 JSQMessagesToolbarContentView.xib 记录
            self.inputTextnumber.frame = CGRect(x: self.inputToolbar.frame.size.width - sendButton!.frame.width - 8 * 2, y: self.inputToolbar.frame.size.height - sendButton!.frame.height - 9.5 - 15 - 9.5, width: sendButton!.frame.width + 8 * 2, height: 15)
            self.inputTextnumber.isHidden = false
            self.inputToolbar.addSubview(self.inputTextnumber)

            let strCount = textField.text.count > stringCountLimit ? stringCountLimit : textField.text.count
            self.inputTextnumber.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: "\(strCount)" as NSString, firstColor: TSColor.normal.statisticsNumberOfWords, firstSize: TSFont.SubInfo.statisticsNumberOfWords.rawValue), second: (secondString: "/\(stringCountLimit)" as NSString, secondColor: TSColor.normal.blackTitle, TSFont.SubInfo.statisticsNumberOfWords.rawValue))
        }
    }

    func setupInputToolbar() {
        // rightBarButton
        let rightBarButton = self.inputToolbar.contentView.rightBarButtonItem
        rightBarButton?.setTitleColor(UIColor.white, for: .normal)
        rightBarButton?.setTitleColor(UIColor.white, for: .disabled)
        rightBarButton?.setTitleColor(UIColor.white, for: .highlighted)
        rightBarButton?.setBackgroundImage(UIImage.create(with: TSColor.button.normal, size: rightBarButton!.frame.size), for: .normal)
        rightBarButton?.setBackgroundImage(UIImage.create(with: TSColor.button.disabled, size: rightBarButton!.frame.size), for: .disabled)
        rightBarButton?.setBackgroundImage(UIImage.create(with: TSColor.button.highlighted, size: rightBarButton!.frame.size), for: .highlighted)
        rightBarButton?.clipsToBounds = true
        rightBarButton?.layer.cornerRadius = 4
        rightBarButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightBarButton?.frame = CGRect(x: 0, y: 0, width: 45, height: 25)
        self.inputToolbar.contentView.rightBarButtonItem = rightBarButton
        self.sendButton = rightBarButton
        // inputToolbar
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.textViewLine.backgroundColor = TSColor.main.theme
        self.inputToolbar.contentView.backgroundColor = TSColor.small.toolBarBackground
        // textView
        self.inputToolbar.contentView.textView?.placeHolder = "随便说说~"
        self.inputToolbar.contentView.textView?.layer.borderWidth = 0
        self.inputToolbar.contentView.textView?.layer.borderColor = UIColor.clear.cgColor
        self.inputToolbar.contentView.textView?.returnKeyType = .send
        self.inputToolbar.contentView.textView?.delegate = self
        self.inputToolbar.contentView.textView?.layer.cornerRadius = 0
        self.inputToolbar.contentView.textView?.backgroundColor = TSColor.small.toolBarBackground
        //  maximumHeight
        self.inputToolbar.maximumHeight = UInt(101 /**三行文本输入框高度*/) // 101s
    }

    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            guard self.sendButton!.isEnabled else {
                return false
            }
            self.didPressSend(UIButton(), withMessageText: textView.text, senderId: senderId, senderDisplayName: senderDisplayName, date: Date())
            return false
        }
        return true
    }

    func setupChatInfo() {
        senderId = "\(TSCurrentUserInfo.share.userInfo!.userIdentity)"
        senderDisplayName = TSCurrentUserInfo.share.userInfo?.name

        //区分是群还是单聊  单聊也要区分是admin还是正常用户
        if self.currentConversationType == EMConversationTypeChat {
            if self.cuurentConversationId == "admin" {
                title = "管理员"
            } else {
                if TSDatabaseManager().user.get(incomingUserIdentity!) != nil {
                    let hyUserInfo = TSDatabaseManager().user.get(incomingUserIdentity!)
                    title = hyUserInfo?.name
                } else {
                    title = currentConversationName
                }
            }
        } else {
            title = "群聊"
        }

        let avatarViewSize = CGSize(width: kTSMessagesAvatarViewNumber, height:kTSMessagesAvatarViewNumber)
        collectionView?.collectionViewLayout.incomingAvatarViewSize = avatarViewSize
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = avatarViewSize
        collectionView?.collectionViewLayout.messageBubbleFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        // 默认值 7.0f, 14.0f, 7.0f, 14.0f
        collectionView.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 2)
        collectionView.collectionViewLayout.messageBubbleTextViewFrameInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView?.showsVerticalScrollIndicator = false
        automaticallyScrollsToMostRecentMessage = true
        showLoadEarlierMessagesHeader = false

        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
    }
}

// MARK: - JSQMessages CollectionView DataSource
extension TSChatViewController {
    /// 消息数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    /// 消息数据提供给UI显示
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    /// 设置气泡样式
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }

    /// 设置头像
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        let jsqAvaterImage: JSQMessagesAvatarImage
        if message.senderId == senderId {
            assert(currentUserAvatar != nil, "获取头像时,未设置头像和默认头像")
            jsqAvaterImage = JSQMessagesAvatarImageFactory.avatarImage(with: currentUserAvatar, diameter: UInt(avatarSizeType!.width))
        } else {
            assert(incomingAvatar != nil, "获取头像时,未设置头像和默认头像")
            jsqAvaterImage = JSQMessagesAvatarImageFactory.avatarImage(with: incomingAvatar, diameter: UInt(avatarSizeType!.width))
        }
        return jsqAvaterImage
    }

    /// 设置时间显示字符显示到`单元格顶部标签`
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: "")
    }

    /// 设置用户名显示到`聊天气泡顶部标签`
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        return NSAttributedString(string: message.senderDisplayName)
    }

    /// 设置`单元格顶部标签`高度 (显示时间单元格)
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        guard indexPath.row > 0 else {
            return CGFloat(kTimeLabelHeight)
        }
        let onMessageDate = messages[indexPath.row - 1].date
        let messageDate = messages[indexPath.row].date
        if messageDate! > (onMessageDate! + 5.minute) {
            return CGFloat(kTimeLabelHeight)
        }
        return 7.5 // 距离缩小为 7.5;头像高出的部分
    }

    /// 重载该方法设置顶部高度
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20 // UI间距
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15 // UI间距
    }

    // MARK: - custom bubble
    // [坑] 以下部分和UI相关的代码,因暂时没找到更好的集成和修改JSQ 三方库的方式,所以暂时记录在该处,后续如果 聊天的页面过于的复杂时,建议将JSQ 进行修改,不建议继续再该处增加代码

    /// 配置单元格文本内容字体颜色,增加发送进度显示按钮
    /// 添加时间标签到顶部,再按照情况隐藏掉时间
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell)!
        let isLeft = cell is JSQMessagesCollectionViewCellIncoming
        let msg = messages[indexPath.row]
        cell.textView.textColor = UIColor.black
        cell.messageBubbleImageView.image = updateBubble(isLeft: isLeft)
        // 判断是否需要创建发送错误按钮
        if !cellContainsErrorButton(cell) {
            let button = TSRemindButton(type: .custom)
            button.isHidden = true
            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            button.setImage(UIImage(named: "IMG_msg_box_remind"), for: .normal)
            button.addTarget(self, action: #selector(pressResend), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = kErrorButtonTag
            cell.contentView.addSubview(button)
            let centerYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: cell.messageBubbleContainerView, attribute: .centerY, multiplier: CGFloat(1.0), constant: CGFloat(0.0))
            cell.contentView.addConstraint(centerYConstraint)
            let xConstraint: NSLayoutConstraint
            if self.senderId == msg.senderId {
                xConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: cell.messageBubbleContainerView, attribute: .left, multiplier: CGFloat(1.0), constant: CGFloat(-10))
            } else {
                xConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: cell.messageBubbleContainerView, attribute: .right, multiplier: CGFloat(1.0), constant: CGFloat(10))
            }
            cell.contentView.addConstraint(xConstraint)
        }

        // 给冲按钮带上行号,点击后会使用行号
        let remindButton = cell.viewWithTag(kErrorButtonTag) as! TSRemindButton
        remindButton.buttonOfCellIndex = indexPath.row
        // 根据消息状态处理错误按钮显示状态
        if let outgoingStatus = msg.outgoingStatus {
            remindButton.isHidden = outgoingStatus
        } else {
            remindButton.isHidden = true
        }

        // 判断是否需要显示时间标签,需要直接显示,无则创建
        if indexPath.row == 0 {
            let timeLable: UILabel?
            let dateString = TSDate().dateString(.detail, nsDate: msg.date as NSDate)
            if !cellContainsTimeLabel(cell) {
                timeLable = creatTimeLabel(time: msg.date as NSDate, superView: cell)
            } else {
                timeLable = cell.viewWithTag(kTimeLabelTag) as? UILabel
            }
            timeLable?.text = dateString
            timeLable?.isHidden = false
        } else {
            let onMessageDate = messages[indexPath.row - 1].date
            let messageDate = messages[indexPath.row].date
            if messageDate! > (onMessageDate! + 5.minute) {
                let timeLable: UILabel?
                let dateString = TSDate().dateString(.detail, nsDate: msg.date as NSDate)
                if !cellContainsTimeLabel(cell) {
                    timeLable = creatTimeLabel(time: msg.date as NSDate, superView: cell)
                } else {
                    timeLable = cell.viewWithTag(kTimeLabelTag) as? UILabel
                }
                timeLable?.text = dateString
                timeLable?.isHidden = false
            } else {
                let timeLable: UILabel?
                if !cellContainsTimeLabel(cell) {
                    timeLable = creatTimeLabel(time: msg.date as NSDate, superView: cell)
                } else {
                    timeLable = cell.viewWithTag(kTimeLabelTag) as? UILabel
                }
                timeLable?.isHidden = true
            }
        }
        return cell
    }

    func creatTimeLabel(time: NSDate, superView: UICollectionViewCell) -> UILabel {
        let dateString = TSDate().dateString(.detail, nsDate: time)
        let timeLable = UILabel()
        let timeLableFont = UIFont.systemFont(ofSize: TSFont.Time.message.rawValue)
        timeLable.textColor = UIColor.white
        timeLable.backgroundColor = TSColor.normal.keyboardTopCutLine
        timeLable.font = timeLableFont
        timeLable.layer.cornerRadius = 8
        timeLable.tag = kTimeLabelTag
        timeLable.clipsToBounds = true
        timeLable.textAlignment = .center
        let timeStringSize = dateString.heightWithConstrainedWidth(width: CGFloat(MAXFLOAT), height: 16, font: timeLableFont)
        timeLable.frame = CGRect(x: superView.frame.width / 2 - (timeStringSize.width + 10) / 2, y: 0, width: timeStringSize.width + 10, height: 16)
        timeLable.text = dateString
        superView.addSubview(timeLable)
        return timeLable
    }

    func cellContainsTimeLabel(_ cell: UICollectionViewCell) -> Bool {
        if cell.viewWithTag(kTimeLabelTag) != nil {
            return true
        } else {
            return false
        }
    }

    func cellContainsErrorButton(_ cell: UICollectionViewCell) -> Bool {
        if cell.viewWithTag(kErrorButtonTag) != nil {
            return true
        } else {
            return false
        }
    }

    /// 更新气泡图片
    func updateBubble(isLeft: Bool) -> UIImage? {
        let imageName = isLeft ? "IMG_bg_chat_grey" : "IMG_bg_chat_blue"
        let bubbleImage = UIImage(named: imageName)?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
        return bubbleImage
    }
}
