//
//  TopicExpertsListController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  专家列表

import UIKit

class TopicExpertsListController: TSTableViewController {

    /// 话题 id
    var topicId: Int!
    /// 数据
    var datas: [TSUserInfoModel] = []

    // MARK: Lifecycle
    init(topicId id: Int) {
        super.init(nibName: nil, bundle: nil)
        topicId = id
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableView.mj_header.beginRefreshing()
    }

    func setUI() {
        title = "专家列表"
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 60
        tableView.register(UINib(nibName: "QuoraExpertsListCell", bundle: nil), forCellReuseIdentifier: QuoraExpertsListCell.identifier)
    }

    // MARK: Data

    /// 下拉刷新
    override func refresh() {
        TSQuoraNetworkManager.getTopicExperts(topicId: topicId, after: nil) { [weak self] (data: [TSUserInfoModel]?, message: String?, _) in
            self?.processRefreshData(data: data, message: message)
        }
    }

    /// 上拉加载更多
    override func loadMore() {
        TSQuoraNetworkManager.getTopicExperts(topicId: topicId, after: datas.last?.userIdentity) { [weak self] (data: [TSUserInfoModel]?, message: String?, _) in
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
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 2.请求成功
        // 2.1 更新 datas
        if let data = data {
            datas = data
            if data.isEmpty == true {
                // 2.2 如果数据为空，显示占位图
                show(placeholderView: .empty)
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
        if let data = data {
            datas = datas + data
            tableView.reloadData()
        }
        // 3. 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if data!.count < TSMomentTaskQueue.listLimit {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            tableView.mj_footer.endRefreshing()
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicExpertsListController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = datas.count < TSAppConfig.share.localInfo.limit
        }
        return datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuoraExpertsListCell.identifier, for: indexPath) as! QuoraExpertsListCell
        cell.setInfo(model: datas[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - QuoraExpertsListCellDelegate: 专家列表 cell 的交互事件
extension TopicExpertsListController: QuoraExpertsListCellDelegate {

    /// 点击了 cell 上的关注按钮
    func cell(_ cell: QuoraExpertsListCell, didSelectedFollow button: UIButton, with cellModel: TSUserInfoModel) {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        // 2.发起关注操作
        let indexPath = tableView.indexPath(for: cell)!
        cellModel.follower = !cellModel.follower
        datas[indexPath.row] = cellModel
        self.tableView.reloadRows(at: [indexPath], with: .none)
        TSUserNetworkingManager().operate(cellModel.follower == true ? .follow : .unfollow, userID: cellModel.userIdentity)
    }
}
