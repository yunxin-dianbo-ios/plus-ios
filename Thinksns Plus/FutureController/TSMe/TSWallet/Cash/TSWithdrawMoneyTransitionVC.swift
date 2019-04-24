//
//  TSWithdrawMoneyTransitionVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSWithdrawMoneyTransitionVC: TSTableViewController {

    /// 数据源
    var dataSource: [TSWithdrawHistoryObject] = []
    /// 分页标识
    var page: Int?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadDataBaseData()
        tableView.mj_header.beginRefreshing()
    }

    // MARK: - Custom user interface

    func setUI() {
        title = "显示_提现明细".localized
        tableView.register(TSTransationCell.nib(), forCellReuseIdentifier: TSTransationCell.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 54
        occupiedView.contentMode = .center
    }

    // MARK: - Data

    /// 加载数据库数据
    func loadDataBaseData() {
        dataSource = TSDataQueueManager.share.wallet.getWithdrawDB()
        tableView.reloadData()
    }

    // 下拉刷新
    override func refresh() {
        page = nil
        TSDataQueueManager.share.wallet.network(withdraw: page) { [weak self] (result: Bool, datas: [TSWithdrawHistoryObject]?, _) in
            if let weakSelf = self {
                if result {
                    // 请求成功
                    weakSelf.dataSource = datas!
                    // 没有数据
                    if weakSelf.dataSource.isEmpty {
                        weakSelf.showOccupiedView(.empty, isDataSourceEmpty: weakSelf.dataSource.isEmpty)
                    } else {
                        // 有数据
                        weakSelf.tableView.reloadData()
                        // 更换页数
                        weakSelf.page = weakSelf.dataSource.last?.id
                    }
                } else {
                    // 请求失败
                    weakSelf.dataSource.isEmpty ? weakSelf.showOccupiedView(.network, isDataSourceEmpty: weakSelf.dataSource.isEmpty) : weakSelf.show(indicatorA: "提示信息_网络错误".localized)
                }
                if weakSelf.tableView.mj_header.isRefreshing() {
                    weakSelf.tableView.mj_header.endRefreshing()
                }
            }
        }
    }

    // 上拉加载更多
    override func loadMore() {
        if dataSource.isEmpty {
            tableView.mj_footer.endRefreshing()
            return
        }
        TSDataQueueManager.share.wallet.network(withdraw: page) { [weak self] (result: Bool, datas: [TSWithdrawHistoryObject]?, _) in
            if let weakSelf = self {
                if !result {
                    // 请求失败
                    weakSelf.tableView.mj_footer.endRefreshingWithWeakNetwork()
                    return
                }
                weakSelf.dismissIndicatorA()
                // 请求成功
                weakSelf.dataSource = weakSelf.dataSource + datas!
                weakSelf.tableView.reloadData()
                if datas!.count < TSMomentTaskQueue.listLimit {
                    weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer.endRefreshing()
                }
                // 更换页数
                weakSelf.page = weakSelf.dataSource.last?.id
            }
        }
    }
}

extension TSWithdrawMoneyTransitionVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dataSource.isEmpty && occupiedView.superview != nil {
            occupiedView.removeFromSuperview()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = dataSource.count < TSAppConfig.share.localInfo.limit
        }
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSTransationCell.cellIdentifier) as! TSTransationCell
        let cellData = dataSource[indexPath.row]
        cell.setInfo(object: TSTransationCellModel(withdraw: cellData))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = TSWalletTransationDetailVC.vc()
        detailVC.viewModel = TSWalletTransationDetailModel(withdraw: dataSource[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
