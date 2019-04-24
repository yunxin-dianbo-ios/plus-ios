//
//  ReceivePendingCommentTopController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//

import Foundation

class ReceivePendingCommentTopController: TSViewController {

    // MARK: - Internal Property
    // MARK: - Private Property
    fileprivate weak var tableView: TSTableView!

    /// 当前展示的评论置顶类型
    let commentTopType: TSTopTargetType.Comment

    /// 数据源列表
    fileprivate var sourceList: [ReceivePendingCommentTopModel] = []
    /// 当前选中的模型
    fileprivate var currentSelectedCommentTopModel: ReceivePendingCommentTopModel?

    fileprivate var after: Int = 0
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit

    // MARK: - Initialize Function

    init(commentTopType: TSTopTargetType.Comment) {
        self.commentTopType = commentTopType
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
    }
}

// MARK: - Private  UI
extension ReceivePendingCommentTopController {
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
        tableView.register(NoticeContentCell.self, forCellReuseIdentifier: "NoticePendingCell")
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
    }
}

// MARK: - Private  数据处理与加载
extension ReceivePendingCommentTopController {
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

    /// 评论置顶的数据请求
    fileprivate func loadInitialData(isRefresh: Bool) -> Void {
        self.after = 0
        TSPinnedNetworkManager.pinnedList(commentTargetType: self.commentTopType, limit: self.limit, after: self.after) { [weak self](models, msg, status) in
            guard let weakSelf = self else {
                return
            }
            guard status, let models = models else {
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
            self?.sourceList = models
            if models.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
            }
            self?.after = models.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = models.count != self?.limit
            self?.tableView.reloadData()
        }
    }

    fileprivate func loadMoreData() -> Void {
        let offset = self.sourceList.count
        let afterId: Int = self.commentTopType == .post ? offset : self.after
        TSPinnedNetworkManager.pinnedList(commentTargetType: commentTopType, limit: self.limit, after: afterId) { [weak self](models, msg, status) in
            guard let weakSelf = self else {
                return
            }
            self?.tableView.mj_footer.endRefreshing()
            guard status, let models = models else {
                return
            }
            // 数据加载处理
            self?.sourceList += models
            self?.after = models.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = models.count != self?.limit
            self?.tableView.reloadData()
        }
    }

}

// MARK: - Private  事件响应

// MARK: - Notification

// MARK: - Function Extension

extension ReceivePendingCommentTopController {
    /// 评论置顶中 点击了评论源时响应
    fileprivate func didClickExtenRegion(_ model: ReceivePendingCommentTopModel) {
        guard let exten = model.exten, let targetId = exten.targetId else {
            assert(false, "点击了页面的扩展区域,但是查询到的数据没有扩展数据")
            return
        }
        switch self.commentTopType {
        case .moment:
            let detailVC = TSCommetDetailTableView(feedId: targetId)
            navigationController?.pushViewController(detailVC, animated: true)
        case .news:
            let newsDetailVC = TSNewsDetailViewController(newsId: targetId)
            self.navigationController?.pushViewController(newsDetailVC, animated: true)
        case .post:
            if let groupId = exten.groupId {
                let detailVC = PostDetailController(groupId: groupId, postId: targetId)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        default:
            break
        }
    }

    /// 同意评论置顶
    func agreeCommentPending() {
        guard let commentTopModel = self.currentSelectedCommentTopModel, let exten = self.currentSelectedCommentTopModel?.exten, let targetId = exten.targetId, let commentInfo = self.currentSelectedCommentTopModel?.commentInfo else {
            assert(false, "操作了没有扩展信息的数据")
            return
        }
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "审核中...")
        loadingAlert.show()
        self.tableView.isUserInteractionEnabled = false
        TSPinnedNetworkManager.agreeCommentPinned(commentId: commentInfo.id, pinnedId: commentTopModel.id, commentTargetId: targetId, commentTargetType: self.commentTopType) { (msg, status) in
            loadingAlert.dismiss()
            self.tableView.isUserInteractionEnabled = true
            if status {
                self.currentSelectedCommentTopModel?.expiresDate = Date()
                let resultIndicator = TSIndicatorWindowTop(state: .success, title: "已同意")
                resultIndicator.show(timeInterval: 2)
                self.tableView.reloadData()
            } else {
                let resultIndicator = TSIndicatorWindowTop(state: .faild, title: "网络错误,稍后再试")
                resultIndicator.show(timeInterval: 2)
            }
        }
    }
    /// 拒绝评论置顶
    func denyCommentPending() {
        guard let commentTopModel = self.currentSelectedCommentTopModel, let exten = self.currentSelectedCommentTopModel?.exten, let targetId = exten.targetId, let commentInfo = self.currentSelectedCommentTopModel?.commentInfo else {
            assert(false, "操作了没有扩展信息的数据")
            return
        }
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "审核中...")
        loadingAlert.show()
        self.tableView.isUserInteractionEnabled = false
        TSPinnedNetworkManager.denyCommentPinned(commentId: commentInfo.id, pinnedId: commentTopModel.id, commentTargetId: targetId, commentTargetType: self.commentTopType) { (msg, status) in
            loadingAlert.dismiss()
            self.tableView.isUserInteractionEnabled = true
            if status {
                self.currentSelectedCommentTopModel?.expiresDate = Date()
                let resultIndicator = TSIndicatorWindowTop(state: .success, title: "已拒绝")
                resultIndicator.show(timeInterval: 2)
                self.tableView.reloadData()
            } else {
                let resultIndicator = TSIndicatorWindowTop(state: .faild, title: "网络错误,稍后再试")
                resultIndicator.show(timeInterval: 2)
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension ReceivePendingCommentTopController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticePendingCell") as! NoticePendingCell
        if self.commentTopType == .moment {
            let model = self.sourceList[indexPath.row] as! ReceivePendingFeedCommentTopModel
            cell.config = model.convertTo()
        } else if self.commentTopType == .news {
            let model = self.sourceList[indexPath.row] as! ReceivePendingNewsCommentTopModel
            cell.config = model.convertTo()
        } else if self.commentTopType == .post {
            let model = self.sourceList[indexPath.row] as! ReceivePendingPostCommentTopModel
            cell.config = model.convertTo()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReceivePendingCommentTopController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 评论置顶 审核操作
        let model = self.sourceList[indexPath.row]
        guard model.sourceIsDelete == false else {
            TSCustomActionsheetView(titles: ["内容已被删除"]).show()
            return
        }
        guard model.sourceIsPending == false else {
            return
        }
        // 判断 是否已审核
        let sheetView = TSCustomActionsheetView(titles: ["选择_同意置顶".localized, "选择_拒绝置顶".localized])
        sheetView.delegate = self
        sheetView.show()
        self.currentSelectedCommentTopModel = self.sourceList[indexPath.row]
    }

}

// MARK: - <NoticePendingProtocol>

extension ReceivePendingCommentTopController: NoticePendingProtocol {
    /// 待操作按钮点击了某些区域
    func notice(pendingCell: NoticePendingCell, didClickRegion: NoticePendingCellClickRegion) {
        let model = self.sourceList[pendingCell.indexPath.row]
        switch didClickRegion {
        case .avatar, .title:
            let userHomPage = TSHomepageVC(model.userId)
            navigationController?.pushViewController(userHomPage, animated: true)
        case .subTitle:
        break // 该页面没有使用这个区域.不应该出现该类型回调
        case .content:
            didClickExtenRegion(model)
        case .pending:
            tableView(tableView, didSelectRowAt: pendingCell.indexPath)
        case .exten:
            didClickExtenRegion(model)
        }
    }
}

// MARK: - <TSCustomAcionSheetDelegate>

extension ReceivePendingCommentTopController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        switch title {
        case "选择_同意置顶".localized:
            self.agreeCommentPending()
        case "选择_拒绝置顶".localized:
            self.denyCommentPending()
        default:
            assert(false, "出现了未配置的情况")
        }
    }
}
