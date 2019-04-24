//
//  MessageViewController.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  消息页面根控制器,持有切换2个子控制器

import UIKit

class MessageViewController: TSLabelViewController {
    /// 会话控制器
    let conversationVC: TSConversationTableViewController
    /// IM第二版聊天列表页面(新构造的)
    let chatListNewVC: ChatListViewController
    /// 是否将通知控制器添加为子控制器
    var isAddNotiVC = false
    /// 网络控制器
    lazy var unreadCountNetworkManager = UnreadCountNetworkManager()
    /// 发起聊天按钮
    fileprivate weak var chatButton: UIButton!
    /// 我的群聊
    fileprivate weak var groupButton: UIButton!

    override init(labelTitleArray: [String], scrollViewFrame: CGRect?, isChat: Bool = false) {
        self.conversationVC = TSConversationTableViewController(style: .plain, model: MessageViewController.pasteNiticeModel())
        self.chatListNewVC = ChatListViewController()
        super.init(labelTitleArray: labelTitleArray, scrollViewFrame: scrollViewFrame, isChat: isChat)
        self.conversationVC.superViewController = self
        self.chatListNewVC.superViewController = self
        self.add(childViewController: chatListNewVC, At: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("该控制器不支持")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setChatButton()
        setGroupButton()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUnreadInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(loadUnreadInfo), name: NSNotification.Name.APNs.receiveNotice, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.APNs.receiveNotice, object: nil)
    }

    // MARK: - 设置发起聊天按钮（设置右上角按钮）
    func setChatButton() {
        let chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(chatItem, title: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatItem)
        self.chatButton = chatItem
        self.chatButton.setImage(UIImage(named: "ico_spchat"), for: UIControlState.normal)
        self.chatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.chatButton.width - (self.chatButton.currentImage?.size.width)!, bottom: 0, right: 0)
    }

    // MARK: - 已经加入的群聊按钮
    func setGroupButton() {
        let chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(leftButtonClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: chatItem)
        self.groupButton = chatItem
        self.groupButton.setImage(UIImage(named: "ico_title_group"), for: UIControlState.normal)
        self.groupButton.size = CGSize(width: 24, height: 24)
    }

    func loadUnreadInfo() {
        self.unreadCountNetworkManager.unreadCount { [weak self] (_) in
            guard let weakSelf = self else {
                return
            }
            // 整合数据给子视图 然后刷新
            DispatchQueue.main.async {
                weakSelf.countUnreadInfo()
                weakSelf.conversationVC.noticeCellModel = MessageViewController.pasteNiticeModel()
                weakSelf.conversationVC.tableView.reloadData()
            }
        }
    }

    open func countUnreadInfo() {
        DispatchQueue.main.async {
            let unreadInfo = TSCurrentUserInfo.share.unreadCount
            var imMessageCount = unreadInfo.imMessage
            if imMessageCount < 0 {
                imMessageCount = 0
            }
            self.badges[1].isHidden = imMessageCount.isEqualZero
            if unreadInfo.isHiddenNoticeBadge && unreadInfo.onlyNoticeUnreadCount().isEqualZero {
                self.badges[0].isHidden = true
            } else {
                self.badges[0].isHidden = false
            }
            self.unreadCountNetworkManager.unploadTabbarBadge()
        }
    }

    func setupUI() {
        scrollView.backgroundColor = TSColor.inconspicuous.background
        add(childViewController: conversationVC, At: 0)
    }

    static func pasteNiticeModel() -> [NoticeConversationCellModel] {
        if TSCurrentUserInfo.share.isLogin == false {
            return []
        } else {
            let unreadInfo = TSCurrentUserInfo.share.unreadCount
            let systemModel = NoticeConversationCellModel(title: "系统消息", content: unreadInfo.systemInfo ?? "暂无系统消息", badgeCount: unreadInfo.system, date: unreadInfo.systemTime, image: "ico_message_systerm")
            let commentModel = NoticeConversationCellModel(title: "收到的评论", content: unreadInfo.commentsUsers ?? "显示_收到的评论占位字".localized, badgeCount: unreadInfo.comments, date: unreadInfo.commentsUsersDate, image: "IMG_message_comment")
            let likeModel = NoticeConversationCellModel(title: "收到的赞", content: unreadInfo.likedUsers ?? "显示_收到的赞占位字".localized, badgeCount: unreadInfo.like, date: unreadInfo.likeUsersDate, image: "IMG_message_good")
            let pendModel = NoticeConversationCellModel(title: "审核通知", content: unreadInfo.pendingUsers ?? "显示_审核通知占位字".localized, badgeCount: unreadInfo.pending, date: unreadInfo.pendingUsersDate, image: "IMG_ico_message_check")
            var atStr = unreadInfo.atUsers ?? "显示_收到的at占位字".localized
            if atStr.isEmpty {
                atStr = "显示_收到的at占位字".localized
            }
            let atModel = NoticeConversationCellModel(title: "@我的", content: atStr, badgeCount: unreadInfo.at, date: unreadInfo.pendingUsersDate, image: "ico_@")

            return [systemModel, atModel, commentModel, likeModel, pendModel]
        }
    }

    override func selectedPageChangedTo(index: Int) {
        if index == 0 { // 当视图切换到第一个时,刷新通知信息
            loadUnreadInfo()
            chatListNewVC.searchBar?.resignFirstResponder()
        }
        // 当视图切换到第二个页面且未成功添加子视图时,添加通知视图
        if index == 1 && isAddNotiVC == false {
            isAddNotiVC = true
            add(childViewController: chatListNewVC, At: 1)
        }
    }

    // MARK: - 发起聊天按钮点击事件（右上角按钮点击事件）
    func rightButtonClick() {
        let vc = TSChatFriendListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - 已加入群聊入口
    func leftButtonClick() {
        let vc = JoinedGroupListVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
