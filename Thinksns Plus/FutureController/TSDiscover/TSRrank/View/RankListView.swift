//
//  RankListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜 总览列表

import UIKit

/// 排行榜列表刷新代理
@objc protocol RankListViewRefreshDelegate: class {
    /// 下拉刷新
    @objc optional func rankTable(_ table: RankListView, refreshing rankTypes: [String])
}

/// 排行榜列表用户交互事件代理
@objc protocol RankListViewDelegate: class {
    /// 点击了 cell
    @objc optional func rankTable(_ table: RankListView, didSelectRowAt indexPath: IndexPath, with cellModel: RankListPreviewCellModel)
}

class RankListView: TSTableView {

    /// 数据
    var datas: [RankListPreviewCellModel] = []
    /// table 区分标识符，当多个 TSQuoraTableView 同时存在同一个界面时区分彼此
    var tableIdentifier = ""
    /// 总览表包含的榜单类型
    var rankTypes: [String] = []

    /// 刷新事件代理
    weak var refreshDelegate: RankListViewRefreshDelegate?
    /// 用户交互代理事件
    weak var interactionDelegate: RankListViewDelegate?

    /// 是否需要在刚显示时自动刷新
    var shouldAutoRefresh = true

    // MARK: - Lifecycle

    /// 初始化
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - rankTypes: 当前总览表中，包含的榜单类型（用于下拉刷新时抛出）
    ///   - shouldAutoRefresh: 是否需要在刚显示时自动刷新
    init(frame: CGRect, rankTypes types: [String], shouldAutoRefresh shouldRefresh: Bool) {
        super.init(frame: frame, style: .plain)
        rankTypes = types
        shouldAutoRefresh = shouldRefresh
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
        mj_footer = nil
        register(RankListPreviewCell.self, forCellReuseIdentifier: RankListPreviewCell.identifier)
        if shouldAutoRefresh {
            mj_header.beginRefreshing()
        }
    }

    // MARK: Data
    override func refresh() {
        refreshDelegate?.rankTable?(self, refreshing: rankTypes)
    }

    /// 处理下拉刷新的数据的界面刷新
    func processRefresh(newDatas: [RankListPreviewCellModel]?, errorMessage: String?) {
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
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
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RankListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankListPreviewCell.identifier, for: indexPath) as! RankListPreviewCell
        cell.setInfo(model: datas[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactionDelegate?.rankTable?(self, didSelectRowAt: indexPath, with: datas[indexPath.row])
    }
}
