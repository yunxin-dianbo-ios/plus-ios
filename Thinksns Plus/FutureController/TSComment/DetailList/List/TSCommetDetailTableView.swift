//
//  TSCommetDetailTableView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  评论详情

import UIKit
import SnapKit

class TSCommetDetailTableView: TSMomentDetailVC, UITableViewDataSource, TSDetailCommentTableViewCellDelegate {

    /// 当前滚动位置
    private var currentScrollOffSet: CGFloat = 0
    /// 记录当前Y轴坐标
    private var yAxis: CGFloat = 0
    /// cell的高度
    private var cellHeight: [CGFloat]!
    /// 是否点击更多
    private var isTapMore = false
    /// 没有数据的高度
    private let nothingHeight: CGFloat = 80
    /// 点击的行数
    private var index = 0
    /// 当前回复的评论模型
    private var commentModel: TSSimpleCommentModel?
    /// 发送类型
    private var sendCommentType: SendCommentType = .send
    /// 是否是键盘导致的上拉加载
    private var isScroll = true
    /// 从数据库获取最大的数量
    let maxLoadDB = TSAppConfig.share.localInfo.limit
    /// 展示底部视图的数量
    let showFootDataCount = TSAppConfig.share.localInfo.limit
    /// 发送的评论内容
    var sendText: String?
    /// 重新请求的id
    var requestId: Int!
    /// 支付信息 直接进入到动态详情就需要弹窗提示付费
    fileprivate var payInfo: PaidInfo?
    /// 数据
    private var commentDatas: [TSSimpleCommentModel] = [TSSimpleCommentModel]() {
        didSet {
            cellHeight = TSDetailCommentTableViewCell().setCommentHeight(comments: commentDatas, width: super.table.bounds.size.width)
            super.table.reloadData()
        }
    }

    // MARK: - Lifecycle
    /// 初始化方法
    ///
    /// - Parameter commnetObject: 评论的对象
    init(model: TSMomentListCellModel, isTapMore: Bool) {
        super.init(model)
        self.isTapMore = isTapMore
        self.requestId = model.data?.feedIdentity
        self.setUI()
        self.addNotification()
    }

    /// 初始化方法2
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    init(feedId: Int, isTapMore: Bool = false) {
        super.init()
        self.isTapMore = isTapMore
        self.requestId = feedId
        self.setUI()
    }

    func showPayAlert(paidInfo: PaidInfo) {
        PaidManager.showFeedPaidTextAlertCallBack(feedId: self.requestId, paidInfo: paidInfo, complete: { (payStatus, content) in
            if payStatus == 0 {
                self.payInfo = nil
                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "购买内容失败")
                self.navigationController?.popViewController(animated: true)
            } else if payStatus == 1 {
                self.payInfo = nil
                TSIndicatorWindowTop.showDefaultTime(state: .success, title: "成功购买内容")
                /// 刷新该页面数据
                self.loading()
                self.refresh()
            } else {
                // 取消或者其他异常
                self.endLoading()
                self.payInfo = nil
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let payInfo = self.payInfo {
            self.showPayAlert(paidInfo: payInfo)
        }
    }

    func requestSuperData() {
        super.getDiggData { [weak self] (isSuccess, momentIsDeleted) in
            if momentIsDeleted {
                self?.loadFaild(type: .delete)
                return
            }
            if isSuccess {
                return
            }
            self?.loadFaild(type: .network)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CommentChange.change, object: self)
    }

    /// 设置通知
    override func addNotification() {
        super.addNotification()
        /// 检测评论更改情况
        NotificationCenter.default.addObserver(self, selector: #selector(changeComment(_:)), name: NSNotification.Name.CommentChange.change, object: nil)
    }

    // MARK: - 其他类修改了评论数据的通知（如果是自己发的就算了）
    func changeComment(_ noti: Notification) {
        let vc = noti.object
        let model = (noti.userInfo!["data"] as? TSMomentListCellModel)!
        if vc is TSCommetDetailTableView {
           return
        }

        super.model = model
        self.commentDatas = model.comments ?? self.commentDatas
        self.table.reloadData()
    }

    // MARK: - setData
    func setTableData() {
        if commentDatas.isEmpty {
            // 显示一行没有数据的
            return
        }
    }

    // MARK: - setUI
    /// 设置UI
    func setUI() {
        super.table.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        super.table.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        super.table.mj_footer.isHidden = true
        super.table.dataSource = self
        super.table.separatorStyle = .none
        super.table.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    // MARK: - refresh
    func refresh() {
        /// 更新动态数据
        self.requestMomentData(feedId: requestId, complete: {(cellModel, resposeInfo, code) in
            if let code = code, code == 404 {
                /// 404 动态已经删除
                self.loadFaild(type: .delete)
                return
            }
            guard let cellModel = cellModel else {
                if code == 403 {
                    // 没有付费
                    if let resposeInfo = resposeInfo as? Dictionary<String, Any>, let messsage = resposeInfo["message"] as? String {
                        TSIndicatorWindowTop.showDefaultTime(state: .faild, title: messsage)
                        self.endLoading()
                        /// 购买流程
                        let paidInfo = PaidInfo()
                        paidInfo.type = .text
                        paidInfo.node = resposeInfo["paid_node"] as! Int
                        paidInfo.price = resposeInfo["amount"] as! Double
                        self.payInfo = paidInfo
                        self.showPayAlert(paidInfo: self.payInfo!)
                    } else {
                        TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "无权限访问该内容")
                        self.loadFaild(type: .delete)
                    }
                } else {
                    self.loadFaild(type: .network)
                }
                return
            }
            if let userInfo = cellModel.userInfo {
                TSTaskQueueTool.getAndSave(userIds: [userInfo.userIdentity]) { [weak self] (datas, _, _) in
                    guard let datas = datas, let data = datas.first else {
                        return
                    }
                    self?.navView.update(model: data)
                }
            }
            self.setModel(model: cellModel)
            self.requestSuperData()
            self.addNotification()
            self.getCommentList()
            self.table.reloadData()
        })

    }
    /// 获取第一页评论列表数据
    func getCommentList() {
        TSDataQueueManager.share.comment.getCommentDatas(momentListObject: model!.data!, maxId: nil, complete: {[weak self] commentModel in
            guard let weak = self else {
                return
            }
            if commentModel == nil {
                weak.loadFaild(type: .network)
                weak.table.mj_header.endRefreshing()
                return
            }

            if (commentModel?.isEmpty)! {
                weak.commentDatas.removeAll()
            }
            if let datas = commentModel {
                weak.commentDatas = datas
                weak.model!.comments = datas
                weak.table.mj_header.endRefreshing()
                weak.table.mj_footer.endRefreshing()
                if weak.isTapMore {
                    weak.isTapMore = false
                    weak.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
            weak.endLoading()
        })
    }
    // 加载更多评论
    func loadMore() {
        let maxId = self.commentDatas.last?.id
        TSDataQueueManager.share.comment.getCommentDatas(momentListObject: model!.data!, maxId: maxId, complete: {[weak self] commentModel in
            guard let weak = self else {
                return
            }
            if commentModel == nil {
                weak.table.mj_footer.endRefreshingWithWeakNetwork()
                return
            }

            if (commentModel?.isEmpty)! {
                /// 显示没有数据
                weak.table.mj_footer.endRefreshingWithNoMoreData()
                return
            }

            if let datas = commentModel {
                weak.commentDatas = weak.commentDatas + datas
                weak.model!.comments = weak.model!.comments! + datas
                weak.table.mj_footer.endRefreshing()
            }
        })
        super.table.mj_footer.endRefreshing()
    }
    /// MARK: - tapNavigationNotNetwork
    override func reloadingButtonTaped() {
        refresh()
    }

    // MARK: - delegateDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.table.mj_footer != nil {
            self.table.mj_footer.isHidden = self.commentDatas.count < self.showFootDataCount
        }

        if commentDatas.isEmpty {
            return 1
        }

        return commentDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TSDetailCommentTableViewCell
        cell?.cellDelegate = self
        if !self.commentDatas.isEmpty {
            cell?.commnetModel = self.commentDatas[indexPath.row]
            cell?.detailCommentcellType = .normal
            cell?.setDatas(width: tableView.bounds.size.width)
        } else {
            cell?.detailCommentcellType = .nothing
            cell?.setDatas(width: tableView.bounds.size.width)
        }
        cell?.layer.removeFromSuperlayer()
        return cell!
    }

    // MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell
        if !(cell?.nothingImageView.isHidden)! {
            return
        }

        let userId = self.commentDatas[indexPath.row].userInfo?.userIdentity
        self.index = indexPath.row
        TSKeyboardToolbar.share.keyboarddisappear()
        if userId == (TSCurrentUserInfo.share.userInfo?.userIdentity)! {
            let customAction = TSCustomActionsheetView(titles: ["申请评论置顶", "选择_删除".localized])
            customAction.delegate = self
            customAction.tag = 250
            customAction.show()
            return
        }

        self.sendCommentType = .replySend
        self.commentModel = self.commentDatas[indexPath.row]
        isScroll = false
        setTSKeyboard(placeholderText: "回复: \((self.commentModel?.userInfo?.name)!)", cell: cell)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.commentDatas.isEmpty {
            return nothingHeight + (UIImage(named: "IMG_img_default_nothing")?.size.height)!
        }
        return cellHeight[indexPath.row]
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentScrollOffSet = scrollView.contentOffset.y
        if isScroll {
           super.scrollViewDidScroll(scrollView)
        }
    }

    // MARK: - TSCustomActionsheetViewDelegate
    override func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        // 当前页 - 评论选项处理(评论置顶、评论删除)
        if view.tag == 250 {
            guard let model = self.model else {
                return
            }
            if title == "申请评论置顶" {
                let commentId = model.comments![self.index].id
                let feedId = model.data!.feedIdentity
                let vc = TSTopAppilicationManager.commentTopVC(comment: commentId, feed: feedId)
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            if title == "选择_删除".localized {
                self.showCommentDeleteConfirmAlert()
                return
            }
        } else {
            /// 工具栏的“更多”按钮弹出视图 （父类持有）
            super.returnSelectTitle(view: view, title: title, index: index)
        }
    }

    /// 显示删除评论的二次确认弹窗
    fileprivate func showCommentDeleteConfirmAlert() -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除评论") {
            self.deleteComment()
        }
        self.present(alertVC, animated: false, completion: nil)
    }
    /// 删除评论
    fileprivate func deleteComment() -> Void {
        let momentModel = TSDataQueueManager.share.comment.deleteComment(cellModel: super.model!, commentModel: self.commentDatas[self.index])
        self.commentDatas = momentModel.comments!
        super.model!.comments = momentModel.comments
        NotificationCenter.default.post(name: NSNotification.Name.CommentChange.change, object: self, userInfo: ["data": momentModel])
        self.commentCount -= 1
    }

    // MARK: - cellDelegate
    /// 点击了名字
    ///
    /// - Parameter userId: 用户Id
    func didSelectName(userId: Int) {
        let userHomPage = TSHomepageVC(userId)
        navigationController?.pushViewController(userHomPage, animated: true)
    }

    /// 点击了头像
    ///
    /// - Parameter userId: 用户Id
    func didSelectHeader(userId: Int) {
        let userHomPage = TSHomepageVC(userId)
        navigationController?.pushViewController(userHomPage, animated: true)
    }

    /// 点击重新发送按钮
    ///
    /// - Parameter commnetModel: 数据模型
    internal func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: TSSimpleCommentModel) {
        let indexPath = self.table.indexPath(for: cell)

        let newCommentData = TSDataQueueManager.share.comment.send(cellModel: super.model!, commentModel: commnetModel, message: commnetModel.content, type: .reSend, complete: { model in
            self.commentDatas = model.comments ?? self.commentDatas
            super.model!.comments = model.comments
            self.table.reloadRows(at: [indexPath!], with: .none)
            NotificationCenter.default.post(name: NSNotification.Name.CommentChange.change, object: self, userInfo: ["data": model])
        })
        self.commentDatas = newCommentData.comments ?? self.commentDatas
        super.model!.comments = newCommentData.comments
        self.table.reloadRows(at: [indexPath!], with: .none)
        NotificationCenter.default.post(name: NSNotification.Name.CommentChange.change, object: self, userInfo: ["data": newCommentData])
    }

    /// 长按了评论
    func didLongPressComment(in cell: TSDetailCommentTableViewCell, model: TSSimpleCommentModel) -> Void {
        // 显示举报评论弹窗
        guard self.requestId != nil else {
            return
        }
        let reportTarget = ReportTargetModel(comment: model, commentType: .momment, sourceId: self.requestId, groupId: nil)
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_举报".localized, style: .default, handler: { (action) in
            let reportVC = ReportViewController(reportTarget: reportTarget)
            self.navigationController?.pushViewController(reportVC, animated: true)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }

    // MARK: TSMomentDetailToolbarDelegate
    /// 点击了评论按钮
    override func toolbarDidSelectedCommentButton(_ toolbar: TSMomentDetailToolbar) {
        self.commentModel = nil
        self.sendCommentType = .send
        super.toolbarDidSelectedCommentButton(toolbar)
        setTSKeyboard(placeholderText: "随便说说~", cell: nil)
    }

    // MARK: - Other
    /// 设置键盘
    ///
    /// - Parameters:
    ///   - placeholderText: 占位字符串
    ///   - cell: cell
    private func setTSKeyboard(placeholderText: String, cell: TSDetailCommentTableViewCell?) {
        if let cell = cell {
            let origin = cell.convert(cell.contentView.frame.origin, to: UIApplication.shared.keyWindow)
            yAxis = origin.y + cell.contentView.frame.size.height
        }
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
    }

    // MARK: - 键盘相关代理
    /// 回传字符串和响应对象
    ///
    /// - Parameter message: 回传的String
    override func keyboardToolbarSendTextMessage(message: String, inputBox: AnyObject?) {
        // 评论完成后合成模型，存入数据库，后台请求发送接口，然后存入当前的TableView 刷新列表
        if message == "" {
            return
        }
        sendText = message
        isScroll = false
        let newCommentData = TSCommentTaskQueue().send(cellModel: super.model!, commentModel: self.commentModel, message: message, type: self.sendCommentType, complete: { model in
            self.commentDatas = model.comments!
            super.model!.comments = model.comments
            NotificationCenter.default.post(name: NSNotification.Name.CommentChange.change, object: self, userInfo: ["data": model])
        })
        self.commentDatas = newCommentData.comments!
        super.model!.comments = newCommentData.comments
        self.commentCount += 1
        NotificationCenter.default.post(name: NSNotification.Name.CommentChange.change, object: self, userInfo: ["data": newCommentData])
    }

    /// 回传键盘工具栏的Frame
    ///
    /// - Parameter frame: 坐标和尺寸
    /// 回传键盘工具栏的Frame
    ///
    /// - Parameter frame: 坐标和尺寸
    internal override func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        if yAxis == 0 {
            return
        }
        let toScrollValue = frame.origin.y - yAxis
        if  frame.origin.y > yAxis && self.table.contentOffset.y < toScrollValue {
            return
        }

        if Int(frame.origin.y) == Int(yAxis) {
            return
        }

        switch type {
        case .popUp, .typing:
            self.table.setContentOffset(CGPoint(x: 0, y: self.table.contentOffset.y - toScrollValue), animated: false)
            yAxis = frame.origin.y
        default:
            break
        }
    }

    override func keyboardWillHide() {
        if sendText != nil {
            sendText = nil
            self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            isScroll = true
            return
        } else {
            isScroll = true
        }

        if self.table.contentOffset.y > self.table.contentSize.height - self.table.bounds.height {
            if self.table.contentSize.height < self.table.bounds.size.height {
                self.table.setContentOffset(CGPoint.zero, animated: true)
                return
            }
            self.table.setContentOffset(CGPoint(x: 0, y: self.table.contentSize.height - self.table.bounds.height), animated: true)
        }
    }

    // MARK: - requestMomentData
    /// 请求一次数据
    private func requestMomentData(feedId: Int, complete: @escaping (TSMomentListCellModel?, Any?, Int?) -> Void) {
        TSMomentNetworkManager.getOneMoment(feedId: feedId, complete: { (momentObject, error, resposeInfo, code) in
            if momentObject == nil && error == nil {
                complete(nil, resposeInfo, code)
            }
            guard let momentObject = momentObject else {
                 complete(nil, resposeInfo, code)
                return
            }
            var cellModel = TSMomentListCellModel()
            cellModel.data = momentObject
            cellModel.comments = []
            if let reward = momentObject.reward {
                self.headerView?.rewardCount = reward
            }
            cellModel.userInfo = TSDatabaseManager().user.get(infoFrom: [momentObject.userIdentity]).first
            if cellModel.userInfo == nil {
                self.requestUserInfo(userId: momentObject.userIdentity, complete: { (userInfo, status) in
                    if status == true {
                        cellModel.userInfo = userInfo
                        complete(cellModel, resposeInfo, code)
                    } else {
                        complete(nil, NSError(), 200)
                    }
                })
            } else {
                complete(cellModel, resposeInfo, code)
            }
        })
    }
    // 获取用户信息更新关注按钮状态
    func requestUserInfo(userId: Int, complete: @escaping (TSUserInfoObject?, Bool) -> Void) {
        TSTaskQueueTool.getAndSave(userIds: [userId]) { (datas, _, _) in
            guard let datas = datas, let data = datas.first, data.userIdentity > 0 else {
                return
            }
            if let userInfo = TSDatabaseManager().user.get(infoFrom: [userId]).first {
                complete(userInfo, true)
            } else {
                complete(nil, true)
            }
        }
    }
}
