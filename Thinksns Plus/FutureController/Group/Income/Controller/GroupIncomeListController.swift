//
//  GroupIncomeListController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子收益明细界面 - 收益列表界面

import UIKit

/// 收益类型
enum GroupIncomeType: String {
    /// 全部
    case all
    /// 成员加入 类型
    case join
    /// 置顶 类型
    case pinned
}

class GroupIncomeListController: TSViewController {
    // MARK: - Internal Property
    let groupId: Int
    // MARK: - Internal Function
    // MARK: - Private Property
    /// 自定义导航栏titleView
    fileprivate weak var titleView: TSTitleSelectControl!

    fileprivate weak var tableView: TSTableView!
    /// 收益类型
    fileprivate var type: GroupIncomeType

    /// 收益类型选择视图
    fileprivate weak var incomeTypeSelectView: GroupIncomeTypeSelectView!
    /// 月份选择器
    fileprivate weak var monthPicker: GroupMonthPickerView!

    /// 数据源列表
    fileprivate var sourceList: [GroupIncomeModel] = [GroupIncomeModel]()

    /// 翻页标识
    fileprivate var after: Int = 0
    /// 每页条数
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    /// 筛选范围
    fileprivate var startTime: TimeInterval = 0
    fileprivate var endTime: TimeInterval = Date().timeIntervalSince1970

    // MARK: - Initialize Function

    init(groupId: Int, type: GroupIncomeType = .all) {
        self.groupId = groupId
        self.type = type
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

extension GroupIncomeListController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // 1. navigationbar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "IMG_ico_circle_screen"), style: .plain, target: self, action: #selector(rightBarItemClick))
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
        tableView.frame = self.view.bounds
        //tableView.estimatedRowHeight = 250
        tableView.register(TSTransationCell.nib(), forCellReuseIdentifier: TSTransationCell.cellIdentifier)
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
        // 3. incomeTypeSelectView
        let incomeTypeSelectView = GroupIncomeTypeSelectView()
        self.view.addSubview(incomeTypeSelectView)
        incomeTypeSelectView.delegate = self
        incomeTypeSelectView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.incomeTypeSelectView = incomeTypeSelectView
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

extension GroupIncomeListController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.setupTitleWith(type: self.type)
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
    fileprivate func setupTitleWith(type: GroupIncomeType) -> Void {
        var title = ""
        switch type {
        case .all:
            title = "收益明细"
        case .join:
            title = "会员费"
        case .pinned:
            title = "置顶收益"
        }
        self.titleView.title = title
        self.type = type
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
        GroupNetworkManager.incomeList(groupId: self.groupId, type: self.type, after: self.after, limit: self.limit, start: self.startTime, end: self.endTime) { [weak self](incomeList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            guard status, let incomeList = incomeList else {
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
            self?.sourceList = incomeList
            // 整个列表为空
            if incomeList.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
            }
            // 不同情况下的评论总数是不一样的，这里暂时这样处理
            self?.after = incomeList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = incomeList.count != self?.limit
            self?.tableView.reloadData()
        }
    }
    /// 加载更多数据
    fileprivate func loadMoreData() -> Void {
        GroupNetworkManager.incomeList(groupId: self.groupId, type: self.type, after: self.after, limit: self.limit, start: self.startTime, end: self.endTime) { [weak self](incomeList, msg, status) in
            guard let weakSelf = self else {
                return
            }
            self?.tableView.mj_footer.endRefreshing()
            guard status, let incomeList = incomeList else {
                return
            }
            // 数据加载处理
            self?.sourceList += incomeList
            self?.after = incomeList.last?.id ?? weakSelf.after
            self?.tableView.mj_footer.isHidden = incomeList.count != self?.limit
            self?.tableView.reloadData()
        }
    }
}

// MARK: - 事件响应

extension GroupIncomeListController {
    /// 标题control 点击响应
    @objc fileprivate func titleControlClick(_ control: UIControl) -> Void {
        self.monthPicker.dismiss()
        self.incomeTypeSelectView.show()
    }
    /// 右侧按钮点击响应
    @objc fileprivate func rightBarItemClick() -> Void {
        self.incomeTypeSelectView.dismiss()
        self.monthPicker.show()
    }
}

// MARK: - Notification

extension GroupIncomeListController {

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension GroupIncomeListController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSTransationCell.cellIdentifier) as! TSTransationCell
        let groupIncomeModel = self.sourceList[indexPath.row]
        cell.setInfo(object: TSTransationCellModel(groupIncomeModel: groupIncomeModel))
        cell.selectionStyle = .none
        return cell
    }

}

// MARK: - UITableViewDelegate

extension GroupIncomeListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

// MARK: - Delegate <GroupIncomeTypeSelectViewProtocol>
/// 收入类型选择弹窗 代理
extension GroupIncomeListController: GroupIncomeTypeSelectViewProtocol {
    // 收益选项选中回调
    func incomeTypeSelectView(_ selectView: GroupIncomeTypeSelectView, didSelectedType type: GroupIncomeType) {
        // 根据当前类型确定是否刷新
        if type == self.type {
            return
        } else {
            self.setupTitleWith(type: type)
            self.tableView.mj_header.beginRefreshing()
        }
    }
}

// MARK: - Delegate <GroupMonthPickerViewProtocol>
/// 月份选择弹窗 代理
extension GroupIncomeListController: GroupMonthPickerViewProtocol {
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
