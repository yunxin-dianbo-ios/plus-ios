//
//  PostableGroupSelectController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 27/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子发布中的圈子选择界面 - 可发布帖子的圈子选择界面

import Foundation

protocol PostableGroupSelectControllerProtocol: class {
    func didSelectedGroup(_ group: GroupListCellModel, in groupSelectVC: PostableGroupSelectController) -> Void
}

class PostableGroupSelectController: TSViewController {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: PostableGroupSelectControllerProtocol?
    var selectedGroupAction: ((_ group: GroupListCellModel) -> Void)?

    // MARK: - Private Property
    /// 为空时的提示视图
    fileprivate weak var tableView: TSTableView!
    /// 是否来自首页的 "+"
    fileprivate let fromAdd: Bool

    /// 数据源列表
    //fileprivate var sourceList: [GroupModel] = [GroupModel]()
    fileprivate var sourceList: [GroupListCellModel] = [GroupListCellModel]()

    // MARK: - Initialize Function
    init(fromAdd: Bool = false) {
        self.fromAdd = fromAdd
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        self.fromAdd = false
        super.init(coder: aDecoder)
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 首次用户没有加入任何圈子的情况
        if self.sourceList.count == 0 {
            self.tableView.mj_header.beginRefreshing()
        }
    }

}

// MARK: - UI
extension PostableGroupSelectController {

    fileprivate func initialUI() -> Void {
        // navigationbar
        self.navigationItem.title = "标题_选择圈子".localized
        // 2. tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.separatorStyle = .none
        //tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 91
        tableView.register(GroupListCell.self, forCellReuseIdentifier: GroupListCell.identifier)
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
        // 1. emptyPromptView
        let emptyView = UIView()
        self.initialEmptyPromptView(emptyView)
        emptyView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 64)
        tableView.set(placeholderView: emptyView, for: .empty)
    }

    // emptyPromptView 布局
    fileprivate func initialEmptyPromptView(_ emptyView: UIView) -> Void {
        // 加入圈子按钮
        let joinGroupBtn = UIButton(cornerRadius: 5)
        emptyView.addSubview(joinGroupBtn)
        joinGroupBtn.addTarget(self, action: #selector(joinGroupBtnClick), for: .touchUpInside)
        joinGroupBtn.setTitle("显示_加入圈子".localized, for: .normal)
        joinGroupBtn.setTitleColor(UIColor(hex: 0xf4f5f5), for: .normal)
        joinGroupBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        joinGroupBtn.backgroundColor = TSColor.main.theme
        joinGroupBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(emptyView).offset(-32) // 64 * 0.5
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalTo(emptyView)
        }
        // 没有可发帖圈子的提示
        let promptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 17), textColor: TSColor.normal.minor, alignment: .center)
        emptyView.addSubview(promptLabel)
        promptLabel.text = "提示信息_未找到可发帖的圈子，去加入感兴趣的圈子吧".localized
        promptLabel.numberOfLines = 0
        promptLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(emptyView)
            make.leading.equalTo(emptyView).offset(25)
            make.trailing.equalTo(emptyView).offset(-25)
            make.bottom.equalTo(joinGroupBtn.snp.top).offset(-20)
        }
    }
}

// MARK: - 数据处理与加载
extension PostableGroupSelectController {

    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
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

    /// 请求列表数据
    fileprivate func requestData(_ loadType: TSListDataLoadType) -> Void {
        switch loadType {
        case .initial:
            self.loading()
            self.loadInitialData(isRefresh: false)
        case .refresh:
            self.loadInitialData(isRefresh: true)
        case .loadmore:
            //  该页面没有上拉加载
            //self.loadMoreData()
            break
        }
    }
    /// 初始化数据 或 刷新数据
    fileprivate func loadInitialData(isRefresh: Bool) -> Void {
        // 请求可发布帖子的圈子列表
        GroupNetworkManager.getMyGroups(type: "allow_post", limit: Int.max, offset: 0) { [weak self](groupList, msg, status) in
            guard status, let groupList = groupList else {
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
                self?.endLoading()
            }
            var idArray:[Int] = []
            var filterGroupList:[GroupModel] = []
            
            for item in groupList {
                if !idArray.contains(item.id) {
                    idArray.append(item.id)
                    filterGroupList.append(item)
                }
            }
            self?.sourceList = filterGroupList.map { GroupListCellModel(model: $0) }
            if groupList.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
            }
            self?.tableView.reloadData()
        }

    }
}
// MARK: - Private  事件响应
extension PostableGroupSelectController {
    /// 加入圈子按钮点击响应
    @objc fileprivate func joinGroupBtnClick() -> Void {
        let groupVC = GroupHomeController()
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PostableGroupSelectController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupListCell.identifier, for: indexPath) as! GroupListCell
        // 加入圈子的回调，但本页面不需要加入响应，因为该界面的都是已加入的 或 可发帖的
        //cell.delegate = self
        cell.model = self.sourceList[indexPath.row]
        return cell
    }

}

// MARK: - UITableViewDelegate

extension PostableGroupSelectController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
        let group = self.sourceList[indexPath.row]
        self.delegate?.didSelectedGroup(group, in: self)
        self.selectedGroupAction?(group)
    }

}

// MARK: - <GroupListCellDelegate> Cell代理事件
extension PostableGroupSelectController: GroupListCellDelegate {

    /// 点击了加入按钮
    func groupListCellDidSelectedJoinButton(_ cell: GroupListCell) {

    }
}
