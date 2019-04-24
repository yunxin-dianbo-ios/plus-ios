//
//  GroupMemberManageController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子成员管理界面
/**
 权限管理：
     圈主：展示(查看所有)、操作(不可操作自己、)
     管理员：展示(查看所有)、操作(不可操作管理员、不可将普通成员升级为管理员)
     普通成员：展示(不可查看黑名单)、操作(不可操作)
     黑名单：展示(不可查看黑名单)、操作(不可操作)
     注：圈主也属于管理员
 
 成员管理界面更新：
     将原来的一个页面调整为2个页面：即黑名单独立出来，但样式、操作和之前一样。
     成员加载方式更新：之前是一次性加载完毕，现在仅仅圈管理一次性加载完毕，其他分批加载
 
 **/

import UIKit

class GroupMemberManageController: TSViewController {

    // MARK: - Internal Property

    let groupId: Int
    /// 是否是黑名单展示
    let isBlack: Bool
    /// 当前用户的成员角色类型
    let currentUserRole: GroupMemberRoleType
    /// 成员总数量
    var memberCount: Int = 0
    // MARK: - Internal Function
    // MARK: - Private Property

    /// 搜索页是不是应该弄个基类、搜索的展示形式
    enum ShowType {
        case normal
        case search
    }
    fileprivate var showType: ShowType = .normal

    /// 搜索的navigationUI
    fileprivate weak var searchBar: TSSearchBarView!
    fileprivate weak var searchField: UITextField!
    fileprivate weak var cancelBtn: UIButton!
    /// tableView
    /// 成员列表
    fileprivate weak var normalTableView: TSTableView!
    /// 搜索结果列表
    fileprivate weak var searchTableView: TSTableView!
    fileprivate weak var currentTableView: TSTableView!

    fileprivate var currentIndexPath: IndexPath?
    fileprivate var currentMember: GroupMemberModel?

    fileprivate let adminKey: String = "adminListkey"
    fileprivate let memberKey: String = "memberListkey"
    fileprivate let blackKey: String = "blackListkey"
    fileprivate var sourceList: [(key: String, list: [GroupMemberModel])] = [(key: String, list: [GroupMemberModel])]()
    /// 管理员列表
    fileprivate var adminList: [GroupMemberModel] = [GroupMemberModel]()
    /// 成员列表
    fileprivate var memberList: [GroupMemberModel] = [GroupMemberModel]()
    /// 黑名单列表
    fileprivate var blackList: [GroupMemberModel] = [GroupMemberModel]()
    /// 搜索结果列表
    fileprivate var searchList: [GroupMemberModel] = [GroupMemberModel]()

    fileprivate var normalAfter: Int = 0
    fileprivate var searchAfter: Int = 0
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit

    /// 搜索字符串
    fileprivate var searchKey: String = ""

    // MARK: - Initialize Function

    init(groupId: Int, isBlack: Bool, currentUserRole: GroupMemberRoleType) {
        self.groupId = groupId
        self.isBlack = isBlack
        self.currentUserRole = currentUserRole
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.initialUI()
        self.initialDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}

// MARK: - UI

extension GroupMemberManageController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // 1. searchBar
        let searchBar = TSSearchBarView()
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.bottom.equalTo(self.view.snp.top).offset(TSNavigationBarHeight)
        }
        self.searchBar = searchBar
        // 1.x 导航栏搜索框相关配置
        self.searchField = searchBar.searchTextFiled
        self.searchField.returnKeyType = .search
        searchField.delegate = self
        self.cancelBtn = searchBar.rightButton
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
        // 2. tableView
        self.normalTableView = self.createTableView()
        self.searchTableView = self.createTableView()
        self.setupShowType(.normal)
    }

    fileprivate func createTableView() -> TSTableView {
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        //tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        //tableView.mj_header.isHidden = true
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true     // 默认隐藏上拉加载更多
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(searchBar.snp.bottom)
        }
        return tableView
    }
}

// MARK: - 数据请求

extension GroupMemberManageController {
    /// 数据源初始化
    fileprivate func initialDataSource() -> Void {
        self.setupShowType(.normal)
        self.normalTableView.mj_header.beginRefreshing()
    }

    /// 下拉刷新
    @objc fileprivate func refresh() -> Void {
        self.requestData(.refresh)
    }
    /// 上拉加载更多
    @objc fileprivate func loadMore() -> Void {
        self.requestData(.loadmore)
    }

    /// 请求列表数据
    fileprivate func requestData(_ loadType: TSListDataLoadType) -> Void {
        // 根据当前展示类型 进行不同的请求加载
        switch self.showType {
        case .normal:
            switch loadType {
            case .initial:
                self.normalLoadInitialData(isRefresh: true)
            case .refresh:
                self.normalLoadInitialData(isRefresh: true)
            case .loadmore:
                self.normalLoadMoreData()
            }
        case .search:
            let key = self.searchKey
            switch loadType {
            case .initial:
                self.searchLoadInitialData(isRefresh: true, key: key)
            case .refresh:
                self.searchLoadInitialData(isRefresh: true, key: key)
            case .loadmore:
                self.searchLoadMoreData(key: key)
            }
        }
    }

    /// normalInitial
    fileprivate func normalLoadInitialData(isRefresh: Bool) -> Void {
        self.normalAfter = 0
        if  self.isBlack == false {
            // 请求管理列表
            let type: GroupNetworkManager.MemberType = .manager
            GroupNetworkManager.memberList(groupId: self.groupId, after: 0, limit: self.limit, type: type) { [weak self](memberList, msg, status) in
                guard status, let memberList = memberList else {
                    if isRefresh {
                        self?.normalTableView.mj_header.endRefreshing()
                    } else {
                        self?.loadFaild(type: .network)
                    }
                    return
                }
                if self?.normalTableView.mj_header.isRefreshing() == true {
                    self?.normalTableView.mj_header.endRefreshing()
                    self?.normalTableView.removePlaceholderViews()
                } else {
                    self?.endLoading()
                }
                self?.adminList = []
                self?.normalSourceProcess(isInitial: false, sourceList: memberList)
                self?.normalTableView.removePlaceholderViews()
                self?.normalTableView.reloadData()
            }
        }
        let type: GroupNetworkManager.MemberType = self.isBlack ? .blacklist : .member
        GroupNetworkManager.memberList(groupId: self.groupId, after: self.normalAfter, limit: self.limit, type: type) { [weak self](memberList, msg, status) in
            guard let WeakSelf = self else {
                return
            }
            guard status, let memberList = memberList else {
                if isRefresh {
                    self?.normalTableView.mj_header.endRefreshing()
                } else {
                    self?.loadFaild(type: .network)
                }
                return
            }
            if isRefresh {
                self?.normalTableView.mj_header.endRefreshing()
            } else {
                self?.endLoading()
            }
            // 数据加载处理
            if memberList.isEmpty {
                self?.normalTableView.show(placeholderView: .empty)
            } else {
                self?.normalTableView.removePlaceholderViews()
            }
            self?.normalSourceProcess(isInitial: true, sourceList: memberList)
            self?.normalAfter = memberList.last?.id ?? WeakSelf.normalAfter
            self?.normalTableView.mj_footer.resetNoMoreData()   // 重置状态，注意位于hidden设置之前
            self?.normalTableView.mj_footer.isHidden = memberList.count != self?.limit
            self?.normalTableView.reloadData()
        }
    }
    /// normalLoadMore
    fileprivate func normalLoadMoreData() -> Void {
        let type: GroupNetworkManager.MemberType = self.isBlack ? .blacklist : .member
        GroupNetworkManager.memberList(groupId: self.groupId, after: self.normalAfter, limit: self.limit, type: type) { [weak self](memberList, msg, status) in
            guard let WeakSelf = self else {
                return
            }
            self?.normalTableView.mj_footer.endRefreshing()
            guard status, let memberList = memberList else {
                self?.normalTableView.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            // 数据加载处理
            self?.normalSourceProcess(isInitial: false, sourceList: memberList)
            self?.normalAfter = memberList.last?.id ?? WeakSelf.normalAfter
            if memberList.count < WeakSelf.limit {
                self?.normalTableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self?.normalTableView.reloadData()
        }
    }

    /// searchInitial
    fileprivate func searchLoadInitialData(isRefresh: Bool, key: String) -> Void {
        self.searchAfter = 0
        let type: GroupNetworkManager.MemberType = self.isBlack ? .blacklist : .audit_user
        GroupNetworkManager.memberSearch(key: key, groupId: self.groupId, after: self.searchAfter, limit: self.limit, type: type) { [weak self](memberList, msg, status) in
            guard let WeakSelf = self else {
                return
            }
            if isRefresh {
                self?.searchTableView.mj_header.endRefreshing()
            }
            guard status, let memberList = memberList else {
                self?.searchTableView.show(placeholderView: .network)
                return
            }
            // 数据加载处理
            if memberList.isEmpty {
                self?.searchTableView.show(placeholderView: .empty)
            } else {
                self?.searchTableView.removePlaceholderViews()
            }
            self?.searchList.removeAll()
            self?.searchList.append(contentsOf: memberList)
            self?.searchAfter = memberList.last?.id ?? WeakSelf.searchAfter
            self?.searchTableView.mj_footer.resetNoMoreData()   // 重置状态，注意位于hidden设置之前
            self?.searchTableView.mj_footer.isHidden = memberList.count != self?.limit
            self?.searchTableView.reloadData()
        }
    }
    /// searchLoadMore
    fileprivate func searchLoadMoreData(key: String) -> Void {
        let type: GroupNetworkManager.MemberType = self.isBlack ? .blacklist : .audit_user
        GroupNetworkManager.memberSearch(key: key, groupId: self.groupId, after: self.searchAfter, limit: self.limit, type: type) { [weak self](memberList, msg, status) in
            guard let WeakSelf = self else {
                return
            }
            self?.searchTableView.mj_footer.endRefreshing()
            guard status, let memberList = memberList else {
                self?.searchTableView.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            // 数据加载处理
            self?.searchList.append(contentsOf: memberList)
            self?.searchAfter = memberList.last?.id ?? WeakSelf.searchAfter
            if memberList.count < WeakSelf.limit {
                self?.searchTableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self?.searchTableView.reloadData()
        }
    }

    /// 正常加载时数据处理
    fileprivate func normalSourceProcess(isInitial: Bool, sourceList: [GroupMemberModel]) -> Void {
        if isInitial {
            /// 管理员列表初始化由其他方法切换
            self.memberList.removeAll()
            self.blackList.removeAll()
        }
        if self.isBlack {
            self.blackList.append(contentsOf: sourceList)
        } else {
            // 将管理员和普通成员分离
            let result = self.auditMemberSeparate(sourceList: sourceList)
            self.adminList.append(contentsOf: result.managerList)
            self.memberList.append(contentsOf: result.memberList)
        }
        self.sourceInitial()
    }

    /// 审核非黑名单成员分离 为 普通成员和管理员
    fileprivate func auditMemberSeparate(sourceList: [GroupMemberModel]) -> (managerList: [GroupMemberModel], memberList: [GroupMemberModel]) {
        var managerList: [GroupMemberModel] = [GroupMemberModel]()
        var memberList: [GroupMemberModel] = [GroupMemberModel]()
        var groupOwner: GroupMemberModel?
        for member in sourceList {
            switch member.roleType {
            case .owner:
                groupOwner = member
            case .administrator:
                managerList.append(member)
            case .member:
                memberList.append(member)
            case .black:
                break
            }
        }
        // 保证圈主位于管理员首位
        if let groupOwner = groupOwner {
            self.adminList.insert(groupOwner, at: 0)
        }
        return (managerList: managerList, memberList: memberList)
    }
}

// MARK: - 数据加载
extension GroupMemberManageController {
    /// 设置当前列表的展示类型
    func setupShowType(_ showType: ShowType) -> Void {
        self.showType = showType
        switch showType {
        case .normal:
            self.normalTableView.isHidden = false
            self.searchTableView.isHidden = true
            self.currentTableView = self.normalTableView
        case .search:
            self.normalTableView.isHidden = true
            self.searchTableView.isHidden = false
            self.currentTableView = self.searchTableView
        }
    }
}

// MARK: - 数据处理
extension GroupMemberManageController {
    /// 数据源构造
    fileprivate func sourceInitial() -> Void {
        self.sourceList.removeAll()
        // 没有内容，仍展示该section
//        self.sourceList.append((key: self.adminKey, list: self.adminList, type: .administrator))
//        self.sourceList.append((key: self.memberKey, list: self.memberList, type: .member))
//        self.sourceList.append((key: self.blackKey, list: self.blackList, type: .black))
        // 没有内容，则不展示该section - 注意本地的数据源同步
        if self.isBlack {
            self.sourceList.append((key: self.blackKey, list: self.blackList))
        } else {
            if !self.adminList.isEmpty {
                self.sourceList.append((key: self.adminKey, list: self.adminList))
            }
            if !self.memberList.isEmpty {
                self.sourceList.append((key: self.memberKey, list: self.memberList))
            }
        }
    }
    /// 从数据源列表中移除该成员
    fileprivate func sourceRemove(memberId: Int) -> GroupMemberModel? {
        var findMember: GroupMemberModel?
        for var data in self.sourceList {
            var findFlag: Bool = false
            for (index, member) in data.list.enumerated() {
                if memberId == member.id {
                    findMember = data.list.remove(at: index)
                    // 数据源同步
                    switch data.key {
                    case self.adminKey:
                        self.adminList.remove(at: index)
                    case self.memberKey:
                        self.memberList.remove(at: index)
                    case self.blackKey:
                        self.blackList.remove(at: index)
                    default:
                        break
                    }
                    findFlag = true
                    break
                }
            }
            if findFlag {
                break
            }
        }
        return findMember
    }
    /// 从search列表查找该成员
    fileprivate func searchFind(memberId: Int) -> (index: Int, member: GroupMemberModel)? {
        var findResult: (index: Int, member: GroupMemberModel)?
        for (index, member) in self.searchList.enumerated() {
            if memberId == member.id {
                findResult = (index: index, member: member)
                break
            }
        }
        return findResult
    }
}

// MARK: - 事件响应

extension GroupMemberManageController {
    @objc fileprivate func cancelBtnClick(_ button: UIButton) -> Void {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

// 更多选项的网络请求接口实现

extension GroupMemberManageController {

    /// 设为圈管理员
    fileprivate func addToAdministrator(memberId: Int) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_处理中".localized)
        loadingAlert.show()
        GroupNetworkManager.setMemberToAdministrator(groupId: self.groupId, memberId: memberId) { (msg, status) in
            self.circleHandleResultTip(loadingAlert, msg, status)
            if status {
                self.sourceProcessForAddToAdministrator(memberId: memberId)
            }
        }
    }
    /// 移除圈管理
    fileprivate func removeFromAdministrator(memberId: Int) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_处理中".localized)
        loadingAlert.show()
        GroupNetworkManager.removeAdministrator(groupId: self.groupId, memberId: memberId) { (msg, status) in
            self.circleHandleResultTip(loadingAlert, msg, status)
            if status {
                self.sourceProcessForRemoveFromAdministrator(memberId: memberId)
            }
        }
    }
    /// 加入黑名单
    fileprivate func addToBlackList(memberId: Int) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_处理中".localized)
        loadingAlert.show()
        GroupNetworkManager.addBlackList(groupId: self.groupId, memberId: memberId) { (msg, status) in
            self.circleHandleResultTip(loadingAlert, msg, status)
            if status {
                self.sourceProcessForAddToBlackList(memberId: memberId)
                self.memberCount -= 1
                NotificationCenter.default.post(name: NSNotification.Name.Group.uploadGroupInfo, object: ["groupId": self.groupId, "type": "addBlack", "count": 1])
            }
        }
    }
    /// 移除黑名单
    fileprivate func removeFromBlackList(memberId: Int) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_处理中".localized)
        loadingAlert.show()
        GroupNetworkManager.removeBlackList(groupId: self.groupId, memberId: memberId) { (msg, status) in
            self.circleHandleResultTip(loadingAlert, msg, status)
            if status {
                self.sourceProcessForRemoveFromBlackList(memberId: memberId)
                self.memberCount -= 1
                NotificationCenter.default.post(name: NSNotification.Name.Group.uploadGroupInfo, object: ["groupId": self.groupId, "type": "removeBlack", "count": 1])
            }
        }
    }
    /// 移除圈子
    fileprivate func removeFromGroup(memberId: Int) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_处理中".localized)
        loadingAlert.show()
        GroupNetworkManager.removeMember(groupId: self.groupId, memberId: memberId) { (msg, status) in
            self.circleHandleResultTip(loadingAlert, msg, status)
            if status {
                self.sourceProcessForRemoveFromGroup(memberId: memberId)
                self.memberCount -= 1
                NotificationCenter.default.post(name: NSNotification.Name.Group.uploadGroupInfo, object: ["groupId": self.groupId, "type": "removeMember", "count": 1])
            }
        }
    }

    /// 对圈子成员操作的提示
    fileprivate func circleHandleResultTip(_ loadingAlert: TSIndicatorWindowTop, _ msg: String?, _ status: Bool) -> Void {
        loadingAlert.dismiss()
        var tipMsg = msg
        if tipMsg == nil {
            tipMsg = status ? "提示信息_操作成功".localized : "提示信息_操作失败".localized
        }
        let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: tipMsg)
        resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
}

// 更多选项请求成功后的本地数据源处理

extension GroupMemberManageController {
    /// 设为圈管理员 的本地数据源处理
    fileprivate func sourceProcessForAddToAdministrator(memberId: Int) -> Void {
        // 数据源处理
        if let sourceRemoveMember = self.sourceRemove(memberId: memberId) {
            sourceRemoveMember.role = .administrator
            self.adminList.append(sourceRemoveMember)
        }
        // 搜索结果处理
        let searchFindResult = self.searchFind(memberId: memberId)
        searchFindResult?.member.role = .administrator
        // 重新构造数据源
        self.sourceInitial()
        self.normalTableView.reloadData()
        self.searchTableView.reloadData()
    }
    /// 移除圈管理 的本地数据源处理
    fileprivate func sourceProcessForRemoveFromAdministrator(memberId: Int) -> Void {
        // 数据源处理
        if let sourceRemoveMember = self.sourceRemove(memberId: memberId) {
            sourceRemoveMember.role = .member
            self.memberList.append(sourceRemoveMember)
        }
        // 搜索结果处理
        let searchFindResult = self.searchFind(memberId: memberId)
        searchFindResult?.member.role = .member
        // 重新构造数据源
        self.sourceInitial()
        self.normalTableView.reloadData()
        self.searchTableView.reloadData()
    }

    // 注：需求更新后，加入黑名单、移除黑名单、移除圈子的本地数据源处理，其实可以统一

    /// 加入黑名单 的本地数据源处理
    fileprivate func sourceProcessForAddToBlackList(memberId: Int) -> Void {
        // 数据源处理
        if let sourceRemoveMember = self.sourceRemove(memberId: memberId) {
            sourceRemoveMember.disabled = true
            // 需求更新，黑名单列表单独展示
            //self.blackList.append(sourceRemoveMember)
        }
        // 搜索结果处理
        if let searchFindResult = self.searchFind(memberId: memberId) {
            searchFindResult.member.disabled = true
            // 需求更新，黑名单列表单独展示
            self.searchList.remove(at: searchFindResult.index)
        }
        // 重新构造数据源
        self.sourceInitial()
        self.normalTableView.reloadData()
        self.searchTableView.reloadData()
    }
    /// 移除黑名单 的本地数据源处理
    fileprivate func sourceProcessForRemoveFromBlackList(memberId: Int) -> Void {
        // 数据源处理
        if let sourceRemoveMember = self.sourceRemove(memberId: memberId) {
            sourceRemoveMember.disabled = false
            // 需求更新，黑名单列表单独展示
            //self.memberList.append(sourceRemoveMember)
        }
        // 搜索结果处理
        if let searchFindResult = self.searchFind(memberId: memberId) {
            searchFindResult.member.disabled = false
            // 需求更新，黑名单列表单独展示
            self.searchList.remove(at: searchFindResult.index)
        }
        // 重新构造数据源
        self.sourceInitial()
        self.normalTableView.reloadData()
        self.searchTableView.reloadData()
    }
    /// 移除圈子 的本地数据源处理
    fileprivate func sourceProcessForRemoveFromGroup(memberId: Int) -> Void {
        // 数据源处理
        _ = self.sourceRemove(memberId: memberId)
        // 搜索结果处理
        if let searchFindResult = self.searchFind(memberId: memberId) {
            self.searchList.remove(at: searchFindResult.index)
        }
        // 重新构造数据源
        self.sourceInitial()
        self.normalTableView.reloadData()
        self.searchTableView.reloadData()
    }
}

// MARK: - Notification

extension GroupMemberManageController {

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension GroupMemberManageController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 1
        if tableView == self.normalTableView {
            sections = self.sourceList.count
        }
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if tableView == self.normalTableView {
            rowCount = self.sourceList[section].list.count
        } else if tableView == self.searchTableView {
            rowCount = self.searchList.count
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GroupMemberCell.cellInTableView(tableView)
        var model: GroupMemberModel?
        if tableView == self.normalTableView {
            cell.model = self.sourceList[indexPath.section].list[indexPath.row]
            model = self.sourceList[indexPath.section].list[indexPath.row]
        } else if tableView == self.searchTableView {
            cell.model = self.searchList[indexPath.row]
            model = self.searchList[indexPath.row]
        }
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        cell.delegate = self
        // 是否显示更多 - 成员管理权限标记 (参考文件头部注释)
        var showMoreFlag: Bool = false
        switch self.currentUserRole {
        case .owner:
            showMoreFlag = true
            // 圈主不能操作自己
            if model?.roleType == .owner {
                showMoreFlag = false
            }
        case .administrator:
            showMoreFlag = true
            // 管理员不能操作管理员(圈主也属管理员)
            if model?.roleType == .owner || model?.roleType == .administrator {
                showMoreFlag = false
            }
        default:
            break
        }
        cell.showMoreFlag = showMoreFlag
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GroupMemberManageController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderView: UIView?
        if tableView == self.normalTableView {
            let headerView = GroupMemberHeaderView.headerInTableView(tableView)
            let data = self.sourceList[section]
            switch data.key {
            case self.adminKey:
                if data.list.count > 0 {
                    headerView.titleLabel.text = String(format: "%@(%d)", "圈管理", data.list.count)
                    sectionHeaderView = headerView
                    self.normalTableView.removePlaceholderViews()
                } else {
                    self.normalTableView.show(placeholderView: .empty)
                }
            case self.memberKey:
                if memberCount - adminList.count > 0 {
                    headerView.titleLabel.text = String(format: "%@(%d)", "成员", memberCount - adminList.count)
                    sectionHeaderView = headerView
                    self.normalTableView.removePlaceholderViews()
                } else {
                    self.normalTableView.show(placeholderView: .empty)
                }
            case self.blackKey:
                if memberCount > 0 {
                    headerView.titleLabel.text = String(format: "%@(%d)", "黑名单", memberCount)
                    sectionHeaderView = headerView
                    self.normalTableView.removePlaceholderViews()
                } else {
                    self.normalTableView.show(placeholderView: .empty)
                }
            default:
                break
            }
        }
        return sectionHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeight: CGFloat = 0.01
        if tableView == self.normalTableView {
            let data = self.sourceList[section]
            switch data.key {
            case self.adminKey:
                headerHeight = data.list.count > 0 ? GroupMemberHeaderView.headerHeight : 0.01
            case self.memberKey:
                headerHeight = memberCount - adminList.count > 0 ? GroupMemberHeaderView.headerHeight : 0.01
            case self.blackKey:
                headerHeight = memberCount > 0 ? GroupMemberHeaderView.headerHeight : 0.01
            default:
                break
            }
        }
        return headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupMemberCell.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt\(indexPath.row)")
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 进入用户详情界面
        var data: GroupMemberModel?
        if tableView == self.normalTableView {
           data = self.sourceList[indexPath.section].list[indexPath.row]
        } else if tableView == self.searchTableView {
            data = self.searchList[indexPath.row]
        }
        if data == nil {
            return
        }
        let userHomPage = TSHomepageVC((data?.userId)!)
        self.navigationController?.pushViewController(userHomPage, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - Delegate <GroupMemberCellProtocol>

extension GroupMemberManageController: GroupMemberCellProtocol {
    /// 成员cell点击更多响应
    func didMoreBtnClickInMemberCell(_ cell: GroupMemberCell) {
        guard let indexPath = cell.indexPath else {
            return
        }
        // 角色类型
        var roleTye: GroupMemberRoleType
        switch self.showType {
        case .normal:
            let member = self.sourceList[indexPath.section].list[indexPath.row]
            self.currentMember = member
            roleTye = member.roleType
        case .search:
            let member = self.searchList[indexPath.row]
            self.currentMember = member
            roleTye = member.roleType
        }
        // 弹窗显示
        self.currentIndexPath = indexPath
        let rectInTableView = self.currentTableView.rectForRow(at: indexPath)
        let rect = self.currentTableView.convert(rectInTableView, to: self.view)
        let centerY: CGFloat = rect.origin.y + rect.size.height * 0.5
        let popView = GroupMemberMorePopView(centerYMargin: centerY, rightMargin: GroupMemberCell.moreShowRightMargin, memberType: roleTye, isOwner: self.currentUserRole == .owner)
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

// MARK: - Delegate <UITextFieldDelegate>

extension GroupMemberManageController: UITextFieldDelegate {
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let str = textField.text else {
            self.setupShowType(.normal)
            return false
        }
        if str == "" {
            self.setupShowType(.normal)
            return false
        }
        self.setupShowType(.search)
        //self.memberSearchWith(keyword: str)
        self.searchKey = str
        self.searchTableView.mj_header.beginRefreshing()
        return true
    }
}

// MARK: - Delegate <GroupMemberMorePopViewProtocol>

extension GroupMemberManageController: GroupMemberMorePopViewProtocol {
    func memberPopView(_ popView: GroupMemberMorePopView, didClickOptionWith title: String) {
        guard let member = self.currentMember else {
            return
        }
        switch title {
        case "移出圈管理":
            self.removeFromAdministrator(memberId: member.id)
        case "设为圈管理员":
            self.addToAdministrator(memberId: member.id)
        case "移出圈子":
            self.removeFromGroup(memberId: member.id)
        case "加入黑名单":
            self.addToBlackList(memberId: member.id)
        case "移出黑名单":
            self.removeFromBlackList(memberId: member.id)
        default:
            break
        }
    }

}
