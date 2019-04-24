//
//  TSMomentDetailVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态详情页 视图控制器

import UIKit
import RealmSwift
import ZFPlayer
import Kingfisher

class TSMomentDetailVC: TSViewController, TSMomentDetailNavViewDelegate/* 导航视图 代理 */, TSMomentDetailHeaderViewDelegate/* headerView 代理 */, UITableViewDelegate, TSMomentDetailToolbarDelegate/* 工具栏点击代理事件 */, TSKeyboardToolbarDelegate, TSCustomAcionSheetDelegate/* 弹出视图的点击代理 */, TSChoosePriceVCDelegate, ZFPlayerDelegate {

    /// 导航视图
    lazy var navView: TSMomentDetailNavView = { () -> TSMomentDetailNavView in
        let userInfoModel = TSUserInfoModel(object: (self.model?.userInfo)!)
        var tempNav = TSMomentDetailNavView(userInfoModel)
        tempNav.delegate = self
        self.view.addSubview(tempNav)
        return tempNav
    }()
    /// 详情展示页
    var headerView: TSMomentDetailHeaderView?
    /// 评论
    let table = TSTableView(frame: CGRect(x: 0, y: TSNavigationBarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight - 48), style: .plain)
    /// 底部视图
    var toolbarView: TSMomentDetailToolbar?

    /// 动态数据
    var model: TSMomentListCellModel?
    /// 是否在当前页面执行删除动态操作
    var isCurrentPageDelete: Bool = false

    /// 评论总数
    var commentCount: Int = 0 {
        didSet {
            self.setData(commentCount: commentCount)
        }
    }
    // 播放器
    var playerView: ZFPlayerView?
    // 离开页面时是否正在播放视频
    var isPlaying: Bool = false
    var playerModel: ZFPlayerModel?

    // MARK: - Lifecycle
    init(_ model: TSMomentListCellModel) {
        self.model = model
        headerView = TSMomentDetailHeaderView(model.data!)
        toolbarView = TSMomentDetailToolbar(model.data!)
        // 记录动态编号，防止在列表刷新时被删除
        TSMomentTaskQueue.usingMomentIdentity = model.data!.feedIdentity
        super.init(nibName: nil, bundle: nil)
        setBasicUI()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// 设置参数
    func setModel(model: TSMomentListCellModel) {
        self.model = model
        // 后续需要将TSMomentListCellModel 持有的object 修改为 modle
        if let userInfo = model.userInfo, self.navView == nil {
            TSTaskQueueTool.getAndSave(userIds: [userInfo.userIdentity]) { [weak self] (datas, _, _) in
                guard let datas = datas, let data = datas.first else {
                    return
                }
                self?.navView = TSMomentDetailNavView(data)
            }
        }
        headerView = TSMomentDetailHeaderView(model.data!)
        toolbarView = TSMomentDetailToolbar(model.data!)
        self.headerView?.rewardCount = model.data?.reward
        loadRewardInfo()
        setBasicUI()
        if let commentCount = model.data?.commentCount {
            self.commentCount = commentCount
        }
    }

    func playWith(model: TSMomentListCellModel) {
        var url: URL?
        if let videoUrl = model.data?.videoURL {
            url = URL(string: videoUrl)
        }
        if let fileURL = model.data?.shortVideoOutputUrl {
            let filePath = TSUtil.getWholeFilePath(name: fileURL)
            url = URL(fileURLWithPath: filePath)
        }
        guard url != nil else {
            return
        }
        playerView = ZFPlayerView()
        playerModel = ZFPlayerModel()
        if let image = headerView?.firstImage.imageView?.image {
            playerModel?.placeholderImage = image
            self.playerView?.placeholderBlurImageView.image = image
        } else {
            self.playerView?.placeholderBlurImageView.image = nil
        }
        playerModel?.title = "一个标题"
        playerModel?.videoURL = url
        playerModel?.fatherView = headerView?.firstImage
        playerView?.playerControlView(CustomPlayerControlView(), playerModel: playerModel!)
        playerView?.playerLayerGravity = ZFPlayerLayerGravity.resizeAspect
        playerView?.hasPreviewView = true
        playerView?.disablePanGesture = true
        playerView?.hasDownload = true
        playerView?.delegate = self
        playerView?.autoPlayTheVideo()
    }

    func setData(commentCount: Int?) {
        headerView!.setCommentLabel(commentCount)
        table.tableHeaderView = headerView
    }

    required init?(coder aDecoder: NSCoder) {
        self.model = TSMomentListCellModel()
        headerView = TSMomentDetailHeaderView(model!.data!)
        toolbarView = TSMomentDetailToolbar(model!.data!)
        super.init(coder: aDecoder)
        setBasicUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loading()
        NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
    }

    func changeStatuBar() {
        let offset: CGFloat = TSStatusBarHeight
        var changeY = toolbarView!.frame.origin.y
        if UIApplication.shared.statusBarFrame.size.height == TSStatusBarHeight {
            changeY += offset
        } else {
            changeY -= offset
        }
        toolbarView?.frame.origin.y = changeY
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
        if self.model != nil {
            // 更新导航栏右边按钮的位置
            navView.updateRightButtonFrame()
        }
        // 注册网络变化监听
        NotificationCenter.default.addObserver(self, selector: #selector(notiNetstatesChange(noti:)), name: Notification.Name.Reachability.Changed, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if self.navigationController?.viewControllers.count == 2 && self.playerView != nil && self.isPlaying {
            self.isPlaying = false
            self.playerView?.playerPushedOrPresented = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didClickShortVideoShareBtn(_:)), name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
    }

    deinit {
        if let notificationTokenForMoment = notificationTokenForMoment {
            notificationTokenForMoment.invalidate()
        }
        // 清除编号记录
        TSMomentTaskQueue.usingMomentIdentity = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        self.navigationController?.navigationBar.isHidden = false

        if self.navigationController?.viewControllers.count == 3, let playerView = self.playerView, playerView.isPauseByUser {
            self.isPlaying = true
            self.playerView?.playerPushedOrPresented = true
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
        // 移除网络变化监听
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Reachability.Changed, object: nil)
    }

    // MARK: - Custom user interface
    func setBasicUI() {
        automaticallyAdjustsScrollViewInsets = false
        // back status bar
        let whiteView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TSStatusBarHeight))
        whiteView.backgroundColor = UIColor.white
        // table
        table.backgroundColor = TSColor.inconspicuous.disabled
        table.delegate = self
        // nav view
        // header
        headerView!.delegate = self
        // tool bar
        toolbarView!.commentDelegate = self
        view.addSubview(table)
        view.addSubview(toolbarView!)
        view.addSubview(whiteView)
        table.tableFooterView = UIView()
        table.keyboardDismissMode = .onDrag
    }

    // MARK: - Button click
    func popBack() {
        TSUtil.popViewController(currentVC: self, animated: true)
    }

    func didClickShortVideoShareBtn(_ sender: Notification) {
        shareMoments()
    }

    // MARK: - Delegete

    // MARK: UITableViewDelegate
    var lastOffsetY: CGFloat = 0.0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var yPoint = self.toolbarView!.frame.height
        if UIApplication.shared.statusBarFrame.size.height != TSStatusBarHeight {
            yPoint += TSStatusBarHeight
        }
        if scrollView.contentOffset.y > (self.navView.frame.height + self.toolbarView!.frame.height) {
            let currentOffsetY = scrollView.contentOffset.y
            let direction = currentOffsetY - lastOffsetY
            let maxContentOffsetY = scrollView.contentSize.height - UIScreen.main.bounds.height + 0
            if currentOffsetY < 0 || currentOffsetY >  maxContentOffsetY {
                self.perform(#selector(scrollViewDidEndScrollingAnimation), with: nil, afterDelay: 0.000_01)
                TSAnimationTool.animationManager.stopGifAnimation()
                TSAnimationTool.animationManager.resetGifSuperView()
                return
            }

            lastOffsetY = currentOffsetY
            navView.scrollowAnimation(direction)
            toolbarView!.scrollowAnimation(direction)
            tableScrollowAnimation(direction)
        } else if scrollView.contentOffset.y <= 0 {
            self.navView.frame = CGRect(x: 0, y: 0, width: self.navView.frame.width, height: self.navView.frame.height)
            self.toolbarView!.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - yPoint, width: self.toolbarView!.frame.width, height: self.toolbarView!.frame.height)
            self.table.frame = CGRect(x: 0, y: self.navView.frame.maxY, width: self.table.frame.width, height: (self.toolbarView!.frame.minY - self.navView.frame.maxY))
        }
        self.perform(#selector(scrollViewDidEndScrollingAnimation), with: nil, afterDelay: 0.000_01)
        TSAnimationTool.animationManager.stopGifAnimation()
        TSAnimationTool.animationManager.resetGifSuperView()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var yPoint = self.toolbarView!.frame.height
        if UIApplication.shared.statusBarFrame.size.height != TSStatusBarHeight {
            yPoint += TSStatusBarHeight
        }
        let navTopY = -navView.frame.height + TSStatusBarHeight + 1
        let navseparateY = -navView.frame.height / 2
        let navBottomY: CGFloat = 0
        let shouldHidden = navView.frame.minY < navseparateY

        let shouldAnimation = (navView.frame.minY < navBottomY && navView.frame.minY > navTopY)
        if !shouldAnimation {
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            if shouldHidden {
                self.navView.frame = CGRect(x: 0, y: navTopY, width: self.navView.frame.width, height: self.navView.frame.height)
                self.toolbarView!.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.toolbarView!.frame.width, height: self.toolbarView!.frame.height)
            } else {
                self.navView.frame = CGRect(x: 0, y: navBottomY, width: self.navView.frame.width, height: self.navView.frame.height)
                self.toolbarView!.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - yPoint, width: self.toolbarView!.frame.width, height: self.toolbarView!.frame.height)
            }
            self.table.frame = CGRect(x: 0, y: self.navView.frame.maxY, width: self.table.frame.width, height: (self.toolbarView!.frame.minY - self.navView.frame.maxY))
        })
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        getCurrentGifPicture()
    }

    /// 这里检索当前可见有动图且动图至少有一张是满足可见百分之八十
    func getCurrentGifPicture() {
        var hasGifAndCanPlay = false
        var curentCellIndex: Int = -1
        if let detailHeaderView = headerView {
            let images = detailHeaderView.object.pictures.filter { (object) -> Bool in
                return object.width > 0 && object.height > 0
            }
            for indexGif in 0..<images.count {
                if images[indexGif].mimeType == "image/gif" {
                    if images[indexGif].payType == 2 {
                        /// 需要付费的不处理（没有付费的）
                    } else {
                        /// 这里需要计算这个gif图片是不是满足可见面积达到百分之八十
                        if let detailImageButton = detailHeaderView.viewWithTag(detailHeaderView.tagForImageButton + indexGif) {
                            let coverPoint = detailImageButton.convert(CGPoint(x: 0, y: 0), to: self.view)
                            if coverPoint.y < 0 {
                                if coverPoint.y + detailImageButton.frame.size.height * 0.2 >= 0 {
                                    hasGifAndCanPlay = true
                                    curentCellIndex = indexGif
                                    break
                                }
                            } else {
                                if coverPoint.y + detailImageButton.frame.size.height * 0.8 <= self.view.frame.size.height {
                                    hasGifAndCanPlay = true
                                    curentCellIndex = indexGif
                                    break
                                }
                            }
                        }
                    }
                }
            }
            if hasGifAndCanPlay {
                TSAnimationTool.animationManager.detailHeaderView = detailHeaderView
                TSAnimationTool.animationManager.allSuperView = self.view
                TSAnimationTool.animationManager.getDetailGifPictures()
            }
        }
    }

    // MARK: TSMomentDetailNavViewDelegate
    /// 点击了返回按钮
    func navView(_ navView: TSMomentDetailNavView, didSelectedLeftButton: TSButton) {
        TSKeyboardToolbar.share.keyboarddisappear()
        TSUtil.popViewController(currentVC: self, animated: true)
    }

    // MARK: TSMomentDetailHeaderViewDelegate
    /// 点击了图片
    func headerView(_ headerView: TSMomentDetailHeaderView, didSelectedImagesAt index: Int) {
        TSKeyboardToolbar.share.keyboarddisappear()
        let imageObjects = Array(headerView.object.pictures)
        // 如果点的是以一张且目前的Cell内加载的数据是视频数据,那么就通知不同的代理,传递视频需要的数据
        if index == 0, let videoUrl = headerView.object.videoURL, videoUrl.count > 0 {
            if TSAppConfig.share.reachabilityStatus == .WIFI {
                playWith(model: self.model!)
            } else if TSAppConfig.share.reachabilityStatus == .Cellular {
                guard TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo == false else {
                    self.playWith(model: self.model!)
                    return
                }
                // 弹窗 然后继续播放
                let alert = TSAlertController(title: "提示", message: "您当前正在使用移动网络，继续播放将消耗流量", style: .actionsheet, sheetCancelTitle: "放弃")
                let action = TSAlertAction(title:"继续", style: .default, handler: { [weak self] (_) in
                    self?.playWith(model: (self?.model!)!)
                    TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = true
                })
                alert.addAction(action)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
            } else if TSAppConfig.share.reachabilityStatus == .NotReachable {
                // 弹窗 然后继续播放
                let alert = TSAlertController(title: "提示", message: "网络未连接，请检查网络", style: .actionsheet, sheetCancelTitle: "停止播放")
                let action = TSAlertAction(title:"继续播放", style: .default, handler: { [weak self] (_) in
                    self?.playWith(model: (self?.model!)!)
                    TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = true
                })
                alert.addAction(action)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
            }
            return
        }

        // 1.如果图片为查看付，弹出购买弹窗
        let imageObject = imageObjects[index]
        if imageObject.paid.value == false && imageObject.type == "read" {
            TSPayTaskQueue.showImagePayAlertWith(imageObject: imageObject, compelet: { [weak self]  (_, _) in
                guard self != nil else {
                    return
                }
                headerView.uploadImage(at: index)
            })
            return
        }

        // 2.如果以上情况不发生，跳转图片查看器
        let imageFrames = headerView.getImagesFrame()
        let images = headerView.getImages()
        let picturePreview = TSPicturePreviewVC(objects: imageObjects, imageFrames: imageFrames, images: images, At: index)
        /* 补丁逻辑，在图片查看器消失后，刷新图片 */
        picturePreview.dismissBlock = { [weak self] in
            self?.uploadImages()
            ImageCache.default.clearMemoryCache()
            TSAnimationTool.animationManager.gifPicture.startAnimating()
        }
        picturePreview.show()
        TSAnimationTool.animationManager.gifPicture.stopAnimating()
    }

    // 补丁方法：刷新付费图片
    func uploadImages() {
        guard let imageDatas = model?.data?.pictures else {
            return
        }
        for index in 0..<imageDatas.count {
            headerView?.uploadImage(at: index)
        }
    }

    /// 点击了“点赞头像栏”
    func headerView(_ headerView: TSMomentDetailHeaderView, didSelectedDiggView: TSMomentDetailDiggView) {
        TSKeyboardToolbar.share.keyboarddisappear()
        let likeList = TSLikeListTableVC(type: .moment, sourceId: (self.model!.data?.feedIdentity)!)
        navigationController?.pushViewController(likeList, animated: true)
    }

    /// 点击了打赏按钮
    func reward() {
        if model?.userInfo?.userIdentity == TSCurrentUserInfo.share.userInfo?.userIdentity {
            let alert = TSAlertController(title: "提示", message: "不能打赏自己", style: .actionsheet, sheetCancelTitle: "取消")
            present(alert, animated: false, completion: nil)
            return
        }
        let vc = TSChoosePriceVCViewController(type: .moment)
        vc.delegate = self
        vc.sourceId = model?.data?.feedIdentity
        navigationController?.pushViewController(vc, animated: true)
    }

    // 点击了打赏用户列表
    func tapUser() {
        let vc = TSRewardListVC.list(type: .moment)
        vc.rewardId = model?.data?.feedIdentity
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: TSMomentDetailToolbarDelegate
    func toolbar(_ toolbar: TSMomentDetailToolbar, DidSelectedItemAt index: Int) {
        if index == 0 { // 喜欢
            headerView!.updateDiggIcon()
        }
        if index == 1 { // 评论
            TSKeyboardToolbar.share.keyboarddisappear()
            toolbarDidSelectedCommentButton(toolbar)
        }
        if index == 2 { // 分享
            shareMoments()
        }
        // [长期注释] 添加工具栏“更多”按钮事件. 2017/04/24
        if index == 3 { // 更多
            if let model = model {
                var selectTitles: [String] = []
                /// 如果是视频动态，第一个选项为“下载”
                // 自己：收藏 + 置顶 + 删除
                // 他人：收藏 + 举报
                // 管理员: 收藏 + 删除
                if model.data?.videoURL != nil {
                    selectTitles.append("下载")
                }
                if model.userInfo?.userIdentity == TSCurrentUserInfo.share.userInfo?.userIdentity {
                    // 如果是自己的发送成功的动态，才可以显示申请置顶按钮
                    selectTitles.append(model.data!.isCollect == 0 ? "选择_收藏".localized : "选择_取消收藏".localized)
                    if model.data?.sendState == 1 {
                        selectTitles.append("显示_申请动态置顶".localized)
                    }
                    selectTitles.append("选择_删除动态".localized)
                } else if (TSCurrentUserInfo.share.accountManagerInfo?.getData())! {
                    selectTitles.append(model.data!.isCollect == 0 ? "选择_收藏".localized : "选择_取消收藏".localized)
                    selectTitles.append("选择_删除动态".localized)
                } else {
                    selectTitles.append(model.data!.isCollect == 0 ? "选择_收藏".localized : "选择_取消收藏".localized)
                    selectTitles.append("选择_举报".localized)
                }
                let alert = TSCustomActionsheetView(titles: selectTitles)
                alert.delegate = self
                alert.show()
            }
        }
    }

    // MARK: TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if let model = model {
            switch title {
            case "选择_收藏".localized, "选择_取消收藏".localized:
                /// 发起动态收藏队列
                let isCollect = model.data!.isCollect == 0 ? true : false
                TSDataQueueManager.share.moment.start(collect: model.data!.feedIdentity, isCollect: isCollect)
                // 更改动态数据库
                TSDatabaseManager().moment.change(collect: model.data!)
                break
            case "选择_删除动态".localized:
                self.showFeedDeleteConfirmAlert(model: model)
                break
            case "选择_申请动态置顶".localized:
                // 申请动态置顶
                let top = TSTopAppilicationManager.momentTopVC(feedId: (model.data?.feedIdentity)!)
                self.navigationController?.pushViewController(top, animated: true)
            case "选择_举报".localized:
                // 动态举报
                let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: model)
                let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget)
                self.navigationController?.pushViewController(reportVC, animated: true)
            case "下载":
                if let videoUrl = model.data?.videoURL {
                    TSUtil.share().showDownloadVC(videoUrl: videoUrl)
                }
            default:
                break
            }
        }
    }

    // 删除动态的二次确认弹窗
    func showFeedDeleteConfirmAlert(model: TSMomentListCellModel) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除动态") {
            self.deleteFeed(model: model)
        }
        self.present(alertVC, animated: false, completion: nil)
    }
    /// 删除动态
    func deleteFeed(model: TSMomentListCellModel) -> Void {
        // 发起动态删除队列
        self.isCurrentPageDelete = true
        TSDataQueueManager.share.moment.start(delete: model.data!.feedIdentity)
        TSDataQueueManager.share.moment.database(delete: model.data!)
        NotificationCenter.default.post(name: NSNotification.Name.Moment.momentDetailVCDelete, object: nil, userInfo: ["feedId": model.data!.feedIdentity])
        self.popBack()
    }

    // MARK: TSKeyboardToolbarDelegate
    func keyboardToolbarSendTextMessage(message: String, inputBox: AnyObject?) {
    }

    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
    }
    /// 键盘准备收起
    internal func keyboardWillHide() {
    }

    // MARK: reward delegate
    func didRewardSuccess(_ rewardModel: TSNewsRewardModel) {
        self.headerView?.userListDataSource?.append(rewardModel)
        guard let oldModel = self.headerView?.rewardListView.rewardModel else {
            return
        }
        guard let amount = oldModel.amount, let value = Int(amount) else {
            oldModel.amount = "\(rewardModel.amount!)"
            oldModel.count = 1
            self.headerView?.rewardListView.rewardModel = oldModel
            return
        }
        oldModel.amount = "\(value + rewardModel.amount!)"
        oldModel.count += 1
        self.headerView?.rewardListView.rewardModel = oldModel
    }

    // MARK: - network request
    func loadRewardInfo() {
        let momentID = model?.data?.feedIdentity
        TSMomentNetworkManager().rewardList(momentID: momentID!, maxID: nil) { [weak self] (rewardModels, _) in
            if rewardModels != nil {
                self?.headerView?.userListDataSource = rewardModels
            }
        }
        /*
         由于 #1021 BUG，故将以下的逻辑整合到了 TSCommetDetailTableView 的 func requestMomentData(feedId: Int, userId: Int, complete: @escaping (TSMomentListCellModel?, Bool) -> Void) 中，后期重写时请注意此处的逻辑。
         */
//        let feedId = model?.data?.feedIdentity
//        TSMomentNetworkManager.getOneMoment(feedId: feedId!, complete: { (momentObject, error) in
//            if momentObject == nil && error == nil {
//                return
//            }
//            guard let momentObject = momentObject else {
//                return
//            }
//            if let reward = momentObject.reward {
//                self.headerView?.rewardCount = reward
//            }
//        })
    }

    // MARK: - Public

    /// 获取点赞头像的数据
    ///
    /// - Parameter complete: 是否成功
    func getDiggData(complete: @escaping (_ isSuccess: Bool, _ momentIsDeleted: Bool) -> Void) {
        headerView!.getDiggData(complete: complete)
    }

    /// 需要在子类实现
    func toolbarDidSelectedCommentButton(_ toolbar: TSMomentDetailToolbar) {
        TSKeyboardToolbar.share.keyboarddisappear()
    }

    // MARK: - Private
    /// table 滑动效果
    func tableScrollowAnimation(_ offset: CGFloat) {
        let minY: CGFloat = TSStatusBarHeight + 1
        let maxY: CGFloat = TSNavigationBarHeight
        let isAtMinY = table.frame.minY == minY
        let isAtMaxY = table.frame.maxY == maxY
        let isScrollowUp = offset > 0
        let isScrollowDown = offset < 0

        if (isScrollowUp && isAtMinY) || (isScrollowDown && isAtMaxY) {
            return
        }
        var tableY = table.frame.minY - offset
        if isScrollowUp && tableY < minY {
            tableY = minY
        }
        if isScrollowDown && tableY > maxY {
            tableY = maxY
        }
        table.frame = CGRect(x: 0, y: tableY, width: table.frame.width, height: (self.toolbarView!.frame.minY - self.navView.frame.maxY))
    }

    /// 分享动态
    private func shareMoments() {
        if let model = model {
            var image = UIImage(named: "IMG_icon")
            if !(model.data?.pictures.isEmpty)! {
                let imageButton = (headerView?.viewWithTag((headerView?.tagForImageButton)!) as? TSPreviewButton)!
                image = imageButton.imageView?.image
            }
            let title = model.data?.title == "" ? TSAppSettingInfoModel().appDisplayName + " " + "动态" : model.data?.title
            var defaultContent = "默认分享内容".localized
            defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
            let description = model.data?.content == "" ? defaultContent: model.data?.content

            let messageModel = TSmessagePopModel(momentDetail: model)
            let shareView = ShareListView(isMineSend: true, isCollection: false, shareType: ShareListType.momenDetail)
            shareView.delegate = self
            shareView.messageModel = messageModel
            shareView.show(URLString: ShareURL.feed.rawValue + "\(model.data!.feedIdentity)", image: image, description: description, title: title)
        }
    }
    // MARK: - Notification

    /// 添加通知
    func addNotification() {
        setMomentNotification()
    }

    /// 动态通知口令
    var notificationTokenForMoment: NotificationToken?
    /// 增加通知检测动态的改变
    func setMomentNotification() {
        if let momentData = model!.data {
            notificationTokenForMoment = momentData.observe({ [weak self] (changes) in
                if let weakSelf = self {
                    switch changes {
                    case .deleted:
                        // [长期注释] 动态详情页收到数据库删除通知执行不同的操作. 2017/04/25
                        if  weakSelf.isCurrentPageDelete {
                            _ = weakSelf.navigationController?.popViewController(animated: true)
                        } else {
                            weakSelf.showDeleteOccupiedView()
                        }
                    case .change:
                        weakSelf.toolbarView!.updateToolBar()
                        weakSelf.headerView!.updateDiggIcon()
                    case .error(let error):
                        assert(false, error.localizedDescription)
                    }
                }
            })
        }
    }
    /// 网络变化回调处理视频自动暂停
    func notiNetstatesChange(noti: NSNotification) {
        if self.playerView != nil && TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo == false && TSAppConfig.share.reachabilityStatus == .Cellular {
            // 弹窗 然后继续播放
            self.playerView?.pause()
            let alert = TSAlertController(title: "提示", message: "您当前正在使用移动网络，继续播放将消耗流量", style: .actionsheet, sheetCancelTitle: "放弃")
            let action = TSAlertAction(title:"继续", style: .default, handler: { [weak self] (_) in
                self?.playerView?.play()
                TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = true
            })
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        }
    }
    func zf_playerDownload(_ url: String!) {
        TSUtil.share().showDownloadVC(videoUrl: url)
    }
}

extension TSMomentDetailVC: ShareListViewDelegate {
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

    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let repostModel = TSRepostModel.coverPostMomentListModel(momentListModel: self.model!)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC)
        self.present(navigation, animated: true, completion: nil)
    }

    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }
}
