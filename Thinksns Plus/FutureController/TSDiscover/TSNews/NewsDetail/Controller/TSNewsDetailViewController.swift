//
//  TSNewsDetailViewController.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  资讯详情页

struct TSNewsCommentUX {
    /// 没有评论时 缺省视图的高度
    static let noCommentCellHeight: CGFloat = 80
    /// 导航栏高度
    static let systemNavigationBarHeight: CGFloat = 64
    /// 广告视图的高度
    static let adHeight: CGFloat = 80
    /// section间距的高度
    static let cellSpace: CGFloat = 5
}

/**
 * 注：资讯详情页暂时使用TSNewsCommentController代替，等测试测试完毕后再用TSNewsCommentController代替本页中的注释代码
 这样做，可以避免出现一些bug时，无从下手或者不好解决时，可以参照之前的代码。
 甚至出现短期解决麻烦的代码时，完全可以使用注释中的代码。因为注释中的代码是完全可用的，且评论部分也已被替换。
 **/
typealias TSNewsDetailViewController = TSNewsCommentController

/**

//  Remark: - 该页面需重构，对部分代码使用Extension方式进行分类整理
//  若需要优化该界面，可以参考TSContributedNewsDetailVC，使用TSNewsDetailView代替TSNewsDetailHeaderVC来展示资讯详情部分。TSNewsDetailView对资讯详情的展示进行了兼容。
//  注1：发送评论和删除评论的时候，需要更新评论高度数组。否则会发生各种奇怪的问题。
//  注2：当前页面可能发生的问题：
//          1. 发送评论后，评论上的section会展示异常，同时广告也展示异常，如果可以看到的话。稍微滑动后又恢复正常。
//          2. 删除评论后，上面的问题也会复现。另有：底部间距的问题，滑动列表距离底部总有一段距离，怎么上拉也无法恢复，需要下拉一段距离才能恢复。
//  注2的分析：1中的原因可能是因为section使用的view没有重用导致；2中的原因与底部工具栏有关系。

import UIKit
import WebKit

private let identifier = "commentCell"

class TSNewsDetailViewController: TSViewController, UITableViewDelegate, UITableViewDataSource, DetailHeaderViewControllerDelegate, TSDetailCommentTableViewCellDelegate, TSNewsNavigationBarDelegate, TSKeyboardToolbarDelegate, TSNewsDetailToolbarDelegate, TSCustomAcionSheetDelegate {
    /// 资讯数据
    var newsObject: NewsDetailModel?
    /// 资讯id
    var id: Int? = nil
    /// 头部控件
    var headerView: TSNewsDetailHeaderViewController?
    /// 自定义的导航栏
    let navigationBar: TSNewsNavigationBar = TSNewsNavigationBar()
    /// 状态栏背景
    let statusbarBGView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 20))
    /// 列表
    var tableView = UITableView()
    /// 工具栏 （收藏、评论、分享等）
    var commentToolBar: TSNewsDetailToolbarView? = nil
    /// 评论数
    var commentCount = 0
    /// 评论分页标记
    var maxID: Int = 0
    /// 评论数据的每一页数量
    let limit: Int = 15
    /// 相关资讯
    var newsCorrelative: [NewsModel] = []
    /// 广告信息
    var advert: [TSAdvertObject] = []
    /// 相关资讯视图
    var newsCorrelativeHeaderView = TSNewsDetailCommentCountsView()

    /** 评论的数据源 */
    /// 发送中的列表(无结果，默认展示再最前面)
    var sendingCommentList = [TSSimpleCommentModel]()
    /// 发送失败的列表(也可能来自数据库)
    var failedCommentList = [TSSimpleCommentModel]()
    /// 正常的评论列表(含置顶 + 非置顶)
    var normalCommentList = [TSSimpleCommentModel]()
    /// 评论数组 （设置后就计算每条评论的高度）
    /// 所有的评论列表
    var commentDataArray: [TSSimpleCommentModel] = []
    /// 每条评论的高度缓存
    var cellHightArray: [CGFloat] = []

    /// 当前要回复的评论
    var commentModel: TSSimpleCommentModel? = nil
    /// 当前回复的评论的位置
    var index: Int = -1
    /// 记录当前Y轴坐标
    private var yAxis: CGFloat = 0
    /// 偏移量
    private var lastOffsetY: CGFloat = 0
    
    init(newsId: Int) {
        self.id = newsId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loading()
        self.creatNavigationBar()
        self.creatTableView()
        self.tableView.mj_header.beginRefreshing()
    }

    // MARK: - UI
    func creatNavigationBar() {
        self.navigationBar.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: TSNewsCommentUX.systemNavigationBarHeight)
        self.navigationBar.layoutControls()
        self.navigationBar.delegate = self
        self.navigationBar.setTitle(title: "资讯详情")
        self.view.addSubview(self.navigationBar)

        statusbarBGView.backgroundColor = TSColor.main.white
        self.view.addSubview(statusbarBGView)
    }

    func creatTableView() {
        self.tableView.frame = CGRect(x: 0, y: self.navigationBar.frame.maxY - 20, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight)
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()

        self.tableView.mj_header = TSRefreshHeader(refreshingBlock: {
            self.refresh()
        })
        self.tableView.mj_footer = TSRefreshFooter(refreshingBlock: {
            self.loadMore()
        })
        self.tableView.mj_footer.isHidden = true

        self.tableView.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView)
        self.view.bringSubview(toFront: self.navigationBar)
        self.view.bringSubview(toFront: self.statusbarBGView)
    }

    /// 创建文章内容视图 markdownView
    func creatHaederView() {
        self.headerView = TSNewsDetailHeaderViewController(newsId: self.newsObject!.id)
        self.headerView?.delegate = self
    }

    func creatToolView() {
        self.commentToolBar = TSNewsDetailToolbarView(self.newsObject!)
        self.commentToolBar?.commentDelegate = self
        self.view.addSubview(self.commentToolBar!)
    }

    // MARK: - Delegate
    // MARK: DetailHeaderViewControllerDelegate
    func headerViewController(headrView view: UIView?, didFinishedLoadHtml successed: Bool) {
        if successed == false {
            self.loadFaild(type: .network)
            return
        }
        guard let view = view else {
            self.loadFaild(type: .network)
            return
        }
        self.endLoading()
        self.commentToolBar == nil ? self.creatToolView() : self.commentToolBar?.uploadData(data: self.newsObject!)
        self.tableView.tableHeaderView = view
    }

    // MARK: TSNewsNavigationBarDelegate
    func Back(navigaruionBar: TSNewsNavigationBar) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    // MARK: tableVieDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 暂时固定为3区
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // 广告
            return 1 // 多条广告也只显示在单行
        }
        if section == 1 { // 相关资讯
            return self.newsCorrelative.count
        }
        if section == 2 { // 评论
            if commentDataArray.isEmpty {
                return 1
            }
            return commentDataArray.count
        }
        assert(false, "出现了配置外的情况")
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { // 广告
            return TSNewsCommentUX.adHeight
        }
        if indexPath.section == 1 { // 相关资讯
            return TSNewsListCellUX.cellHeight
        }
        if indexPath.section == 2 { // 评论
            if self.commentDataArray.isEmpty {
                return TSNewsCommentUX.noCommentCellHeight + (UIImage(named: "IMG_img_default_nothing")?.size.height)!
            }
            return cellHightArray[indexPath.row]
        }
        assert(false, "数据源配置错误")
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { // 广告
            return nil
        }
        if section == 1 { // 相关资讯
            if newsCorrelative.isEmpty {
                return nil
            }
            let sectionHeaderView = TSNewsDetailCommentCountsView()
            var labelNames = [String]()
            for label in newsObject!.labels {
                labelNames.append(label.name)
            }
            sectionHeaderView.userInfoLabelDataSource = labelNames
            sectionHeaderView.uploadString("界面_相关资讯".localized)
            self.newsCorrelativeHeaderView = sectionHeaderView
            return sectionHeaderView
        }
        if section == 2 { // 评论
            if self.commentDataArray.isEmpty {
                return nil
            }
            let sectionHeaderView = TSNewsDetailCommentCountsView()
            sectionHeaderView.uploadCount(CommentCount: String(self.commentCount))
            return sectionHeaderView
        }
        assert(false, "数据源配置错误")
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { // 广告
            return CommentCountsViewUX.top
        }
        if section == 1 { // 相关资讯
            if self.newsCorrelative.isEmpty {
                return CommentCountsViewUX.top
            }
            if self.newsObject!.labels.isEmpty {
                return CommentCountsViewUX.viewHeight
            } else {
                var labelList = [String]()
                for label in self.newsObject!.labels {
                    labelList.append(label.name)
                }
                return CommentCountsViewUX.viewHeight + TSUserInfoLabel.heightWithData(labelList, layout: TSNewsDetailCommentCountsView().layout)
            }
        }
        if section == 2 { // 评论
            if self.commentDataArray.isEmpty {
                return CommentCountsViewUX.top
            }
            return CommentCountsViewUX.viewHeight
        }
        assert(false, "数据源配置错误")
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // 广告
            let identifier = "advertView"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            }

            let advertView = TSAdvertNormal(itemCount:  advert.count)
            advertView.set(models: advert.map { TSAdvertViewModel(object: $0) })
            advertView.frame = CGRect(x: 0, y: 0, width: cell!.contentView.frame.width, height: cell!.contentView.frame.height)
            cell!.contentView.addSubview(advertView)
            return cell!
        }
        if indexPath.section == 1 { // 相关资讯
            let identifier = "ListCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TSNewsListCell
            if cell == nil {
                cell = TSNewsListCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
            let model = newsCorrelative[indexPath.row]
            cell!.cellData = model
            let isRead = TSCurrentUserInfo.share.newsViewStatus.isContains(newsId: model.id)
            cell!.updateCellStyle(isSelected: isRead)
            return cell!
        }
        if indexPath.section == 2 { // 评论
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! TSDetailCommentTableViewCell
            cell.cellDelegate = self
            if !self.commentDataArray.isEmpty {
                cell.commnetModel = self.commentDataArray[indexPath.row]
                cell.detailCommentcellType = .normal
                cell.setDatas(width: tableView.bounds.size.width)
            } else {
                cell.detailCommentcellType = .nothing
                cell.setDatas(width: tableView.bounds.size.width)
            }
            return cell
        }
        assert(false, "数据源配置错误")
        return TSDetailCommentTableViewCell()
    }

    // MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // 广告
            // 广告视图自己携带了点击事件处理
        }
        if indexPath.section == 1 { // 相关资讯
            let newsModel = newsCorrelative[indexPath.row]
            let newsDetailVC = TSNewsDetailViewController(newsId: newsModel.id)
            TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsModel.id)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.navigationController?.pushViewController(newsDetailVC, animated: true)
        }
        if indexPath.section == 2 { // 评论
            let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell
            if !(cell?.nothingImageView.isHidden)! {
                return
            }

            let userId = self.commentDataArray[indexPath.row].userInfo?.userIdentity
            self.index = indexPath.row
            TSKeyboardToolbar.share.keyboarddisappear()
            if userId == (TSCurrentUserInfo.share.accountToken?.userIdentity)! {
                let customAction = TSCustomActionsheetView(titles: ["选择_申请评论置顶".localized, "选择_删除".localized])
                customAction.delegate = self
                customAction.show()
                return
            }

            self.commentModel = self.commentDataArray[indexPath.row]
            self.showKeyBoard(placeHolderText: "回复: \((self.commentModel?.userInfo?.name)!)", cell: cell)
        }
    }

    // MARK: scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var sectionHeight = CommentCountsViewUX.viewHeight
        if self.commentDataArray.isEmpty {
            sectionHeight = CommentCountsViewUX.top
        }

        if scrollView.contentOffset.y <= sectionHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= sectionHeight {
            scrollView.contentInset = UIEdgeInsets(top: -sectionHeight, left: 0, bottom: 0, right: 0)
        }

        let currentOffsetY = scrollView.contentOffset.y
        let direction = currentOffsetY - lastOffsetY
        let maxContentOffsetY = scrollView.contentSize.height - UIScreen.main.bounds.height
        if currentOffsetY < 0 || currentOffsetY >  maxContentOffsetY {
            return
        }

        lastOffsetY = currentOffsetY
        self.navigationBar.scrollowAnimation(direction)
        self.tableScrollowAnimation(direction)
        self.commentToolBar?.scrollowAnimation(direction)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let navTopY = -navigationBar.frame.height + 21
        let navseparateY = -navigationBar.frame.height / 2
        let navBottomY: CGFloat = 0
        let shouldHidden = navigationBar.frame.minY < navseparateY

        let shouldAnimation = (navigationBar.frame.minY < navBottomY && navigationBar.frame.minY > navTopY)
        if !shouldAnimation {
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            if shouldHidden {
                self.navigationBar.frame = CGRect(x: 0, y: navTopY, width: self.navigationBar.frame.width, height: self.navigationBar.frame.height)
                self.commentToolBar?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: (self.commentToolBar?.frame.width)!, height: (self.commentToolBar?.frame.height)!)
            } else {
                self.navigationBar.frame = CGRect(x: 0, y: navBottomY, width: self.navigationBar.frame.width, height: self.navigationBar.frame.height)
                self.commentToolBar?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - (self.commentToolBar?.frame.height)!, width: (self.commentToolBar?.frame.width)!, height: (self.commentToolBar?.frame.height)!)
            }
            self.tableView.frame = CGRect(x: 0, y: self.navigationBar.frame.maxY, width: self.tableView.frame.width, height: self.tableView.frame.height)
        })
    }

    // MARK: Refreshdelegate
    func refresh() {
        self.maxID = 0
        self.commentDataArray.removeAll()
        self.sendingCommentList.removeAll()
        self.failedCommentList.removeAll()
        self.normalCommentList.removeAll()
        self.maxID = 0
        // 获取本地失败的评论列表
        let faildComments = TSDatabaseManager().commentManager.getAllFailedComments(type: .news, sourceId: id!)
        self.failedCommentList = TSCommentHelper.convertToSimple(faildComments)
        self.commentDataArray += self.failedCommentList
        TSNewsTaskManager().refreshNewsData(newsID: id!, limit: self.limit) { [unowned self] (newsFullModel, _) in
            self.tableView.mj_header.endRefreshing()
            guard let newsFullModel = newsFullModel else {
                self.loadFaild(type: .network)
                return
            }

            self.newsObject = newsFullModel.newsDetail
            self.headerView == nil ? self.creatHaederView() : self.headerView?.loadContent()
            self.headerView?.newsDetailModel = newsFullModel.newsDetail

            self.normalCommentList = newsFullModel.comment
            self.commentDataArray += newsFullModel.comment
            self.commentCount = self.commentDataArray.count

            self.newsCorrelative = newsFullModel.newsCorrelative
            if newsFullModel.advert.count > 3 {
                self.advert = Array(newsFullModel.advert[0...2])
            } else {
                self.advert = newsFullModel.advert
            }

            if !self.commentDataArray.isEmpty {
                self.maxID = self.commentDataArray.last!.id
            }
            self.tableView.mj_footer.isHidden = self.commentDataArray.count >= self.limit ? false : true
            self.cellHightArray = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentDataArray, width: ScreenSize.ScreenWidth)
            self.tableView.mj_footer.resetNoMoreData()
            self.tableView.reloadData()
        }
    }

    func loadMore() {
        TSCommentTaskQueue.getCommentList(type: .news, sourceId: id!, groupId: nil, afterId: self.maxID, limit: self.limit) { (commentList, msg, status) in
            guard status, let commentList = commentList else {
                self.tableView.mj_footer.endRefreshing()
                TSLogCenter.log.debug(msg)
                return
            }
            if commentList.count > self.limit {
                self.tableView.mj_footer.endRefreshing()
            } else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self.commentDataArray = self.commentDataArray + commentList
            self.commentCount = self.commentDataArray.count
            if !self.commentDataArray.isEmpty {
                self.maxID = (self.commentDataArray.last?.id)!
            }
            self.cellHightArray = self.cellHightArray + TSDetailCommentTableViewCell().setCommentHeight(comments: commentList, width: ScreenSize.ScreenWidth)
            self.tableView.reloadData()
        }
    }

    // MARK: TSDetailCommentTableViewCellDelegate
    /// 发送失败的评论点击重发处理
    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: TSSimpleCommentModel) {
        // 获取修改处的数据
        let indexPath = self.tableView.indexPath(for: cell)
        let content = self.commentDataArray[indexPath!.row].content
        let failedModel = self.failedCommentList[indexPath!.row - self.sendingCommentList.count]
        // 从数据库中移除
        TSDatabaseManager().commentManager.deleteFaildComment(commentId: failedModel.id)
        // 从当前列表中移除
        self.failedCommentList.remove(at: indexPath!.row - self.sendingCommentList.count)
        self.commentDataArray.remove(at: indexPath!.row)
        // 重新发送
        self.keyboardToolbarSendTextMessage(message: content, inputBox: nil)
    }

    func didSelectName(userId: Int) {
        TSKeyboardToolbar.share.keyboarddisappear()
        let userHomPage = TSHomepageVC(userId)
        if let navigationController = navigationController {
            navigationController.pushViewController(userHomPage, animated: true)
        }
    }

    func didSelectHeader(userId: Int) {
        TSKeyboardToolbar.share.keyboarddisappear()
        let userHomPage = TSHomepageVC(userId)
        if let navigationController = navigationController {
            navigationController.pushViewController(userHomPage, animated: true)
        }
    }

    // MARK: TSDetailToolBarViewDelegate
    func didSelectedCommentButton(_ toolbar: TSNewsDetailToolbarView) {
        self.commentModel = nil
        self.showKeyBoard(placeHolderText: "占位符_评论".localized, cell: nil)
    }

    func didPressNewsApplyBtn(_ toolbar: TSNewsDetailToolbarView) {
        let applyTopVC = TSTopAppilicationManager.newsTopVC(newsId: newsObject!.id)
        _ = navigationController?.pushViewController(applyTopVC, animated: true)
    }

    // MARK: TSKeyboardToolbarDelegate
    /// 键盘发送评论
    func keyboardToolbarSendTextMessage(message: String, inputBox: AnyObject?) {
        guard let newsId = self.newsObject?.id else {
            return
        }
        // TODO: - 这里可以进行优化
        var replyUserId: Int?
        if self.commentModel != nil {
            replyUserId = self.commentModel?.userInfo?.userIdentity
        }
        // 默认展示，放置该数据到评论列表开头
        let sendingComment = TSSimpleCommentModel(content: message, replyUserId: replyUserId, status: 2)
        self.sendingCommentList.insert(sendingComment, at: 0)
        self.commentDataArray = self.sendingCommentList + self.failedCommentList + self.normalCommentList
        self.cellHightArray = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentDataArray, width: ScreenSize.ScreenWidth)
        // 更新VC数据(评论数)
        self.commentModel = nil
        self.commentCount += 1
        self.tableView.reloadData()

        TSCommentTaskQueue.submitComment(for: .news, content: message, sourceId: newsId, groupId: nil, replyUserId: replyUserId) { (successModel, faildModel, _, status) in
            // 关于是否需要这样做，待定。因为如果有置顶的，会导致发送成功后位置变更
            // 需要对sendingCommentList里进行移除，否则会对别的地方造成影响
            for (index, comment) in self.sendingCommentList.enumerated() {
                if comment.content == sendingComment.content && comment.createdAt == sendingComment.createdAt && comment.replyUserInfo?.userIdentity == sendingComment.replyUserInfo?.userIdentity {
                    self.sendingCommentList.remove(at: index)
                    break
                }
            }
            // 发送成功
            if let successModel = successModel {
                // 使用该评论代替之前的伪造评论
                self.normalCommentList.insert(successModel.simpleModel(), at: 0)
                self.commentDataArray = self.failedCommentList + self.normalCommentList
                self.cellHightArray = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentDataArray, width: ScreenSize.ScreenWidth)
                self.tableView.reloadData()
                return
            }
            // 发送失败
            if let failedModel = faildModel {
                // 发送失败的提示，待完成
                self.failedCommentList.insert(failedModel.simpleModel(), at: 0)
                self.commentDataArray = self.failedCommentList + self.normalCommentList
                self.cellHightArray = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentDataArray, width: ScreenSize.ScreenWidth)
                self.tableView.reloadData()
                return
            }
        }
    }

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

    func keyboardWillHide() {
        if tableView.contentOffset.y > tableView.contentSize.height - tableView.bounds.height {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.height), animated: true)
        }
    }

    // MARK: TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        guard let newsId = self.newsObject?.id else {
            return
        }
        let model = self.commentDataArray[self.index]
        // 判断操作选项
        if title == "选择_申请评论置顶".localized {
            let applyTopVC = TSTopAppilicationManager.newsCommentTopVC(newsId: newsId, commentId: model.id)
            navigationController?.pushViewController(applyTopVC, animated: true)
            return
        } else if title == "选择_删除".localized {
            /// 删除tableview数据
            self.commentDataArray.remove(at: self.index)
            /// 更新评论数
            self.commentCount -= 1
            if 2 == model.status {
                // 发送中的
                self.sendingCommentList.remove(at: self.index)
            } else if 1 == model.status {
                // 本地保存的发送失败的
                self.failedCommentList.remove(at: self.index - self.sendingCommentList.count)
                TSDatabaseManager().commentManager.deleteFaildComment(commentId: model.id)
            } else if 0 == model.status {
                // 发送成功的
                self.normalCommentList.remove(at: self.index - self.sendingCommentList.count - self.failedCommentList.count)
                TSCommentNetWorkManager.deleteComment(for: .news, commentId: model.id, sourceId: newsId, groupId: nil, complete: { (msg, status) in
                    if !status {
                        let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    }
                })
            }
            self.cellHightArray = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentDataArray, width: ScreenSize.ScreenWidth)
            self.tableView.reloadData()
        }
    }

    // MARK: loadingViewDelegate
    override func reloadingButtonTaped() {
        self.refresh()
    }

    // MARK: - private
    func tableScrollowAnimation(_ offset: CGFloat) {
        let minY: CGFloat = 0
        let maxY: CGFloat = 64
        let isAtMinY = tableView.frame.minY == minY
        let isAtMaxY = tableView.frame.maxY == maxY
        let isScrollowUp = offset > 0
        let isScrollowDown = offset < 0

        if (isScrollowUp && isAtMinY) || (isScrollowDown && isAtMaxY) {
            return
        }
        var tableY = tableView.frame.minY - offset
        if isScrollowUp && tableY < minY {
            tableY = minY
        }
        if isScrollowDown && tableY > maxY {
            tableY = maxY
        }
        tableView.frame = CGRect(x: 0, y: tableY, width: tableView.frame.width, height: tableView.frame.height)
    }

    /// 弹出回复键盘
    ///
    /// - Parameters:
    ///   - placeHolderText: 提示语句
    ///   - cell: cell （回复他人才有）
    func showKeyBoard(placeHolderText: String, cell: TSDetailCommentTableViewCell?) {
        if let cell = cell {
            let origin = cell.convert(cell.contentView.frame.origin, to: UIApplication.shared.keyWindow)
            yAxis = origin.y + cell.contentView.frame.size.height
        }
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeHolderText)
    }
}

*/
