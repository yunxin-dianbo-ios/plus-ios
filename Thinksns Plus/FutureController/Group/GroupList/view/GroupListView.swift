//
//  GroupListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子列表视图

import UIKit

/// 圈子列表刷新代理
protocol GroupListViewRefreshDelegate: class {
    /// 下拉刷新
    func groupListView(_ view: GroupListView, didRefreshWithIdentidier identifier: String)
    /// 上拉加载
    func groupListView(_ view: GroupListView, didLoadMoreWithIdentidier identifier: String)
}

protocol GroupListViewActionDelegate: class {
    /// 点击了加入按钮
    func groupListView(_ view: GroupListView, didSelectedJoinButtonAt cell: GroupListCell)
    /// 点击了 cell
    func groupListView(_ view: GroupListView, didSelectedCellAt indexPath: IndexPath)
}

class GroupListView: TSTableView {

    /// 视图标识
    var tableIdentifier = ""
    /// 刷新代理
    weak var refreshDelegate: GroupListViewRefreshDelegate?
    /// 交互代理
    weak var actionDelegate: GroupListViewActionDelegate?

    /// 数据源
    var datas: [GroupListCellModel] = []
    /// 单页数量限制
    var listLimit = TSAppConfig.share.localInfo.limit

    // MARK: - Lifecycle
    init(frame: CGRect, tableIdentifier: String) {
        super.init(frame: frame, style: .plain)
        self.tableIdentifier = tableIdentifier
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        dataSource = self
        delegate = self
        separatorStyle = .none
        rowHeight = 91
        register(GroupListCell.self, forCellReuseIdentifier: GroupListCell.identifier)
        register(GroupListSectionView.self, forHeaderFooterViewReuseIdentifier: GroupListSectionView.identifier)
    }

    // MARK: - Data

    override func refresh() {
        refreshDelegate?.groupListView(self, didRefreshWithIdentidier: tableIdentifier)
    }

    override func loadMore() {
        refreshDelegate?.groupListView(self, didLoadMoreWithIdentidier: tableIdentifier)
    }

    /// 处理下拉刷新的界面刷新
    func processRefresh(newDatas: [GroupListCellModel]?, errorMessage: String?) {
        // 隐藏指示器
        dismissIndicatorA()
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        mj_footer.resetNoMoreData()
        // 获取数据失败，显示占位图或者 A 指示器
        if let message = errorMessage {
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 获取数据成功，更新数据
        guard let newDatas = newDatas else {
            return
        }
        datas = newDatas
        // 如果数据为空，显示占位图
        if datas.isEmpty {
            show(placeholderView: .empty)
        }
        // 刷新界面
        reloadData()
    }

    /// 处理上拉加载的数据的界面刷新
    func processLoadMore(newDatas: [GroupListCellModel]?, errorMessage: String?) {
        // 获取数据失败，显示"网络失败"的 footer
        if errorMessage != nil {
            mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        // 隐藏 A 指示器
        dismissIndicatorA()
        // 请求成功
        // 更新 datas，并刷新界面
        guard let newDatas = newDatas else {
            mj_footer.endRefreshing()
            return
        }
        datas = datas + newDatas
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if newDatas.count < listLimit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
        reloadData()
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension GroupListView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        if mj_footer != nil {
            mj_footer.isHidden = datas.count < listLimit
        }
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupListCell.identifier, for: indexPath) as! GroupListCell
        cell.delegate = self
        let model = datas[indexPath.row]
        cell.model = model
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        actionDelegate?.groupListView(self, didSelectedCellAt: indexPath)
    }

}

// MARK: - GroupListCell 代理事件
extension GroupListView: GroupListCellDelegate {

    /// 点击了加入按钮
    func groupListCellDidSelectedJoinButton(_ cell: GroupListCell) {
        actionDelegate?.groupListView(self, didSelectedJoinButtonAt: cell)
    }
}
