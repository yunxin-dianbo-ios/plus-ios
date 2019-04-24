//
// Created by lip on 2017/9/18.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//
// 收到的待操作信息视图控制器
//  该页面最开始只兼容评论置顶，后来随着类型增加，已弃用，请使用ReveivePendingController

import Foundation
import MJRefresh

class ReceivePendingTypeView: UIView {
    /// 动画时间
    let animationTime = TimeInterval(0.3)
    /// 按钮视图
    @IBOutlet weak var buttonView: UIView!
    /// 按钮基础 tag 值
    internal let tagForButton = 200
    /// row 点击事件 block
    internal var tapOperationBlock: ((_ index: Int) -> Void)?
    /// 视图消失事件 block
    internal var dismissOperationBlock: (() -> Void)?

    // MARK: - Lifecycle
    /// 初始化方法
    class func makeTransitionTypeView() -> ReceivePendingTypeView {
        let typeView = (Bundle.main.loadNibNamed("TSTransitionTypeView", owner: self, options: nil)?[1] as?ReceivePendingTypeView)!
        return typeView
    }

    // MAKR: - Button click
    @IBAction func rowTaped(_ sender: UIButton) {
        dismiss()
        let index = sender.tag - tagForButton
        if let operation = tapOperationBlock {
            operation(index)
        }
    }

    /// 点击了背景视图
    @IBAction func backButtonTaped(_ sender: UIButton) {
        dismiss()
    }

    // MARK: - Public
    /// 设置 row 点击事件
    func setTap(operation: @escaping (_ index: Int) -> Void) {
        tapOperationBlock = operation
    }

    /// 设置消失响应事件
    func setDismiss(operation: @escaping () -> Void) {
        dismissOperationBlock = operation
    }

    /// 出场动画
    func show() {
        buttonView.frame.origin.y = -buttonView.frame.height
        superview?.isHidden = false
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.buttonView.frame.origin.y = 0
            }
            }, completion: nil)
    }
    /// 退场动画
    func dismiss() {
        buttonView.frame.origin.y = 0
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.buttonView.frame.origin.y = -weakSelf.buttonView.frame.height
            }
            }, completion: { [weak self] (_) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.superview?.isHidden = true
                if let block = weakSelf.dismissOperationBlock {
                    block()
                }
        })
    }
}

class ReceivePendingTableVC: TSTableViewController, NoticePendingProtocol, TSCustomAcionSheetDelegate {
    // MARK: - property
    var dataSource: [ReceivePendingCommentTopModel] = []
    var type: TSTopTargetType.Comment
    /// 操作的数据
    lazy var pendingData: ReceivePendingCommentTopModel = ReceivePendingCommentTopModel()
    lazy var indicator = TSIndicatorWindowTop(state: .loading, title: "审核中")
    /// 标题按钮
    let buttonForTitle = TSTransationTitleButton(type: .custom)
    /// 标题弹出菜单
    let titleView = ReceivePendingTypeView.makeTransitionTypeView()
    /// 标题弹窗菜单容器视图
    let titleViewSuperView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 65), size: UIScreen.main.bounds.size))

    let limit: Int = TSAppConfig.share.localInfo.limit

    // MARK: - lifecycle
    init(style: UITableViewStyle, type: TSTopTargetType.Comment) {
        self.type = type
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(NoticeContentCell.self, forCellReuseIdentifier: "NoticePendingCell")
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if titleViewSuperView.superview == nil {
            navigationController?.view.addSubview(titleViewSuperView)
            navigationController?.view.insertSubview(titleViewSuperView, belowSubview: (navigationController?.navigationBar)!)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleViewSuperView.removeFromSuperview()
    }
    // MARK: - setup
    func setupUI() {
        buttonForTitle.frame = CGRect(x: 0, y: 0, width: 120, height: 25)
        buttonForTitle.setTitle("动态评论置顶", for: .normal)
        navigationItem.titleView = buttonForTitle
        buttonForTitle.addTarget(self, action: #selector(transitionButtonTaped), for: .touchUpInside)
        // title view
        titleViewSuperView.isHidden = true
        titleView.frame = UIScreen.main.bounds
        titleView.setTap { [weak self] (index) in // 标题菜单栏的点击事件
            guard let weakSelf = self else {
                return
            }
            guard let type = TSTopTargetType.Comment(rawValue: index) else {
                TSLogCenter.log.debug("出现了未知的交易类型")
                return
            }
            weakSelf.type = type
            weakSelf.updateButtonForTitle()
        }
        titleView.setDismiss { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.buttonForTitle.isSelected = false
        }

        titleViewSuperView.addSubview(titleView)
        navigationController?.view.addSubview(titleViewSuperView)
        navigationController?.view.insertSubview(titleViewSuperView, belowSubview: (navigationController?.navigationBar)!)
    }

    func updateButtonForTitle() {
        // 1. 更新 title
        var title = ""
        switch type {
        case .moment:
            title = "动态评论置顶"
        case .news:
            title = "文章评论置顶"
        case .post:
            title = "帖子评论置顶"
        }
        buttonForTitle.setTitle(title, for: .normal)
        dataSource.removeAll()
        tableView.mj_header.beginRefreshing()
    }

    // MARK: - Delegete
    // MARK: Refresh delegate
    override func refresh() {
        TSPinnedNetworkManager.pinnedList(commentTargetType: self.type, limit: self.limit, after: 0) { [weak self](models, msg, status) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_header.endRefreshing()
            guard let models = models else {
                weakSelf.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.show(placeholderView: .empty)
                return
            } else {
                weakSelf.removePlaceholderViews()
            }
            weakSelf.dataSource = models
            weakSelf.tableView.mj_footer.isHidden = models.count < weakSelf.limit
            weakSelf.tableView.reloadData()
        }
    }

    // MARK: GTMLoadMoreFooterDelegate
    override func loadMore() {
        guard let model = self.dataSource.last else {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        let offset = self.dataSource.count
        let afterId: Int = self.type == .post ? offset : model.id
        TSPinnedNetworkManager.pinnedList(commentTargetType: self.type, limit: self.limit, after: afterId) { [weak self](models, msg, status) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_footer.endRefreshing()
            guard let models = models else {
                weakSelf.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            } else {
                weakSelf.removePlaceholderViews()
            }
            weakSelf.dataSource += models
            if models.count < weakSelf.limit {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            weakSelf.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticePendingCell") as! NoticePendingCell
        if type == .moment, dataSource.isEmpty == false {
            let model = dataSource[indexPath.row] as! ReceivePendingFeedCommentTopModel
            cell.config = model.convertTo()
        } else if type == .news, dataSource.isEmpty == false {
            let model = dataSource[indexPath.row] as! ReceivePendingNewsCommentTopModel
            cell.config = model.convertTo()
        } else if type == .post, dataSource.isEmpty == false {
            let model = dataSource[indexPath.row] as! ReceivePendingPostCommentTopModel
            cell.config = model.convertTo()
        }

        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }

    // MARK: - did click
    /// 点击了标题按钮
    func transitionButtonTaped() {
        buttonForTitle.isSelected = !buttonForTitle.isSelected
        buttonForTitle.isSelected ? titleView.show() : titleView.dismiss()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 审核操作
        let model = dataSource[indexPath.row]
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
        pendingData = dataSource[indexPath.row]
    }

    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        switch title {
        case "选择_同意置顶".localized:
            agreePending()
        case "选择_拒绝置顶".localized:
            denyPending()
        default:
            assert(false, "出现了未配置的情况")
        }
    }

    func agreePending() {
        guard let exten = pendingData.exten, let targetId = exten.targetId else {
            assert(false, "操作了没有扩展信息的数据")
            return
        }
        guard let commentInfo = pendingData.commentInfo else {
            assert(false, "操作了没有扩展信息的数据")
            return
        }
        indicator.show()
        self.tableView.isUserInteractionEnabled = false
        TSPinnedNetworkManager.agreeCommentPinned(commentId: commentInfo.id, pinnedId: pendingData.id, commentTargetId: targetId, commentTargetType: self.type) { (msg, status) in
            self.indicator.dismiss()
            self.tableView.isUserInteractionEnabled = true
            if status {
                self.pendingData.expiresDate = Date()
                let resultIndicator = TSIndicatorWindowTop(state: .success, title: "已同意")
                resultIndicator.show(timeInterval: 2)
                self.tableView.reloadData()
            } else {
                let resultIndicator = TSIndicatorWindowTop(state: .faild, title: "网络错误,稍后再试")
                resultIndicator.show(timeInterval: 2)
            }
        }
    }

    func denyPending() {
        guard let exten = pendingData.exten, let targetId = exten.targetId else {
            assert(false, "操作了没有扩展信息的数据")
            return
        }
        guard let commentInfo = pendingData.commentInfo else {
            assert(false, "操作了没有扩展信息的数据")
            return
        }
        indicator.show()
        self.tableView.isUserInteractionEnabled = false
        TSPinnedNetworkManager.denyCommentPinned(commentId: commentInfo.id, pinnedId: pendingData.id, commentTargetId: targetId, commentTargetType: self.type) { (msg, status) in
            self.indicator.dismiss()
            self.tableView.isUserInteractionEnabled = true
            if status {
                self.pendingData.expiresDate = Date()
                let resultIndicator = TSIndicatorWindowTop(state: .success, title: "已拒绝")
                resultIndicator.show(timeInterval: 2)
                self.tableView.reloadData()
            } else {
                let resultIndicator = TSIndicatorWindowTop(state: .faild, title: "网络错误,稍后再试")
                resultIndicator.show(timeInterval: 2)
            }
        }
    }

    func notice(pendingCell: NoticePendingCell, didClickRegion: NoticePendingCellClickRegion) {
        let model = dataSource[pendingCell.indexPath.row]
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

    private func didClickExtenRegion(_ model: ReceivePendingCommentTopModel) {
        guard let exten = model.exten, let targetId = exten.targetId else {
            assert(false, "点击了页面的扩展区域,但是查询到的数据没有扩展数据")
            return
        }
        switch type {
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
        }
    }
}
