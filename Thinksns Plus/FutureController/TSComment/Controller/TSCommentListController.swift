//
//  TSCommentListController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论列表控制器
//  注1：暂时都使用之前的评论视图和评论视图模型，等修改完毕后根据需要再使用新的评论视图和评论视图模型。
//  注2：评论列表需要的数据源方式，需要进行修正。因为评论列表总数：本地失败的 + 发送中的 + 正常的评论列表
/**
 评论的交互：
 1. 点击评论：自己的弹出操作选择视图、别人的则弹出回复视图、
 2. 长按评论：默认举报(暂不用弹出举报选择视图)，但如果是圈子中且是该圈子的管理员(含圈主)则弹出删除选择视图
 **/

/**
 关于基类设计的一些注意点：
 1. extension的设计
 2. protocol实现的位置
 3. 抽象类的设计
 
 **/

import UIKit

/// 评论列表的协议: 列表数据加载协议TSListDataLoadProtocol
protocol TSCommentListProtocol: class {
    /// 数据

    /// 构造时传入的数据
    var type: TSCommentType { get }
    var sourceId: Int { get }
    var groupId: Int? { get }

    /// 列表视图
    var tableView: TSTableView! { get set }

    /// 评论列表为空时的显示类型
    var emptyType: TSCommentEmptyShowType { get }

    /// 数据源列表
    var sourceList: [TSSimpleCommentModel] { get set }
    /// 高度数组
    var cellHeightList: [CGFloat] { get set }

    var limit: Int { get }

    /// 加载更多评论时的标记id
    var afterId: Int { get set }
    /// 评论总数，不同情况下的评论总数是不一样的，需要分别处理。暂使用评论列表总数
    var commentCount: Int { get set }
    /// 当前操作的评论序号
    var index: Int { get set }
    /// 当前操作的评论
    var commentModel: TSSimpleCommentModel? { get set }
    /// 弹出键盘时相关的偏移
    var yAxis: CGFloat { get set }

    /// 接口

    // 需要添加一个回调，这里的对数据源有修改的地方，都需要添加回调，以方便子类调用后可以修正部分本地的数据源，特别是评论总数。

    /// 删除评论
    /// 提交评论
    /// 编辑评论(含回复)
    /// 重发评论

    /// 评论Cell的操作响应

    /// 删除评论
    /// 选中评论

    /// 开始编辑评论

    /// 数据加载

    /// 键盘相关

}

extension TSCommentListProtocol {

    /// 相关的接口添加待完成

    /// 提交评论
    func submitComment(_ content: String, complete: (() -> Void)?) -> Void {}
    /// 删除评论
    func deleteComment(at index: Int, complete: (() -> Void)?) -> Void {}

    /// 开始编辑评论
    func startEditComment(replyComment: TSSimpleCommentModel?, with indexPath: IndexPath?) -> Void { }

    /// 选中评论
    func selectComment(at indexPath: IndexPath) -> Void { }

}

/// 评论列表数据为空时的展示类型
enum TSCommentEmptyShowType {
    /// 整个tableView展示空
    case tableView
    /// 展示一个空的cell
    case cell
}

class TSCommentListController: TSViewController, TSListDataLoadProtocol, TSCommentListProtocol, TSDetailCommentTableViewCellDelegate {

    // MARK: - Internal Property
    /// 是否隐藏header（评论数量），默认不隐藏
    var isHidenHeader = false
    /// 构造时传入的数据
    let type: TSCommentType
    let sourceId: Int
    let groupId: Int?

    /// 列表视图
    weak var tableView: TSTableView!
    /// 评论列表为空时的显示类型
    let emptyType: TSCommentEmptyShowType
    /// 数据源列表
    var sourceList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()
    /// 高度数组
    var cellHeightList: [CGFloat] = [CGFloat]()

    let cellIdentifier = "TSDetailCommentTableViewCellReuseIdentifier"
    let limit: Int = TSAppConfig.share.localInfo.limit

    /// 加载更多评论时的标记id
    var afterId: Int = 0
    /// 评论总数，不同情况下的评论总数是不一样的，需要分别处理。暂使用评论列表总数
    var commentCount: Int = 0
    /// 当前操作的评论序号
    var index: Int = 0
    /// 当前操作的评论
    var commentModel: TSSimpleCommentModel?
    /// 弹出键盘时相关的偏移
    var yAxis: CGFloat = 0

    /// 是否可以申请评论置顶(动态、资讯中自己的评论可以申请评论置顶)
    var couldTopComment: Bool = false

    // MARK: - Initialize Function

    init(type: TSCommentType, sourceId: Int, groupId: Int? = nil, emptyType: TSCommentEmptyShowType = .cell) {
        // 异常处理
        if type == .post && nil == groupId {
            fatalError("需要传入圈子id")
        }
        self.type = type
        self.sourceId = sourceId
        self.groupId = groupId
        self.emptyType = emptyType
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        TSKeyboardToolbar.share.keyboardstartNotice()
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }

    // MARK: - Delegate Function

    func requestData(_ type: TSListDataLoadType) -> Void {
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            // 请求列表页数据
            self.afterId = 0
            TSCommentTaskQueue.getCommentList(type: self.type, sourceId: self.sourceId, afterId: self.afterId, limit: self.limit, complete: { (commentList, _, status) in
                guard status, let commentList = commentList else {
                    switch type {
                    case .initial:
                        self.loadFaild(type: .network)
                    case .refresh:
                        self.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    return
                }
                switch type {
                case .initial:
                    self.endLoading()
                case .refresh:
                    self.tableView.mj_header.endRefreshing()
                case .loadmore:
                    break
                }
                // 注：别的地方重新加载列表时，调用下拉刷新操作，若将移除代码放置在请求前，可能导致崩溃，因数据被移除但另外那边正在重新加载列表。
                self.sourceList.removeAll()
                let faildList = TSDatabaseManager().commentManager.getAllFailedComments(type: self.type, sourceId: self.sourceId)
                self.sourceList += TSCommentHelper.convertToSimple(faildList)
                self.sourceList += commentList
                // 整个列表为空
                if self.sourceList.isEmpty && self.emptyType == .tableView {
                    self.tableView.show(placeholderView: .empty)
                } else {
                    self.tableView.removePlaceholderViews()
                }
                // 不同情况下的评论总数是不一样的，这里暂时这样处理
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.afterId = commentList.last?.id ?? 0
                self.tableView.mj_footer.isHidden = commentList.count != self.limit
                self.tableView.reloadData()
            })
        case .loadmore:
            // 加载更多评论
            TSCommentTaskQueue.getCommentList(type: self.type, sourceId: self.sourceId, afterId: self.afterId, limit: self.limit, complete: { (commentList, _, status) in
                self.tableView.mj_footer.endRefreshing()
                guard status, let commentList = commentList else {
                    return
                }
                // 数据加载处理
                self.sourceList += commentList
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.afterId = commentList.last?.id ?? self.afterId
                self.tableView.mj_footer.isHidden = commentList.count < self.limit
                self.tableView.reloadData()
            })
        }
    }

    // MARK: - TSDetailCommentTableViewCellDelegate - 评论cell的回调

    /// 点击重新发送按钮
    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: TSSimpleCommentModel) {
        // 获取修改处的数据
        let indexPath = self.tableView?.indexPath(for: cell)
        let content = commnetModel.content
        // 如果是重发“回复XXX”的评论，就创造一个当前正在处理的评论model
        if commnetModel.replyUser != nil {
            self.commentModel = TSSimpleCommentModel()
            self.commentModel?.userInfo = commnetModel.replyUserInfo
            self.commentModel?.content = content
        }
        // 从当前列表中移除
        self.sourceList.remove(at: indexPath!.row)
        // 从数据库中删除
        TSDatabaseManager().commentManager.deleteFaildComment(commentId: commnetModel.id)
        // 重新发送
        self.sendComment(content)
    }
    /// 点击了名字
    func didSelectName(userId: Int) {
        self.didSelectHeader(userId: userId)
    }
    /// 点击了头像
    func didSelectHeader(userId: Int) {
        let userHomPage = TSHomepageVC(userId)
        self.navigationController?.pushViewController(userHomPage, animated: true)
    }
    /// 长按了评论
    func didLongPressComment(in cell: TSDetailCommentTableViewCell, model: TSSimpleCommentModel) -> Void {
        let reportTarget = ReportTargetModel(comment: model, commentType: self.type, sourceId: self.sourceId, groupId: self.groupId)
        // 直接进入举报界面
        let reportVC = ReportViewController(reportTarget: reportTarget)
        self.navigationController?.pushViewController(reportVC, animated: true)
        // 显示举报评论弹窗
        //self.showCommentReportPopView(reportTarget: reportTarget)
    }

   override func reloadingButtonTaped() {
        self.requestData(.initial)
    }
}

// MARK: - UI布局

extension TSCommentListController {
    /// UI布局初始化
    /// 子类可重写该方法修改布局，或者对tableView进行修正完善
    func initialUI() -> Void {
        self.navigationItem.title = "评论列表"
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
    }
}

// MARK: - 数据处理与加载

extension TSCommentListController {
    /// 数据源初始化
    func initialDataSource() -> Void {
        self.requestData(.initial)
    }
    /// 上拉加载更多
    func loadMore() -> Void {
        self.requestData(.loadmore)
    }
    /// 下拉刷新
    func refresh() -> Void {
        self.requestData(.refresh)
    }

}

// Mark: - 评论操作相关扩展

extension TSCommentListController {
    /// 发送评论
    func sendComment(_ content: String) -> Void {
        let replyId: Int? = self.commentModel?.userInfo?.userIdentity
        TSCommentTaskQueue.submitComment(for: self.type, content: content, sourceId: self.sourceId, replyUserId: replyId) { (successModel, faildModel, msg, _) in
            // 发送成功
            if let successModel = successModel {
                // 修改当前页展示的评论数，
                self.commentCount += 1
                if self.sourceList.isEmpty && self.emptyType == .tableView {
                    self.tableView.removePlaceholderViews()
                }
                self.commentModel = nil
                self.sourceList.insert(successModel.simpleModel(), at: 0)
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.tableView?.reloadData()
                return
            }
            // 发送失败
            if let faildModel = faildModel {
                // 发送失败的提示
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.commentCount += 1
                if self.sourceList.isEmpty && self.emptyType == .tableView {
                    self.tableView.removePlaceholderViews()
                }
                self.sourceList.insert(faildModel.simpleModel(), at: 0)
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.tableView?.reloadData()
                return
            }
        }
    }

    /// 评论删除弹窗 - 用于二次弹窗确认
    func showCommentDeleteConfirmAlert(commentIndex: Int) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除评论") {
            self.deleteComment(at: commentIndex)
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 删除评论
    func deleteComment(at index: Int) -> Void {
        // 移除列表中当前待删除的选项
        let model = self.sourceList.remove(at: self.index)
        self.commentCount -= 1
        self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
        self.tableView.reloadData()
        self.deleteComment(model)
    }
    func deleteComment(_ comment: TSSimpleCommentModel) -> Void {
        let model = comment
        // 根据model的状态分别处理
        if 2 == model.status {
            // 发送中的
        } else if 1 == model.status {
            // 本地保存的发送失败的，从数据库中移除
            TSDatabaseManager().commentManager.deleteFaildComment(commentId: model.id)
        } else if 0 == model.status {
            // 发送成功的
            TSCommentNetWorkManager.deleteComment(for: self.type, commentId: model.id, sourceId: self.sourceId, complete: { (msg, status) in
                if !status {
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
    }

    /// 编写评论
    func writeComment(replyComment: TSSimpleCommentModel?, cell: TSDetailCommentTableViewCell?) -> Void {
        if let replyComment = replyComment {
            self.commentModel = replyComment
            self.showKeyBoard(placeHolderText: "回复: \((replyComment.userInfo?.name)!)", cell: cell)
        } else {
            self.commentModel = nil
            self.showKeyBoard(placeHolderText: "显示_说点什么吧".localized, cell: nil)
        }
    }

    /// 去评论置顶申请页r
    func gotoCommentTopApplicationPage(commentId: Int) -> Void {
        switch self.type {
        case .momment:
            // 动态评论置顶申请页
            let topVC = TSTopAppilicationManager.commentTopVC(comment: commentId, feed: self.sourceId)
            self.navigationController?.pushViewController(topVC, animated: true)
        case .news:
            // 资讯评论置顶申请页
            let applyTopVC = TSTopAppilicationManager.newsCommentTopVC(newsId: self.sourceId, commentId: commentId)
            self.navigationController?.pushViewController(applyTopVC, animated: true)
        case .post:
            // 帖子评论置顶申请
            let applyTopVC = TSTopAppilicationManager.postCommentTopVC(commentId: commentId)
            self.navigationController?.pushViewController(applyTopVC, animated: true)
        default:
            break
        }
    }
}

extension TSCommentListController {
    /// 评论举报弹窗
    fileprivate func showCommentReportPopView(reportTarget: ReportTargetModel) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_举报".localized, style: .default, handler: { (action) in
            let reportVC = ReportViewController(reportTarget: reportTarget)
            self.navigationController?.pushViewController(reportVC, animated: true)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
}
// MARK: - 评论键盘弹窗扩展

extension TSCommentListController {
    /// 弹出回复键盘
    ///
    /// - Parameters:
    ///   - placeHolderText: 提示语句
    ///   - cell: cell （回复他人才有）
    /// - Note:
    ///     调用该方法之前应设置当前的评论模型，没有则设置为nil。实际发送评论时需要使用该模型。
    func showKeyBoard(placeHolderText: String, cell: TSDetailCommentTableViewCell?) {
        if let cell = cell {
            let origin = cell.convert(cell.contentView.frame.origin, to: UIApplication.shared.keyWindow)
            self.yAxis = origin.y + cell.contentView.frame.size.height
        }
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeHolderText)
    }
}

// MARK: - UITableViewDataSource

extension TSCommentListController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = self.sourceList.count
        self.navigationItem.title = "评论(\(count))"
        if self.sourceList.isEmpty {
            count = (self.emptyType == TSCommentEmptyShowType.tableView) ? 0 : 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if self.sourceList.isEmpty {
            let cell = TSCommentEmptyCell.cellInTableView(tableView)
            return cell
        }

        // 新版Cell
//        let cell = TSDetailCommentCell.cellInTableView(tableView)
//        cell.simpleModel = self.sourceList[indexPath.row]
//        //cell.delegate = self
//        cell.indexPath = indexPath
//        return cell

        // 旧版Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as! TSDetailCommentTableViewCell
        cell.commnetModel = self.sourceList[indexPath.row]
        cell.detailCommentcellType = .normal
        cell.setDatas(width: ScreenWidth)
        cell.cellDelegate = self
        cell.indexPath = indexPath
        return cell

        //        if indexPath.section == 0 {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier_Intro) as! TSMusicCommentIntroCell
        //            if let introModel = self.introModel {
        //                cell.reloadData(title: introModel.title!, testCount: introModel.listenedCount, strogeID: introModel.strogeId!)
        //            }
        //            return cell
        //        }
        //        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier_comment) as! TSDetailCommentTableViewCell
        //        cell.cellDelegate = self
        //        if !self.commentArray.isEmpty {
        //            cell.commnetModel = self.commentArray[indexPath.row]
        //            cell.detailCommentcellType = .normal
        //            cell.setDatas(width: tableView.bounds.size.width)
        //        } else {
        //            cell.detailCommentcellType = .nothing
        //            cell.setDatas(width: tableView.bounds.size.width)
        //        }
        //        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sourceList.isEmpty || self.isHidenHeader {
            return nil
        }
        let headerView = TSCommentHeaderView.headerInTableView(tableView)
        headerView.commentCount = self.commentCount
        return headerView
    }

}

// MARK: - UITableViewDelegate

extension TSCommentListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.sourceList.isEmpty {
            return TSCommentEmptyCell.cellHeight
        }
        return self.cellHeightList[indexPath.row]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerH: CGFloat = self.sourceList.isEmpty || self.isHidenHeader ? 0.01 : TSCommentHeaderView.headerHeight
        return headerH
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.sourceList.isEmpty {
            return
        }

        let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell
        if !(cell?.nothingImageView.isHidden)! {
            return
        }
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        let comment = self.sourceList[indexPath.row]
        TSKeyboardToolbar.share.keyboarddisappear()
        if let commentUserId = comment.userInfo?.userIdentity, let userId = TSCurrentUserInfo.share.userInfo?.userIdentity, userId == commentUserId {
            // 自己的评论，则弹出删除选项
            self.index = indexPath.row
            let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
            alertVC.addAction(TSAlertAction(title: "选择_删除".localized, style: .default, handler: { (_) in
                self.showCommentDeleteConfirmAlert(commentIndex: self.index)
            }))
            // 评论申请置顶
            if self.couldTopComment {
                alertVC.addAction(TSAlertAction(title: "选择_申请评论置顶".localized, style: .default, handler: { (_) in
                    self.gotoCommentTopApplicationPage(commentId: comment.id)
                }))
            }
            // 注：该操作需要使用主线程，否则可能导致弹窗间隔，即弹窗一次下次又没有弹窗，需要点击别的地方才会触发上次的弹窗.
            DispatchQueue.main.async(execute: {
                self.present(alertVC, animated: false, completion: nil)
            })
            return
        }
        self.writeComment(replyComment: self.sourceList[indexPath.row], cell: cell)
    }
}

// MARK: - TSKeyboardToolbarDelegate

/// 自定义键盘输入框
extension TSCommentListController: TSKeyboardToolbarDelegate {
    /// 回传字符串和响应对象
    func keyboardToolbarSendTextMessage(message: String, inputBox: AnyObject?) {
        self.view.endEditing(true)
        self.sendComment(message)
    }

    /// 回传键盘工具栏的Frame
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        let toScrollValue = frame.origin.y - yAxis
        if  frame.origin.y > yAxis && self.tableView.contentOffset.y < toScrollValue {
            return
        }

        if Int(frame.origin.y) == Int(yAxis) {
            return
        }

        switch type {
        case .popUp, .typing:
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y - toScrollValue), animated: false)
            yAxis = frame.origin.y
        default:
            break
        }
    }

    /// 键盘准备收起
    func keyboardWillHide() {

    }

}
