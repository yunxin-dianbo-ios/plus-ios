//
//  TSPopChatListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Regex

class TSPopChatListVC: TSChatListTableViewController {
    var messageModel: TSmessagePopModel? = nil
    var tableHeader = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self)
        EMClient.shared().chatManager.remove(self as EMChatManagerDelegate)
        EMClient.shared().groupManager.removeDelegate(self as EMGroupManagerDelegate)
        EMClient.shared().removeDelegate(self as EMClientDelegate)
        setHeader()
    }

    override func setupTableView() {
        tableView.register(TSMessagePopCell.nib(), forCellReuseIdentifier: TSMessagePopCell.cellReuseIdentifier)
        tableView.register(NoticeConversationCell.self, forCellReuseIdentifier: "NoticeConversationCell")
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableView.mj_header.isRefreshing() == true {
            return
        }
        /// 调试用环信详情页
        let chatCell: TSMessagePopCell? = tableView.cellForRow(at: indexPath) as? TSMessagePopCell
        let chatConversation: EMConversation
        if isSearch {
            chatConversation = self.searchArray[indexPath.row] as! EMConversation
        } else {
            chatConversation = self.conversationArray[indexPath.row] as! EMConversation
        }
        messageModel?.titleSecond = chatCell?.nameLabel.text ?? ""
        let messagePopVC = TSMessagePopoutVC()
        messagePopVC.show(vc: messagePopVC)
        messagePopVC.setInfo(model: messageModel!)
        messagePopVC.sendBlock = { (sendModel) in
            let topIndicator = TSIndicatorWindowTop(state: .loading, title: "发送中..")
            topIndicator.show()
            TSIMMessageManager.sendShareCardMessage(model: sendModel, conversationId: chatConversation.conversationId, conversationType: chatConversation.type, UpProgress: { (progress) in
            }, complete: { (aMessage, aError) in
                topIndicator.dismiss()
                if aError == nil {
                    TSIndicatorWindowTop.showDefaultTime(state: .success, title: "分享成功")
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "sendMessageReloadChatListVc")))
                    /// 需求：返回进入私信分享的页面
                    self.navigationController?.popViewController(animated: true)
                } else {
                    TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "分享失败")
                }
            })
        }
    }

    override func processConversations(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSMessagePopCell.cellReuseIdentifier) as! TSMessagePopCell
        /// 区分是群还是单聊  群聊需要群头像群昵称  单聊要去拿聊天对象的头像昵称
        let conver: EMConversation
        if isSearch {
            conver = self.searchArray[indexPath.row] as! EMConversation
        } else {
            /// 异常情况
            if self.conversationArray.count <= indexPath.row {
                return cell
            }
            conver = self.conversationArray[indexPath.row] as! EMConversation
        }
        var avatarString: String? = nil
        var chatName: String? = nil
        var verifiedIcon: String? = nil
        var verifiedType: String? = nil
        cell.isnewUser = false
        let idSt: String = (conver.conversationId)!
        let idInt: Int = Int(idSt)!
        if conver.type == EMConversationTypeChat {
            if conver.conversationId == "admin" {
                chatName = "管理员"
            } else {
                if TSDatabaseManager().user.get(idInt) != nil {
                    let hyUserInfo = TSDatabaseManager().user.get(idInt)
                    avatarString = TSUtil.praseTSNetFileUrl(netFile:hyUserInfo?.avatar)
                    verifiedIcon = hyUserInfo?.verified?.icon
                    verifiedType = hyUserInfo?.verified?.type
                    chatName = hyUserInfo?.name
                } else {
                    cell.isnewUser = true
                }
            }
        } else {
            chatName = "[群聊]"
            if let groupdict = conver.groupInfo {
                let groupFace = groupdict["group_face"]
                let groupChatFace = "\(groupFace ?? "")"
                let groupName = groupdict["name"]
                var groupChatName = "\(groupName ?? "")"
                let menberNumber = groupdict["affiliations_count"] ?? ""
                groupChatName = "\(groupName ?? "")(\(menberNumber))"
                avatarString = groupChatFace
                chatName = groupChatName
            }
        }
        cell.tag = indexPath.row
        let cellLongPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressResponse(resture:)))
        cell.addGestureRecognizer(cellLongPress)
        let avatarInfo = AvatarInfo()
        avatarInfo.verifiedIcon = verifiedIcon ?? ""
        avatarInfo.verifiedType = verifiedType ?? ""
        avatarInfo.avatarURL = avatarString
        cell.avatarInfo = avatarInfo
        cell.nameLabel.text = chatName
        cell.headerButton.avatarInfo = avatarInfo
        // 群组的默认头像是在cell的hyConversation set方法中设置的
        // 所以需要在头像btn avatarInfo设置之后,否则群的默认头像会无效
        cell.hyConversation = conver
        cell.currentIndex = indexPath.row
        return cell
    }

    // MARK: - 搜索会话
    override func searchChatList(keyWord: String) {
        if keyWord.isEmpty {
            isSearch = false
            copyTableView?.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            self.searchArray.removeAllObjects()
            if self.copyTableView?.superview == nil {
                self.copyTableView?.frame = self.tableView.frame
                self.pViewControllerMessage?.view.addSubview(copyTableView!)
            }
            for (_, item) in self.conversationArray.enumerated() {
                var chatName = self.getChatName(conver: item as! EMConversation)
                // 忽略字母大小写
                chatName = chatName.lowercased()
                let lowKey = keyWord.lowercased()
                if (chatName.range(of: lowKey)) != nil {
                    self.searchArray.add(item as! EMConversation)
                }
            }
            self.isSearch = true
            self.tableView.isHidden = true
            self.copyTableView?.isHidden = false
            self.copyTableView?.reloadData()
        }
    }

    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pViewControllerMessage?.searchBar?.resignFirstResponder()
    }

    override func longPressResponse(resture: UITapGestureRecognizer) {
        return
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TSPopChatListVC {
    func setHeader() {
        tableHeader.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 133)
        tableHeader.backgroundColor = UIColor.white
        /// 创建新的聊天
        let newChatlabel = UILabel(frame: CGRect(x: 10, y: 0, width: 150, height: 66))
        newChatlabel.text = "创建新的聊天"
        newChatlabel.textColor = UIColor(hex: 0x333333)
        newChatlabel.font = UIFont.systemFont(ofSize: 17)
        tableHeader.addSubview(newChatlabel)

        let rightIconNew = UIImageView(frame: CGRect(x: ScreenWidth - 10 - 15, y: 0, width: 10, height: 20))
        rightIconNew.image = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
        rightIconNew.centerY = newChatlabel.centerY
        tableHeader.addSubview(rightIconNew)

        let newLine = UIView(frame: CGRect(x: 0, y: newChatlabel.bottom, width: ScreenWidth, height: 0.5))
        newLine.backgroundColor = TSColor.inconspicuous.disabled
        tableHeader.addSubview(newLine)

        let newChatButton = UIButton(type: .custom)
        newChatButton.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 66)
        newChatButton.backgroundColor = UIColor.clear
        newChatButton.addTarget(self, action: #selector(newChatButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        tableHeader.addSubview(newChatButton)

        /// 选择群聊
        let groupChatlabel = UILabel(frame: CGRect(x: 10, y: newLine.bottom, width: 150, height: 66))
        groupChatlabel.text = "选择群聊"
        groupChatlabel.textColor = UIColor(hex: 0x333333)
        groupChatlabel.font = UIFont.systemFont(ofSize: 17)
        tableHeader.addSubview(groupChatlabel)

        let rightIconGroup = UIImageView(frame: CGRect(x: ScreenWidth - 10 - 15, y: 0, width: 10, height: 20))
        rightIconGroup.image = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
        rightIconGroup.centerY = groupChatlabel.centerY
        tableHeader.addSubview(rightIconGroup)

        let groupLine = UIView(frame: CGRect(x: 0, y: groupChatlabel.bottom, width: ScreenWidth, height: 0.5))
        groupLine.backgroundColor = TSColor.inconspicuous.disabled
        tableHeader.addSubview(groupLine)

        let groupChatButton = UIButton(type: .custom)
        groupChatButton.frame = CGRect(x: 0, y: groupChatlabel.top, width: ScreenWidth, height: 66)
        groupChatButton.backgroundColor = UIColor.clear
        groupChatButton.addTarget(self, action: #selector(groupChatButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        tableHeader.addSubview(groupChatButton)

        self.tableView.tableHeaderView = tableHeader
    }

    func newChatButtonClick(sender: UIButton) {
        let vc = TSMessagePopNewChatVC()
        vc.messageModel = messageModel
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func groupChatButtonClick(sender: UIButton) {
        let vc = TSMessagePopGroupVC()
        vc.messageModel = messageModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
