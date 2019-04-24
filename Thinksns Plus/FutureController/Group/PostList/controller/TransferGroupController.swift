//
//  TransferGroupController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子转让视图控制器

import UIKit

class TransferGroupController: TSViewController {

    // MARK: - Internal Property

    let groupId: Int

    /// 完成转让的回调
    var finishTransferBlock: (() -> Void)?

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

    fileprivate var sourceList: [GroupMemberModel] = []
    /// 管理员列表
    fileprivate var adminList: [GroupMemberModel] = [GroupMemberModel]()
    /// 成员列表
    fileprivate var memberList: [GroupMemberModel] = [GroupMemberModel]()
    /// 黑名单列表
    fileprivate var blackList: [GroupMemberModel] = [GroupMemberModel]()
    /// 搜索结果列表
    fileprivate var searchList: [GroupMemberModel] = [GroupMemberModel]()
    /// 圈子名称
    var groupTitle: String

    // MARK: - Initialize Function

    init(groupId: Int, groupTitle: String) {
        self.groupId = groupId
        self.groupTitle = groupTitle
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

extension TransferGroupController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // 1. searchBar
        let searchBar = TSSearchBarView()
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.height.equalTo(64)
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
        //tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.mj_footer.isHidden = true
        tableView.mj_header.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(searchBar.snp.bottom)
        }
        return tableView
    }
}

// MARK: - 数据处理与加载

extension TransferGroupController {
    /// 数据源初始化
    fileprivate func initialDataSource() -> Void {
        self.initialData()
    }

    /// 初始化列表数据
    fileprivate func initialData() -> Void {
        // 一次请求完所有的成员列表
        self.loading()
        GroupNetworkManager.memberList(groupId: self.groupId, after: 0, limit: Int.max, type: .all, complete: { (memberList, msg, status) in
            guard status, let memberList = memberList else {
                self.loadFaild(type: .network)
                return
            }
            self.endLoading()
            // 整个列表为空
            if memberList.count < 2 {
                self.normalTableView.show(placeholderView: .empty)
            } else {
                self.normalTableView.removePlaceholderViews()
            }
            // 数据处理
            self.sourceSeparate(sourceList: memberList)
            self.normalTableView.reloadData()
            self.setupShowType(.normal)
        })
    }
    /// 数据分离
    fileprivate func sourceSeparate(sourceList: [GroupMemberModel]) -> Void {
        self.adminList.removeAll()
        self.memberList.removeAll()
        self.blackList.removeAll()
        for member in sourceList {
            // 黑名单
            if member.disabled {
                self.blackList.append(member)
                continue
            }
            switch member.role {
            case .founder:
                continue
            case .administrator:
                self.adminList.append(member)
            case .member:
                // 判断是否已经通过审核了
                if member.audit == .agree {
                    self.memberList.append(member)
                }
            }
        }
        self.sourceInitial()
    }

    /// 数据源构造
    fileprivate func sourceInitial() -> Void {
        self.sourceList.removeAll()
        sourceList = adminList + memberList
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

    /// 搜索请求
    fileprivate func memberSearchWith(keyword: String) -> Void {
        // 圈子成员搜索 无接口，本地数据搜搜
        self.searchList.removeAll()
        for member in sourceList {
            if let user = member.user {
                if user.name.contains(keyword) {
                    searchList.append(member)
                }
            }
        }
        if self.searchList.isEmpty {
            self.searchTableView.show(placeholderView: .empty)
        } else {
            self.searchTableView.removePlaceholderViews()
        }
        self.searchTableView.reloadData()
    }

}

// MARK: - 事件响应

extension TransferGroupController {
    @objc fileprivate func cancelBtnClick(_ button: UIButton) -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// 更多选项的网络请求接口实现

extension TransferGroupController {
}

// MARK: - Notification

extension TransferGroupController {

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension TransferGroupController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.normalTableView {
            return sourceList.isEmpty ? 0 : 1
        } else if tableView == self.searchTableView {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if tableView == self.normalTableView {
            rowCount = self.sourceList.count
        } else if tableView == self.searchTableView {
            rowCount = self.searchList.count
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GroupMemberCell.cellInTableView(tableView)
        if tableView == self.normalTableView {
            cell.model = self.sourceList[indexPath.row]
        } else if tableView == self.searchTableView {
            cell.model = self.searchList[indexPath.row]
        }
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        cell.moreBtn.isHidden = true
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TransferGroupController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = GroupMemberHeaderView.headerInTableView(tableView)
        headerView.titleLabel.text = "选择新圈主"
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return GroupMemberHeaderView.headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupMemberCell.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1.获取用户名称和 id
        var userName = ""
        var userId = 0
        if tableView == self.normalTableView {
            userName = self.sourceList[indexPath.row].user?.name ?? ""
            userId = self.sourceList[indexPath.row].userId
        } else if tableView == self.searchTableView {
            userName = self.searchList[indexPath.row].user?.name ?? ""
            userId = self.searchList[indexPath.row].userId
        }
        // 2.创建弹窗
        let alert = TSAlertController(title: "提示", message: "确定将圈子\"\(groupTitle)\"转让给\"\(userName)\"，\n使其成为新的圈主？", style: .actionsheet)
        alert.addAction(TSAlertAction(title: "确定", style: .default, handler: { (_) in
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在转让圈子...")
            alert.show()
            GroupNetworkManager.transferGroup(groupId: self.groupId, toUser: userId, complete: { [weak self] (status, message) in
                alert.dismiss()
                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                if status {
                    self?.finishTransferBlock?()
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        }))
        present(alert, animated: false, completion: nil)
    }
}

// MARK: - Delegate <UITextFieldDelegate>
extension TransferGroupController: UITextFieldDelegate {
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        guard let str = textField.text else {
            self.setupShowType(.normal)
            return false
        }
        if str == "" {
            self.setupShowType(.normal)
            return false
        }
        self.setupShowType(.search)
        self.memberSearchWith(keyword: str)
        return true
    }
}
