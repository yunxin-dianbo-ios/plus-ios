//
//  TSQuoraDetailController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答详情页 = 问题详情页
//  注1：没有答案时的展示未完成，TSTableView中的展示空的方案不可行，因为答案列表为空不代表问题详情为空
//       没有答案时仍然展示一个Cell，表示没有答案
//  注2：+号发布成功进入该界面，必须传入type且为addPublish

import Foundation
import UIKit
import MJRefresh

/// 问答的来源类型，用于区别addPublish(+号发布)下返回时使用dimiss方案
enum TSQuoraSourceType {
    /// 正常情况下使用push方案进入
    case normal
    /// +号下发布问答成功进入
    case addPublish
}

protocol TSQuestionDetailControllerProtocol: class {
    /// 问题删除
    func didDeletedQuestion(_ questionId: Int) -> Void
}

typealias TSQuestionDetailController = TSQuoraDetailController
class TSQuoraDetailController: TSViewController {
    // MARK: - Internal Property
    /// 问题id
    var questionId: Int = 0
    /// 来源类型
    var type: TSQuoraSourceType = .normal
    /// 回调
    weak var delegate: TSQuestionDetailControllerProtocol?
    var questionDeletedAction: ((_ questionId: Int) -> Void)?

    // MARK: - Private Property
    /// 底部工具栏
    fileprivate weak var bottomBar: TSQuoraDetailToolBar!
    /// 问题详情视图
    fileprivate weak var questionView: TSQuestionDetailView!
    fileprivate weak var tableView: TSTableView!
    /// 答案列表
    fileprivate var sourceList: [TSAnswerListModel] = [TSAnswerListModel]()
    /// 问题详情数据模型
    fileprivate var questionDetail: TSQuestionDetailModel?
    /// 答案的便宜
    fileprivate var answerOffset: Int = 0
    /// 答案列表的排序
    fileprivate var answerOrderType: TSAnserOrderType = .diggCount
    /// 答案列表每次请求的限制
    fileprivate let answerLimit: Int = TSAppConfig.share.localInfo.limit
    /// 是否已经有采纳答案
    var isAdopted = false

    // MARK: - Initialize Function
    // MARK: - Internal Function

    // MARK: - LifeCircle
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "reloaddataquestiondetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeAnswerAgreeStatus(notice:)), name: NSNotification.Name(rawValue: "changeAnswerAgreeStatus"), object: nil)
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    // MARK: - Private  UI
    private func initialUI() -> Void {
        // 1. navigationbar
        self.navigationItem.title = "问题详情"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        // 2. bottomTool
        let bottomBar = TSQuoraDetailToolBar()
        self.view.addSubview(bottomBar)
        bottomBar.barDelegate = self
        bottomBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(TSAnswerDetailToolBar.defaultH)
        }
        self.bottomBar = bottomBar
        // 3. headerView
        let questionView = TSQuestionDetailView()
        questionView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 250)
        questionView.delegate = self
        self.questionView = questionView    // 注： tableView.tableHeaderView = questionView 方式持有 
        // 4. tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = questionView
        tableView.backgroundColor = TSColor.inconspicuous.background
        // 添加刷新控件
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(bottomBar.snp.top)
        }
        self.tableView = tableView
    }

    // MARK: - Private  数据处理与加载
    // TODO: - 这里的数据加载可以考虑适当合并，特别是initialDataSource和refresh
    private func initialDataSource() -> Void {
        self.answerOffset = 0
        self.loading()
        TSQuoraTaskManager().networkQuoraDetailData(in: self.questionId, offset: self.answerOffset, orderType: self.answerOrderType, limit: self.answerLimit) { (quoraDetail, answerList, _, status, code) in
            if code == 404 {
                self.loadFaild(type: .delete)
                return
            }
            guard status, let quoraDetail = quoraDetail, let answerList = answerList else {
                self.loadFaild(type: .network)
                return
            }
            self.questionDetail = quoraDetail
            self.answerOffset = answerList.count
            // 答案列表处理：采纳答案在问题详情中，不会出现在答案列表中；但邀请答案可能出现，因此需要对答案进行去重处理。
            self.sourceList.removeAll()
            // 邀请答案位于采纳答案之前
            if let invitationAnswers = quoraDetail.invitationAnswers {
                self.sourceList.append(contentsOf: invitationAnswers)
            }
            if let adoptedAnswers = quoraDetail.adoptionAnswers {
                self.sourceList.append(contentsOf: adoptedAnswers)
                if (adoptedAnswers.count > 0) {
                    self.isAdopted = true
                }
            }
            // 答案去重处理
            self.sourceList.append(contentsOf: self.removeDuplicateAnswer(answerList))
            self.tableView.mj_footer.isHidden = answerList.count != self.answerLimit
            self.questionView.loadModel(quoraDetail, complete: { (height) in
                self.endLoading()
                if TSCurrentUserInfo.share.accountManagerInfo?.getQuestionManager() ?? false {
                    self.bottomBar.type = (quoraDetail.userId == TSCurrentUserInfo.share.userInfo?.userIdentity) ? .publisher : .manager
                } else {
                    self.bottomBar.type = (quoraDetail.userId == TSCurrentUserInfo.share.userInfo?.userIdentity) ? .publisher : .normal
                }
                self.questionView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
                self.tableView.reloadData()
            })
        }
    }
    func refresh() {
        self.answerOffset = 0
        TSQuoraTaskManager().networkQuoraDetailData(in: self.questionId, offset: self.answerOffset, orderType: .diggCount, limit: self.answerLimit) { (quoraDetail, answerList, msg, status, code) in
            if code == 404 {
                self.loadFaild(type: .delete)
                return
            }
            guard status, let quoraDetail = quoraDetail, let answerList = answerList else {
                self.tableView.mj_header.endRefreshing()
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            self.questionDetail = quoraDetail
            self.answerOffset = answerList.count
            // 答案列表处理：采纳答案在问题详情中，不会出现在答案列表中；但邀请答案可能出现，因此需要对答案进行去重处理。
            self.sourceList.removeAll()
            // 邀请答案位于采纳答案之前
            if let invitationAnswers = quoraDetail.invitationAnswers {
                self.sourceList.append(contentsOf: invitationAnswers)
            }
            if let adoptedAnswers = quoraDetail.adoptionAnswers {
                self.sourceList.append(contentsOf: adoptedAnswers)
                if (adoptedAnswers.count > 0) {
                    self.isAdopted = true
                }
            }
            // 答案去重处理
            self.sourceList.append(contentsOf: self.removeDuplicateAnswer(answerList))
            self.tableView.mj_footer.isHidden = answerList.count != self.answerLimit
            if TSCurrentUserInfo.share.accountManagerInfo?.getQuestionManager() ?? false {
                self.bottomBar.type = (quoraDetail.userId == TSCurrentUserInfo.share.userInfo?.userIdentity) ? .publisher : .manager
            } else {
                self.bottomBar.type = (quoraDetail.userId == TSCurrentUserInfo.share.userInfo?.userIdentity) ? .publisher : .normal
            }
            self.questionView.loadModel(quoraDetail, complete: { (height) in
                self.tableView.mj_header.endRefreshing()
                self.questionView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
                self.tableView.reloadData()
            })
        }
    }
    func loadMore() {
        TSQuoraTaskManager().networkAnswerList(in: self.questionId, offset: self.answerOffset, orderType: self.answerOrderType, limit: self.answerOffset) { (answerList, _, status) in
            guard status, let answerList = answerList else {
                self.tableView.mj_footer.endRefreshing()
                return
            }
            if answerList.count < self.answerLimit {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self.answerOffset += answerList.count
            // 答案去重处理
            self.sourceList.append(contentsOf: self.removeDuplicateAnswer(answerList))
            self.tableView.reloadData()
        }
    }
    /// 重新加载答案列表 - 用于答案排序时调用
    fileprivate func initialAnswerList() -> Void {
        self.answerOffset = 0
        TSQuoraNetworkManager.getAnswerList(questionId: self.questionId, offset: self.answerOffset, orderType: self.answerOrderType, limit: self.answerLimit) { (answerList, msg, status) in
            guard status, let answerList = answerList else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            self.answerOffset = answerList.count
            // 答案列表处理：采纳答案在问题详情中，不会出现在答案列表中；但邀请答案可能出现，因此需要对答案进行去重处理。
            self.sourceList.removeAll()
            // 邀请答案位于采纳答案之前
            if let invitationAnswers = self.questionDetail?.invitationAnswers {
                self.sourceList.append(contentsOf: invitationAnswers)
            }
            if let adoptedAnswers = self.questionDetail?.adoptionAnswers {
                self.sourceList.append(contentsOf: adoptedAnswers)
            }
            // 答案去重处理
            self.sourceList.append(contentsOf: self.removeDuplicateAnswer(answerList))
            self.tableView.mj_footer.isHidden = answerList.count != self.answerLimit
            self.tableView.reloadData()
        }
    }
    /// 答案去重处理 - 邀请答案在问题详情中返回，但答案列表中也可能返回，需去重处理
    private func removeDuplicateAnswer(_ originAnswerList: [TSAnswerListModel]) -> [TSAnswerListModel] {
        guard let invitationAnswerList = self.questionDetail?.invitationAnswers else {
            return originAnswerList
        }
        if invitationAnswerList.isEmpty || originAnswerList.isEmpty {
            return originAnswerList
        }
        // 去重
        var resultAnswerList = [TSAnswerListModel]()
        for originAnswer in originAnswerList {
            var isDuplicateFlag: Bool = false
            for invitationAnswer in invitationAnswerList {
                if originAnswer.id == invitationAnswer.id {
                    isDuplicateFlag = true
                    break
                }
            }
            if !isDuplicateFlag {
                resultAnswerList.append(originAnswer)
            }
        }
        return resultAnswerList
    }

    // MARK: - Event Action

    /// 导航栏返回按钮响应
    @objc fileprivate func backItemClick() -> Void {
        TSUtil.popViewController(currentVC: self, animated: true)
    }

    /// 处理回答详情页传递过来的采纳成功通知
    func changeAnswerAgreeStatus(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        guard let answerId = dict["answerId"], let questionId = dict["questionId"] else {
            return
        }
        let answerID = "\(answerId)"
        let questionID = "\(questionId)"
        let follow = "\(dict["status"] ?? "")"
        let followStatus = follow == "1" ? true : false
        for (index, item) in self.sourceList.enumerated() {
            if "\(item.questionId)" == questionID && "\(item.id)" == answerID {
                item.isAdoption = followStatus
                self.sourceList.insert(item, at: index)
                self.sourceList.remove(at: index + 1)
                break
            }
        }
        if (followStatus) {
            self.isAdopted = true
        } else {
            self.isAdopted = false
        }
        self.tableView.reloadData()
    }

    // MARK: - Delegate Function
    // MARK: - Notification
}

// MARK: - UITableViewDataSource

extension TSQuoraDetailController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.isEmpty ? 1 : self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.sourceList.isEmpty {
            let cell = TSAnswerEmptyCell.cellInTableView(tableView)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = TSAnswerListCell.cellInTableView(tableView)
            cell.selectionStyle = .none
            cell.loadAnswer(self.sourceList[indexPath.row], questionUserId: self.questionDetail?.userId, isAdopted: self.isAdopted)
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension TSQuoraDetailController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sourceList.isEmpty {
            return nil
        } else {
            let headerView = TSAnswerListHeaderView.headerInTableView(tableView)
            headerView.answersCount = self.sourceList.count
            headerView.orderType = self.answerOrderType
            headerView.delegate = self
            return headerView
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.sourceList.isEmpty {
            return 0.01
        } else {
            return TSAnswerListHeaderView.headerHeight
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 数据源列表为空时，显示没有回答
        if self.sourceList.isEmpty {
            return
        }
        let answer = self.sourceList[indexPath.row]
        // 判断是会否需要围观付费
        if nil == answer.could || true == answer.could {
            // 进入答案详情页
            let answerDetailVC = TSAnswerDetailController(answerId: answer.id)
            answerDetailVC.delegate = self
            answerDetailVC.isAdopted = self.isAdopted
            self.navigationController?.pushViewController(answerDetailVC, animated: true)
        } else {
            // 围观支付弹窗
            TSQuoraHelper.processAnswerOutlook(answerId: answer.id, payComplete: { [weak self] (payResult, answerDetail) in
                guard let WeakSelf = self else {
                    return
                }
                if payResult {
                    // 支付成功处理
                    answer.could = true     // 围观状态数据更新
                    if let answerDetail = answerDetail {
                        answer.body = answerDetail.body
                    }
                    answer.outlookCount! += 1
                    WeakSelf.questionDetail!.outlookAmount! += TSAppConfig.share.localInfo.quoraOutLookAmount
                    self?.questionView.reloadExceptContent()
                    self?.tableView.reloadData()
                    /// 这个地方需要更新列表数据来同步修改模糊状态
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAnSwerLookStatus"), object: nil, userInfo: ["questionid": answer.questionId, "answerid": answer.id, "could": "1", "bodyText": answer.body_text ?? answer.body.ts_customMarkdownToNormal()])
                }
                }, cancel: {
            })
        }
    }

}

// MARK: - TSQuestionDetailViewProtocol

/// 问题详情视图代理回调
extension TSQuoraDetailController: TSQuestionDetailViewProtocol {
    /// 关注按钮点击回调
    func questionView(_ questionView: TSQuestionDetailView, didClickFollowControl followControl: UIControl) -> Void {
        guard let questionDetail = self.questionDetail else {
            return
        }
        followControl.isEnabled = false
        // 判断当前关注状态，再请求相关操作
        let followOperate: TSFollowOperate = questionDetail.isWatched ? .unfollow : .follow
        TSQuoraNetworkManager.quoraFollowOperate(followOperate, quoraId: questionDetail.id) { [weak self] (msg, status) in
            followControl.isEnabled = true
            if status {
                followControl.isSelected = !followControl.isSelected
                // 修改数据模型
                questionDetail.isWatched = !questionDetail.isWatched
                // 修改关注数
                switch followOperate {
                case .follow:
                    questionDetail.watchersCount += 1
                case .unfollow:
                    questionDetail.watchersCount -= 1
                }
                // 更新关注数展示
                self?.questionView.reloadExceptContent()
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
    /// 悬赏按钮点击回调
    func questionView(_ questionView: TSQuestionDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void {
        guard let questionDetail = self.questionDetail else {
            return
        }
        // 判断问题的悬赏类型
        switch questionDetail.rewardType {
        case .none:
            // 未设置悬赏：未采纳答案(采纳答案标记这里不可用) 且 当前用户是发布者，则去设置悬赏
            if (nil == questionDetail.adoptionAnswers || questionDetail.adoptionAnswers!.isEmpty) && (TSCurrentUserInfo.share.isLogin && TSCurrentUserInfo.share.userInfo?.userIdentity == questionDetail.userId) {
                let rewardSetVC = TSQuestionOfferRewardSetController()
                rewardSetVC.rewardType = .normal
                rewardSetVC.questionId = questionDetail.id
                self.navigationController?.pushViewController(rewardSetVC, animated: true)
            }
        case .normal:
            // 公开悬赏(无邀请悬赏)
            break
        case .invitation:
            // 邀请悬赏 - 显示邀请用户
            // 注：没有答案时仍展示一个没有答案的提示的cell，但sectionHeader不予展示
            let rectInTableView = tableView.rectForHeader(inSection: 0)
            let rect = tableView.convert(rectInTableView, to: self.view)
            let topMargin = rect.origin.y - 10
            let popView = TSQuestionInvitationUserPopView(topMargin: topMargin)
            self.view.addSubview(popView)
            popView.iconView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: self.questionDetail?.invitations?.first?.sex)
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:self.questionDetail?.invitations?.first?.avatar)
            popView.iconView.avatarInfo = avatarInfo
            popView.nameLabel.text = self.questionDetail?.invitations?.first?.name
            popView.delegate = self
            popView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.view)
            }
        }
    }
    /// 回答按钮
    func questionView(_ questionView: TSQuestionDetailView, didClickAnswerBtn answerBtn: UIButton) -> Void {
        // 登录判断
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 判断当前用户是否已提交答案
        if let myAnswer = self.questionDetail?.myAnswer {
            // 进入答案详情界面
            let answerDetailVC = TSAnswerDetailController(answerId: myAnswer.id)
            answerDetailVC.delegate = self
            self.navigationController?.pushViewController(answerDetailVC, animated: true)
        } else {
            // 进入回答发布界面
            UserDefaults.standard.set("reply", forKey: "webEditorType")
            UserDefaults.standard.synchronize()
            let answerPublishVC = TSPublishAnswerController(questionId: self.questionId, questionTitle: self.questionDetail?.title)
            answerPublishVC.publishAnswerSuccessAction = { (answer) -> Void in
                self.questionDetail?.myAnswer = answer
                // 答案编辑入口修正
                self.questionView.reloadExceptContent()
                // 答案列表修正 - 答案列表采用offset方式加载更多
                if self.sourceList.count < self.answerLimit {
                    self.sourceList.append(answer)
                }
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(answerPublishVC, animated: true)
        }
    }
    /// 更多点击展开的回调
    func questionView(_ questionView: TSQuestionDetailView, didClickMoreWithNewHeight newHeight: CGFloat) -> Void {
        self.questionView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: newHeight)
        self.tableView.reloadData()
    }
    /// 话题点击
    func questionView(_ questionView: TSQuestionDetailView, didClickTopic topic: TSQuoraTopicModel) -> Void {
        // 进入话题详情页
        let topicDetailVC = TopicDetailController(topicId: topic.id)
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }
}

// MARK: - TSAnswerListCellProtocol

extension TSQuoraDetailController: TSAnswerListCellProtocol {
    /// 点赞Item点击响应
    func didClickFavorItemInCell(_ cell: TSAnswerListCell) {
        guard let model = cell.model else {
            return
        }
        // 点赞相关请求
        cell.toolBarEnable = false
        let favorOperate = model.liked ? TSFavorOperate.unfavor : TSFavorOperate.favor
        cell.favorOrUnFavor = !model.liked
        TSQuoraNetworkManager.answerFavorOperate(favorOperate, answerId: model.id) { (msg, status) in
            cell.toolBarEnable = true
            if status {
                model.liked = favorOperate == TSFavorOperate.favor ? true : false
                model.likesCount += favorOperate == TSFavorOperate.favor ? 1 : -1
                cell.updateToolBar()
            } else {
                // 提示
                let loadingShow = TSIndicatorWindowTop(state: .faild, title: msg)
                loadingShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 评论Item点击响应
    func didClickCommentItemInCell(_ cell: TSAnswerListCell) -> Void {
        // 点击Item进入答案详情
        guard let model = cell.model else {
            return
        }
        // 需要判断是否是“围观”的回答
        // 如果是“设置了围观且还没有参与围观” == “没有付费”，需要拦截并提示付费
        if model.could == false {
            self.tableView(self.tableView, didSelectRowAt: self.tableView.indexPath(for: cell)!)
            return
        }
        // 进入答案详情页
        let answerDetailVC = TSAnswerDetailController(answerId: model.id)
        answerDetailVC.delegate = self
        self.navigationController?.pushViewController(answerDetailVC, animated: true)
    }

    /// 采纳按钮点击事件
    func didClickAgreeButton(_ cell: TSAnswerListCell) {
        guard let answerId = cell.model?.id, let questionId = cell.model?.questionId else {
            return
        }
        // 采纳答案的网络请求
        TSQuoraNetworkManager.adoptAnswer(answerId, forQuestion: questionId) { (msg, status) in
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_采纳成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.refresh()
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
}

// MARK: - TSQuoraDetailToolBarProtocol

/// 底部工具栏点击回调
extension TSQuoraDetailController: TSQuoraDetailToolBarProtocol {
    ///  评论点击回调
    func didClickCommentItem(in bar: TSQuoraDetailToolBar) -> Void {
        // 点击进入评论列表页
        let commentCount = self.questionDetail?.commentsCount ?? 0
        let commentVC = TSQuestionCommentListController(questionId: self.questionId, commentCount: commentCount)
        commentVC.isHidenHeader = true
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    /// 分享点击回调
    func didClickShareItem(in bar: TSQuoraDetailToolBar) -> Void {
        guard let quoraDetail = self.questionDetail else {
            return
        }
        let messageModel = TSmessagePopModel(questionDetail: questionDetail!)
        let shareView = ShareListView(isMineSend: quoraDetail.userId == TSCurrentUserInfo.share.userInfo?.userIdentity, isCollection: false, shareType: ShareListType.questionDetail)
        shareView.delegate = self
        shareView.messageModel = messageModel
        let shareTitle = quoraDetail.title.count > 0 ? quoraDetail.title : TSAppSettingInfoModel().appDisplayName + " " + "问答"
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let shareContent = quoraDetail.body.ts_customMarkdownToNormal().count > 0 ? quoraDetail.body.ts_customMarkdownToNormal() : defaultContent
        shareView.show(URLString: ShareURL.question.rawValue + "\(quoraDetail.id)", image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
    }
    /// 编辑点击回调
    func didClickEditItem(in bar: TSQuoraDetailToolBar) -> Void {
        // 问题发布者才有编辑选项，点击进入问题编辑界面
        let questionEditVC = TSQuestionTitleEditController()
        questionEditVC.type = .update
        questionEditVC.updatedQuestion = self.questionDetail
        self.navigationController?.pushViewController(questionEditVC, animated: true)
    }
    /// 更多点击回调
    func didClickMoreItem(in bar: TSQuoraDetailToolBar) -> Void {
        var alert: TSCustomActionsheetView
        switch bar.type {
        // 普通用户界面的更多点击: 举报
        case .normal:
            alert = TSCustomActionsheetView(titles: ["选择_举报".localized])
            alert.tag = 251
        // 问题发布者界面的更多点击
        case .publisher:
            // 弹窗：申请为精选问答 + 删除问题
            alert = TSCustomActionsheetView(titles: ["选择_申请为精选问答".localized, "选择_删除问题".localized])
            alert.setColor(color: TSColor.main.warn, index: 1)
            alert.tag = 250
        case .manager:
            // 弹窗：申请为精选问答 + 删除问题
            alert = TSCustomActionsheetView(titles: ["选择_删除问题".localized])
            alert.setColor(color: TSColor.main.warn, index: 1)
            alert.tag = 252
        }
        alert.delegate = self
        alert.show()
    }
}

// MARK: - TSAnswerListHeaderViewProtocol

/// 答案列表上的hader回调
extension TSQuoraDetailController: TSAnswerListHeaderViewProtocol {
    /// 排序方式点击
    func didClickOrderTyp(in header: TSAnswerListHeaderView) {
        let rectInTableView = tableView.rectForHeader(inSection: 0)
        let rect = tableView.convert(rectInTableView, to: self.view)
        let popView = TSAnswerOrderTypeSelectPopView(currentType: self.answerOrderType, topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 15)
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

// MARK: - TSAnswerOrderTypeSelectPopViewProtocol

/// 答案排序弹窗选择回调
extension TSQuoraDetailController: TSAnswerOrderTypeSelectPopViewProtocol {
    func popView(_ popView: TSAnswerOrderTypeSelectPopView, didSelected answerOrderType: TSAnserOrderType) {
        if answerOrderType == self.answerOrderType {
            return
        }
        // 重新请求答案列表
        self.answerOrderType = answerOrderType
        self.initialAnswerList()
    }
}

// MARK: - TSQuestionInvitationUserPopViewProtocol

extension TSQuoraDetailController: TSQuestionInvitationUserPopViewProtocol {
    /// 悬赏点击弹窗中的用户点击回调
    func didClickUser(in popView: TSQuestionInvitationUserPopView) {
        // 进入用户详情页
        guard let invitationUser = self.questionDetail?.invitations?.first else {
            return
        }
        let userHomeVC = TSHomepageVC(invitationUser.userIdentity)
        self.navigationController?.pushViewController(userHomeVC, animated: true)
    }
}

// MARK: - TSCustomAcionSheetDelegate

extension TSQuoraDetailController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        switch view.tag {
        // 问题发布者的更多选项点击回调
        case 250:
            fallthrough
        // 举报选项点击回调
        case 251:
            fallthrough
        case 252:
            switch title {
            case "选择_举报".localized:
                self.reportQuestion()
            case "选择_申请为精选问答".localized:
                // 精选问答支付弹窗
                self.showApplyQuoraApplicationAlert()
            case "选择_删除问题".localized:
                self.showDeleteQuestionConfirmAlert()
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - TSAnswerDetailControllerProtocol

extension TSQuoraDetailController: TSAnswerDetailControllerProtocol {
    /// 答案删除的回调
    func didDeletedAnswer(_ answerId: Int) {
        // 删除的答案肯定是自己发布的答案
        self.questionDetail?.myAnswer = nil
        // 数据源列表中的数据移除
        for (index, answer) in self.sourceList.enumerated() {
            if answer.id == answerId {
                self.sourceList.remove(at: index)
                break
            }
        }
        // 刷新数据
        self.questionView.reloadExceptContent()
        self.tableView.reloadData()
    }
}
// MARK: - 更多选项具体响应弹窗扩展
extension TSQuoraDetailController {

    /// 删除问题弹窗
    fileprivate func showDeleteQuestionConfirmAlert() -> Void {
        let alertVC = TSAlertController(title: nil, message: "删除问题后将无法复原，确认删除该问题?", style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "删除问题", style: .destructive, handler: { (_) in
            self.deleteQuestion()
        }))
        self.present(alertVC, animated: false, completion: nil)

    }
    /// 申请为精选问答弹窗
    fileprivate func showApplyQuoraApplicationAlert() -> Void {
        let price: Int = TSAppConfig.share.localInfo.quoraApplyAmount
        let payAlert = TSIndicatorPayQuoraApplication(price: Double(price))
        payAlert.show(quoraId: self.questionId, success: nil, failure: nil)
    }
    /// 举报问题
    fileprivate func reportQuestion() -> Void {
        guard let question = self.questionDetail else {
            return
        }
        let reportModel: ReportTargetModel = ReportTargetModel(question: question)
        let reportVC = ReportViewController(reportTarget: reportModel)
        self.navigationController?.pushViewController(reportVC, animated: true)
    }
    /// 删除问题
    fileprivate func deleteQuestion() -> Void {
        // 问题删除的请求
        let loadingShow = TSIndicatorWindowTop(state: .loading, title: "正在请求中...")
        loadingShow.show()
        if bottomBar.type == .manager {
            TSQuoraNetworkManager.managerDeleteQuora(self.questionId, complete: { (msg, status) in
                loadingShow.dismiss()
                // 显示提示
                if status {
                    let topShow = TSIndicatorWindowTop(state: .success, title: "删除成功!")
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        _ = self.navigationController?.popViewController(animated: true)
                        self.delegate?.didDeletedQuestion(self.questionId)
                        self.questionDeletedAction?(self.questionId)
                    })
                } else {
                    let topShow = TSIndicatorWindowTop(state: .faild, title: msg)
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        } else {
            TSQuoraNetworkManager.deleteQuora(self.questionId, complete: { (msg, status) in
                loadingShow.dismiss()
                // 显示提示
                if status {
                    let topShow = TSIndicatorWindowTop(state: .success, title: "删除成功!")
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        _ = self.navigationController?.popViewController(animated: true)
                        self.delegate?.didDeletedQuestion(self.questionId)
                        self.questionDeletedAction?(self.questionId)
                    })
                } else {
                    let topShow = TSIndicatorWindowTop(state: .faild, title: msg)
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
    }

}
extension TSQuoraDetailController: ShareListViewDelegate {
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        let chooseFriendVC = TSPopMessageFriendList(model: model)
        self.navigationController?.pushViewController(chooseFriendVC, animated: true)
    }

    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let repostModel = TSRepostModel.coverQuestionModel(questionModel: self.questionDetail!)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC)
        self.present(navigation, animated: true, completion: nil)
    }
}
