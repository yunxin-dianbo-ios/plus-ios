//
//  TSAnswerCommentController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 10/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案的评论列表界面，其实就是答案详情界面
//  该页面主要用来测试答案的评论列表，之后答案详情页将完全采用该页面代码

import UIKit

class TSAnswerCommentController: TSCommentListController {
    // MARK: - Internal Property 
    /// 回调
    weak var delegate: TSAnswerDetailControllerProtocol?
    var answerDeletedAction: ((_ answerId: Int) -> Void)?

    // MARK: - Internal Function

    // MARK: - Private Property
    fileprivate weak var titleBtn: UIButton!

    /// 答案详情视图 - 也是tableView的头视图
    fileprivate weak var headView: TSAnswerDetailView!
    /// 底部工具栏
    fileprivate weak var toolBar: TSAnswerDetailToolBar!
    /// 答案详情
    fileprivate var answerDetail: TSAnswerDetailModel?
    /// 是否需要显示购买(围观)弹窗
    private var shouldShowPayAlert = false
    /// 是否已经有采纳答案
    var isAdopted = false

    // MARK: - Initialize Function

    init(answerId: Int) {
        super.init(type: .answer, sourceId: answerId)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Function
    override func viewWillAppear(_ animated: Bool) {
        if shouldShowPayAlert {
            // 围观支付弹窗
            TSQuoraHelper.processAnswerOutlook(answerId: self.sourceId, payComplete: { [weak self] (payResult, answerDetail) in
                guard let WeakSelf = self else {
                    return
                }
                if payResult {
                    WeakSelf.view.isHidden = false
                    WeakSelf.view.alpha = 1
                    // 支付成功处理
                    WeakSelf.requestData(.initial)
                }
                }, cancel: {
                    // 取消或者其他异常
                    TSUtil.popViewController(currentVC: self, animated: true)
            })
        }
    }
    /// 请求数据
    override func requestData(_ type: TSListDataLoadType) -> Void {
        let answerId = self.sourceId
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            // 请求详情页数据
            self.afterId = 0
            TSQuoraTaskManager().networkAnswerDetailData(for: answerId, afterId: self.afterId, limit: self.limit, complete: { (answerDetail, commentList, _, status, code) in
                if code == 404 {
                    self.loadFaild(type: .delete)
                    return
                }
                guard status, let answerDetailModel = answerDetail, let commentList = commentList else {
                    switch type {
                    case .initial:
                        /// 返回了false，并且body为空，就是需要开启围观的回答
                        /// 弹窗提示
                        if let answerDetail = answerDetail, answerDetail.body.count == 0 {
                            self.shouldShowPayAlert = true
                            UIView.animate(withDuration: 0.5, animations: {
                                self.view.alpha = 0
                            }, completion: { (status) in
                                self.view.isHidden = true
                            })
                            self.endLoading()
                            // 围观支付弹窗
                            TSQuoraHelper.processAnswerOutlook(answerId: answerDetail.id, payComplete: { [weak self] (payResult, answerDetail) in
                                guard let WeakSelf = self else {
                                    return
                                }
                                if payResult {
                                    WeakSelf.shouldShowPayAlert = false
                                    WeakSelf.view.alpha = 1
                                    WeakSelf.view.isHidden = false
                                    // 支付成功处理
                                    WeakSelf.requestData(.initial)
                                }
                                }, cancel: {
                                    // 取消或者其他异常
                                    TSUtil.popViewController(currentVC: self, animated: true)
                            })
                        } else {
                            self.loadFaild(type: .network)
                        }
                    case .refresh:
                        self.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    return
                }
                self.view.alpha = 1
                self.view.isHidden = false
                self.titleBtn.setTitle(answerDetailModel.question?.title, for: .normal)
                self.toolBar.isFavored = answerDetailModel.liked ? true : false
                if answerDetailModel.question?.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                    // 先判断是否有采纳
                    if (self.isAdopted) {
                        // 是否是采纳答案
                        if (answerDetailModel.isAdoption) {
                            self.toolBar.changeSubView(newAnswerDetail: true)
                            self.toolBar.toolBar.isHidden = false
                            self.toolBar.isAgree = answerDetailModel.isAdoption
                        } else {
                            self.toolBar.changeSubView(newAnswerDetail: false)
                            self.toolBar.toolBar.isHidden = false
                        }
                    } else {
                        self.toolBar.changeSubView(newAnswerDetail: true)
                        self.toolBar.toolBar.isHidden = false
                        self.toolBar.isAgree = answerDetailModel.isAdoption
                    }
                } else {
                    self.toolBar.changeSubView(newAnswerDetail: false)
                    self.toolBar.toolBar.isHidden = false
                }
                self.answerDetail = answerDetailModel
                self.sourceList = commentList
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.afterId = commentList.last?.id ?? 0
                self.tableView.mj_footer.isHidden = commentList.count != self.limit
                // 加载markdown
                self.headView.loadModel(answerDetailModel, complete: { (height) in
                    switch type {
                    case .initial:
                        self.endLoading()
                    case .refresh:
                        self.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    self.headView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
                    self.commentCount = answerDetailModel.commentsCount
                    self.tableView.reloadData()
                })
            })

        case .loadmore:
            // 加载更多评论
            super.requestData(.loadmore)
        }
    }
}

// MARK: - UI加载

extension TSAnswerCommentController {
    override func initialUI() {
        super.initialUI()
        // navitionbar - 导航栏标题可点击，进入问题详情页
        let button = UIButton(type: .custom)
        button.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 44)  // 宽度过长会自动作为titleView被限制约束
        button.addTarget(self, action: #selector(navigationTitleClick(_:)), for: .touchUpInside)
        button.setTitleColor(TSColor.inconspicuous.navTitle, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        self.navigationItem.titleView = button
        self.titleBtn = button
        // bottomBar
        let toolBar = TSAnswerDetailToolBar(newAnswerDetail: true)
        toolBar.toolBar.isHidden = true
        self.view.addSubview(toolBar)
        toolBar.delegate = self
        toolBar.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.height.equalTo(TSAnswerDetailToolBar.defaultH)
        }
        self.toolBar = toolBar
        // tableView
        self.tableView.snp.remakeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.bottom.equalTo(toolBar.snp.top)
        }
        // tableHeaderView
        let headView = TSAnswerDetailView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth))
        self.tableView.tableHeaderView = headView
        headView.delegate = self
        self.headView = headView
    }
}

extension TSAnswerCommentController {
    /// 导航栏标题点击响应
    @objc fileprivate func navigationTitleClick(_ button: UIButton) -> Void {
        // 进入问题详情页
        guard let questionId = self.answerDetail?.questionId, let title = button.currentTitle else {
            return
        }
        let questionVC = TSQuestionDetailController()
        questionVC.questionId = questionId
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
}

// MARK: - TSAnswerDetailViewProtocol

// 答案详情页的视图响应回调
extension TSAnswerCommentController: TSAnswerDetailViewProtocol {
    // 关注状态按钮点击响应
    func answerView(_ answerView: TSAnswerDetailView, didClickFollowControl followControl: TSFollowControl) -> Void {
        // TODO: - 这里没有起到作用，待完成
        followControl.isFollow = !followControl.isFollow
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 判断关注状态
        guard let user = answerDetail?.user else {
            return
        }
        followControl.isEnabled = false
        let followOperate = user.follower ? TSFollowOperate.unfollow : TSFollowOperate.follow
        TSUserNetworkingManager.followOperate(followOperate, userId: user.userIdentity) { (msg, status) in
            followControl.isEnabled = true
            if status {
                // 更新数据源，并刷新数据
                self.answerDetail?.user?.follower = followOperate == TSFollowOperate.follow ? true : false
                followControl.isFollow = followOperate == TSFollowOperate.follow
            } else {
                // 重新刷新数据
                followControl.isFollow = user.follower
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
    // 打赏按钮点击响应
    func answerView(_ answerView: TSAnswerDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void {
        // 进入打赏界面
        let rewardVC = TSChoosePriceVCViewController(type: .answer)
        rewardVC.sourceId = self.sourceId
        rewardVC.delegate = self
        self.navigationController?.pushViewController(rewardVC, animated: true)
    }
    // 打赏列表点击响应
    func didClickRewardListIn(answerView: TSAnswerDetailView) -> Void {
        let answerId = self.sourceId
        let rewardListVC = TSRewardListVC.list(type: .answer)
        rewardListVC.rewardId = answerId
        self.navigationController?.pushViewController(rewardListVC, animated: true)
    }
    /// 点赞列表点击响应
    func didClickLikeListIn(answerView: TSAnswerDetailView) {
        let answerId = self.sourceId
        let likeListVC = TSLikeListTableVC(type: .answer, sourceId: answerId)
        self.navigationController?.pushViewController(likeListVC, animated: true)
    }
}

// MARK: - TSChoosePriceVCDelegate

// 打赏界面打赏成功的回调
extension TSAnswerCommentController: TSChoosePriceVCDelegate {
    func didRewardSuccess(_ rewardModel: TSNewsRewardModel) {
        guard let answerDetail = self.answerDetail else {
            return
        }
        self.answerDetail?.rewardsAmount += Float(rewardModel.amount)
        answerDetail.rewardersCount += 1
        answerDetail.rewarders?.append(rewardModel)
        self.headView.loadRewardInfo(with: answerDetail)
    }
}

// MARK: - UITableViewDataSource

extension TSAnswerCommentController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0
        rowCount = super.tableView(tableView, numberOfRowsInSection: section)
        return rowCount
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerSection: UIView? = nil
        headerSection = super.tableView(tableView, viewForHeaderInSection: section)
        return headerSection
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

}

// MARK: - UITableViewDelegate

extension TSAnswerCommentController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
    }

}

// MARK: - TSAnswerDetailToolBarProtocol

/// 底部工具栏点击回调
extension TSAnswerCommentController: TSAnswerDetailToolBarProtocol {
    /// 点赞按钮点击响应
    func didClickFavorItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        toolBar.isFavored = !toolBar.isFavored
        // TODO: - 将点赞部分提取出来
        // 答案 点赞/取消赞 请求
        guard let answerDetail = self.answerDetail else {
            return
        }
        let answerId = self.sourceId
        let favorOperate: TSFavorOperate = answerDetail.liked ? TSFavorOperate.unfavor : TSFavorOperate.favor
        TSQuoraNetworkManager.answerFavorOperate(favorOperate, answerId: answerId) { (msg, status) in
            if status {
                answerDetail.liked = favorOperate == TSFavorOperate.favor ? true : false
                answerDetail.likesCount += favorOperate == TSFavorOperate.favor ? 1 : -1
                if answerDetail.likesCount < 0 {
                    answerDetail.likesCount = 0
                }
                // 点赞列表数据更新
                let user = TSCurrentUserInfo.share.userInfo!
                if var likes = answerDetail.likes {
                    if favorOperate == TSFavorOperate.favor {
                        // 点赞 - 添加点赞用户
                        likes.insert(TSLikeUserModel(userId: user.userIdentity, user: user.convert(), sourceId: answerId), at: 0)
                        answerDetail.likes = likes
                    } else {
                        // 取消点赞 - 遍历移除当前用户
                        for (index, likeUserModel) in likes.enumerated() {
                            if likeUserModel.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                                likes.remove(at: index)
                                break
                            }
                        }
                        answerDetail.likes = likes
                    }
                } else {
                    if favorOperate == TSFavorOperate.favor {
                        var likes = [TSLikeUserModel]()
                        likes.append(TSLikeUserModel(userId: user.userIdentity, user: user.convert(), sourceId: answerId))
                        answerDetail.likes = likes
                    }
                }
                self.headView.loadFavorInfo(with: answerDetail)
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                toolBar.isFavored = answerDetail.liked ? true : false
            }
        }
    }
    /// 评论按钮点击响应
    func didClickCommentItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        self.commentModel = nil
        self.showKeyBoard(placeHolderText: "显示_说点什么吧".localized, cell: nil)
    }
    /// 分享按钮点击响应
    func didClickShareItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        guard let answerDetail = self.answerDetail, let question = self.answerDetail?.question else {
            return
        }
        let messageModel = TSmessagePopModel(questionAnswer: answerDetail)
        let shareView = ShareListView(isMineSend: answerDetail.userId == TSCurrentUserInfo.share.userInfo?.userIdentity, isCollection: false, shareType: ShareListType.questionAnswerDetail)
        shareView.delegate = self
        shareView.messageModel = messageModel
        var answerShareUrl = ShareURL.answswer.rawValue
        answerShareUrl.replaceAll(matching: "replacequestion", with: "\(question.id)")
        answerShareUrl = answerShareUrl + "\(answerDetail.id)"
        let shareTitle = question.title.count > 0 ? question.title : TSAppSettingInfoModel().appDisplayName + " " + "问答"
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let shareContent = answerDetail.body.ts_customMarkdownToNormal().count > 0 ? answerDetail.body.ts_customMarkdownToNormal() : defaultContent
        shareView.show(URLString: answerShareUrl, image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
    }
    /// 更多按钮点击响应
    func didClickMoreItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        /// 注：更多弹窗应提取出一个方法来，直接供代理调用
        guard let answerDetail = self.answerDetail, let question = self.answerDetail?.question else {
            return
        }
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        /// 是否有采纳的答案
        let adoptedFlag: Bool = question.hasAdopted
        // 是否是采纳答案标记
        let isAdoptionFlag: Bool = answerDetail.isAdoption
        // 是否是邀请答案的标记
        let isInvitationFlag: Bool = answerDetail.isInvited
        /// 收藏状态标记 - 已收藏的答案，显示已收藏，点击则取消收藏
        let collectTitle: String = answerDetail.collected ? "选择_取消收藏".localized : "选择_收藏".localized
        let reportTitle: String = "选择_举报".localized
        var customAction: TSCustomActionsheetView
        if TSCurrentUserInfo.share.userInfo?.userIdentity == answerDetail.question?.userId {
            /// 发布者：采纳答案、(编辑 - 自己的答案)、(删除 - 自己的答案)、收藏 - 已采纳的有答案时不再显示采纳、举报(才可举报自己)
            var titles: [String] = [String]()
            // 没有采纳答案
            if !adoptedFlag {
//                titles.insert("选择_采纳答案".localized, at: 0)
            }
            // 问题发布者  也是  答案发布者，则可以编辑，可以删除
            if TSCurrentUserInfo.share.userInfo?.userIdentity == answerDetail.userId {
                titles.append("选择_编辑".localized)
                titles.append("选择_删除".localized)
            } else {
                titles.append(reportTitle)
            }
            titles.append(collectTitle)
            customAction = TSCustomActionsheetView(titles: titles)
            customAction.tag = 251
        } else if TSCurrentUserInfo.share.userInfo?.userIdentity == answerDetail.userId {
            /// 回答者：删除、编辑、收藏、(不可举报自己)
            ///     -  回答者不能编辑的情况：该回答被采纳、该回答者是被邀请的人、
            ///     -  回答者不能删除的情况：该回答被采纳、该回答者是被邀请的人、
            var titles: [String] = [String]()
            if isAdoptionFlag {
                // 该答案被采纳，则该答案也不可删除
            } else {
                // 该答案不是被采纳的，则判断该回答者是不是被邀请的人
                // 不是被邀请的人，则可以删除、编辑。 注：若是被邀请的人，则该答案不可删除、不可编辑
                if !isInvitationFlag {
                    titles.append("选择_删除".localized)
                    titles.append("选择_编辑".localized)
                }
            }
            titles.append(collectTitle)
            customAction = TSCustomActionsheetView(titles: titles)
            customAction.tag = 252
        } else if TSCurrentUserInfo.share.accountManagerInfo?.getAnswerManager() ?? false {
            customAction = TSCustomActionsheetView(titles: [collectTitle, "选择_删除".localized])
            customAction.tag = 254
        } else {
            /// 普通人：收藏、举报
            customAction = TSCustomActionsheetView(titles: [collectTitle, reportTitle])
            customAction.tag = 253
        }
        customAction.delegate = self
        customAction.show()
    }
    /// 采纳按钮点击事件
    func didClickAgreeItem(toolBar: TSAnswerDetailToolBar) {
        guard let model = answerDetail else {
            return
        }
        /// 自己添加的回答是不能自己点击采纳的,就算是自己的问题下面的自己的回答也不行.
        if model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
            return
        }
        if model.isAdoption {
            return
        }
        guard let answerId = answerDetail?.id, let questionId = answerDetail?.questionId else {
            return
        }
        toolBar.isAgree = true
        // 采纳答案的网络请求
        TSQuoraNetworkManager.adoptAnswer(answerId, forQuestion: questionId) { (msg, status) in
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_采纳成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.answerDetail?.isAdoption = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeAnswerAgreeStatus"), object: nil, userInfo: ["answerId": "\(answerId)", "questionId": "\(questionId)", "status": "1"])
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                toolBar.isAgree = false
            }
        }
    }
}

// MARK: - TSCustomAcionSheetDelegate

/// 选择弹窗的回调处理
extension TSAnswerCommentController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        switch view.tag {
        // 发布者 更多弹窗
        case 251:
            fallthrough
        // 回答者 更多弹窗
        case 252:
            fallthrough
        // 普通人 更多弹窗
        case 253:
            fallthrough
        case 254:
            // 答案的更多选项弹窗，统一处理，根据title
            switch title {
            case "选择_删除".localized:
                self.showAnswerDeleteConfirmAlert()
            case "选择_采纳答案".localized:
                self.adoptAnswer()
            case "选择_收藏".localized:
                self.answerCollectOperate(.collect)
            case "选择_取消收藏".localized:
                self.answerCollectOperate(.uncollect)
            case "选择_编辑".localized:
                self.editAnswer()
            case "选择_举报".localized:
                self.reportAnswer()
            default:
                break
            }
        default:
            break
        }
    }

}

// 弹窗相关的扩展处理
extension TSAnswerCommentController {

    /// 答案删除的二次确认弹窗
    func showAnswerDeleteConfirmAlert() -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除回答") { [weak self] in
            self?.deleteAnswer()
        }
        self.present(alertVC, animated: false, completion: nil)
    }
    /// 答案删除
    func deleteAnswer() -> Void {
        let answerId = self.sourceId
        // 答案删除 请求
        /// 这里没有细化判断是不是被邀请人什么的。
        if TSCurrentUserInfo.share.accountManagerInfo?.getAnswerManager() ?? false {
            TSQuoraNetworkManager.managerDeleteAnswer(answerId) { (msg, status) in
                if status {
                    let alert = TSIndicatorWindowTop(state: .success, title: "删除成功!")
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        self.delegate?.didDeletedAnswer(answerId)
                        self.answerDeletedAction?(answerId)
                        NotificationCenter.default.post(name: NSNotification.Name.AnswerDeletedNotification, object: answerId)
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        } else {
            TSQuoraNetworkManager.deleteAnswer(answerId) { (msg, status) in
                if status {
                    let alert = TSIndicatorWindowTop(state: .success, title: "删除成功!")
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        self.delegate?.didDeletedAnswer(answerId)
                        self.answerDeletedAction?(answerId)
                        NotificationCenter.default.post(name: NSNotification.Name.AnswerDeletedNotification, object: answerId)
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        }
    }
    /// 答案编辑
    func editAnswer() -> Void {
        guard let answerDetail = self.answerDetail else {
            return
        }
        // 进入答案编辑页
        let answerEditVC = TSPublishAnswerController(answer: answerDetail)
        answerEditVC.editAnswerSuccessAction = { (newAnswer) in
            answerDetail.body = newAnswer
            self.headView.loadModel(answerDetail, complete: { (height) in
                self.headView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
                self.tableView.reloadData()
            })
        }
        self.navigationController?.pushViewController(answerEditVC, animated: true)
    }
    /// 采纳答案
    func adoptAnswer() -> Void {
        guard let answerId = self.answerDetail?.id, let questionId = self.answerDetail?.question?.id else {
            return
        }
        // 采纳答案的网络请求
        TSQuoraNetworkManager.adoptAnswer(answerId, forQuestion: questionId) { (msg, status) in
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_采纳成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.answerDetail?.isAdoption = true
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
    /// 答案 收藏/取消收藏
    func answerCollectOperate(_ collectOperate: TSCollectOperate) -> Void {
        let answerId = self.sourceId
        TSQuoraNetworkManager.answerCollectOperate(collectOperate, answerId: answerId) { (msg, status) in
            if status {
                self.answerDetail?.collected = collectOperate == .collect ? true : false
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
    /// 答案举报
    fileprivate func reportAnswer() -> Void {
        guard let answer = self.answerDetail else {
            return
        }
        let reportTarget = ReportTargetModel(answer: answer)
        let reportVC = ReportViewController(reportTarget: reportTarget)
        self.navigationController?.pushViewController(reportVC, animated: true)
    }
}
extension TSAnswerCommentController: ShareListViewDelegate {
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
        let repostModel = TSRepostModel.coverQuestionAnswerModel(questionAnswerModel: self.answerDetail!)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC)
        self.present(navigation, animated: true, completion: nil)
    }
}
