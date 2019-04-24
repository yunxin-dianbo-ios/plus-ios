//
//  TSPopMessageVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPopMessageVC: TSViewController, UISearchBarDelegate {

    /// IM第二版聊天列表页面
    var chatListVC: TSPopChatListVC!
    var superViewController: MessageViewController!
    var superMessagePop: TSPopMessageFriendList!
    var messageModel: TSmessagePopModel? = nil

    /// 搜索框
    var searchBar: TSSearchBar?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar?.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setSearchBarUI()
        self.chatListVC = TSPopChatListVC(style: .plain, model: ChatListViewController.pasteNiticeModel())
        self.chatListVC.superViewController = self.superViewController
        self.chatListVC.superMessagePop = self.superMessagePop
        self.chatListVC.pViewControllerMessage = self
        self.chatListVC.messageModel = messageModel
        self.addChildViewController(chatListVC)
        chatListVC.view.frame = CGRect(x: 0, y: 47, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 47)
        self.view.addSubview(chatListVC.view)
    }

    func setSearchBarUI() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 47))
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        self.searchBar = TSSearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: bgView.height))
        self.searchBar?.layer.masksToBounds = true
        self.searchBar?.layer.cornerRadius = 5.0
        self.searchBar?.backgroundImage = nil
        self.searchBar?.backgroundColor = UIColor.white
        self.searchBar?.returnKeyType = .search
        self.searchBar?.barStyle = UIBarStyle.default
        self.searchBar?.barTintColor = UIColor.clear
        self.searchBar?.tintColor = TSColor.main.theme
        self.searchBar?.searchBarStyle = UISearchBarStyle.minimal
        self.searchBar?.delegate = self
        self.searchBar?.placeholder = "搜索"
        bgView.addSubview(self.searchBar!)
    }

    static func pasteNiticeModel() -> [NoticeConversationCellModel] {
        if TSCurrentUserInfo.share.isLogin == false {
            return []
        } else {
            let unreadInfo = TSCurrentUserInfo.share.unreadCount
            let systemModel = NoticeConversationCellModel(title: "系统消息", content: unreadInfo.commentsUsers ?? "暂无系统消息", badgeCount: unreadInfo.comments, date: unreadInfo.commentsUsersDate, image: "ico_message_systerm")
            let commentModel = NoticeConversationCellModel(title: "收到的评论", content: unreadInfo.commentsUsers ?? "显示_收到的评论占位字".localized, badgeCount: unreadInfo.comments, date: unreadInfo.commentsUsersDate, image: "IMG_message_comment")
            let likeModel = NoticeConversationCellModel(title: "收到的赞", content: unreadInfo.likedUsers ?? "显示_收到的赞占位字".localized, badgeCount: unreadInfo.like, date: unreadInfo.likeUsersDate, image: "IMG_message_good")
            let pendModel = NoticeConversationCellModel(title: "审核通知", content: unreadInfo.pendingUsers ?? "显示_审核通知占位字".localized, badgeCount: unreadInfo.pending, date: unreadInfo.pendingUsersDate, image: "IMG_ico_message_check")

            return [systemModel, commentModel, likeModel, pendModel]
        }
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        chatListVC.searchChatList(keyWord: searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            chatListVC.searchChatList(keyWord: searchBar.text ?? "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
