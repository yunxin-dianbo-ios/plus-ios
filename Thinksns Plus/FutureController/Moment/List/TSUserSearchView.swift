//
//  TSUserSearchView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSUserSearchView: TSTableView, UITableViewDelegate, UITableViewDataSource, TSNewFriendsCellDelegate {

    /// 占位图
    let occupiedView = UIImageView()
    /// 数据源
    var userDataSource: [TSUserInfoModel] = []
    /// 搜索关键词
    var keyword = "" {
        didSet {
            mj_header.beginRefreshing()
            TSDatabaseManager().quora.deleteByContent(content: keyword)
            TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
        }
    }

    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - refresh
    override func refresh() {
        // 2.有搜索内容，展示与搜索内容相关的用户
        TSNewFriendsNetworkManager.searchUsers(keyword: keyword, offset: 0) { [weak self] (datas: [TSUserInfoModel]?, message: String?, _) in
            self?.processRefresh(datas: datas, message: message)
        }
    }

    override func loadMore() {
        guard keyword != "", userDataSource.count != 0 else {
            // 1.不输入搜索内容，显示的是后台推荐用户，后台推荐用户没有分页
            mj_footer.endRefreshingWithNoMoreData()
            return
        }
        TSNewFriendsNetworkManager.searchUsers(keyword: keyword, offset: userDataSource.count) { [weak self] (datas: [TSUserInfoModel]?, _, _) in
            guard let weakSelf = self else {
                return
            }
            guard let datas = datas else {
                weakSelf.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                weakSelf.mj_footer.endRefreshingWithNoMoreData()
            } else {
                weakSelf.mj_footer.endRefreshing()
            }
            weakSelf.userDataSource = weakSelf.userDataSource + datas
            weakSelf.reloadData()
        }
    }

    func processRefresh(datas: [TSUserInfoModel]?, message: String?) {
        mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            userDataSource = datas
            if userDataSource.isEmpty {
                showOccupiedView(type: .empty)
            }
        }
        // 获取数据失败
        if message != nil {
            userDataSource = []
            showOccupiedView(type: .network)
        }
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        reloadData()
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        switch type {
        case .empty:
            self.show(placeholderView: .empty)
        case .network:
            self.show(placeholderView: .network)
        }
    }

    // MARK: UI
    func setUI() {
        //tableview
        delegate = self
        dataSource = self
        rowHeight = 77.5
        separatorStyle = .none
        register(UINib(nibName: "TSNewFriendsCell", bundle: nil), forCellReuseIdentifier: TSNewFriendsCell.identifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mj_footer.isHidden = userDataSource.count < TSNewFriendsNetworkManager.limit
        if !userDataSource.isEmpty {
            self.removePlaceholderViews()
        }
        return userDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSNewFriendsCell.identifier, for: indexPath) as! TSNewFriendsCell
        cell.setInfo(model: userDataSource[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = userDataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }
    func cell(_ cell: TSNewFriendsCell, didSelectedFollowButton button: UIButton) {
        let index = self.indexPath(for: cell)
        let userInfo = userDataSource[(index?.row)!]
        userInfo.follower = !userInfo.follower
        userDataSource[(index?.row)!] = userInfo
        reloadRows(at: [index!], with: .none)
        TSUserNetworkingManager().operate(userInfo.follower == true ? .follow : .unfollow, userID: userInfo.userIdentity)
    }
}
