//
//  TSNewsCommentController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 13/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯评论列表

import UIKit

class TSNewsCommentController: TSCommentListController {
    // MARK: - Internal Property
    let newsId: Int

    // MARK: - Internal Function

    // MARK: - Private Property

    /// 资讯数据
    var newsDetail: NewsDetailModel?

    /// 自定义的导航栏
    let navigationBar: TSNewsNavigationBar = TSNewsNavigationBar()
    /// 状态栏背景
    let statusbarBGView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: TSStatusBarHeight))

    /// 头部控件
    //fileprivate weak var headerView: TSNewsDetailView!
    var headerView: TSNewsDetailHeaderViewController?

    /// 工具栏 （收藏、评论、分享等），该视图的创建必须要资讯详情模型，因此可能并不存在，根据需要进行创建
    fileprivate var commentToolBar: TSNewsDetailToolbarView?

    /// 相关资讯
    var newsCorrelative: [NewsModel] = []
    /// 广告信息
    var advert: [TSAdvertObject] = []
    /// 相关资讯视图
    var newsCorrelativeHeaderView = TSNewsDetailCommentCountsView()

    /// 偏移量
    fileprivate var lastOffsetY: CGFloat = 0
    /// 分享的图片
    var shareImage: UIImage?

    // MARK: - Initialize Function

    init(newsId: Int) {
        self.newsId = newsId
        super.init(type: .news, sourceId: newsId)
        // 资讯评论可以申请置顶
        self.couldTopComment = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(updataFollowStatus(notice:)), name: NSNotification.Name(rawValue: "newChangeFollowSrarus"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Override Function

    /// 请求数据
    override func requestData(_ type: TSListDataLoadType) -> Void {
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            // 请求详情页数据
            self.afterId = 0
            TSNewsTaskManager().refreshNewsData(newsID: self.newsId, limit: self.limit, complete: { [weak self](newsFullModel, _, code) in
                guard let WeakSelf = self else {
                    return
                }
                if code == 404 {
                    self?.loadFaild(type: .delete)
                    return
                }
                guard let newsFullModel = newsFullModel else {
                    switch type {
                    case .initial:
                        self?.loadFaild(type: .network)
                    case .refresh:
                        self?.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    return
                }
                self?.newsDetail = newsFullModel.newsDetail

                self?.newsCorrelative = newsFullModel.newsCorrelative
                if newsFullModel.advert.count > 3 {
                    self?.advert = Array(newsFullModel.advert[0...2])
                } else {
                    self?.advert = newsFullModel.advert
                }

                self?.sourceList.removeAll()
                let faildList = TSDatabaseManager().commentManager.getAllFailedComments(type: WeakSelf.type, sourceId: WeakSelf.sourceId)
                self?.sourceList += TSCommentHelper.convertToSimple(faildList)
                self?.sourceList += newsFullModel.comment
                self?.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: WeakSelf.sourceList, width: ScreenWidth)
                self?.afterId = newsFullModel.comment.last?.id ?? 0
                self?.tableView.mj_footer.isHidden = newsFullModel.comment.count != self?.limit
                self?.commentCount = newsFullModel.newsDetail.commentCount

                // 加载markdown视图
                if nil == self?.headerView {
                    self?.creatHaederView()
                }
                self?.headerView?.newsDetailModel = newsFullModel.newsDetail
                self?.setShareImage()

            })
        case .loadmore:
            // 加载更多评论
            super.requestData(.loadmore)
        }
    }

    // MARK: - private
    func tableScrollowAnimation(_ offset: CGFloat) {
        let minY: CGFloat = 0
        let maxY: CGFloat = TSNavigationBarHeight
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
        TSLogCenter.log.debug("tableScrollowAnimation  " + "\(self.tableView)")
        tableView.frame = CGRect(x: 0, y: tableY, width: tableView.frame.width, height: tableView.frame.height)
    }

    override func keyboardWillHide() {
        if tableView.contentOffset.y > tableView.contentSize.height - tableView.bounds.height {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.height), animated: true)
        }
    }

    func setShareImage() {
        guard let data = self.newsDetail else {
            return
        }
        let faceImageView = UIImageView(frame: CGRect(x: 12, y: 20, width: 50, height: 50))
        faceImageView.clipsToBounds = true
        faceImageView.layer.cornerRadius = 25
        if let imgInfos = data.coverInfos, imgInfos.isEmpty == false {
            let strPrefixUrl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
            let imageUrl = String(format: "%@/%d", strPrefixUrl, imgInfos[0].id)
            faceImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "IMG_icon"), options: nil, progressBlock: nil) { (image, _, _, _) in
                if let image = image {
                    self.shareImage = image
                } else {
                    self.shareImage = UIImage(named: "IMG_icon")
                }
            }
        }
        self.shareImage = faceImageView.image
    }

    func updataFollowStatus(notice: NSNotification) {
        let userid: String = (notice.userInfo!["userid"] ?? "-1") as! String
        guard let currentUserid = self.headerView?.user.userIdentity else {
            return
        }
        if userid != "\(currentUserid)" {
            return
        }
        let statusFollow: String = (notice.userInfo!["follow"] ?? "0") as! String
        self.headerView?.user.follower = statusFollow == "1" ? true : false
        self.headerView?.followControl.isSelected = statusFollow == "1" ? true : false
    }
}

// MARK: - UI加载

extension TSNewsCommentController {

    override func initialUI() {
        self.creatNavigationBar()
        self.creatTableView()
    }

    func creatNavigationBar() {
        self.navigationBar.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: TSNavigationBarHeight)
        self.navigationBar.layoutControls()
        self.navigationBar.delegate = self
        self.navigationBar.setTitle(title: "资讯详情")
        self.view.addSubview(self.navigationBar)

        statusbarBGView.backgroundColor = TSColor.main.white
        self.view.addSubview(statusbarBGView)
    }

    func creatTableView() {
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)

        tableView.frame = CGRect(x: 0, y: self.navigationBar.frame.maxY - TSStatusBarHeight, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 95
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        self.tableView = tableView

        self.view.bringSubview(toFront: self.navigationBar)
        self.view.bringSubview(toFront: self.statusbarBGView)
    }

    /// 创建文章内容视图 markdownView
    func creatHaederView() {
        self.headerView = TSNewsDetailHeaderViewController(newsId: self.newsId)
        self.headerView?.delegate = self
    }

    /// 创建底部工具栏
    func creatToolView() {
        guard let newsDetail = self.newsDetail else {
            return
        }
        self.commentToolBar = TSNewsDetailToolbarView(newsDetail)
        self.commentToolBar?.commentDelegate = self
        self.view.addSubview(self.commentToolBar!)
    }
}

// MARK: loadingViewDelegate

extension TSNewsCommentController {
    override func reloadingButtonTaped() {
        self.initialDataSource()
    }
}

// MARK: DetailHeaderViewControllerDelegate

extension TSNewsCommentController: DetailHeaderViewControllerDelegate {
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
        self.tableView.mj_header.endRefreshing()
        self.commentToolBar == nil ? self.creatToolView() : self.commentToolBar?.uploadData(data: self.newsDetail!)
        self.tableView.tableHeaderView = view
        self.tableView.reloadData()
    }

    func newsFollow(_ newHeaderView: UIView?, didClickFollowControl followControl: TSFollowControl) {
        // TODO: - 这里没有起到作用，待完成
        followControl.isFollow = !followControl.isFollow
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 判断关注状态
        guard let user = headerView?.user else {
            return
        }
        followControl.isEnabled = false
        let followOperate = user.follower ? TSFollowOperate.unfollow : TSFollowOperate.follow
        TSUserNetworkingManager.followOperate(followOperate, userId: user.userIdentity) { (msg, status) in
            followControl.isEnabled = true
            if status {
                // 更新数据源，并刷新数据
                self.headerView?.user?.follower = followOperate == TSFollowOperate.follow ? true : false
                followControl.isFollow = followOperate == TSFollowOperate.follow
            } else {
                // 重新刷新数据
                followControl.isFollow = user.follower
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension TSNewsCommentController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 暂时固定为3区
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0
        switch section {
        case 0:     // 相关资讯
            rowCount = self.newsCorrelative.count
        case 1:     // 广告
            rowCount = advert.count > 0 ? 1 : 0
        case 2:    // 评论
            rowCount = super.tableView(tableView, numberOfRowsInSection: section)
        default:
            break
        }
        return rowCount
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerSection: UIView? = nil
        switch section {
        case 0:     // 相关资讯
            if newsCorrelative.isEmpty {
                break
            }
            /// 注：相关资讯部分需要更改
            let sectionHeaderView = TSNewsDetailCommentCountsView.headerInTableView(tableView)
            var labelNames = [String]()
            for label in newsDetail!.labels {
                labelNames.append(label.name)
            }
            sectionHeaderView.userInfoLabelDataSource = labelNames
            sectionHeaderView.uploadString("界面_相关资讯".localized)
            self.newsCorrelativeHeaderView = sectionHeaderView
            headerSection = sectionHeaderView
        case 1:     // 广告
            break
        case 2:     // 评论
            headerSection = super.tableView(tableView, viewForHeaderInSection: section)
        default:
            break
        }
        return headerSection
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:     // 相关资讯
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
        case 1:     // 广告
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
        default:    // 评论
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

}

// MARK: - UITableViewDelegate

extension TSNewsCommentController {

    // MARK: TableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0
        switch indexPath.section {
        case 0:
            rowHeight = UITableViewAutomaticDimension
        case 1:
            rowHeight = advert.count == 0 ? 0 : TSAdvertHelper.share.getAdvertHeight(advertType: .normal, Advertwith: ScreenWidth, itemCount: advert.count ) + 10
        case 2:
            rowHeight = super.tableView(tableView, heightForRowAt: indexPath)
        default:
            break
        }
        return rowHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var sectionHeight: CGFloat = 0
        switch section {
        case 0:     // 相关资讯
            if self.newsCorrelative.isEmpty {
                sectionHeight = CommentCountsViewUX.top
            } else if self.newsDetail!.labels.isEmpty {
                sectionHeight = CommentCountsViewUX.viewHeight
            } else {
                var labelList = [String]()
                for label in self.newsDetail!.labels {
                    labelList.append(label.name)
                }
                sectionHeight = CommentCountsViewUX.viewHeight + TSUserInfoLabel.heightWithData(labelList, layout: TSNewsDetailCommentCountsView().layout)
            }
        case 1:     // 广告
            sectionHeight = CommentCountsViewUX.top
        case 2:     // 评论
            sectionHeight = super.tableView(tableView, heightForHeaderInSection: section)
        default:
            break
        }
        return sectionHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:         // 相关资讯
            let newsModel = newsCorrelative[indexPath.row]
            let newsDetailVC = TSNewsDetailViewController(newsId: newsModel.id)
            TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsModel.id)
            self.tableView.reloadData()
            self.navigationController?.pushViewController(newsDetailVC, animated: true)
        case 1:         // 广告
            // 广告视图自己携带了点击事件处理
            break
        case 2:         // 评论
            super.tableView(tableView, didSelectRowAt: indexPath)
        default:
            break
        }
    }

    // MARK: ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.tableView {
            return
        }
        var sectionHeight = CommentCountsViewUX.viewHeight
        if self.sourceList.isEmpty {
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
}

// MARK: TSNewsNavigationBarDelegate

extension TSNewsCommentController: TSNewsNavigationBarDelegate {
    func Back(navigaruionBar: TSNewsNavigationBar) {
        TSUtil.popViewController(currentVC: self, animated: true)
    }
}

// MARK: TSDetailToolBarViewDelegate

// 底部工具栏响应
extension TSNewsCommentController: TSNewsDetailToolbarDelegate {
    func didClickShareButton(_ toolbar: TSNewsDetailToolbarView) {
        guard let newsDetail = self.newsDetail else {
            return
        }
        let messageModel = TSmessagePopModel(newsDetail: newsDetail)
        // 当分享内容为空时，显示默认内容
        let shareTitle = newsDetail.title != "" ? newsDetail.title : TSAppSettingInfoModel().appDisplayName + " " + "资讯"
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let shareContent = newsDetail.subject != "" ? newsDetail.subject : defaultContent
        let url = ShareURL.news.rawValue + "\(newsDetail.id!)"
        if TSCurrentUserInfo.share.userInfo?.userIdentity == newsDetail.authorId {
            let shareView = ShareListView(isMineSend: true, isCollection: newsDetail.isCollect, shareType: ShareListType.newDetail)
            shareView.delegate = self
            shareView.messageModel = messageModel
            if self.shareImage != nil {
                shareView.show(URLString: url, image: self.shareImage, description: shareContent, title: shareTitle)
            } else {
                shareView.show(URLString: url, image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
            }
        } else {
            let shareView = ShareListView(isMineSend: false, isCollection: newsDetail.isCollect, shareType: ShareListType.newDetail)
            shareView.delegate = self
            shareView.messageModel = messageModel
            if self.shareImage != nil {
                shareView.show(URLString: url, image: self.shareImage, description: shareContent, title: shareTitle)
            } else {
                shareView.show(URLString: url, image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
            }
        }
    }

    func didSelectedCommentButton(_ toolbar: TSNewsDetailToolbarView) {
        TSKeyboardToolbar.share.keyboarddisappear()
        self.writeComment(replyComment: nil, cell: nil)
    }

    func didPressNewsApplyBtn(_ toolbar: TSNewsDetailToolbarView) {
        let applyTopVC = TSTopAppilicationManager.newsTopVC(newsId: self.newsId)
        _ = navigationController?.pushViewController(applyTopVC, animated: true)
    }

    func didClickDeleteNewsOptionIn(toolbar: TSNewsDetailToolbarView, isManager: Bool) {
        self.showNewsDeleteConfirmAlert(ismanager: isManager)
    }
}

extension TSNewsCommentController {
    /// 显示资讯删除的二次确认弹窗
    func showNewsDeleteConfirmAlert(ismanager: Bool) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "选择_删除资讯".localized) {
            self.deleteNews(isManager: ismanager)
        }
        self.present(alertVC, animated: false, completion: nil)
    }

    /// 删除资讯
    fileprivate func deleteNews(isManager: Bool) -> Void {
        guard let object = self.newsDetail else {
            return
        }
        // 显示加载中动画
        let alert = TSIndicatorWindowTop(state: .loading, title: "正在发起删除申请...")
        alert.show()
        if isManager {
            TSNewsNetworkManager().managerDeletePostNews(newsId: object.id, category: object.categoryInfo.id, complete: { (message, status) in
                alert.dismiss()
                let alertMsg: String
                if status {
                    alertMsg = message ?? "申请删除成功"
                } else {
                    alertMsg = "申请删除失败" + (message ?? "")
                }
                let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: alertMsg)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            })
        } else {
            TSNewsNetworkManager().deletePostNews(newsId: object.id, category: object.categoryInfo.id, complete: { (message, status) in
                alert.dismiss()
                let alertMsg: String
                if status {
                    alertMsg = message ?? "申请删除成功"
                } else {
                    alertMsg = "申请删除失败" + (message ?? "")
                }
                let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: alertMsg)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            })
        }
    }

}

extension TSNewsCommentController: ShareListViewDelegate {
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        let messageModel = model
        // 优先使用封面图
        if let coverInfos = self.newsDetail?.coverInfos, coverInfos.isEmpty == false, let coverImageID = coverInfos[0].id {
            let strurl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue + "/\(coverImageID)"
            messageModel.contentType = .newsPic
            messageModel.coverImage = strurl
        } else if (self.headerView?.imageArray.isEmpty)! {
            // 然后采用正文中的图片
            messageModel.contentType = .newsText
        } else {
            messageModel.contentType = .newsPic
            messageModel.coverImage = (self.headerView?.imageArray[0])!
        }
        let chooseFriendVC = TSPopMessageFriendList(model: messageModel)
        self.navigationController?.pushViewController(chooseFriendVC, animated: true)
    }

    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let repostModel = TSRepostModel.coverNewsModel(newsModel: self.newsDetail!)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC)
        self.present(navigation, animated: true, completion: nil)
    }

    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }
}
