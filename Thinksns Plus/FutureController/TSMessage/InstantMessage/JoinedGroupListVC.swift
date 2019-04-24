//
//  JoinedGroupListVC.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/13.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
class JoinedChatGroup: NSObject {
    var groupId: String = ""
    var face: String = ""
    var name: String = ""
    var groupOwnerId: Int = 0
    var isMyGroup: Bool = false
}

class JoinedGroupListVC: TSViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    var searchBar: TSSearchBar!
    var tableview: TSTableView!
    var dataSource: [JoinedChatGroup] = []
    var searchArray: [JoinedChatGroup] = []
    var showDataArray: [JoinedChatGroup] = []
    // 是否是显示搜索结果
    var isSearchResult: Bool = false
    fileprivate var currentPage: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "群"
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 47))
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        self.searchBar = TSSearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: bgView.height))
        self.searchBar.layer.masksToBounds = true
        self.searchBar.layer.cornerRadius = 5.0
        self.searchBar.backgroundImage = nil
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.returnKeyType = .search
        self.searchBar.barStyle = UIBarStyle.default
        self.searchBar.barTintColor = UIColor.clear
        self.searchBar.tintColor = TSColor.main.theme
        self.searchBar.searchBarStyle = UISearchBarStyle.minimal
        self.searchBar.delegate = self
        self.searchBar.placeholder = "搜索"
        bgView.addSubview(self.searchBar!)

        self.tableview = TSTableView(frame: CGRect(x: 0, y: bgView.bottom, width: ScreenWidth, height: ScreenHeight - 64 - bgView.height))
        self.view.addSubview(self.tableview!)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = 65
        self.tableview.separatorStyle = .none
        self.tableview.register(UINib(nibName: "JoinedGroupListCell", bundle: nil), forCellReuseIdentifier: "JoinedGroupListCell")
        self.tableview.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getGroupInfo))
        self.tableview.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableview.mj_footer.isHidden = true
        self.tableview.mj_header.beginRefreshing()
    }
    func getGroupInfo() {
        // 同步方法获取环信的所有群信息
        var resultError: EMError? = nil
        var myGroup = NSArray()
        if let hyOnlineGroup = EMClient.shared().groupManager.getJoinedGroupsFromServer(withPage: self.currentPage, pageSize: TSAppConfig.share.localInfo.limit, error: &resultError) {
            myGroup = hyOnlineGroup as NSArray
        } else {
            // 有可能是在其他设备上登录了该账号
        }
        var groupsID = ""
        for item in myGroup {
            let group = item as? EMGroup
            if groupsID == "" {
                groupsID = "\(group?.groupId ?? "")"
            } else {
                groupsID = "\(groupsID),\(group?.groupId ?? "")"
            }
        }
        if groupsID.isEmpty == true {
            if self.currentPage == 1 {
                self.tableview.mj_header.endRefreshing()
                self.tableview.show(placeholderView: .empty)
            } else {
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            }
            return
        }
        TSAccountNetworkManager().getHySimpleGroupInfo(groupid: groupsID, complete: { (data, status, message) in
            self.tableview.mj_header.endRefreshing()
            self.tableview.mj_footer.endRefreshing()
            if status == false && message?.isEmpty == false {
                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: message)
            }
            if status == false && self.currentPage == 1 {
                self.tableview.show(placeholderView: .network)
                return
            }
            if data == nil || (data?.count)! < 1 {
                self.tableview.show(placeholderView: .empty)
                return
            } else if (data?.count)! < TSAppConfig.share.localInfo.limit {
                // 不够一页即没有更多了
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            }
            self.tableview.mj_footer.isHidden = false
            self.tableview.removePlaceholderViews()
            if self.currentPage == 1 {
                self.dataSource.removeAll()
            }
            if let dataArray = data as? [[String: Any]] {
                for groupDic in dataArray {
                    let chatGroupModel = JoinedChatGroup()
                    if let name = groupDic["name"] as? String, let groupId = groupDic["id"] as? String {
                        chatGroupModel.name = name
                        chatGroupModel.groupId = groupId
                        if let face = groupDic["group_face"] as? String {
                            chatGroupModel.face = face
                        }
                        //找到群主id，并判断是否是自己的群
                        if let groupMembers = groupDic["affiliations"] as? [[String: Any]] {
                            for member in groupMembers {
                                if let ownerID = member["owner"] as? String {
                                    chatGroupModel.groupOwnerId = Int(ownerID)!
                                    if Int(ownerID)! == TSCurrentUserInfo.share.userInfo?.userIdentity {
                                        chatGroupModel.isMyGroup = true
                                    }
                                    continue
                                }
                            }
                        }
                        self.dataSource.append(chatGroupModel)
                    }
                }
            }
            self.showDataArray = self.dataSource
            self.tableview.reloadData()
        })
    }
    // MARK: - 本地搜索群昵称
    func searchGroupName(name: String) {
        if name.isEmpty == true {
           self.isSearchResult = false
            self.showDataArray = self.dataSource
            self.tableview.reloadData()
        } else {
            self.searchArray = []
            for item in self.dataSource {
                var chatName = item.name
                // 忽略字母大小写
                chatName = chatName.lowercased()
                let lowKey = name.lowercased()
                if (chatName.range(of: lowKey)) != nil {
                    self.searchArray.append(item)
                }
            }
            self.showDataArray = self.searchArray
            self.tableview.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "JoinedGroupListCell", for: indexPath) as! JoinedGroupListCell
        let infoModel = self.showDataArray[indexPath.row]
        cell.nameLab.text = infoModel.name
        let avatarInfo = AvatarInfo()
        avatarInfo.verifiedIcon = ""
        avatarInfo.verifiedType = ""
        avatarInfo.avatarURL = infoModel.face
        cell.avatarView.avatarPlaceholderType = .group
        cell.avatarView.avatarInfo = avatarInfo
        cell.gruopTagButton.isHidden = !infoModel.isMyGroup
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showDataArray.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoModel = self.showDataArray[indexPath.row]
        let groupName = infoModel.name
        let groupID = infoModel.groupId
        let vc = ChatDetailViewController(conversationChatter: groupID, conversationType: EMConversationTypeGroupChat)
        vc?.chatTitle = groupName
        navigationController?.pushViewController(vc!, animated: true)
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchGroupName(name: searchBar.text ?? "")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchGroupName(name: searchBar.text ?? "")
        }
    }

    func loadMore() {
        self.currentPage += 1
        self.getGroupInfo()
    }

    func refresh() {
        self.currentPage = 1
        self.dataSource = []
        self.getGroupInfo()
        self.tableview.mj_footer.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
