//
//  MyNewsDetailView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  资讯类列表视图
//  
//  此列表包含各种通过资讯设置的 cell，具体类型可参见 MyNewsDetailViewType。
//
//  带有上下拉刷新的数据处理。

import UIKit

/// 数据刷新代理
protocol NewsListViewRefreshDelegate: class {
    /// 下拉刷新
    func table(view: NewsListView, refreshWith identifier: String)
    /// 上拉加载更多
    func table(view: NewsListView, loadMoreWith identifier: String)
}

/// 界面交互代理
protocol NewsListViewInteractDelegate: class {
    /// 点击了 cell
    func table(view: NewsListView, didSelectedCellAt indexPath: IndexPath, with identifier: String)
}

class NewsListView: TSTableView {

    enum MyNewsDetailViewType {
        /// 已发布，使用 TSNewsListCell
        case publish
        /// 待审核，使用 UnpublishedNewsCell
        case unPublish
    }

    /// 刷新代理
    weak var refreshDelegate: NewsListViewRefreshDelegate?
    /// 交互代理
    weak var interActDelegate: NewsListViewInteractDelegate?

    /// 列表唯一标识（用于同一个界面存在多个 NewsListView 时区分彼此）
    var identifier = ""
    /// 数据
    var datas: [NewsDetailModel] = []
    /// cell 类型
    var type: MyNewsDetailViewType = .publish

    /// 单页数据条数
    var listLimit = TSAppConfig.share.localInfo.limit

    // MARK: - Lifecycle
    init(identifier id: String, frame: CGRect, cellType: MyNewsDetailViewType) {
        super.init(frame: frame, style: .plain)
        identifier = id
        type = cellType
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - UI

    func setUI() {
        delegate = self
        dataSource = self
        separatorStyle = .none
        backgroundColor = TSColor.inconspicuous.disabled
        register(TSNewsListCell.self, forCellReuseIdentifier: TSNewsListCell.identifier)
        register(UnpublishedNewsCell.self, forCellReuseIdentifier: UnpublishedNewsCell.identifier)
        mj_header.beginRefreshing()
    }

    // MARK: - Data

    /// 下拉刷新
    override func refresh() {
        refreshDelegate?.table(view: self, refreshWith: identifier)
    }

    /// 上拉加载
    override func loadMore() {
        refreshDelegate?.table(view: self, loadMoreWith: identifier)
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processRefresh(data: [NewsDetailModel]?, message: String?, status: Bool) {
        // 隐藏指示器
        dismissIndicatorA()
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        mj_footer.resetNoMoreData()
        // 获取数据失败，显示占位图或者 A 指示器
        if let message = message {
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 获取数据成功，更新数据
        guard let newDatas = data else {
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

    /// 处理下拉刷新的数据，并更新界面 UI
    func processloadMore(data: [NewsDetailModel]?, message: String?, status: Bool) {
        // 获取数据失败，显示"网络失败"的 footer
        if message != nil {
            mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        // 隐藏 A 指示器
        dismissIndicatorA()
        // 请求成功
        // 更新 dataSource，并刷新界面
        guard let newDatas = data else {
            mj_footer.endRefreshing()
            return
        }
        datas = datas + newDatas
        reloadData()
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if data!.count < listLimit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
    }

}

extension NewsListView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        if mj_footer != nil {
            mj_footer.isHidden = datas.count < listLimit
        }
        return datas.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if type == .publish {
            let publishCell = tableView.dequeueReusableCell(withIdentifier: TSNewsListCell.identifier, for: indexPath) as! TSNewsListCell
            publishCell.cellData = datas[indexPath.row]
            cell = publishCell
        }
        if type == .unPublish {
            let unPublishCell = tableView.dequeueReusableCell(withIdentifier: UnpublishedNewsCell.identifier, for: indexPath) as! UnpublishedNewsCell
            unPublishCell.setInfo(model: datas[indexPath.row])
            cell = unPublishCell
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interActDelegate?.table(view: self, didSelectedCellAt: indexPath, with: identifier)
    }
}
