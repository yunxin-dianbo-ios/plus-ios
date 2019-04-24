//
//  QuoraAnswersListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答答案列表

import UIKit

/// 问答列表刷新代理
@objc protocol QuoraAnswersListViewRefreshDelegate: class {
    /// 下拉刷新
    @objc optional func answerTable(_ table: QuoraAnswersListView, refreshingDataOf tableIdentifier: String)
    /// 上拉加载
    @objc optional func answerTable(_ table: QuoraAnswersListView, loadMoreDataOf tableIdentifier: String)
}

/// 问答列表用户交互事件代理
@objc protocol QuoraAnswersListViewDelegate: class {
    /// 点击了 cell
    @objc optional func answerTable(_ table: QuoraAnswersListView, didSelectRowAt indexPath: IndexPath, with tableIdentifier: String)
}

class QuoraAnswersListView: TSTableView {

    /// table 区分标识符，当多个 TSQuoraTableView 同时存在同一个界面时区分彼此
    var tableIdentifier = ""
    /// 数据源
    var datas: [TSAnswerListModel] = []
    /// 刷新事件代理
    weak var refreshDelegate: QuoraAnswersListViewRefreshDelegate?
    /// 用户交互代理事件
    weak var interactionDelegate: QuoraAnswersListViewDelegate?
    /// 单页条数
    var listLimit = TSAppConfig.share.localInfo.limit

    /// 是否需要在刚显示时自动刷新
    var shouldAutoRefresh = true

    // MARK: - Lifecycle

    /// 初始化
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - identifier: table 区分标识符，当多个 TSQuoraTableView 同时存在同一个界面时区分彼此
    ///   - shouldAutoRefresh: 是否需要在刚显示时自动刷新
    init(frame: CGRect, tableIdentifier identifier: String, shouldAutoRefresh shouldRefresh: Bool) {
        super.init(frame: frame, style: .plain)
        tableIdentifier = identifier
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
        backgroundColor = TSColor.inconspicuous.disabled
        // 注册标题 cell
        register(TSAnswerListCell.self, forCellReuseIdentifier: "TSAnswerListCell")
        if shouldAutoRefresh {
            mj_header.beginRefreshing()
        }
    }

    // MARK: Data
    override func refresh() {
        refreshDelegate?.answerTable?(self, refreshingDataOf: tableIdentifier)
    }

    override func loadMore() {
        refreshDelegate?.answerTable?(self, loadMoreDataOf: tableIdentifier)
    }

    /// 处理下拉刷新的数据的界面刷新
    func processRefresh(newDatas: [TSAnswerListModel]?, errorMessage: String?) {
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
    func processLoadMore(newDatas: [TSAnswerListModel]?, errorMessage: String?) {
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
        reloadData()
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if newDatas.count < listLimit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension QuoraAnswersListView: UITableViewDelegate, UITableViewDataSource {
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
        let cell = TSMyAnswerListCell.cellInTableView(tableView)
        cell.loadAnswer(datas[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactionDelegate?.answerTable?(self, didSelectRowAt: indexPath, with: tableIdentifier)
    }
}

extension QuoraAnswersListView: TSMyAnswerListCellProtocol {
        /// 点赞Item点击响应
        func didClickFavorItemInCell(_ cell: TSMyAnswerListCell) {
            guard let model = cell.model else {
                return
            }
            // 点赞相关请求
            cell.toolBarEnable = false
            let favorOperate = model.liked ? TSFavorOperate.unfavor : TSFavorOperate.favor
            cell.favorOrUnFavor = !model.liked
            TSQuoraNetworkManager.answerFavorOperate(favorOperate, answerId: model.id) { (msg, status) in
                cell.toolBarEnable = true
                if status {
                    model.liked = favorOperate == TSFavorOperate.favor ? true : false
                    model.likesCount += favorOperate == TSFavorOperate.favor ? 1 : -1
                    cell.updateToolBar()
                } else {
                    // 提示
                    let loadingShow = TSIndicatorWindowTop(state: .faild, title: msg)
                    loadingShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        }
        /// 评论Item点击响应
        func didClickCommentItemInCell(_ cell: TSMyAnswerListCell) {
            // 点击Item进入答案详情
            guard let model = cell.model else {
                return
            }
            // 进入答案详情页
            let answerDetailVC = TSAnswerDetailController(answerId: model.id)
            self.parentViewController?.navigationController?.pushViewController(answerDetailVC, animated: true)
        }
}
