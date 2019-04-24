//
//  TSNewFriendsDetailVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSNewFriendsDetailVC: TSTableViewController, TSNewFriendsCellDelegate {

    /// 数据源
    var dataSource: [TSUserInfoModel] = []
    /// 类型
    var type: TSNewFriendsVC.UserType = .hot

    /// 地址
    var location: TSLocationModel? {
        didSet {
            guard type == .nearby else {
                return
            }
            tableView.mj_header.beginRefreshing()
        }
    }

    // MARK: - Lifecycle
    init(type: TSNewFriendsVC.UserType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableView.mj_header.beginRefreshing()
    }

    // MARK: - Custom user interface
    func setUI() {
        tableView.rowHeight = 77.5
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TSNewFriendsCell", bundle: nil), forCellReuseIdentifier: TSNewFriendsCell.identifier)
    }

    // MARK: - Data
    override func refresh() {
        var offset = 0
        // 附近的人的默认偏移量比较不同，是 1，其它都是 0
        if type == .nearby {
            offset = 1
        }
        TSDataQueueManager.share.findFriends.getNewFriends(type: type, latitude: location?.latitudes(), longitude: location?.longitudes(), offset: offset) { [weak self] (data, message, _) in
            self?.processRefreshData(data: data, message: message)
        }
    }

    override func loadMore() {
        TSDataQueueManager.share.findFriends.getNewFriends(type: type, latitude: location?.latitudes(), longitude: location?.longitudes(), offset: dataSource.count) { [weak self] (data, message, _) in
            self?.processLoadMoreData(data: data, message: message)
        }
    }

    /// 处理下拉刷新的数据，并调整相关的交互视图
    func processRefreshData(data: [TSUserInfoModel]?, message: String?) {
        tableView.mj_footer.resetNoMoreData()
        // 1.网络失败
        if let message = message {
            // 1.1 结束 footer 动画
            tableView.mj_header.endRefreshing()
            // 1.2 如果界面上有数据，显示 indicatorA；如果界面上没有数据，显示"网络错误"的占位图
            dataSource.isEmpty ? showOccupiedView(.network, isDataSourceEmpty: dataSource.isEmpty) : show(indicatorA: message)
            occupiedView.image = UIImage(named: "IMG_img_default_internet")
            return
        }
        // 2.请求成功
        // 2.1 更新 dataSource
        if let data = data {
            dataSource = data
            if data.isEmpty == true {
                // 2.2 如果数据为空，显示占位图
                showOccupiedView(.empty, isDataSourceEmpty: dataSource.isEmpty)
                occupiedView.image = UIImage(named: "IMG_img_default_nobody")
            }
        }
        // 3.隐藏多余的指示器和刷新动画
        dismissIndicatorA()
        if tableView.mj_header.isRefreshing() {
            tableView.mj_header.endRefreshing()
        }
        // 4.刷新界面
        tableView.reloadData()
    }

    /// 处理上拉加载更多的数据，并调整相关的交互视图
    func processLoadMoreData(data: [TSUserInfoModel]?, message: String?) {
        // 1.网络失败，显示"网络失败"的 footer
        if message != nil {
            tableView.mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        dismissIndicatorA()
        // 2.请求成功
        guard let data = data else {
            tableView.mj_footer.endRefreshing()
            return
        }
        dataSource = dataSource + data
        tableView.reloadData()
        // 3. 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if data.count < TSAppConfig.share.localInfo.limit {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            tableView.mj_footer.endRefreshing()
        }
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dataSource.isEmpty && occupiedView.superview != nil {
            occupiedView.removeFromSuperview()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = dataSource.count < 15
        }
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSNewFriendsCell.identifier, for: indexPath) as! TSNewFriendsCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.setInfo(model: dataSource[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }

    // MARK: TSNewFriendsCellDelegate
    func cell(_ cell: TSNewFriendsCell, didSelectedFollowButton button: UIButton) {
        // 1.判断是否为游客模式
        if !TSCurrentUserInfo.share.isLogin {
            // 如果是游客模式，拦截操作显示登录界面
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.进行关注操作
        let indexPath = tableView.indexPath(for: cell)!
        let userInfo = dataSource[indexPath.row]
        userInfo.follower = !userInfo.follower
        dataSource[indexPath.row] = userInfo
        self.tableView.reloadRows(at: [indexPath], with: .none)
        TSUserNetworkingManager().operate(userInfo.follower == true ? .follow : .unfollow, userID: userInfo.userIdentity)
    }
}
