//
//  TSRewardListVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  打赏列表界面
//  目前打赏列表主要是：资讯、动态、问答答案，注：用户打赏里暂时没有打赏列表
//  注：打赏列表的网络请求可以使用通用的网络请求

import UIKit

class TSRewardListVC: TSTableViewController {
    /// 类型
    var type: TSRewardType = .moment
    ///
    var rewardId: Int!
    /// 数据源
    var dataSource: [TSNewsRewardModel] = []
    /// 每次请求时的数量限制
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit

    // MARK: - Lifecycle
    class func list(type: TSRewardType) -> TSRewardListVC {
        let listVC = UIStoryboard(name: "TSRewardListVC", bundle: nil).instantiateInitialViewController() as! TSRewardListVC
        listVC.type = type
        return listVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.mj_footer.isHidden = true
        self.tableView.mj_header.beginRefreshing()
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        title = "打赏列表"
    }

    // MARK: - Data
    override func refresh() {
        /// 用户打赏暂无打赏列表
        if self.type == .user {
            return
        }
        TSRewardNetworkManger.getRewardList(type: self.type, sourceId: self.rewardId, offset: 0, limit: self.limit) { [weak self](rewardModels, msg, status) in
            self?.tableView.mj_header.endRefreshing()
            guard status, let rewardModels = rewardModels else {
                return
            }
            self?.dataSource = rewardModels
            self?.tableView.mj_footer.isHidden = rewardModels.count != self?.limit
            self?.tableView.reloadData()
        }
    }

    override func loadMore() {
        /// 用户打赏暂无打赏列表
        if self.type == .user {
            return
        }
        let offset = self.dataSource.count
        TSRewardNetworkManger.getRewardList(type: self.type, sourceId: self.rewardId, offset: offset, limit: self.limit) { [weak self](rewardModels, msg, status) in
            self?.tableView.mj_footer.endRefreshing()
            guard status, let rewardModels = rewardModels else {
                self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            if rewardModels.isEmpty {
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self?.dataSource += rewardModels
            self?.tableView.reloadData()
        }
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSRewardListCell.identifier, for: indexPath) as! TSRewardListCell
        cell.rewardType = self.type
        cell.set(model: dataSource[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
