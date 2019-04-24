//
//  TSQuestionInvitationSearchController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答发布 - 悬赏设置中 邀请搜索界面/专家搜索界面
//  注：该界面功能更正：由之前的专家邀请 更正为 专家推荐 + 用户邀请，即内容为空时显示推荐的话题专家，否则显示用户搜索

import UIKit
import Alamofire

protocol TSQuestionInvitationSearchControllerProtocol: class {
    func expertSearchVC(_ expertSearchVC: TSQuestionInvitationSearchController, didSelectedExpert expert: TSUserInfoModel) -> Void
}

/// 邀请类型
private enum TSQuestionInvitationType {
    /// 用户
    case user
    /// 专家
    case expert
}

typealias TSQuestionExpertSearchController = TSQuestionInvitationSearchController
class TSQuestionInvitationSearchController: TSViewController {
    // MARK: - Internal Property
    weak var delegate: TSQuestionInvitationSearchControllerProtocol?
    var topics: [TSQuoraTopicModel]?
    // MARK: - Internal Function
    // MARK: - Private Property

    /// 当前展示的类型，默认为专家 - 用于数据请求时的分类确认
    fileprivate var currentShowType: TSQuestionInvitationType {
        if nil == self.currentKeyword || self.currentKeyword!.isEmpty {
            return TSQuestionInvitationType.expert
        } else {
            return TSQuestionInvitationType.user
        }
    }

    /// 搜索控件
    fileprivate weak var searchField: UITextField!
    /// 专家列表
    fileprivate weak var tableView: TSTableView!

    /// 数据列表
    fileprivate var sourceList: [TSUserInfoModel] = [TSUserInfoModel]()
    /// 上一个请求
    fileprivate var lastRequest: DataRequest?
    /// 每次请求的个数限制
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    /// 请求后的数据的便宜量
    fileprivate var offset: Int = 0
    /// 当前搜索关键字
    fileprivate var currentKeyword: String? {
        return self.searchField.text
    }

    // MARK: - Initialize Function

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }
    deinit {
        // 通知移除
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // 输入控件内容变更的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

}

// MARK: - UI

extension TSQuestionInvitationSearchController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = TSColor.normal.background
        // 1. 自定义导航栏
        let barView = UIView()
        self.view.addSubview(barView)
        barView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        barView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(TSNavigationBarHeight)
        }
        let navigationView = UIView()
        barView.addSubview(navigationView)
        navigationView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(barView)
            make.height.equalTo(44)
        }
        // 1.2 cancelBtn
        let cancelTitle = "显示_导航栏_返回".localized
        let cancelFont = UIFont.systemFont(ofSize: 17)
        let cancelBtn = UIButton(type: .custom)
        let cancelW: CGFloat = cancelTitle.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: cancelFont, lineMargin: 0).width + 5.0 * 2
        navigationView.addSubview(cancelBtn)
        cancelBtn.setTitle(cancelTitle, for: .normal)
        cancelBtn.setTitleColor(TSColor.main.theme, for: .normal)
        cancelBtn.titleLabel?.font = cancelFont
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
        cancelBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(navigationView)
            make.width.equalTo(cancelW)
            // 按钮文字两侧间距为15，但按钮本身宽度为 文字宽度 + 左右各增加5.0
            make.trailing.equalTo(navigationView).offset(-10)
        }
        // 1.1 searchField
        let searchField = UITextField()
        navigationView.addSubview(searchField)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let leftIcon = UIImageView(image: UIImage(named: "IMG_search_icon_search"))
        leftView.addSubview(leftIcon)
        leftIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(12)
            make.center.equalTo(leftView)
        }
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.layer.cornerRadius = 5
        searchField.backgroundColor = UIColor(hex: 0xe7e7e7)
        searchField.clipsToBounds = true
        searchField.textColor = TSColor.main.content
        searchField.font = UIFont.systemFont(ofSize: 12)
        searchField.placeholder = "显示_搜索".localized
        searchField.delegate = self
        searchField.returnKeyType = UIReturnKeyType.search
        searchField.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.centerY.equalTo(navigationView)
            make.leading.equalTo(navigationView).offset(15)
            // 按钮文字两侧间距为15，但按钮本身宽度为 文字宽度 + 左右各增加5.0
            make.trailing.equalTo(cancelBtn.snp.leading).offset(-10)
        }
        self.searchField = searchField
        // 2. tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.register(UINib(nibName: "QuoraExpertsListCell", bundle: nil), forCellReuseIdentifier: QuoraExpertsListCell.identifier)
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = TSColor.normal.background
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(barView.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        self.tableView = tableView
    }
}

// MARK: - 数据处理与加载

extension TSQuestionInvitationSearchController {
    /// 初始化配置
    fileprivate func initialDataSource() -> Void {
        // 加载话题下的专家推荐列表
        self.requestData(type: .initial)
    }
    /// 下拉刷新
    @objc fileprivate func refresh() -> Void {
        self.requestData(type: .refresh)
    }
    /// 上拉加载更多
    @objc fileprivate func loadMore() -> Void {
        self.requestData(type: .loadmore)
    }
    /// 数据加载
    fileprivate func requestData(type: TSListDataLoadType) -> Void {
        switch self.currentShowType {
        case .expert:
            self.requestExpertData(loadType: type)
        case .user:
            self.requestUserData(loadType: type)
        }
    }
    /// 加载用户列表数据 -
    private func requestUserData(loadType: TSListDataLoadType) -> Void {
        guard let searchText: String = self.searchField.text else {
            return
        }
        switch loadType {
        case .initial:
            self.sourceList.removeAll()
            fallthrough
        case .refresh:
            self.offset = 0
        case .loadmore:
            break
        }
        // 取消掉上一次请求，并重新请求
        self.lastRequest?.cancel()
        self.lastRequest = TSNewFriendsNetworkManager.searchUsersWith(keyword: searchText, offset: self.offset, limit: self.limit, complete: { (_, userList, _, status) in
            switch loadType {
            case .initial:
                break
            case .refresh:
                self.tableView.mj_header.endRefreshing()
            case .loadmore:
                self.tableView.mj_footer.endRefreshing()
            }
            // 这里应判断搜索字段是否与当前字段一致
            guard status, let userList = userList, searchText == self.currentKeyword else {
                self.offset = self.sourceList.count
                self.tableView.reloadData()
                return
            }
            // 数据加载处理
            switch loadType {
            case .initial:
                fallthrough
            case .refresh:
                self.sourceList = userList
            case .loadmore:
                self.sourceList += userList
            }
            self.offset = self.sourceList.count
            self.tableView.mj_footer.isHidden = userList.count < self.limit
            if self.sourceList.isEmpty {
                self.tableView.show(placeholderView: .empty)
            } else {
                self.tableView.removePlaceholderViews()
            }
            self.tableView.reloadData()
        })
    }
    /// 加载专家列表数据
    private func requestExpertData(loadType: TSListDataLoadType) -> Void {
        guard let topicList = self.topics else {
            return
        }
        switch loadType {
        case .initial:
            self.sourceList.removeAll()
            fallthrough
        case .refresh:
            self.offset = 0
        case .loadmore:
            break
        }
        var topics = [Int]()
        for topic in topicList {
            topics.append(topic.id)
        }
        TSQuoraNetworkManager.getExpertListFor(keyword: "", topicIds: topics, offset: self.offset) { (expertList, _, status) in
            switch loadType {
            case .initial:
                break
            case .refresh:
                self.tableView.mj_header.endRefreshing()
            case .loadmore:
                self.tableView.mj_footer.endRefreshing()
            }
            guard status, let expertList = expertList else {
                self.offset = self.sourceList.count
                self.tableView.reloadData()
                return
            }
            // 数据加载处理
            switch loadType {
            case .initial:
                fallthrough
            case .refresh:
                self.sourceList = expertList
            case .loadmore:
                self.sourceList += expertList
            }
            self.offset = self.sourceList.count
            self.tableView.mj_footer.isHidden = expertList.count < self.limit
            if self.sourceList.isEmpty {
                self.tableView.show(placeholderView: .empty)
            } else {
                self.tableView.removePlaceholderViews()
            }
            self.tableView.reloadData()
        }
    }

}

// MARK: - 事件响应

extension TSQuestionInvitationSearchController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 取消按钮点击响应
    @objc fileprivate func cancelBtnClick(_ button: UIButton) -> Void {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Notification

// MARK: - Notification

extension TSQuestionInvitationSearchController {
    /// UITextField输入的通知处理
    @objc fileprivate func textFiledDidChanged(notification: Notification) {
        // 非titleField判断
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField != self.searchField {
            return
        }
        // 输入框输入文字上限
        let maxLen: Int = Int(MAX_INPUT)
        if nil != textField.text && "" != textField.text! {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: maxLen)
        }
        // 关闭联想请求
        //self.requestData(type: .initial)
    }
}

// MARK: - Delegate Function

// MARK: - UITextFieldDelegate
extension TSQuestionInvitationSearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.requestData(type: .initial)
        return true
    }
}

// MARK: - UITableViewDataSource

extension TSQuestionInvitationSearchController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuoraExpertsListCell.identifier) as! QuoraExpertsListCell
        cell.tagsView.tagRadius = 3
        cell.tagsView.tagFont = 13
        cell.tagsView.tagPadding = UIEdgeInsets(top: 4, left: 5, bottom: 4, right: 5)
        cell.setInfo(model: self.sourceList[indexPath.row])
        cell.buttonForFollow.isHidden = true
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.currentShowType {
        case .expert:
            if self.sourceList.isEmpty {
                return nil
            } else {
                let view = TSRecommendExpertsSectionHeader.headerInTableView(tableView)
                return view
            }
        case .user:
            return nil
        }
    }
}

// MARK: - UITableViewDelegate

extension TSQuestionInvitationSearchController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        // 注：不能邀请自己
        let user = self.sourceList[indexPath.row]
        if TSCurrentUserInfo.share.userInfo?.userIdentity == user.userIdentity {
            let alert = TSIndicatorWindowTop(state: .faild, title: "不能邀请自己额")
            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        } else {
            self.delegate?.expertSearchVC(self, didSelectedExpert: self.sourceList[indexPath.row])
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.currentShowType {
        case .expert:
            // 注：因为暂时tableView的空视图设计有位置的bug，导致没有数据源时的显示异常，先这样处理。
            if self.sourceList.isEmpty {
                return 0.01
            } else {
                return TSRecommendExpertsSectionHeader.headerHeight
            }
        case .user:
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
