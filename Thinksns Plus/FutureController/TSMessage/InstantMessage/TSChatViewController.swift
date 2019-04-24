//
//  TSChatViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  聊天视图控制器

import UIKit
import Kingfisher
import RealmSwift
import SwiftDate
import MJRefresh
import JSQMessagesViewController

class TSChatViewController: JSQMessagesViewController, TSCustomAcionSheetDelegate, EMChatManagerDelegate, EMGroupManagerDelegate {
    // MARK: 常量
    var incomingUserIdentity: Int?
    /// 头像尺寸
    var avatarSizeType: AvatarType? = nil
    /// 会话信息
    var conversationObject: TSConversationObject?
    /// 聊天视图头像宽和高
    let kTSMessagesAvatarViewNumber = 40.0
    /// 气泡顶部标签高度(该标签是显示用户名的标签)
    let kTSMessagesBubbleTopLabelHeight = 30.0
    let kTimeLabelHeight = 37.5
    /// 发送时间的 tag 值
    let kTimeLabelTag = 10_085
    /// 发送错误按钮的tag 值
    let kErrorButtonTag = 10_044
    // MARK: 变量
    /// 输入文字字数显示标签
    var inputTextnumber: UILabel = UILabel()
    /// 发送按钮
    var sendButton: UIButton?
    /// 消息单页数量
    let pageCount = 20
    /// 当前显示的最旧消息的时间
    ///
    /// - Note: 记录下来用户查询数据库显示更旧的消息
    var oldestMessageDate: NSDate? = nil
    /// 消息数组
    lazy var messages = [TSQMessage]()
    /// 重发按钮 (感叹号)
    ///
    /// - Note: 按钮的`tag`等于发送消息时的时间戳,在重发时作为标记删除旧数据时也会使用`tag`
    var currentResenderButton: TSRemindButton? = nil
    /// 聊天对方的头像
    var incomingAvatar: UIImage?
    /// 自己的头像
    var currentUserAvatar: UIImage?
    /// 占位头像
    lazy var placeholderHeaderImage = UIImage(named: "IMG_pic_default_portrait1")

    // MARK: 私有
    let incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage(named: "IMG_bg_chat_blue"), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: TSColor.small.incomingBubble)
    let outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage(named: "IMG_bg_chat_blue"), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: TSColor.small.outgoingBubble)

    /// 数据库消息
    var messageObjects: Results<TSMessageObject>? = nil
    /// 数据库口令
    private var notificationToken: NotificationToken?

    /// 环信
    var currentConversattion: EMConversation?
    var currentConversationType: EMConversationType?
    var cuurentConversationId: String?
    var currentConversationName: String?
    var hyOriginMessages = NSMutableArray()

    /// 环信原生消息类型数组
    var messsagesSource = NSMutableArray()
    /// 作为cell传值的数组 用环信原生数据数组处理后的
    var dataArray = NSMutableArray()
    var messageTimeIntervalTag = TimeInterval()

    var lastMessageId: String? = ""

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupChatInfo()
        setupRefresh()
        setupDataBase()
        setupInputToolbar()
        setupConversation()
        setupHeaderImage()

        /// 环信
        registerNotifications()
        setHyMessageReaded()
        loadHyMessagesBefore(messageId: lastMessageId!, count: pageCount, isAppend: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let conversationObject = conversationObject {
            TSDatabaseManager().chat.read(messages: conversationObject.identity)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let conversationObject = conversationObject {
            TSDatabaseManager().chat.read(messages: conversationObject.identity)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    deinit {
        messageObjects = nil
        notificationToken?.invalidate()
    }

    // MARK: user interface
    func setUI() {
        // 添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        collectionView.addGestureRecognizer(tap)
    }

    func avatarTaped() {
        // 点击了 cell 上的头像
    }

    func endEditing() {
        view.endEditing(true)
    }

    // MARK: setup
    func setupRefresh() {
        self.collectionView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
    }

    func setupDataBase() {
        guard let conversationObject = conversationObject  else {
            collectionView.mj_header.isHidden = true
            return
        }
        messageObjects = TSDatabaseManager().chat.getMessages(with: conversationObject.identity, messageDate: nil)
        notificationToken = messageObjects!.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.process(messages: self.messageObjects!)
                self.collectionView.reloadData()
                break
            case .update:
                break
            case .error(let err):
                // 获取数据库信息错误
                fatalError("\(err)")
                break
            }
        }
    }

    /// 没有聊天信息时,检查是否数据库,没有就创建聊天
    func setupConversation() {
        guard conversationObject == nil else {
            return
        }
        // 查询数据库
        conversationObject = TSDatabaseManager().chat.getConversationInfo(withUserInfoId: incomingUserIdentity!)
        guard conversationObject == nil else {
            self.setupDataBase()
            return
        }
        TSChatTaskManager.startChat(with: incomingUserIdentity!) { [unowned self] (error) in
            if error == nil {
                self.conversationObject = TSDatabaseManager().chat.getConversationInfo(withUserInfoId: self.incomingUserIdentity!)
                self.setupDataBase()
            }
        }
    }

    /// 发送消息
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        guard let conversationObject = conversationObject else {
//            setupConversation()
//            let podView = TSAllKindsOfPopView(title: "似乎断开了网络连接,稍后再试", isFail: true, complete: {
//            })
//            podView.itsShowTime()
//            return
//        }
        let nsDate = date as NSDate
//        let sendMessage = TSMessage(fromUserID: Int(senderId)!, conversationID: conversationObject.identity, messageContent: text, sendDate: nsDate)
        let message = TSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        message?.sendErrorButtonTag = nsDate

        /// 环信发消息
        self.sendTextMessgae(message: message!)
    }

    /// 点击重发
    func pressResend(sender: TSRemindButton) {
        let actionSheet = TSCustomActionsheetView(titles: ["重发消息"])
        actionSheet.delegate = self
        currentResenderButton = sender
        if inputToolbar.contentView.textView.isFirstResponder {
            inputToolbar.contentView.textView.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.22, execute: { // 键盘收起动画时间
                actionSheet.show()
            })
        } else {
            actionSheet.show()
        }
    }

    /// TSCustomActionsheetView delegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        let sendFailedMessage: EMMessage = self.hyOriginMessages[currentResenderButton!.buttonOfCellIndex] as! EMMessage
        /// 再用环信代理异步去发送消息，成功则刷新，不成功则检索出这条失败的消息，打上发送失败的状态，再刷新
        EMClient.shared().chatManager.send(sendFailedMessage, progress: { (progress) in

        }) { (sucMessage, sendError) in
            if sendError == nil {
                /// 重发送成功改变状态
                self.refreshAfterSentMessage(hyMessage: sucMessage!, succuce: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
            } else {
                /// 失败了打上失败状态，刷新
                if sucMessage != nil {
                    self.refreshAfterSentMessage(hyMessage: sucMessage!, succuce: false)
                } else {
                    self.refreshAfterSentMessage(hyMessage: sendFailedMessage, succuce: false)
                }
            }
        }

//        // 根据重发按钮的行号找到旧的信息
//        let message = messages[currentResenderButton!.buttonOfCellIndex]
//        let sendMessageTime = message.sendErrorButtonTag
//        guard let oldMessage = TSDatabaseManager().chat.getMessageObject(with: sendMessageTime!) else {
//            assert(false, "查询到了错误的数据")
//            return
//        }
//        let messageContent = oldMessage.messageContent
//        TSDatabaseManager().chat.delete(message: oldMessage) // 删除数据库旧数据
//        let buttonOfCellIndex = currentResenderButton!.buttonOfCellIndex
//        messages.remove(at: buttonOfCellIndex)
//        didPressSend(currentResenderButton!, withMessageText: messageContent, senderId: senderId, senderDisplayName: senderDisplayName, date: Date())
//        currentResenderButton = nil
    }

    // MARK: - Data process
    func process(object: TSMessageObject!) -> TSQMessage {
        let senderDisplayName = object.fromUserID == Int(self.senderId) ? self.senderDisplayName : self.conversationObject?.incomingUserName
        let senderId = object.fromUserID == Int(self.senderId) ? self.senderId : "\(object.fromUserID)"
        let outgoingStatus = object.isOutgoing.value
        let message = TSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: object.responseTimeStamp as Date!, text: object.messageContent)
        message?.outgoingStatus = outgoingStatus
        message?.sendErrorButtonTag = object.timeStamp
        return message!
    }

    func process(messages: Results<TSMessageObject>) {
        guard messages.isEmpty != true else {
            collectionView.mj_header.isHidden = true
            return
        }
        if messages.count > pageCount {
            collectionView.mj_header.isHidden = false
        } else {
            collectionView.mj_header.isHidden = true
        }
        let messageCount = messages.count > pageCount ? pageCount : messages.count
        for index in 0..<messageCount {
            let message = self.process(object: messages[index])
            self.messages.insert(message, at: 0)
        }
        self.oldestMessageDate = messages[messageCount - 1].responseTimeStamp
        assert(oldestMessageDate != nil, "参数错误")
    }

    /// 点击头像跳转用户主页
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        let message = messages[indexPath.row]
        let userIdentity = Int(message.senderId)!

        let userHomPage = TSHomepageVC(userIdentity)
        navigationController?.pushViewController(userHomPage, animated: true)
    }

    /// 点击了 cell
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        endEditing()
    }

    /// 点击了气泡
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        endEditing()
    }

    // MARK: - 注册环信聊天代理
    func registerNotifications() {
        self.unregisterNotifications()
        EMClient.shared().chatManager.add(self as EMChatManagerDelegate, delegateQueue: nil)
        EMClient.shared().groupManager.add(self as EMGroupManagerDelegate, delegateQueue: nil)
    }

    // MARK: - 移除聊天代理
    func unregisterNotifications() {
        EMClient.shared().chatManager.remove(self as EMChatManagerDelegate)
        EMClient.shared().groupManager.removeDelegate(self)
    }

    // MARK: - 进入聊天室之后，需要把所有未读消息设置已读
    func setHyMessageReaded() {
        self.currentConversattion = EMClient.shared().chatManager.getConversation(self.cuurentConversationId, type: self.currentConversationType!, createIfNotExist: true)
        var resultError: EMError? = nil
        self.currentConversattion?.markAllMessages(asRead: &resultError)
    }

//    func refresh() {
//        guard collectionView.mj_header.isHidden == false else {
//            return
//        }
//        collectionView?.mj_header.beginRefreshing()
//        let messages = TSDatabaseManager().chat.getMessages(with: conversationObject!.identity, messageDate: oldestMessageDate)
//        process(messages: messages)
//        collectionView?.mj_header.endRefreshing()
//        collectionView?.reloadData()
//    }

    // MARK: - 加载环信历史消息
    func loadHyMessagesBefore(messageId: String, count: Int, isAppend: Bool) {
        self.messageTimeIntervalTag = -1
        self.currentConversattion = EMClient.shared().chatManager.getConversation(cuurentConversationId, type: self.currentConversationType!, createIfNotExist: true)
        self.currentConversattion?.loadMessagesStart(fromId: messageId, count: Int32(count), searchDirection: EMMessageSearchDirectionUp, completion: { (aMessage, aError) in
            if aError == nil && ((aMessage?.count) != 0) {
                let originArray = NSMutableArray(array: aMessage!)
                self.hyOriginMessages.removeAllObjects()
                self.hYmesssgeTransfToTSMessage(originArray: originArray, isAppend: isAppend)
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: NSIndexPath(row: self.messages.count - 1, section: 0) as IndexPath, at: UICollectionViewScrollPosition.top, animated: false)
            }
        })
    }

    func hYmesssgeTransfToTSMessage(originArray: NSMutableArray, isAppend: Bool) {

        for messageData in originArray {
            let message: EMMessage = messageData as! EMMessage
            let textBody: EMTextMessageBody = message.body as! EMTextMessageBody
            let messageDate = NSDate(timeIntervalSince1970: TimeInterval(message.timestamp / 1_000))
            var chatName: String? = nil
            let currentUid: Int = Int(message.from)!

            if currentUid == TSCurrentUserInfo.share.userInfo?.userIdentity {
                chatName = TSCurrentUserInfo.share.userInfo?.name
            } else {
                chatName = title
            }
            let newMessage = TSQMessage(senderId: String(message.from), senderDisplayName: chatName, date: messageDate as Date!, text: textBody.text)
            if currentUid == TSCurrentUserInfo.share.userInfo?.userIdentity {
                if message.status == EMMessageStatusFailed {
                    newMessage?.outgoingStatus = false
                } else {
                    newMessage?.outgoingStatus = true
                }
            }
            self.hyOriginMessages.add(message)
            self.messages.append(newMessage!)
        }
    }

    // MARK: - 环信原生消息处理（转换）
    func changeHyMessage(originArray: NSMutableArray, isAppend: Bool) {
        let formattedMessages = self.formatMessages(messageData: originArray)
        var scrollToIndex = 0
        if isAppend {
            self.messsagesSource.insert(originArray as! [Any], at: NSIndexSet(indexesIn: NSRange(location: 0, length: originArray.count)) as IndexSet)
            let firstMessage = self.dataArray.firstObject
            if firstMessage is String {
                let timestamp = firstMessage
                formattedMessages.enumerateObjects(options: NSEnumerationOptions.reverse, using: { (model, idx, stop) in
                    if model is String && timestamp == model as! _OptionalNilComparisonType {
                        self.dataArray.removeObject(at: 0)
                    }
                })
                scrollToIndex = self.dataArray.count
                self.dataArray.insert(formattedMessages as! [Any], at: NSIndexSet(indexesIn: NSRange(location:0, length: formattedMessages.count)) as IndexSet)
            }
        } else {
            self.messsagesSource.removeAllObjects()
            self.messsagesSource.add(originArray)
            self.dataArray.removeAllObjects()
            self.dataArray.add(formattedMessages)
        }
        let latest: EMMessage = self.messsagesSource.lastObject as! EMMessage
        messageTimeIntervalTag = TimeInterval(latest.timestamp / 1_000)
    }

    // MARK: - 格式化环信消息(处理加一个时间文本消息)
    func formatMessages(messageData: NSMutableArray) -> NSMutableArray {
        let finalMessageArray = NSMutableArray()
        if messageData.count == 0 {
            return finalMessageArray
        }
        for message in messageData {
            let transfMessage: EMMessage? = message as? EMMessage
            let interval = messageTimeIntervalTag - Double((transfMessage?.timestamp)!) / 1_000
            if self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60 {
                let messageDate = NSDate(timeIntervalSince1970: TimeInterval(transfMessage!.timestamp / 1_000))
                let timeMessageText = TSDate().dateString(.detail, nsDate: messageDate)
                print("聊天信息时间 = \(timeMessageText) 时间戳 = \(String(describing: transfMessage?.timestamp)) 两次信息时间差 = \(interval)")
                finalMessageArray.add(timeMessageText)
                self.messageTimeIntervalTag = TimeInterval(((transfMessage?.timestamp)! / 1_000))
            }
            finalMessageArray.add(transfMessage as Any)
        }
        return finalMessageArray
    }

    // MARK: - 环信接受消息回调
    func messagesDidReceive(_ aMessages: [Any]!) {
        let messaA = NSMutableArray(array: aMessages)
        self.hYmesssgeTransfToTSMessage(originArray: messaA, isAppend: true)
        collectionView.reloadData()
        self.collectionView.scrollToItem(at: NSIndexPath(row: self.messages.count - 1, section: 0) as IndexPath, at: UICollectionViewScrollPosition.top, animated: false)

        /// 暂时全部设置为已读状态(如果当前页面是聊天详情页的话)
        let currentVC: UIViewController = TSAccountRegex.getCurrentVC()
        if currentVC.isKind(of: TSChatViewController.self) {
            for messageStatus in messaA {
                let hyMessage: EMMessage = messageStatus as! EMMessage
                var resultError: EMError? = nil
                self.currentConversattion?.markMessageAsRead(withId: hyMessage.messageId, error: &resultError)
            }
        }
    }

    func sendTextMessgae(message: TSQMessage) {
        let messageBody: EMTextMessageBody = EMTextMessageBody(text: message.text)
        let messageFrom = EMClient.shared().currentUsername
        let messageReal = EMMessage(conversationID: self.cuurentConversationId, from: messageFrom, to: self.cuurentConversationId, body: messageBody, ext: nil)
        messageReal?.chatType = EMChatTypeChat

        /// 先把消息加入数据源（此时不考虑发送是否成功）
        let messaA = NSMutableArray(object: messageReal as Any)
        self.hYmesssgeTransfToTSMessage(originArray: messaA, isAppend: true)
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: NSIndexPath(row: self.messages.count - 1, section: 0) as IndexPath, at: UICollectionViewScrollPosition.top, animated: false)
        self.finishSendingMessage(animated: true)

        /// 再用环信代理异步去发送消息，成功则刷新，不成功则检索出这条失败的消息，打上发送失败的状态，再刷新
        EMClient.shared().chatManager.send(messageReal, progress: { (progress) in

        }) { (sucMessage, sendError) in
            if sendError == nil {
                /// 发送成功目前不处理 保持原状
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
            } else {
                /// 失败了打上失败状态，刷新
                if sucMessage != nil {
                    self.refreshAfterSentMessage(hyMessage: sucMessage!, succuce: false)
                } else {
                    self.refreshAfterSentMessage(hyMessage: messageReal!, succuce: false)
                }
            }
        }
    }

    // MARK: - 发送消息成功之后刷新页面
    func refreshAfterSentMessage(hyMessage: EMMessage, succuce: Bool) {

        if self.hyOriginMessages.count > 0 && EMClient.shared().options.sortMessageByServerTime {
            let currentId = hyMessage.messageId
            let lastMessage = self.hyOriginMessages.lastObject
            var messageIndex = NSNotFound
            if lastMessage is EMMessage {
                self.hyOriginMessages.enumerateObjects(options: NSEnumerationOptions.reverse, using: { (model, idx, stop) in
                    if model is EMMessage {
                        let msg = model as? EMMessage
                        if currentId == msg?.messageId {
                            messageIndex = idx
                        }
                    }
                })
                if messageIndex != NSNotFound {
                    hyMessage.status = succuce ? EMMessageStatusSucceed : EMMessageStatusFailed
                    self.hyOriginMessages.replaceObject(at: messageIndex, with: hyMessage)
                    self.messages.removeAll()
                    for messageData in self.hyOriginMessages {
                        let message: EMMessage = messageData as! EMMessage
                        let textBody: EMTextMessageBody = message.body as! EMTextMessageBody
                        let messageDate = NSDate(timeIntervalSince1970: TimeInterval(message.timestamp / 1_000))
                        var chatName: String? = nil
                        let currentUid: Int = Int(message.from)!

                        if currentUid == TSCurrentUserInfo.share.userInfo?.userIdentity {
                            chatName = TSCurrentUserInfo.share.userInfo?.name
                        } else {
                            chatName = title
                        }
                        let newMessage = TSQMessage(senderId: String(message.from), senderDisplayName: chatName, date: messageDate as Date!, text: textBody.text)
                        if currentUid == TSCurrentUserInfo.share.userInfo?.userIdentity {
                            if message.status == EMMessageStatusFailed {
                                newMessage?.outgoingStatus = false
                            } else {
                                newMessage?.outgoingStatus = true
                            }
                        }
                        self.messages.append(newMessage!)
                    }
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: NSIndexPath(row: self.messages.count - 1, section: 0) as IndexPath, at: UICollectionViewScrollPosition.top, animated: false)
                }
            }
        }
    }

    // MARK: - 收到消息送达回执
    func messagesDidDeliver(_ aMessages: [Any]!) {

    }
}
