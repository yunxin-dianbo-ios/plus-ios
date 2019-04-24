//
//  TSFriendSearchVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSFriendSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TSFriendListCellDelegate, UITextFieldDelegate {

    /// 搜索框
    @IBOutlet weak var searchbarView: TSSearchBarView!
    /// 列表
    @IBOutlet weak var tableview: UITableView!
    /// 占位图
    let occupiedView = UIImageView()

    /// 数据源
    var dataSource: [TSUserInfoModel] = []
    /// 搜索关键词
    var keyword = ""
    /// 是否是第一次自动搜索（增加这个属性的原因：参见#1418 后台若没有推荐用户，刚进入搜索页时应该显示空白页，不应该显示缺省图）
    var firstLoad = true

    // MARK: - Lifecycle

    class func vc() -> TSFriendSearchVC {
        let vc = UIStoryboard(name: "TSFriendSearchVC", bundle: nil).instantiateInitialViewController() as! TSFriendSearchVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Custom user interface

    func setUI() {
        // table
        tableview.rowHeight = 77.5
        tableview.separatorStyle = .none
        tableview.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableview.mj_header = nil
        tableview.register(UINib(nibName: "TSFriendListCell", bundle: nil), forCellReuseIdentifier: TSFriendListCell.identifier)
        // 搜索框
        searchbarView.rightButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        searchbarView.searchTextFiled.placeholder = "搜索"
        searchbarView.searchTextFiled.returnKeyType = .search
        searchbarView.searchTextFiled.delegate = self
        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center

        // 让搜索框加载后台推荐用户，让用户一进这个页面就有东西看
        textFieldShouldReturn(searchbarView.searchTextFiled)
    }

    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        var image = ""
        switch type {
        case .empty:
            image = "IMG_img_default_search"
        case .network:
            image = "IMG_img_default_internet"
        }
        occupiedView.image = UIImage(named: image)
        if occupiedView.superview == nil {
            occupiedView.frame = tableview.bounds
            tableview.addSubview(occupiedView)
        }
    }

    // MARK: - Data

    /// 查询用户信息
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            // 如果是第一次进入
            if self.firstLoad == true {
                self.firstLoad = false
                // 需求：如果第一次进入（自动刷新），获取后台推荐用户是空的，就显示空白页，不显示缺省图
                if userModels?.isEmpty == true {
                    return
                }
            }
            self.processRefresh(datas: userModels, message: networkError)
        })
        return true
    }

    func processRefresh(datas: [TSUserInfoModel]?, message: NetworkError?) {
        tableview.mj_footer.resetNoMoreData()
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
        tableview.reloadData()
    }

    func loadMore() {
        guard keyword != "" else {
            // 1.不输入搜索内容，显示的是后台推荐用户，后台推荐用户没有分页
            tableview.mj_footer.endRefreshingWithNoMoreData()
            return
        }

        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: keyword, complete: { (userModels, networkError) in
            guard let datas = userModels else {
                self.tableview.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.tableview.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.tableview.reloadData()
        })
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableview.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSFriendListCell.identifier, for: indexPath) as! TSFriendListCell
        cell.delegate = self
        cell.setInfo(model: dataSource[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }

    // MARK: TSNewFriendsCellDelegate
    func cell(userId: Int, chatName: String) {
        if !EMClient.shared().isLoggedIn {
            let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
            appDeleguate.getHyPassword()
            return
        }
        let idSt: String = String(userId)
        let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
        vc?.chatTitle = chatName
        navigationController?.pushViewController(vc!, animated: true)
        /*let chatVC = TSChatViewController()
        chatVC.currentConversationType = EMConversationTypeChat
        let idSt: String = String(userId)
        chatVC.incomingUserIdentity = userId
        chatVC.cuurentConversationId = idSt
        chatVC.currentConversationName = chatName
        chatVC.avatarSizeType = AvatarType.width26(showBorderLine: false)
        navigationController?.pushViewController(chatVC, animated: true)*/
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
