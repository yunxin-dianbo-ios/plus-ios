//
//  TSQuestionTopicSelectController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答发布 - 话题选择界面

import UIKit
import Alamofire

class TSQuestionTopicSelectController: TSViewController {

    // MARK: - Internal Property
    /// 编辑类型
    var type: TSQuoraEditType = .normalPublish
    /// 当前编辑模型
    var contributeModel: TSQuestionContributeModel?
    // MARK: - Internal Function
    // MARK: - Private Property
    /// 导航栏上的下一步按钮
    fileprivate weak var nextBtn: UIButton!
    /// 话题列表
    fileprivate weak var tableView: TSTableView!
    // 话题列表
    fileprivate var sourceList: [TSQuoraTopicModel] = [TSQuoraTopicModel]()
    /// 当前选中的话题视图
    fileprivate weak var topicSelectedView: TSQuestionTopicSelectedView!
    /// 搜索视图
    fileprivate weak var searchField: UITextField!

    fileprivate let searchMaxLen: Int = 25

    /// 当前选中的话题列表
    fileprivate var selectedTopicList: [TSQuoraTopicModel] = [TSQuoraTopicModel]()
    /// 最大选中话题数
    fileprivate let maxSlecteTopicNum: Int = 5
    /// 话题请求 列表限制数
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    /// 分页id
    fileprivate var afterId: Int = 0
    /// 上一个请求
    fileprivate var lastRequest: DataRequest?

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
        // 输入控件内容变更的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    // MARK: - UI
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white

        let iconWH: CGFloat = 15
        let iconLeftMargin: CGFloat = 15
        let searchFieldLeftMargin: CGFloat = 15
        let searchFieldRightMargin: CGFloat = 15

        // 1. navigationbar
        self.navigationItem.title = "标题_问答_话题添加页".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(nextItemClick), for: .touchUpInside)
        let rightTitle: String = self.couldSetRewardQuora() ? "显示_下一步".localized : "显示_发布".localized
        self.setupNavigationTitleItem(nextItem, title: rightTitle)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.nextBtn = nextItem
        // 2. topicSelectedView
        let selectedView = TSQuestionTopicSelectedView()
        self.view.addSubview(selectedView)
        selectedView.delegate = self
        selectedView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(0)
        }
        self.topicSelectedView = selectedView
        // 3. topicSearchView
        let searchView = UIView()
        self.view.addSubview(searchView)
        searchView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        searchView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(selectedView.snp.bottom)
            make.height.equalTo(60)
        }
        // 3.1 searchIcon(也可使用UITextField.leftView来实现)
        let searchIcon = UIImageView(image: UIImage(named: "IMG_search_icon_search"))
        searchView.addSubview(searchIcon)
        searchIcon.contentMode = .scaleAspectFill
        searchIcon.clipsToBounds = true
        searchIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.centerY.equalTo(searchView)
            make.leading.equalTo(searchView).offset(iconLeftMargin)
        }
        // 3.2 searchField
        let searchField = UITextField()
        searchView.addSubview(searchField)
        searchField.font = UIFont.systemFont(ofSize: 15)
        searchField.textColor = TSColor.main.content
        searchField.placeholder = "占位符_搜索话题".localized
        searchField.clearButtonMode = .whileEditing
        searchField.snp.makeConstraints { (make) in
            make.leading.equalTo(searchIcon.snp.trailing).offset(searchFieldLeftMargin)
            make.trailing.equalTo(searchView).offset(-searchFieldRightMargin)
            make.centerY.equalTo(searchView)
        }
        self.searchField = searchField
        // 4. topicList
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
//        tableView.mj_header.isHidden = true
        tableView.mj_footer.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(searchView.snp.bottom)
        }
        self.tableView = tableView
    }

    // MARK: - 数据处理与加载
    /// 初始化配置
    fileprivate func initialDataSource() -> Void {
        // 已选中话题设置
        if nil != self.contributeModel?.topics {
            self.selectedTopicList = self.contributeModel!.topics!
        }
        self.topicSelectedView.topics = self.selectedTopicList
        self.topicSelectedView.snp.updateConstraints { (make) in
            make.height.equalTo(self.topicSelectedView.currentHeight)
        }
        // nextBtn按钮的默认设置
        self.couldNextProcess()
        // 加载默认的推荐列表
        self.requestData(type: .initial)
    }
    /// 下拉刷新
    @objc private func refresh() -> Void {
        self.requestData(type: .refresh)
    }
    /// 上拉加载更多
    @objc private func loadMore() -> Void {
        self.requestData(type: .loadmore)
    }
    /// 数据加载
    fileprivate func requestData(type: TSListDataLoadType) -> Void {
        guard let searchText: String = self.searchField.text else {
            return
        }
        switch type {
        case .initial:
            fallthrough
        case .refresh:
            self.afterId = 0
        case .loadmore:
            if self.sourceList.last != nil {
                self.afterId = (self.sourceList.last?.id)!
            } else {
              self.afterId = 0
            }
            break
        }
        // 取消掉上一次请求，并重新请求
        self.lastRequest?.cancel()
        self.lastRequest = TSQuoraNetworkManager.getAllTopics(limit: self.limit, after: self.afterId, shouldGetFollowStatus: false, keyword: searchText) { (topicList, _, status) in
            switch type {
            case .initial:
                break
            case .refresh:
                self.tableView.mj_header.endRefreshing()
            case .loadmore:
                self.tableView.mj_footer.endRefreshing()
            }
            guard status, let topicList = topicList else {
                return
            }
            // Remark: - 这里应判断搜索字段是否与当前字段一致

            // 数据加载处理
            switch type {
            case .initial:
                fallthrough
            case .refresh:
                self.sourceList = topicList
            case .loadmore:
                self.sourceList += topicList
            }
            if !topicList.isEmpty {
                self.afterId = topicList.last!.id
            }
            self.tableView.mj_footer.isHidden = topicList.count < self.limit
            if self.sourceList.isEmpty {
                self.tableView.show(placeholderView: .empty)
            } else {
                self.tableView.removePlaceholderViews()
            }
            self.tableView.reloadData()
        }
    }

    /// next按钮是否可用/next操作是否可执行
    private func couldNext() -> Bool {
        var nextFlag: Bool = true
        // 判断当前选中的话题个数
        if self.selectedTopicList.isEmpty {
            nextFlag = false
        }
        return nextFlag
    }
    /// next按钮是否可用的判断与处理
    fileprivate func couldNextProcess() -> Void {
        self.nextBtn.isEnabled = self.couldNext()
    }
    /// 可不可以设置悬赏 - 某些特定条件下的问题不可设置悬赏。不可以的话，则右上角显示发布，且响应为修改请求
    fileprivate func couldSetRewardQuora() -> Bool {
        var rewardUpdateFlag: Bool = true
        switch self.type {
            // 修改问题：未设置悬赏、未采纳答案 才可进入设置悬赏
        case .update:
            if true == self.contributeModel?.isAdoptedAnswer {
                // 已采纳答案
                rewardUpdateFlag = false
            } else if nil != self.contributeModel?.offerRewardPrice && self.contributeModel!.offerRewardPrice! > 0 {
                // 已设置悬赏
                rewardUpdateFlag = false
            }
        default:
            break
        }
        return rewardUpdateFlag
    }

    /// 进入问题详情页
    fileprivate func gotoQuestionDetail(questionId: Int) -> Void {
        if var childVCList = self.navigationController?.childViewControllers {
            // 发布过程中的页面删除
            for (index, childVC) in childVCList.enumerated() {
                if childVC is TSQuestionTitleEditController {
                    childVCList.replaceSubrange(Range<Int>(uncheckedBounds: (lower: index, upper: childVCList.count)), with: [])
                    break
                }
            }
            // 如果是从问题详情页进入的，则移除该问题详情页
            if childVCList.last is TSQuestionDetailController {
                childVCList.removeLast()
            }
            // 进入问题详情页
            let questionDetailVC = TSQuoraDetailController()
            questionDetailVC.questionId = questionId
            questionDetailVC.type = (self.type == .addPublish) ? .addPublish : .normal
            childVCList.append(questionDetailVC)
            self.navigationController?.setViewControllers(childVCList, animated: true)
        }
    }
}

// MARK: - 事件响应

extension TSQuestionTopicSelectController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 返回按钮点击响应
    @objc fileprivate func backItemClick() -> Void {
        self.contributeModel?.topics = self.selectedTopicList
        _ = self.navigationController?.popViewController(animated: true)
    }
    /// 下一步按钮点击响应
    @objc fileprivate func nextItemClick() -> Void {
        // 保存已选的话题列表
        self.contributeModel?.topics = self.selectedTopicList
        // 判断是否可以设置悬赏
        if self.couldSetRewardQuora() {
            // 进入悬赏设置界面
            let offerRewardSetVC = TSQuestionOfferRewardSetController()
            // 悬赏类型，若修改问题，则悬赏类型为修改的悬赏类型，即不可设置邀请人，但标题和其他又类似发布
            offerRewardSetVC.rewardType = (self.type == .update) ? .update : .publish
            offerRewardSetVC.editType = self.type
            offerRewardSetVC.contributeModel = self.contributeModel
            self.navigationController?.pushViewController(offerRewardSetVC, animated: true)
        } else {
            guard let contributeModel = self.contributeModel, let questionId = self.contributeModel?.updatedQuestionId else {
                return
            }
            // 修改问题
            self.nextBtn.isEnabled = false
            TSQuoraNetworkManager.updateQuestion(questionId, isUpdateRewardPrice: false, newQuestion: contributeModel, complete: { [weak self](msg, status) in
                self?.nextBtn.isEnabled = true
                if status {
                    let alert = TSIndicatorWindowTop(state: .success, title: "修改成功")
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        self?.gotoQuestionDetail(questionId: questionId)
                    })
                } else {
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
    }
}

// MARK: - Notification

extension TSQuestionTopicSelectController {
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
        let maxLen = self.searchMaxLen
        if textField.text == nil || textField.text == "" {
        } else {
            // 长度限定
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: maxLen)
        }
        // 下一步按钮的可用性判断
        self.couldNextProcess()
        self.requestData(type: .initial)
    }
}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension TSQuestionTopicSelectController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TSQuestionPublishTopicAddCell.cellInTableView(tableView)
        cell.selectionStyle = .none
        cell.model = self.sourceList[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TSQuestionTopicSelectController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TSQuestionPublishTopicAddCell.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 判断是否已选中该话题
        let topic = self.sourceList[indexPath.row]
        if self.selectedTopicList.contains(where: { (model) -> Bool in
            if model.id == topic.id {
                let alert = TSIndicatorWindowTop(state: .faild, title: "提示信息_专题不能重复".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
            return model.id == topic.id
        }) {
            return
        } else {
            // 还没有选中该话题，判断当前已选中话题数 是否达到最大选中数
            if self.selectedTopicList.count >= self.maxSlecteTopicNum {
                return
            }
            // 选中该话题，并重新对选中话题视图赋值并修正高度
            self.selectedTopicList.append(topic)
            self.topicSelectedView.topics = self.selectedTopicList
            self.topicSelectedView.snp.updateConstraints({ (make) in
                make.height.equalTo(self.topicSelectedView.currentHeight)
            })
            self.couldNextProcess() // 导航栏next按钮的可用性判断
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - TSQuestionTopicSelectedViewProtocol

/// 话题选中视图的回调
extension TSQuestionTopicSelectController: TSQuestionTopicSelectedViewProtocol {
    /// 指定的删除按钮点击响应
    func topicView(_ topicView: TSQuestionTopicSelectedView, didDeleteBtnClickWith cancelTopic: TSQuoraTopicModel) {
        let index = self.selectedTopicList.index(where: { (model) -> Bool in
            return model.id == cancelTopic.id
        })
        if nil == index {
            return
        }
        self.selectedTopicList.remove(at: index!)
        self.topicSelectedView.topics = self.selectedTopicList
        self.topicSelectedView.snp.updateConstraints({ (make) in
            make.height.equalTo(self.topicSelectedView.currentHeight)
        })
        self.couldNextProcess()     // 导航栏next按钮的可用性判断
    }
}
