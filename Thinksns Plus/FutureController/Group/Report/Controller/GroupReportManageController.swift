//
//  GroupReportManageController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子举报管理界面
/**
 四种类型共用一个列表视图，数据的加载与处理是否会出现异常？
 **/

import UIKit

enum GroupReportManageType {
    /// 全部
    case all
    /// 待处理
    case waiting
    /// 已处理 - 已同意
    case accepted
    /// 已驳回
    case rejected
}

class GroupReportManageController: TSViewController {
    // MARK: - Internal Property

    let groupId: Int

    // MARK: - Internal Function
    // MARK: - Private Property
    /// 自定义导航栏titleView
    fileprivate weak var titleView: TSTitleSelectControl!

    fileprivate weak var tableView: TSTableView!
    /// 月份选择器
    fileprivate weak var monthPicker: GroupMonthPickerView!
    /// 收益类型
    fileprivate var showType: GroupReportManageType = .all
    /// 举报管理处理类型选择弹窗视图
    fileprivate weak var reportPopView: GroupReportTypeSelectPopView!

    /// 数据源列表
    fileprivate var sourceList: [GroupReportModel] = [GroupReportModel]()

    /// 当前处理的数据模型
    fileprivate var currentSelectedModel: GroupReportModel?

    /// 翻页标识
    fileprivate var after: Int = 0
    /// 每页条数
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    /// 筛选范围
    fileprivate var startTime: TimeInterval = 0
    fileprivate var endTime: TimeInterval = Date().timeIntervalSince1970

    // MARK: - Initialize Function

    init(groupId: Int, showType: GroupReportManageType = .all) {
        self.groupId = groupId
        self.showType = showType
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension GroupReportManageController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // 1. navigationbar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "IMG_ico_circle_screen"), style: .plain, target: self, action: #selector(rightItemClick))
        let titleControl = TSTitleSelectControl()
        self.navigationItem.titleView = titleControl
        titleControl.addTarget(self, action: #selector(titleControlClick(_:)), for: .touchUpInside)
        self.titleView = titleControl
        // 2. tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
        // 3. incomeTypeSelectView
        let popView = GroupReportTypeSelectPopView()
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.reportPopView = popView
        // 4. monthPicker
        let monthPicker = GroupMonthPickerView()
        self.view.addSubview(monthPicker)
        monthPicker.delegate = self
        monthPicker.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.monthPicker = monthPicker
    }

}

// MARK: - 数据处理与加载

extension GroupReportManageController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.setupTitleWith(type: self.showType)
        self.requestData(.initial)
    }
    /// tableView 加载刷新数据 回调
    @objc fileprivate func refresh() -> Void {
        self.requestData(.refresh)
    }
    /// tableView 加载更多数据 回调
    @objc fileprivate func loadMore() -> Void {
        self.requestData(.loadmore)
    }

    /// 根据类型设置标题 - 需等自定义标题控件可用
    fileprivate func setupTitleWith(type: GroupReportManageType) -> Void {
        var title = ""
        switch type {
        case .all:
            title = "举报管理"
        case .waiting:
            title = "未处理"
        case .accepted:
            title = "已处理"
        case .rejected:
            title = "已驳回"
        }
        self.titleView.title = title
        self.showType = type
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
    /// 初始化数据 或 刷新数据
    fileprivate func loadInitialData(isRefresh: Bool) -> Void {
        self.after = 0
        TSReportNetworkManager.groupReportList(groupId: self.groupId, type: self.showType, after: self.after, limit: self.limit, start: self.startTime, end: self.endTime) { [weak self](reportList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            guard status, let reportList = reportList else {
                if isRefresh {
                    self?.tableView.mj_header.endRefreshing()
                } else {
                    self?.loadFaild(type: .network)
                }
                return
            }
            if isRefresh {
                self?.tableView.mj_header.endRefreshing()
            } else {
                self?.endLoading()
            }
            self?.sourceList = reportList
            // 整个列表为空
            if reportList.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
            }
            // 不同情况下的评论总数是不一样的，这里暂时这样处理
            self?.after = reportList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = reportList.count != self?.limit
            self?.tableView.reloadData()
        }
    }
    /// 加载更多数据
    fileprivate func loadMoreData() -> Void {
        TSReportNetworkManager.groupReportList(groupId: self.groupId, type: self.showType, after: self.after, limit: self.limit, start: self.startTime, end: self.endTime) { [weak self](reportList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            self?.tableView.mj_footer.endRefreshing()
            guard status, let reportList = reportList else {
                return
            }
            // 数据加载处理
            self?.sourceList += reportList
            self?.after = reportList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = reportList.count != self?.limit
            self?.tableView.reloadData()
        }
    }

}

extension GroupReportManageController {
    /// 显示举报处理弹窗
    fileprivate func showReportProcessPopView(for reportId: Int) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_已处理".localized, style: TSAlertActionStyle.default, handler: { (alertAction) in
            self.reportProcess(reportId: reportId, reportProcess: .accept)
        }))
        alertVC.addAction(TSAlertAction(title: "选择_驳回".localized, style: .default, handler: { (alertAction) in
            self.reportProcess(reportId: reportId, reportProcess: .reject)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 举报处理
    fileprivate func reportProcess(reportId: Int, reportProcess: TSGroupReportProcessOperate) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .success, title: "请求处理中...")
        loadingAlert.show()
        TSReportNetworkManager.groupReportProcess(reportId: reportId, processOperate: reportProcess) { (msg, status) in
            loadingAlert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            if reportId == self.currentSelectedModel?.id {
                self.currentSelectedModel?.status = (reportProcess == .accept) ? GroupReportStatus.accepted : GroupReportStatus.rejected
                self.tableView.reloadData()
            }
        }
    }

    /// 显示举报原因弹窗
    fileprivate func showReportReasonPopView(_ reason: String) -> Void {
        let popView = GroupReportReasonPopView(frame: UIScreen.main.bounds)
        popView.reason = reason
        UIApplication.shared.keyWindow?.addSubview(popView)
    }

}
// MARK: - 事件响应

extension GroupReportManageController {
    /// 标题control 点击响应
    @objc fileprivate func titleControlClick(_ control: UIControl) -> Void {
        self.monthPicker.dismiss()
        self.reportPopView.show()
    }
    /// 右侧按钮点击响应
    @objc fileprivate func rightItemClick() -> Void {
        self.reportPopView.dismiss()
        self.monthPicker.show()
    }
}

// MARK: - Notification

extension GroupReportManageController {

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension GroupReportManageController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GroupReportManageCell.cellInTableView(tableView)
        cell.model = self.sourceList[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }

}

// MARK: - UITableViewDelegate

extension GroupReportManageController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.sourceList[indexPath.row]
        // 帖子被删除时 点击不予响应
        if model.type == .post && model.post == nil {
            return
        }
        // 显示审核操作弹窗
        if model.status == .waiting {
            self.currentSelectedModel = model
            self.showReportProcessPopView(for: model.id)
        }
    }

}

// MARK: - Delegate <GroupReportTypeSelectPopViewProtocol>

extension GroupReportManageController: GroupReportTypeSelectPopViewProtocol {
    /// 选项 选中回调
    func popView(_ popView: GroupReportTypeSelectPopView, didSelectedType type: GroupReportManageType) -> Void {
        // 根据当前类型确定是否刷新
        if type == self.showType {
            return
        } else {
            self.setupTitleWith(type: type)
            self.tableView.mj_header.beginRefreshing()
        }
    }
}

// MARK: - Protocol <GroupReportManageCellProtocol>

extension GroupReportManageController: GroupReportManageCellProtocol {
    /// 举报用户 点击回调
    func didClickReportUser(in reportCell: GroupReportManageCell) -> Void {
        guard let model = reportCell.model, let user = model.user else {
            return
        }
        let userVC = TSHomepageVC(user.userIdentity)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    /// 被举报用户 点击回调
    func didClickReportedUser(in reportCell: GroupReportManageCell) -> Void {
        guard let model = reportCell.model, let targetUser = model.targetUser else {
            return
        }
        let userVC = TSHomepageVC(targetUser.userIdentity)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    /// 审核按钮 点击回调
    func didClickAuditBtn(in reportCell: GroupReportManageCell) -> Void {
        guard let model = reportCell.model else {
            return
        }
        self.currentSelectedModel = model
        // 显示审核操作弹窗
        self.showReportProcessPopView(for: model.id)
    }
    /// 被举报的资源 点击回调
    func didClickReportedResource(in reportCell: GroupReportManageCell) -> Void {
        guard let post = reportCell.model?.post else {
            return
        }
        let postDetailVC = PostDetailController(groupId: post.groupId, postId: post.id)
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    /// 举报原因显示更多 点击回调
    func didClickShowMore(in reportCell: GroupReportManageCell) -> Void {
        guard let model = reportCell.model else {
            return
        }
        self.showReportReasonPopView(model.content)
    }
}

// MARK: - Delegate <GroupMonthPickerViewProtocol>
/// 月份选择弹窗 代理
extension GroupReportManageController: GroupMonthPickerViewProtocol {
    /// 确定按钮点击回调
    func monthPickerView(_ pickerView: GroupMonthPickerView, didClickDoneWithYear year: Int, month: Int) {
        /// 方案1. 通过月份计算天数
        /// 方案2. 月份加1获取下个月的初始值(注意12月的特殊处理)
        let monthStart = String(format: "%4d %2d", year, month)
        var monthEnd = String(format: "%4d %2d", year, month + 1)
        if month == 12 {
            monthEnd = String(format: "%4d %2d", year + 1, 01)
        }
        if let startDate = monthStart.date(format: "yyyy-MM", timeZone: nil), let endDate = monthEnd.date(format: "yyyy-MM", timeZone: nil) {
            self.startTime = startDate.timeIntervalSince1970
            self.endTime = endDate.timeIntervalSince1970
        }
        self.tableView.mj_header.beginRefreshing()
    }
}
