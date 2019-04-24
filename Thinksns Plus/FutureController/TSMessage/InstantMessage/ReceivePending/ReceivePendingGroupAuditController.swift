//
//  ReceivePendingGroupAuditController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  消息审核页面之加入圈子审核子页面

import Foundation

class ReceivePendingGroupAuditController: TSViewController {

    // MARK: - Internal Property
    // MARK: - Private Property
    fileprivate weak var tableView: TSTableView!

    /// 数据源列表
    fileprivate var sourceList: [ReceivePendingGroupAuditModel] = []
    /// 当前选中的模型
    fileprivate var currentSelectedAuditModel: ReceivePendingGroupAuditModel?

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
extension ReceivePendingGroupAuditController {
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
extension ReceivePendingGroupAuditController {
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
        GroupNetworkManager.getAuditList(after: self.after, limit: self.limit) { [weak self](auditList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            guard status, let auditList = auditList else {
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
            self?.sourceList = auditList
            if auditList.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
            }
            self?.after = auditList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = auditList.count != self?.limit
            self?.tableView.reloadData()
        }
    }
    fileprivate func loadMoreData() -> Void {
        GroupNetworkManager.getAuditList(after: self.after, limit: self.limit) { [weak self](auditList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            self?.tableView.mj_footer.endRefreshing()
            guard status, let auditList = auditList else {
                return
            }
            // 数据加载
            self?.sourceList += auditList
            self?.after = auditList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = auditList.count != self?.limit
            self?.tableView.reloadData()
        }
    }

}

// MARK: - Private  事件响应

// MARK: - Notification

// MARK: - Function Extension

extension ReceivePendingGroupAuditController {
    /// 显示圈子审核弹窗
    fileprivate func showGroupAuditPopView(auditId: Int, groupId: Int, memberId: Int) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "同意加入圈子", style: .default, handler: { (action) in
            self.groupAudit(auditId: auditId, groupId: groupId, memberId: memberId, audit: .accept)
        }))
        alertVC.addAction(TSAlertAction(title: "拒绝加入圈子", style: .default, handler: { (action) in
            self.groupAudit(auditId: auditId, groupId: groupId, memberId: memberId, audit: .reject)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 圈子审核
    fileprivate func groupAudit(auditId: Int, groupId: Int, memberId: Int, audit: GroupNetworkManager.MemberJoinAudit) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "请求中...")
        loadingAlert.show()
        GroupNetworkManager.auditJoin(groupId: groupId, memberId: memberId, audit: audit) { [weak self](msg, status) in
            loadingAlert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            // 审核成功，修改本地数据
            if status && auditId == self?.currentSelectedAuditModel?.id {
                self?.currentSelectedAuditModel?.status = (audit == .accept) ? ReceivePendingGroupAuditModel.Status.agree : ReceivePendingGroupAuditModel.Status.reject
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension ReceivePendingGroupAuditController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ReceivePendingGroupAuditCell.cellInTableView(tableView)
        cell.model = self.sourceList[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReceivePendingGroupAuditController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.sourceList[indexPath.row]
        if model.status == .wait {
            self.currentSelectedAuditModel = model
            self.showGroupAuditPopView(auditId: model.id, groupId: model.groupId, memberId: model.memberId)
        }
    }

}

// MARK: - <ReceivePendingGroupAuditCellProtocol>

extension ReceivePendingGroupAuditController: ReceivePendingGroupAuditCellProtocol {
    /// 申请用户 点击回调
    func didClickUserInGroupAuditCell(_ cell: ReceivePendingGroupAuditCell) -> Void {
        guard let userId = cell.model?.userId else {
            return
        }
        let userVC = TSHomepageVC(userId)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    /// 审核按钮 点击响应
    func didClickAuditInGroupAuditCell(_ cell: ReceivePendingGroupAuditCell) -> Void {
        guard let model = cell.model else {
            return
        }
        self.currentSelectedAuditModel = model
        self.showGroupAuditPopView(auditId: model.id, groupId: model.groupId, memberId: model.memberId)
    }
}
