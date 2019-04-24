//
//  TSHomepageVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户主页，进入需传入用户的id

import UIKit
import Photos
import Kingfisher
import ZFPlayer
import ObjectMapper
import TZImagePickerController

class TSHomepageVC: UIViewController, TZImagePickerControllerDelegate, ZFPlayerDelegate {

    enum FeedsType: String {
        /// 付费动态
        case paid
        /// 置顶动态
        case pinned
    }

    /// 用户标识
    var userId: Int
    /// 用户名称
    var userName: String
    /// 动态类型，为 nil 时表示“全部动态”
    var feedType: FeedsType?
    /// 个人主页数据模型
    var model: HomepageModel
    /// 当前滚动位置
    fileprivate var currentScrollOffSet: CGFloat = 0
    /// 发送类型
    fileprivate var sendCommentType: SendCommentType = .send
    /// 导航视图
    let navView = TSHomePageNavView()
    /// 底部视图
    let bottomView = TSHomepageBottomView()
    /// header view
    let headerView = HomePageHeaderView()
    /// 列表视图
    let table = FeedListActionView(frame: UIScreen.main.bounds, tableIdentifier: "homepage")
    // 判断是否是当前用户的个人主页
    var isCurrentUser: Bool {
        return TSCurrentUserInfo.share.userInfo?.userIdentity == userId
    }
    /// 背景图弹窗 tag
    let actionSheetTag = 300
    /** 视频播放相关 **/
    var playerView: ZFPlayerView!
    var isPlaying = false
    /// 当前显示的视图
    var currentShowPage: FeedListActionView?
    /// 当前正在播放视频的视图
    var currentPlayingView: FeedListActionView?
    /// 当前正在播放视频的cell
    var currentPlayingCell: FeedListCell?

    // MARK: - Lifecycle
    init(_ userIdentity: Int, _ uName: String = "") {
        model = HomepageModel(userIdentity: userIdentity, userName: uName)
        userId = userIdentity
        userName = uName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingView.share.delegate = self
        loading() // 加载动画
        setUI()
        loadData() // 加载数据
        setPlayerView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        // 更新状态栏的颜色,和navView的title颜色相同
        if self.navView.isButtonWhite == false {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        } else {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
        // 更新导航栏右方按钮的位置
        navView.updateRightButtonFrame()
        NotificationCenter.default.addObserver(self, selector: #selector(didClickShortVideoShareBtn(_:)), name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        // 更新状态栏的颜色
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        self.playerView.pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
        // 移除网络变化监听
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Reachability.Changed, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
        // 注册网络变化监听
        NotificationCenter.default.addObserver(self, selector: #selector(notiNetstatesChange(noti:)), name: Notification.Name.Reachability.Changed, object: nil)
    }

    // MARK: - UI
    func setUI() {
        // 2.列表视图
        table.refreshDelegate = self
        table.mj_header = nil
        table.scrollDelegate = self
        let tableHeight = isCurrentUser ? UIScreen.main.bounds.height : UIScreen.main.bounds.height - bottomView.frame.height
        table.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: tableHeight))
        table.set(placeholderContentInset: UIEdgeInsets(top: TSStatusBarHeight + 15, left: 0, bottom: 0, right: 0))
        table.feedListViewDelegate = self
        // 1.头部视图
        headerView.set(taleView: table)
        headerView.delegate = self

        // 3.导航视图
        navView.delegate = self

        // 4.底部视图
        bottomView.delegate = self

        view.addSubview(table)
        view.addSubview(navView)
        // 如果是当前用户的个人主页，就没有底部视图
        if !isCurrentUser {
            view.addSubview(bottomView)
        }
    }

    func setPlayerView() {
        playerView = ZFPlayerView.shared()
        playerView.cellPlayerOnCenter = false
        playerView.stopPlayWhileCellNotVisable = true
        // 等比例填充，直到一个维度到达区域边界
        playerView.playerLayerGravity = ZFPlayerLayerGravity.resizeAspect
        playerView.forcePortrait = true
        playerView.hasPreviewView = false
    }

    // MARK: - Notification
    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
    }
    /// 网络变化回调处理视频自动暂停
    func notiNetstatesChange(noti: NSNotification) {
        if self.playerView != nil && TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo == false && TSAppConfig.share.reachabilityStatus == .Cellular {
            // 弹窗 然后继续播放
            self.playerView.pause()
            let alert = TSAlertController(title: "提示", message: "您当前正在使用移动网络，继续播放将消耗流量", style: .actionsheet, sheetCancelTitle: "放弃")
            let action = TSAlertAction(title:"继续", style: .default, handler: { [weak self] (_) in
                self?.playerView.play()
                TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = true
            })
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        }
    }
    func changeStatuBar() {
        var offset: CGFloat = UIScreen.main.bounds.height - 47 - TSBottomSafeAreaHeight
        if UIApplication.shared.statusBarFrame.size.height != TSStatusBarHeight {
            offset -= TSStatusBarHeight
        }
        bottomView.frame.origin.y = offset
    }

    // MARK: - Data

    /// 加载最新的用户主页数据
    func loadData() {
        model.reloadHomepageInfo { [weak self] (isSuccess) in
            // 1.数据获取失败
            guard isSuccess else {
                self?.loadFaild(type: .nobody)
                return
            }
            // 更新当前页面的用户ID，如果是用户名请求的个人主页就uid为0必须要更新
            self?.userId = (self?.model.userIdentity)!
            // 2.数据全部获取成功
            self?.loadModel()
            // 加载动态列表
            self?.refresh()
        }
    }

    func loadModel() {
        // 设置列表中的用户名，用于个人主页举报信息中显示用户名
        table.homePageUserName = model.userInfo.name
        // 1.header
        headerView.load(contentModel: model)

        // 2.底部视图
        if !isCurrentUser {
            bottomView.setFollowStatus(model.userInfo.getFollowStatus())
        }

        // 3.加载 section view
        let sectionModel = FilterSectionViewModel()
        sectionModel.countInfo = "\(model.userInfo.extra?.feedsCount ?? 0)条动态"
        sectionModel.filterInfo = ["全部动态", "付费动态", "置顶动态"]
        if userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
            table.sectionViewType = .filter(sectionModel, self)
        } else {
            table.sectionViewType = .count(sectionModel)
        }

        // 4.加载 nav view
        navView.setTitle(model.userInfo.name)
    }

    func playVideoWith(_ feedListView: FeedListActionView, indexPath: IndexPath) {
        let model = feedListView.datas[indexPath.row]
        var url = URL(string: model.videoURL)
        if let fileURL = model.localVideoFileURL {
            let filePath = TSUtil.getWholeFilePath(name: fileURL)
            url = URL(fileURLWithPath: filePath)
        }
        guard url != nil else {
            return
        }
        if let fileURL = model.localVideoFileURL {
            let filePath = TSUtil.getWholeFilePath(name: fileURL)
            url = URL(fileURLWithPath: filePath)
        }
        let playModel = ZFPlayerModel()
        playModel.videoURL = url
        playModel.indexPath = indexPath
        playModel.scrollView = feedListView
        playModel.fatherViewTag = 10_086

        if let cell = feedListView.cellForRow(at: indexPath) as? FeedListCell, let image = cell.picturesView.pictureViews.first?.picture {
            playModel.placeholderImage = image
            self.playerView.placeholderBlurImageView.image = image
        } else {
            self.playerView.placeholderBlurImageView.image = nil
        }
        playerView.playerControlView(CustomPlayerControlView(), playerModel: playModel)
        playerView.playerLayerGravity = ZFPlayerLayerGravity.resizeAspect
        playerView.hasDownload = true
        playerView.delegate = self
        playerView.autoPlayTheVideo()
        currentPlayingView = feedListView
        currentPlayingCell = feedListView.cellForRow(at: indexPath) as? FeedListCell
    }

    func didClickShortVideoShareBtn(_ sender: Notification) {
        // 当分享内容为空时，显示默认内容
        guard let feedId = currentPlayingCell?.model.id["feedId"] else {
            return
        }
        guard currentPlayingCell?.model.sendStatus == .success else {
            return
        }
        let image = currentPlayingCell?.picturesView.pictures.first ?? UIImage(named: "IMG_icon")
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let description = currentPlayingCell?.model.content != "" ? currentPlayingCell?.model.content : defaultContent
        let shareView = ShareView()
        shareView.show(URLString: ShareURL.feed.rawValue + "\(feedId)", image: image, description: description, title: TSAppSettingInfoModel().appDisplayName + " " + "动态")
    }

    func zf_playerDownload(_ url: String!) {
        TSUtil.share().showDownloadVC(videoUrl: url)
    }
}

extension TSHomepageVC: FeedListActionViewDelegate {
    func canPlayVideoCell(_ feedListView: FeedListActionView, indexPath: IndexPath) {
        // 关闭了自动播放
    }

    func didClickVideoCell(_ feedListView: FeedListActionView, cellIndexPath: IndexPath, fatherViewTag: Int) {
        if TSAppConfig.share.reachabilityStatus == .WIFI {
            playVideoWith(feedListView, indexPath: cellIndexPath)
        } else if TSAppConfig.share.reachabilityStatus == .Cellular {
            guard TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo == false else {
                self.playVideoWith(feedListView, indexPath: cellIndexPath)
                return
            }
            // 弹窗 然后继续播放
            let alert = TSAlertController(title: "提示", message: "您当前正在使用移动网络，继续播放将消耗流量", style: .actionsheet, sheetCancelTitle: "放弃")
            let action = TSAlertAction(title:"继续", style: .default, handler: { [weak self] (_) in
                self?.playVideoWith(feedListView, indexPath: cellIndexPath)
                TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = true
            })
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        } else if TSAppConfig.share.reachabilityStatus == .NotReachable {
            // 弹窗 然后继续播放
            let alert = TSAlertController(title: "提示", message: "网络未连接，请检查网络", style: .actionsheet, sheetCancelTitle: "停止播放")
            let action = TSAlertAction(title:"继续播放", style: .default, handler: { [weak self] (_) in
                self?.playVideoWith(feedListView, indexPath: cellIndexPath)
                TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = true
            })
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        }
    }
}

// MARK: - LoadingViewDelegate
extension TSHomepageVC: LoadingViewDelegate {

    /// 点击了 loading view 上的重新加载按钮
    func reloadingButtonTaped() {
        loadData()
    }
    /// 点击了返回
    func loadingBackButtonTaped() {
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true) {
            }
        }
    }
}

// MARK: - 帖子列表滚动代理事件
extension TSHomepageVC: FeedListViewScrollowDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1.更新 header view 的动画效果
        headerView.updateChildviews(tableOffset: scrollView.contentOffset.y)

        // 2.更新导航视图的动画效果
        // 这里需要把 offset 处理一下，移除 headerView 引起的 table inset 偏移的影响
        let offset = -(scrollView.contentOffset.y + headerView.stretchModel.headerHeightMin)
        navView.updateChildView(offset: offset)
        // 3.当下拉到一定程度的时候，发起下拉刷新操作
        if offset > 70 {
            // 如果下拉刷新正在进行，就什么都不做
            if navView.indicator.isAnimating {
                return
            }
            /*
             //[长期注释]05.15 根据需求调整,个人主页取消下拉刷新
             // 发起下拉刷新操作
             refresh()
             */
        }
    }

    // 下拉刷新
    func refresh() {
        FeedListNetworkManager.getUserFeed(userId: userId, screen: feedType?.rawValue, after: nil) { [weak table, weak self] (model, message, status) in
            self?.navView.indicator.dismiss()
            var cellModels: [FeedListCellModel]?
            if let models = model?.feeds {
                cellModels = models.map { FeedListCellModel(homepageModel: $0) }
            }
            // 隐藏加载数据
            self?.endLoading()
            table?.processRefresh(data: cellModels, message: message, status: status)
        }
    }
}

// MARK: - FeedListViewRefreshDelegate
extension TSHomepageVC: FeedListViewRefreshDelegate {

    /// 上拉加载
    func feedListTable(_ table: FeedListView, loadMoreDataOf tableIdentifier: String) {
        FeedListNetworkManager.getUserFeed(userId: userId, screen: feedType?.rawValue, after: table.after) { [weak table] (model, message, status) in
            var cellModels: [FeedListCellModel]?
            if let models = model?.feeds {
                cellModels = models.map { FeedListCellModel(homepageModel: $0) }
            }
            table?.processloadMore(data: cellModels, message: message, status: status)
        }
    }
}

// MARK: - TSHomePageNavViewDelegate
extension TSHomepageVC: TSHomePageNavViewDelegate {
    /// 点击了导航视图左边按钮
    func navView(_ navView: TSHomePageNavView, didSelectedLeftButton: TSButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    /// 点击了导航视图右边按钮
    func navView(_ navView: TSHomePageNavView, didSelectedRightButton: TSButton) {
        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alert.addAction(TSAlertAction(title: "分享", style: .default, handler: { [weak self] (_) in
            self?.share()
        }))
        if userId != TSCurrentUserInfo.share.userInfo?.userIdentity {
            alert.addAction(TSAlertAction(title: "举报", style: .default, handler: { [weak self] (_) in
                self?.informUser()
            }))
        }
        if userId != TSCurrentUserInfo.share.userInfo?.userIdentity, model.userInfo.isBlacked == false {
            alert.addAction(TSAlertAction(title: "加入黑名单", style: .default, handler: { [weak self] (_) in
                self?.addBlackList(self?.userId)
            }))
        }
        if userId != TSCurrentUserInfo.share.userInfo?.userIdentity, model.userInfo.isBlacked == true {
            alert.addAction(TSAlertAction(title: "移除黑名单", style: .default, handler: { [weak self] (_) in
                self?.deleteBlackList(self?.userId)
            }))
        }
        DispatchQueue.main.async {
            self.present(alert, animated: false, completion: nil)
        }
    }

    /// 举报用户
    func informUser() {
        let informModel = ReportTargetModel(userModel: model.userInfo)
        let informVC = ReportViewController(reportTarget: informModel)
        navigationController?.pushViewController(informVC, animated: true)
    }

    func addBlackList(_ userId: Int?) {
        guard let id = userId else {
            return
        }
        var request = UserNetworkRequest().addBlackList
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "网络错误，请稍后再试")
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                var errorMessage = "网络错误，请稍后再试"
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(let response):
                var errorMessage = "操作成功"
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .success, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.model.userInfo.isBlacked = !self.model.userInfo.isBlacked
            }
        }
    }

    func deleteBlackList(_ userId: Int?) {
        guard let id = userId else {
            return
        }
        var request = UserNetworkRequest().deleteBlackList
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "网络错误，请稍后再试")
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                var errorMessage = "网络错误，请稍后再试"
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(let response):
                var errorMessage = "操作成功"
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .success, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.model.userInfo.isBlacked = !self.model.userInfo.isBlacked
            }
        }
    }

    /// 分享个人主页
    func share() {
        let shareView = ShareView()
        var avaterImage = UIImage(named: "IMG_pic_default_secret")!
        if let avatar = headerView.contentView.avatar.buttonForAvatar.imageView?.image {
            avaterImage = avatar
        }
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let description: String = model.userInfo.shortDesc().count > 0 ? model.userInfo.shortDesc() : defaultContent
        // 个人主页右上角分享
        shareView.show(URLString: ShareURL.user.rawValue + "\(userId)", image: avaterImage, description: description, title: model.userInfo.name)
    }

}

// MARK: - TSHomepageBottomViewDelegate
extension TSHomepageVC: TSHomepageBottomViewDelegate {
    /// 点击了底部视图的上的按钮
    func bottomView(_ bottomView: TSHomepageBottomView, didSelectedButtonAt index: Int, title: String?) {
        guard let title = title else {
            return
        }
        // 是否有打赏的状态下index的值有差异，故使用title而不是index。
        switch title {
        case "显示_打赏".localized:
            let vc = TSChoosePriceVCViewController(type: .user)
            vc.sourceId = self.model.userInfo.userIdentity
            navigationController?.pushViewController(vc, animated: true)

        case "显示_关注".localized:
            fallthrough
        case "显示_已关注".localized:
            fallthrough
        case "显示_互相关注".localized:
            model.userInfo.follower = !model.userInfo.follower
            let relationship = model.userInfo.relationshipWithCurrentUser()!
            bottomView.setFollowStatus(relationship)
            let followStatus: FollowStatus = model.userInfo.follower == true ? .follow : .unfollow
            // 修改用户的粉丝数
            if followStatus == .follow {
                if let userExtra = model.userInfo.extra {
                    userExtra.followersCount = userExtra.followersCount + 1
                } else {
                    let extraStr = """
                    {
                    "user_id": \(model.userInfo.userIdentity),"followers_count": 0,
                    }
                    """
                    let extra = Mapper<TSUserExtraModel>().map(JSONString: extraStr)
                    model.userInfo.extra = extra
                    model.userInfo.extra!.followersCount = model.userInfo.extra!.followersCount + 1
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFollowSrarus"), object: nil, userInfo: ["follow": "1"])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowSrarus"), object: nil, userInfo: ["follow": "1","userid": "\(model.userInfo.userIdentity)"])
            } else if followStatus == .unfollow {
                if let userExtra = model.userInfo.extra {
                    userExtra.followersCount = userExtra.followersCount - 1
                } else {
                    let extraStr = """
                    {
                    "user_id": \(model.userInfo.userIdentity),"followers_count": 0,
                    }
                    """
                    let extra = Mapper<TSUserExtraModel>().map(JSONString: extraStr)
                    model.userInfo.extra = extra
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFollowSrarus"), object: nil, userInfo: ["follow": "0"])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowSrarus"), object: nil, userInfo: ["follow": "0","userid": "\(model.userInfo.userIdentity)"])
            }
// 不能全部刷新，只需要刷新粉丝数量
//            loadModel()
            // 调用关注接口
            TSUserNetworkingManager().operate(followStatus, userID: model.userInfo.userIdentity)
        case "显示_聊天".localized:
            if !EMClient.shared().isLoggedIn {
                let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                appDeleguate.getHyPassword()
                return
            }
            let idSt: String = String(self.userId)
            let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
            vc?.chatTitle = self.model.userInfo.name
            navigationController?.pushViewController(vc!, animated: true)
        default:
            break
        }
    }
}

// MARK: - HomePageHeaderViewDelegate
extension TSHomepageVC: HomePageHeaderViewDelegate {

    // 点击了背景图
    func headerview(_ headerview: HomePageHeaderView, didSelectedBackImageView: UIImageView) {
        guard isCurrentUser else {
            return
        }
        // 更换背景视图
        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alert.addAction(TSAlertAction(title: "选择_相册".localized, style: .default, handler: { [weak self] (_) in
            self?.openLibrary()
        }))
        alert.addAction(TSAlertAction(title: "选择_相机".localized, style: .default, handler: { [weak self] (_) in
            self?.openCamera()
        }))
        present(alert, animated: false, completion: nil)
    }

    // 点击了粉丝关注按钮
    func headerview(_ headerview: HomePageHeaderView, didSelectedFansOrFollowButton isFansButton: Bool) {
        let fansAndFollowVC = TSFansAndFollowVC(userIdentity: userId)
        fansAndFollowVC.setSelectedAt(isFansButton ? 0 : 1)
        if let navigationController = navigationController {
            navigationController.pushViewController(fansAndFollowVC, animated: true)
        }
    }
}

// MARK: - FilterSectionViewDelegate
extension TSHomepageVC: FilterSectionViewDelegate {

    /// 选择了一种过滤类型
    func filterSectionView(_ view: FilterSectionView, didSeleteNewAtIndex index: Int) {
        let message = view.model.filterInfo[index]
        // 如果新选择的过滤类型和旧的类型不同，就更新
        if message == "全部动态" && feedType != nil {
            feedType = nil
            refresh()
        }
        if message == "付费动态" && feedType != .paid {
            feedType = .paid
            refresh()
        }
        if message == "置顶动态" && feedType != .pinned {
            feedType = .pinned
            refresh()
        }
    }
}

// MARK: - Private
extension TSHomepageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate func openCamera() {
        let isSuccess = TSSetUserInfoVC.checkCamearPermissions()
        if isSuccess {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            if (UIDevice.current.systemVersion as NSString).floatValue >= 7.0 {
                imagePicker.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
            }
            imagePicker.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor

            var tzBarItem: UIBarButtonItem?
            var BarItem: UIBarButtonItem?
            tzBarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [TZImagePickerController.self])
            BarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
            let titleTextAttributes = tzBarItem?.titleTextAttributes(for: .normal)
            BarItem?.setTitleTextAttributes(titleTextAttributes, for: .normal)

            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                imagePicker.sourceType = sourceType
                if (UIDevice.current.systemVersion as NSString).floatValue >= 9.0 {
                    imagePicker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                }
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                return
            }
//            let imagePicker = TSImagePickerViewController.canCropCamera(cropType: .rectangle, finish: { [weak self] (image: UIImage) in
//                guard let weakSelf = self else {
//                    return
//                }
//                weakSelf.uploadBackImage(image: image)
//            })
//            imagePicker.show()
        }
    }

    fileprivate func openLibrary() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCountTSType: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true, square: false, shouldPick: true, topTitle: "更换封面", mainColor: TSColor.main.theme)
            else {
                return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #图片选择列表页面
        /// item右上角蓝色的选中图片
//            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")

        imagePickerVC.maxImagesCount = 1
        imagePickerVC.allowCrop = true
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingImage = true
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowPickingGif = false
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
//        let isSuccess = TSSetUserInfoVC.PhotoLibraryPermissions()
//        if isSuccess {
//            let imagePicker = TSImagePickerViewController.canCropAlbum(cropType: .rectangle, finish: { [weak self] (image) in
//                guard let weakSelf = self else {
//                    return
//                }
//                weakSelf.uploadBackImage(image: image)
//            })
//            imagePicker.show()
//        }
    }
    // MARK: - 系统拍照选择图片回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let infoDict: NSDictionary = (info as? NSDictionary)!
        let type: String = infoDict.object(forKey: UIImagePickerControllerMediaType) as! String
        if type == "public.image" {
            let photo: UIImage = infoDict.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
            let photoOrigin: UIImage = photo.fixOrientation()
            if photoOrigin != nil {
                let lzImage = LZImageCropping()
                lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 2.0)
                lzImage.image = photoOrigin
                lzImage.isRound = false
                lzImage.titleLabel.text = "更换封面"
                lzImage.didFinishPickingImage = {(image) -> Void in
                    guard let image = image else {
                        return
                    }
                    self.uploadBackImage(image: image)
                }
                self.navigationController?.present(lzImage, animated: true, completion: nil)
            }
        }
    }

    // 图片选择回调
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        if photos.count > 0 {
            if picker != nil {
                picker.dismiss(animated: true) {
                }
            }
            self.uploadBackImage(image: photos[0])
        } else {
            let resultAlert = TSIndicatorWindowTop(state: .faild, title: "图片选择异常,请重试!")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }
    /// 上传图片
    func uploadBackImage(image: UIImage) {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_个人主页背景图修改中".localized)
        loadingAlert.show()
        headerView.bgImageView.image = image
        // 修改用户背景图片 网络请求
        let data = UIImageJPEGRepresentation(image, 1.0)!
        TSUserNetworkingManager().updateUserBgImage(data) { (_, status) in
            loadingAlert.dismiss()
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_个人主页背景图修改成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 单张图片的kf缓存更新
                if let key = TSUtil.praseTSNetFileUrl(netFile: TSCurrentUserInfo.share.userInfo?.bg) {
                    // 清除之前的缓存
                    ImageCache.default.removeImage(forKey: key)
                    // 更新缓存内容
                    ImageCache.default.store(image, forKey: key)
                }
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: "提示信息_个人主页背景图修改失败".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 检测相机
    ///
    /// - Returns: 是否允许
    func checkCamearPermissions() -> Bool {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted {
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相机权限设置", TitleContent: "请为\(appName)开放相机权限：手机设置-隐私-相机-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
            return false
        } else {
            return true
        }
    }

    /// 检测相册
    ///
    /// - Returns: 是否允许
    func PhotoLibraryPermissions() -> Bool {
        let library: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if library == PHAuthorizationStatus.denied || library == PHAuthorizationStatus.restricted {
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
            return false
        } else {
            return true
        }
    }
}
