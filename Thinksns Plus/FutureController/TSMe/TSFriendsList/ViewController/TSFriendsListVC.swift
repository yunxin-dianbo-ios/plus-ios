//
//  TSFriendsListVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSFriendsListVC: TSViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TSMyFriendListCellDelegate {
    /// 数据源
    var dataSource: [TSUserInfoModel] = []
    var friendListTableView: TSTableView!
    var searchView = UIView()
    var searchTextfield = UITextField()
    var addFriendBt: UIButton = UIButton(type: .system)
    /// 占位图
    let occupiedView = UIImageView()
    var selectedBlock: ((TSUserInfoModel) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatSubView()
        friendListTableView = TSTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 64), style: UITableViewStyle.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        friendListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.view.addSubview(friendListTableView)
        friendListTableView.mj_footer.isAutomaticallyHidden = true
        friendListTableView.mj_header.beginRefreshing()
        occupiedView.contentMode = .center
        var request = UserNetworkRequest().readCounts
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["type": "mutual"]
        RequestNetworkData.share.text(request: request) { (_) in
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if searchView.superview == nil {
            self.navigationController?.navigationBar.addSubview(searchView)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if searchView.superview != nil {
            searchView.removeFromSuperview()
        }
    }

    // MARK: - 创建搜索一系列视图
    func creatSubView() {
        searchView = UIView(frame: CGRect(x: 50, y: 0, width: ScreenWidth - 50, height: 44))
        searchView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.addSubview(searchView)
        let tap = UITapGestureRecognizer { (_) in
            self.pushSearchPeopleVC()
        }
        searchView.addGestureRecognizer(tap)
        searchTextfield = UITextField(frame: CGRect(x: 15, y: 5, width: searchView.width - 15 - 70, height: 34))
        searchTextfield.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextfield.textColor = TSColor.normal.minor
        searchTextfield.placeholder = "搜索"
        searchTextfield.backgroundColor = TSColor.normal.placeholder
        searchTextfield.layer.cornerRadius = 5
        searchTextfield.isUserInteractionEnabled = false

        let searchIcon = UIImageView()
        searchIcon.image = #imageLiteral(resourceName: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        searchTextfield.leftView = searchIcon
        searchTextfield.leftViewMode = .always
        searchView.addSubview(searchTextfield)

        let lineViw = UIView(frame: CGRect(x: 0, y: 43.5, width: ScreenWidth, height: 0.5))
        lineViw.backgroundColor = TSColor.inconspicuous.disabled
        searchView.addSubview(lineViw)
        addFriendBt = UIButton(frame: CGRect(x: searchTextfield.right + 10, y: searchTextfield.top, width: 50, height: searchTextfield.height))
        addFriendBt.setImage(#imageLiteral(resourceName: "ico_addfriends"), for: UIControlState.normal)
        searchView.addSubview(addFriendBt)
        addFriendBt.addTarget(self, action: #selector(addFriendButtonClick), for: UIControlEvents.touchUpInside)
        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center
    }

    func refresh() {
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: nil, complete: { (userModels, networkError) in
            // 如果是第一次进入
            self.friendListTableView.mj_header.endRefreshing()
            self.processRefresh(datas: userModels, message: networkError)
        })
    }

    func loadMore() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: nil, complete: { (userModels, networkError) in
            guard let datas = userModels else {
                self.friendListTableView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.friendListTableView.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.friendListTableView.reloadData()
        })
    }

    // MARK: - 添加好友按钮点击事件（跳转到找人页面）
    func addFriendButtonClick() {
        let vc = TSNewFriendsVC.vc()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let vc = TSFriendSearchVC.vc()
        let nav = TSNavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
        return false
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendListTableView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "fiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSMyFriendListCell
        if cell == nil {
            cell = TSMyFriendListCell(style: UITableViewCellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.setUserInfoData(model: dataSource[indexPath.row])
        cell?.delegate = self
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]

        if self.selectedBlock != nil {
            self.selectedBlock!(model)
            self.navigationController?.popViewController(animated: true)
            return
        }
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        var image = ""
        switch type {
        case .empty:
            image = "IMG_img_default_nobody"
        case .network:
            image = "IMG_img_default_internet"
        }
        occupiedView.image = UIImage(named: image)
        if occupiedView.superview == nil {
            occupiedView.frame = friendListTableView.bounds
            friendListTableView.addSubview(occupiedView)
        }
    }

    func processRefresh(datas: [TSUserInfoModel]?, message: NetworkError?) {
        friendListTableView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty {
                showOccupiedView(type: .empty)
            }
        }
        // 获取数据失败
        if message != nil {
            dataSource = []
            showOccupiedView(type: .network)
        }
        friendListTableView.reloadData()
    }

    // MARK: - TSMyFriendListCellDelegate
    func chatWithUserId(userId: Int, chatName: String) {
        if !EMClient.shared().isLoggedIn {
            let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
            appDeleguate.getHyPassword()
            return
        }
        let idSt: String = String(userId)
        let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
        vc?.chatTitle = chatName
        navigationController?.pushViewController(vc!, animated: true)
    }

    /// 跳转到搜索页
    func pushSearchPeopleVC() {
        let vc = TSNewFriendsSearchVC.vc()
        vc.isJustSearchFriends = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
