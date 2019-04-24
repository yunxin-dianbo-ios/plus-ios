//
//  TSAnswerCollectionController.swift
//  ThinkSNSPlus
//
//  Created by 小唐 on 20/03/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  答案收藏界面

import UIKit

class TSAnswerCollectionController: TSViewController {

    // MARK: - Internal Property
    // MARK: - Private Property
    fileprivate weak var tableView: TSTableView!

    /// 数据源列表
    fileprivate var sourceList: [TSCollectionAnswerModel] = []
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    fileprivate var after: Int = 0

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }
}

// MARK: - UI

extension TSAnswerCollectionController {
    fileprivate func initialUI() -> Void {
        // 2. tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.backgroundColor = TSColor.inconspicuous.background
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - TSNewsTagButtonUX.buttonHeight - TSNavigationBarHeight)
        self.tableView = tableView
    }
}

// MARK: - Data

extension TSAnswerCollectionController {
    /// 数据加载
    func initialDataSource() -> Void {
        //self.requestData(.initial)
        self.tableView.mj_header.beginRefreshing()
    }
    /// tableView 加载刷新数据 回调
    @objc fileprivate func refresh() -> Void {
        self.requestData(.refresh)
    }
    /// tableView 加载更多数据 回调
    @objc fileprivate func loadMore() -> Void {
        self.requestData(.loadmore)
    }

    /// 请求列表数据
    fileprivate func requestData(_ loadType: TSListDataLoadType) -> Void {
        switch loadType {
        case .initial:
            self.loading()
            self.loadInitialData(isRefresh: false)
        case .refresh:
            self.loadInitialData(isRefresh: true)
        case .loadmore:
            self.loadMoreData()
        }
    }

    fileprivate func loadInitialData(isRefresh: Bool) -> Void {
        self.after = 0
        TSQuoraNetworkManager.answerCollectionList(afterId: self.after, limit: self.limit) { [weak self](answerList, msg, status) in
            guard let `self` = self else {
                return
            }
            guard status, let collectionList = answerList else {
                if isRefresh {
                    self.tableView.mj_header.endRefreshing()
                } else {
                    self.loadFaild(type: .network)
                }
                self.tableView.reloadData()
                return
            }
            if isRefresh {
                self.tableView.mj_header.endRefreshing()
            } else {
                self.loadFaild(type: .network)
            }
            self.sourceList = collectionList
            if collectionList.isEmpty {
                self.tableView.show(placeholderView: .empty)
            } else {
                self.tableView.removePlaceholderViews()
            }
            self.after = collectionList.last?.id ?? self.after
            self.tableView.mj_footer.isHidden = collectionList.count != self.limit
            for (index, item) in self.sourceList.enumerated().reversed() {
                if self.sourceList[index].answer == nil {
                    self.sourceList.remove(at: index)
                }
            }
            self.tableView.reloadData()
        }
    }
    fileprivate func loadMoreData() -> Void {
        TSQuoraNetworkManager.answerCollectionList(afterId: self.after, limit: self.limit) { [weak self](answerList, msg, status) in
            guard let `self` = self else {
                return
            }
            self.tableView.mj_footer.endRefreshing()
            guard status, let collectionList = answerList else {
                return
            }
            // 数据加载
            self.sourceList += collectionList
            self.after = collectionList.last?.id ?? self.after
            self.tableView.mj_footer.isHidden = collectionList.count != self.limit
            for (index, item) in self.sourceList.enumerated().reversed() {
                if self.sourceList[index].answer == nil {
                    self.sourceList.remove(at: index)
                }
            }
            self.tableView.reloadData()
        }
    }

}

// MARK: - 事件响应

// MARK: - Notification

// MARK: - Delegate Function

// MARK: - <UITableViewDataSource>

extension TSAnswerCollectionController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TSMyAnswerListCell.cellInTableView(tableView)
        if let answer = self.sourceList[indexPath.row].answer {
            cell.loadAnswer(answer)
        }
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

}

// MARK: - <UITableViewDelegate>

extension TSAnswerCollectionController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let answer = self.sourceList[indexPath.row].answer else {
            return
        }
        // 进入答案详情页
        let answerDetailVC = TSAnswerDetailController(answerId: answer.id)
        self.navigationController?.pushViewController(answerDetailVC, animated: true)
    }

}

// MARK: - <TSMyAnswerListCellProtocol>

extension TSAnswerCollectionController: TSMyAnswerListCellProtocol {
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
        self.navigationController?.pushViewController(answerDetailVC, animated: true)
    }
}
