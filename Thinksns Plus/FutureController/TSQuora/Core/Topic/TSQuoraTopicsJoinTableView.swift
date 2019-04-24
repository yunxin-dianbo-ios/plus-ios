//
//  TSQuoraTopicsTableVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答话题列表
//
//  纯 UI 展示，所有交互事件由代理抛出
//
/*
 示例代码:
 
 let table = TSQuoraTopicsJoinTableView(frame: UIScreen.main.bounds)
 // 设置刷新操作代理事件
 table.refreshDelegate = self
 // 设置用户交互代理事件
 table.interactionDelegate = self

 // 传递数据源，刷新界面
 let dataModel: TSQuoraTopicModel! // 网络请求获取 dataModel
 let cellModel = TSQuoraTopicsJoinTableCellModel(model: dataModel)
 table.datas = [cellModel]
 table.reloadData()

 具体使用可参见 TSTopicListView.swift，QuoraTopicSearchView.swift

 */

import UIKit

/// 问答话题类型枚举
@objc enum TSQuoraTopicsJoinDataType: Int {
    /// 所有话题
    case all
    /// 我关注的话题
    case follow
    /// 搜索话题
    case search

    /// 枚举的 key
    var keyValue: String {
        switch self {
        case .all:
            return "all"
        case .follow:
            return "follow"
        case .search:
            return "search"
        }
    }
}

/// 话题列表刷新代理
@objc protocol TSQuoraTopicsJoinTableRefreshDelegate: class {
    /// 下拉刷新
    @objc optional func topicTable(_ table: TSQuoraTopicsJoinTableView, refreshingDataOf type: TSQuoraTopicsJoinDataType)
    /// 上拉加载
    @objc optional func topicTable(_ table: TSQuoraTopicsJoinTableView, loadMoreDataOf type: TSQuoraTopicsJoinDataType)
}

/// 话题列表用户交互事件代理
@objc protocol TSQuoraTopicsJoinTableViewDelegate: class {
    /// 点击了 cell 上的关注按钮
    @objc optional func topicTable(_ table: TSQuoraTopicsJoinTableView, didSelectedFollowButton button: UIButton, at cell: TSQuoraTopicsJoinTableCell, with cellModel: TSQuoraTopicsJoinTableCellModel)
    /// 点击了 cell
    @objc optional func topicTable(_ table: TSQuoraTopicsJoinTableView, didSelectRowAt indexPath: IndexPath, with cellModel: TSQuoraTopicsJoinTableCellModel)
}

class TSQuoraTopicsJoinTableView: TSTableView {

    /// 数据类型，默认为 all
    var dataType: TSQuoraTopicsJoinDataType = .all
    /// 数据源
    var datas: [TSQuoraTopicsJoinTableCellModel] = []
    /// 刷新事件代理
    weak var refreshDelegate: TSQuoraTopicsJoinTableRefreshDelegate?
    /// 用户交互代理事件
    weak var interactionDelegate: TSQuoraTopicsJoinTableViewDelegate?
    /// 单页条数
    var listLimit = TSAppConfig.share.localInfo.limit
    /// 分页标识
    var after: Int?

    // MARK: - Lifecycle
    init(frame: CGRect, dataType type: TSQuoraTopicsJoinDataType) {
        super.init(frame: frame, style: .plain)
        dataType = type
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Custom user interface
    func setUI() {
        delegate = self
        dataSource = self
        estimatedRowHeight = 500
        separatorStyle = .none
        backgroundColor = TSColor.inconspicuous.disabled
        // 注册标题 cell
        register(UINib(nibName: "TSQuoraTopicsJoinTableCell", bundle: nil), forCellReuseIdentifier: TSQuoraTopicsJoinTableCell.identifier)
        mj_header.beginRefreshing()
    }

    // MARK: Data
    override func refresh() {
        refreshDelegate?.topicTable?(self, refreshingDataOf: dataType)
    }

    override func loadMore() {
        refreshDelegate?.topicTable?(self, loadMoreDataOf: dataType)
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processRefresh(data: [TSQuoraTopicsJoinTableCellModel]?, message: String?, status: Bool) {
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
    func processloadMore(data: [TSQuoraTopicsJoinTableCellModel]?, message: String?, status: Bool) {
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TSQuoraTopicsJoinTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

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
        let cell = tableView.dequeueReusableCell(withIdentifier: TSQuoraTopicsJoinTableCell.identifier, for: indexPath) as! TSQuoraTopicsJoinTableCell
        cell.setInfo(model: datas[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactionDelegate?.topicTable?(self, didSelectRowAt: indexPath, with: datas[indexPath.row])
    }
}

// MARK: - TSQuoraTopicsJoinTableCellDelegate: cell 交互事件代理
extension TSQuoraTopicsJoinTableView: TSQuoraTopicsJoinTableCellDelegate {

    /// 点击了 cell 上的关注按钮
    func cell(_ cell: TSQuoraTopicsJoinTableCell, didSelectedFollowButton button: UIButton, cellModel: TSQuoraTopicsJoinTableCellModel) {
        let indexPath = self.indexPath(for: cell)!
        interactionDelegate?.topicTable?(self, didSelectedFollowButton: button, at: cell, with: cellModel)
    }
}
