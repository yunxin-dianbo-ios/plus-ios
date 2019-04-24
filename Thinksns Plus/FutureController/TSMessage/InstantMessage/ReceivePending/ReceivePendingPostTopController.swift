//
//  ReceivePendingPostTopController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  消息审核页面之帖子置顶审核页面

import Foundation

class ReceivePendingPostTopController: TSViewController {

    // MARK: - Internal Property
    // MARK: - Private Property
    fileprivate weak var tableView: TSTableView!

    /// 数据源列表
    fileprivate var sourceList: [ReceivePendingPostTopModel] = []
    /// 当前选中的模型
    fileprivate var currentSelectedPostTopModel: ReceivePendingPostTopModel?

    fileprivate var after: Int = 0
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
    }

}

// MARK: - Private  UI
extension ReceivePendingPostTopController {
    fileprivate func initialUI() -> Void {
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
    }
}

// MARK: - Private  数据处理与加载
extension ReceivePendingPostTopController {
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

    /// 帖子置顶的数据请求
    fileprivate func loadInitialData(isRefresh: Bool) -> Void {
        self.after = 0
        TSPinnedNetworkManager.getPostTopList(groupId: nil, after: self.after, limit: self.limit) { [weak self](modelList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            guard status, let modelList = modelList else {
                if isRefresh {
                    self?.tableView.mj_header.endRefreshing()
                } else {
                    self?.loadFaild(type: .network)
                }
                self?.tableView.reloadData()
                return
            }
            if isRefresh {
                self?.tableView.mj_header.endRefreshing()
            } else {
                self?.loadFaild(type: .network)
            }
            self?.sourceList = modelList
            if modelList.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
            }
            self?.after = modelList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = modelList.count != self?.limit
            self?.tableView.reloadData()
        }
    }

    fileprivate func loadMoreData() -> Void {
        TSPinnedNetworkManager.getPostTopList(groupId: nil, after: self.after, limit:self.limit) { [weak self](modelList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            self?.tableView.mj_footer.endRefreshing()
            guard status, let modelList = modelList else {
                return
            }
            self?.sourceList += modelList
            self?.after = modelList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = modelList.count != self?.limit
            self?.tableView.reloadData()
        }
    }

}

// MARK: - Private  事件响应

// MARK: - Notification

// MARK: - Function Extension

extension ReceivePendingPostTopController {
    /// 显示帖子置顶审核弹窗
    fileprivate func showPostTopPopView(postId: Int) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_同意置顶".localized, style: .default, handler: { (action) in
            self.postTopAudit(postId: postId, audit: .agree)
        }))
        alertVC.addAction(TSAlertAction(title: "选择_拒绝置顶".localized, style: .default, handler: { (action) in
            self.postTopAudit(postId: postId, audit: .reject)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 帖子置顶审核
    fileprivate func postTopAudit(postId: Int, audit: TSPinnedNetworkManager.PostTopAudit) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "审核中...")
        loadingAlert.show()
        TSPinnedNetworkManager.postTopPinnedAudit(postId: postId, audit: audit, complete: { [weak self](msg, status) in
            loadingAlert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            // 审核成功，修改本地数据
            if status && postId == self?.currentSelectedPostTopModel?.post?.id {
                self?.currentSelectedPostTopModel?.status = (audit == .agree) ? .agree : .reject
                self?.tableView.reloadData()
            }
        })
    }
}

// MARK: - UITableViewDataSource

extension ReceivePendingPostTopController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ReceivePendingPostTopCell.cellInTableView(tableView)
        cell.model = self.sourceList[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReceivePendingPostTopController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}

// MARK: - Delegate <ReceivePendingPostTopCellProtocol>
// 帖子置顶Cell回调
extension ReceivePendingPostTopController: ReceivePendingPostTopCellProtocol {
    /// 申请用户 点击回调
    func didClickUserInPostTopCell(_ cell: ReceivePendingPostTopCell) -> Void {
        guard let userId = cell.model?.userId else {
            return
        }
        let userVC = TSHomepageVC(userId)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    /// 审核按钮 点击响应
    func didClickAuditInPostTopCell(_ cell: ReceivePendingPostTopCell) -> Void {
        guard let model = cell.model, let post = cell.model?.post else {
            return
        }
        self.showPostTopPopView(postId: post.id)
        self.currentSelectedPostTopModel = model
    }
    /// 帖子 点击响应
    func didClickPostInPostTopCell(_ cell: ReceivePendingPostTopCell) -> Void {
        guard let post = cell.model?.post else {
            return
        }
        let postVC = PostDetailController(groupId: post.groupId, postId: post.id)
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}
