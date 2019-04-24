//
//  RankListDetailView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  注：排行榜中限定仅展示前100名。

import UIKit

@objc protocol RankListDetailViewRefreshDelegate: class {
    /// 下拉刷新
    @objc optional func rankDetailTable(_ table: RankListDetailView, refreshingDataOf tableIdentifier: String)
    /// 上拉加载
    @objc optional func rankDetailTable(_ table: RankListDetailView, loadMoreDataOf tableIdentifier: String)
}

/// 交互代理事件
@objc protocol RankListDetailViewDelegate: class {
    /// 点击了 normal cell 的关注按钮
    @objc optional func rankDetailTable(_ table: RankListDetailView, didSelectedNormal cell: RankListCell, at indexPath: IndexPath)
    /// 点击了 detail cell 的关注按钮
    @objc optional func rankDetailTable(_ table: RankListDetailView, didSelectedDetail cell: RankListDetailCell, at indexPath: IndexPath)
    /// 点击了整行cell
    func rankDetailTable(_ table: RankListDetailView, didSelectedRankListCell cell: RankListCell, at indexPath: IndexPath) -> Void
    func rankDetailTable(_ table: RankListDetailView, didSelectedRankListDetailCell cell: RankListDetailCell, at indexPath: IndexPath) -> Void
}

class RankListDetailView: TSTableView {

    /// 刷新事件代理
    weak var refreshDelegate: RankListDetailViewRefreshDelegate?
    /// 用户交互代理事件
    weak var interactionDelegate: RankListDetailViewDelegate?

    /// table 区分标识符，当多个 TSQuoraTableView 同时存在同一个界面时区分彼此
    var tableIdentifier = ""
    /// 单页条数
    var listLimit = TSAppConfig.share.localInfo.limit
    /// 最大展示数量
    let maxLimit = 100
    /// 排行榜数字特殊颜色
    var rankNumberSpecialColors: [Int: UIColor] = [:]
    /// 排行榜数字普通颜色
    var rankNumberNormalColor = UIColor(hex: 0x999999)

    /// 数据源
    var datas: [Any] = []

    // MARK: - Lifecycle
    init(frame: CGRect, tableIdentifier identifier: String) {
        super.init(frame: frame, style: .plain)
        tableIdentifier = identifier
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Custom user interface
    func setUI() {
        delegate = self
        dataSource = self
        estimatedRowHeight = 75.5
        separatorStyle = .none
        backgroundColor = TSColor.inconspicuous.background
        // 注册 normal cell
        register(UINib(nibName: "RankListCell", bundle: nil), forCellReuseIdentifier: RankListCell.identifier)
        // 注册 detail cell
        register(UINib(nibName: "RankListDetailCell", bundle: nil), forCellReuseIdentifier: RankListDetailCell.identifier)
        mj_header.beginRefreshing()
    }

    // MARK: Data
    override func refresh() {
        refreshDelegate?.rankDetailTable?(self, refreshingDataOf: tableIdentifier)
    }

    override func loadMore() {
        refreshDelegate?.rankDetailTable?(self, loadMoreDataOf: tableIdentifier)
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processRefresh(data: [Any]?, message: String?, status: Bool) {
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
    func processloadMore(data: [Any]?, message: String?, status: Bool) {
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
        if datas.count >= self.maxLimit {
            self.mj_footer = nil
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RankListDetailView: UITableViewDelegate, UITableViewDataSource {
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
        // 取出数据
        let data = datas[indexPath.row]
        var cell: UITableViewCell!
        // 排行榜名次 label
        var rankNumberLabel: UILabel?
        if let model = data as? RankListCellModel {
            model.rank = indexPath.row + 1
            let normalCell = RankListCell.cellFor(table: tableView, at: indexPath, with: model)
            normalCell.delegate = self
            cell = normalCell
            rankNumberLabel = normalCell.labelForRank
        }
        if let model = data as? RankListDetailCellModel {
            model.rank = indexPath.row + 1
            let detailCell = RankListDetailCell.cellFor(table: tableView, at: indexPath, with: model)
            detailCell.delegate = self
            cell = detailCell
            rankNumberLabel = detailCell.labelForRank
        }
        // 取消 cell 的点击效果
        cell.selectionStyle = .none
        // 设置名次 label 的字体颜色
        change(rankNumberLabel: rankNumberLabel, textColorAt: indexPath)
        return cell
    }

    /// 修改排行榜 cell 上的名次 label 的字体颜色
    func change(rankNumberLabel: UILabel?, textColorAt indexPath: IndexPath) {
        guard let label = rankNumberLabel else {
            return
        }
        // 1.判断有没有特殊的颜色
        if let specialColor = rankNumberSpecialColors[indexPath.row] {
            // 2.如果有，使用特殊颜色
            label.textColor = specialColor
        } else {
            // 3.如果没有，使用普通颜色
            label.textColor = rankNumberNormalColor
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        if let cell = cell as? RankListCell {
            self.interactionDelegate?.rankDetailTable(self, didSelectedRankListCell: cell, at: indexPath)
        } else if let cell = cell as? RankListDetailCell {
            self.interactionDelegate?.rankDetailTable(self, didSelectedRankListDetailCell: cell, at: indexPath)
        }
    }
}

extension RankListDetailView: RankListCellDelegate {
    /// 点击了 normal cell 上的关注按钮
    func rankCell(_ cell: RankListCell, didSelected followButtn: UIButton) {
        let indexPath = self.indexPath(for: cell)!
        interactionDelegate?.rankDetailTable?(self, didSelectedNormal: cell, at: indexPath)
    }
}

extension RankListDetailView: RankListDetailCellDelegate {
    /// 点击了 detail cell 上的关注按钮
    func rankDetailCell(_ cell: RankListDetailCell, didSelected followButtn: UIButton) {
        let indexPath = self.indexPath(for: cell)!
        interactionDelegate?.rankDetailTable?(self, didSelectedDetail: cell, at: indexPath)
    }
}
