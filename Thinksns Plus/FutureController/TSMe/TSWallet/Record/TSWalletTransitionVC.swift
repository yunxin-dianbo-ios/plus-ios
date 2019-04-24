//
//  TSWalletTransitionVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  交易明细列表 视图控制器

import UIKit
import RealmSwift

class TSWalletTransitionVC: TSTableViewController {

    /// 全部数据源
    var allDataSource: [TSWalletHistoryObject] = []
    /// table 数据源
    var dataSource: [TSWalletHistoryObject] {
        // 根据选择的交易类型，返回对应的数据
        switch selectedType {
        case .all:
            return allDataSource
        case .expend:
            return allDataSource.filter({ (object) -> Bool in
                return object.type == -1
            })
        case .income:
            return allDataSource.filter({ (object) -> Bool in
                return object.type == 1
            })
        }
    }

    /// 标题按钮
    let buttonForTitle = TSTransationTitleButton(type: .custom)
    /// 标题弹出菜单
    let titleView = TSTransitionTypeView.makeTransitionTypeView()
    let titleViewSuperView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 65), size: UIScreen.main.bounds.size))
    /// 标题菜单栏的下标
    var selectedType: TransitionType = .all
    /// 交易类型
    enum TransitionType: Int {
        /// 全部
        case all = 0
        /// 支付
        case expend
        /// 收入
        case income
    }

    /// 分页标识
    var page: Int?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadDataBaseData()
        tableView.mj_header.beginRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if titleViewSuperView.superview == nil {
            navigationController?.view.addSubview(titleViewSuperView)
            navigationController?.view.insertSubview(titleViewSuperView, belowSubview: (navigationController?.navigationBar)!)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleViewSuperView.removeFromSuperview()
    }

    // MARK: - Custom user interface

    func setUI() {
        tableView.register(TSTransationCell.nib(), forCellReuseIdentifier: TSTransationCell.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 54
        // title button
        buttonForTitle.frame = CGRect(x: 0, y: 0, width: 60, height: 25)
        navigationItem.titleView = buttonForTitle
        buttonForTitle.addTarget(self, action: #selector(transitionButtonTaped), for: .touchUpInside)
        // title view
        titleViewSuperView.isHidden = true
        titleView.frame = UIScreen.main.bounds
        titleView.setTap { [weak self] (index) in // 标题菜单栏的点击事件
            guard let weakSelf = self else {
                return
            }
            guard let type = TransitionType(rawValue: index) else {
                TSLogCenter.log.debug("出现了未知的交易类型")
                return
            }
            weakSelf.selectedType = type
            weakSelf.updateUI()
        }
        titleView.setDismiss { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.buttonForTitle.isSelected = false
        }

        titleViewSuperView.addSubview(titleView)
        navigationController?.view.addSubview(titleViewSuperView)
        navigationController?.view.insertSubview(titleViewSuperView, belowSubview: (navigationController?.navigationBar)!)
    }

    override func showOccupiedView(_ type: TSTableViewController.OccupiedType, isDataSourceEmpty: Bool) {
        super.showOccupiedView(type, isDataSourceEmpty: isDataSourceEmpty)
        tableView.bringSubview(toFront: titleViewSuperView)
    }

    func updateUI() {
        // 1. 更新 title
        switch selectedType {
        case .all:
            buttonForTitle.setTitle("全部", for: .normal)
        case .expend:
            buttonForTitle.setTitle("支出", for: .normal)
        case .income:
            buttonForTitle.setTitle("收入", for: .normal)
        }
        // 2. 刷新 table 数据
        if dataSource.isEmpty {
            showOccupiedView(.empty, isDataSourceEmpty: dataSource.isEmpty)
        }
        tableView.reloadData()
    }

    // MARK: - Data

    /// 加载数据库数据
    func loadDataBaseData() {
        allDataSource = TSDataQueueManager.share.wallet.getWalletDB()
        tableView.reloadData()
    }

    /// 下拉刷新
    override func refresh() {
        page = nil
        TSDataQueueManager.share.wallet.network(wallet: page) { [weak self] (result: Bool, datas: [TSWalletHistoryObject]?, _) in
            guard let weakSelf = self else {
                return
            }
            if result {
                // 请求成功
                weakSelf.allDataSource = datas!
                // 没有数据
                if weakSelf.allDataSource.isEmpty {
                    weakSelf.showOccupiedView(.empty, isDataSourceEmpty: weakSelf.allDataSource.isEmpty)
                } else {
                    // 有数据
                    weakSelf.tableView.reloadData()
                    // 更换页数
                    weakSelf.page = weakSelf.allDataSource.last!.id
                }
            } else {
                // 请求失败
                weakSelf.allDataSource.isEmpty ? weakSelf.showOccupiedView(.network, isDataSourceEmpty: weakSelf.allDataSource.isEmpty) : weakSelf.show(indicatorA: "提示信息_网络错误".localized)
            }
            if weakSelf.tableView.mj_header.isRefreshing() {
                weakSelf.tableView.mj_header.endRefreshing()
            }
        }
    }

    /// 上拉加载更多
    override func loadMore() {
        if allDataSource.isEmpty {
            tableView.mj_footer.endRefreshing()
            return
        }
        TSDataQueueManager.share.wallet.network(wallet: page) { [weak self] (result: Bool, datas: [TSWalletHistoryObject]?, _) in
            guard let weakSelf = self else {
                return
            }
            if !result {
                // 请求失败
                weakSelf.tableView.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            weakSelf.dismissIndicatorA()
            // 请求成功
            weakSelf.allDataSource = weakSelf.allDataSource + datas!
            weakSelf.tableView.reloadData()
            if datas!.count < TSMomentTaskQueue.listLimit {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                weakSelf.tableView.mj_footer.endRefreshing()
            }
            // 更换页数
            weakSelf.page = weakSelf.allDataSource.last!.id
        }
    }

    // MARK: - Button click

    /// 点击了标题按钮
    func transitionButtonTaped() {
        buttonForTitle.isSelected = !buttonForTitle.isSelected
        buttonForTitle.isSelected ? titleView.show() : titleView.dismiss()
    }
}

extension TSWalletTransitionVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dataSource.isEmpty && occupiedView.superview != nil {
            occupiedView.removeFromSuperview()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = allDataSource.count < TSAppConfig.share.localInfo.limit
        }
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSTransationCell.cellIdentifier) as! TSTransationCell
        let cellData = dataSource[indexPath.row]
        if cellData.isInvalidated == false {
            cell.setInfo(object: TSTransationCellModel(walletObject: cellData))
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = TSWalletTransationDetailVC.vc()
        let cellData = dataSource[indexPath.row]
        detailVC.viewModel = TSWalletTransationDetailModel(walletObject: cellData)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
