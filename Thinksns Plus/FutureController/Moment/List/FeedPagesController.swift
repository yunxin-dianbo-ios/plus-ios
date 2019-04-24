//
//  FeedListController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态首页 视图控制器

import UIKit
import ZFPlayer
import Kingfisher

/// 动态列表的类型
enum FeedListType: String {
    case new
    case hot
    case follow
}

class FeedPagesController: TSLabelViewController, ZFPlayerDelegate {
    /// 热门列表
    let hotPage = FeedListActionView(frame: .zero, tableIdentifier: FeedListType.hot.rawValue)
    /// 最新列表
    let newPage = FeedListActionView(frame: .zero, tableIdentifier: FeedListType.new.rawValue)
    /// 关注列表
    let followPage = FeedListActionView(frame: .zero, tableIdentifier: FeedListType.follow.rawValue)
    /// 广告 Banner
    let banner = TSAdvertBanners(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 2))
    /// 还没有被显示的列表内广告
    var advertObjects: [FeedListCellModel] = []
    var playerView: ZFPlayerView!
    var isPlaying = false
    /// 当前显示的视图
    var currentShowPage: FeedListActionView?
    /// 当前正在播放视频的视图
    var currentPlayingView: FeedListActionView?
    /// 当前正在播放视频的cell
    var currentPlayingCell: FeedListCell?
    /// 第一次载入数据正常
    var isFirstLoadSuccess: Bool = false
    // MARK: - 生命周期
    init() {
        let height = UIScreen.main.bounds.height - (64 + 49)
        super.init(labelTitleArray: ["最新", "热门", "关注"], scrollViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
        setUI()
        loadDatabase()
        setPlayerView()
        currentShowPage = hotPage
        setSelectedAt(1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController?.viewControllers.count == 1 && self.playerView != nil && self.isPlaying {
            self.isPlaying = false
            self.playerView.playerPushedOrPresented = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didClickShortVideoShareBtn(_:)), name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didClickAdvertToolBtn(_:)), name: NSNotification.Name(rawValue: "didClickAdvertToolBtn"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
        banner.startAnimation()
        // 注册网络变化监听
        NotificationCenter.default.addObserver(self, selector: #selector(notiNetstatesChange(noti:)), name: Notification.Name.Reachability.Changed, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除网络变化监听
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Reachability.Changed, object: nil)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        banner.stopAnimation()
        if self.navigationController?.viewControllers.count == 2 && self.playerView != nil && self.playerView.isPauseByUser == false {
            self.isPlaying = true
            self.playerView.playerPushedOrPresented = true
        } else {
            self.playerView.resetPlayer()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didClickAdvertToolBtn"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI
    func setUI() {
        // 导航栏右侧按钮进入问题详情页
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_ico_search"), style: .plain, target: self, action: #selector(rightItemClick))
        // 1.热门列表要显示广告 banner
        loadAdvertBanner()

        // 2.设置刷新代理
        followPage.refreshDelegate = self
        hotPage.refreshDelegate = self
        newPage.refreshDelegate = self
        followPage.backgroundColor = UIColor.white
        hotPage.backgroundColor = UIColor.white
        newPage.backgroundColor = UIColor.white
        add(childView: followPage, at: 2)
        add(childView: hotPage, at: 1)
        add(childView: newPage, at: 0)
        hotPage.feedListViewDelegate = self
        newPage.feedListViewDelegate = self
        followPage.feedListViewDelegate = self
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

    /// 增加一个广告的 Banner
    func loadAdvertBanner() {
        // 2.获取 banner 的广告
        let bannerAdverts = TSDatabaseManager().advert.getObjects(type: .feedListTop)
        if bannerAdverts.isEmpty {
            return
        }
        banner.setModels(models: bannerAdverts.map { TSAdvertBannerModel(object: $0) })
        hotPage.tableHeaderView = banner
    }

    // MARK: - Data

    /// 在动态数据最后添加广告
    func addAdvert(to models: inout [FeedListCellModel]) {
        // 1.判断还有没有“没有显示的”广告
        if advertObjects.isEmpty {
            return
        }
        // 2.如果有，取出第一个广告
        let advertObject = advertObjects.first!
        advertObjects.removeFirst()
        // 3.将广告 object 转换成动态的 cellModel，并设置其分页标识和最后一条动态相等
        guard let pageId = models.last?.id["feedId"], let link = advertObject.id.link else {
            return
        }
        advertObject.id = .advert(pageId: pageId, link: link)
        // 6.将广告添加到动态中
        models.append(advertObject)
    }

    /// 加载数据库的数据
    func loadDatabase() {
        advertObjects = TSDatabaseManager().advert.getObjects(type: .feedListIn).map { FeedListCellModel(advert: $0) }
        // 1.关注列表加载数据库数据
        let followDatas = FeedListRealmManager().get(feedlist: .follow).map { FeedListCellModel(object: $0) }
        // 关注要显示加载失败的动态
        followPage.datas = getFaildFeedModels() + followDatas
        followPage.reloadData()

        // 1.热门列表加载数据库数据
        var hotDatas = FeedListRealmManager().get(feedlist: .hot).map { FeedListCellModel(object: $0) }
        // 热门列表要显示列表内容广告
        addAdvert(to: &hotDatas)
        hotPage.datas = hotDatas
        hotPage.reloadData()

        // 1.最新列表加载数据库数据
        let newDatas = FeedListRealmManager().get(feedlist: .new).map { FeedListCellModel(object: $0) }
        // 最新要显示加载失败的动态
        newPage.datas = getFaildFeedModels() + newDatas
        newPage.reloadData()
    }

    /// 将列表动态的数据同步更新到数据库（models 为 nil 则仅清空对应旧数据）
    func save(models: [FeedListCellModel]?, type: FeedListType) {

        // 1.清空旧数据
        FeedListRealmManager().delete(feedlist: type)

        // 2.处理新数据
        guard let models = models else {
            return
        }
        var objects: [FeedListObject] = []
        for (index, model) in models.enumerated() {
            let object = model.object(type)
            object.sortId = index
            objects.append(object)
        }
        switch type {
        case .follow:
            objects = objects.map({ (object) -> FollowFeedListObject in
                return object as! FollowFeedListObject
            })
        case .hot:
            objects = objects.map({ (object) -> HotFeedsListObject in
                return object as! HotFeedsListObject
            })
        case .new:
            objects = objects.map({ (object) -> NewFeedListObject in
                return object as! NewFeedListObject
            })
        }

        // 3.保存新数据到数据库
        FeedListRealmManager().save(feedlist: objects)
    }

    /// 获取数据库中发送失败的动态
    func getFaildFeedModels() -> [FeedListCellModel] {
        let faildMoments = TSDatabaseManager().moment.getFaildSendMoments().map { FeedListCellModel(faildMoment: $0) }
        return faildMoments
    }

    // MARK: - Notification

    func addNotification() {
        /// 正常发布流程发布的动态
        NotificationCenter.default.addObserver(self, selector: #selector(addNewFeed(_:)), name: NSNotification.Name.Moment.AddNew, object: nil)
        /// 话题详情页发布的动态
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTopicFeed(_:)), name: NSNotification.Name.Moment.TopicAddNew, object: nil)
        /// 添加游客通知
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFirstPage), name: NSNotification.Name.Visitor.login, object: nil)
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
    /// 重新刷新第一页
    func reloadFirstPage() {
        newPage.mj_header.beginRefreshing()
        hotPage.mj_header.beginRefreshing()
        followPage.mj_header.beginRefreshing()
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
        var shareContent = ""
        if let content = currentPlayingCell?.model.content {
            shareContent = content
        } else {
            shareContent = defaultContent
        }
        let shareView = ShareView()
        shareView.show(URLString: ShareURL.feed.rawValue + "\(feedId)", image: image, description: shareContent, title: TSAppSettingInfoModel().appDisplayName + " " + "动态")
    }

    func didClickAdvertToolBtn(_ sender: Notification) {
        guard let cell: FeedListCell = sender.userInfo?["FeedListCell"] as? FeedListCell, let link = cell.model.id.link else {
            return
        }
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let shareView = ShareView()
        shareView.shareUrlString = link
        shareView.show(URLString: nil, image: cell.picturesView.pictures.first ?? UIImage(named: "IMG_icon"), description: cell.model.content.isEmpty ? defaultContent : cell.model.content, title: TSAppSettingInfoModel().appDisplayName + " " + "动态")
    }

    func shareFeedAction(link: String, title: String, description: String, image: UIImage?) -> TSAlertAction {
        // 当分享内容为空时，显示默认内容
        let image = image ?? UIImage(named: "IMG_icon")
        let title = title.isEmpty ? TSAppSettingInfoModel().appDisplayName + " " + "动态" : title
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let description = description.isEmpty ? defaultContent : description
        // 创建 action
        let action = TSAlertAction(title:"选择_分享".localized, style: .default, handler: { (_) in
            let shareView = ShareView()
            shareView.shareUrlString = link
            shareView.show(URLString: nil, image: image, description: description, title: title)
        })
        return action
    }

    /// 添加话题下面发布的新动态
    func addNewTopicFeed(_ notification: Notification) {
        // 2.解析通知发送的信息
        let notiInfo = notification.userInfo
        // 如果信息里同时有 oldId 和 newId，说明某个动态发送成功了
        if let newId = notiInfo?["newId"] as? Int, let oldId = notiInfo?["oldId"] as? Int {
            self.updateNewFeedSendStatus(oldId: oldId, newId: newId)
            return
        }
        // 如果信息里只有 oldId，说明某个动态发送失败了
        if let oldFeedId = notiInfo?["oldId"] as? Int {
            self.updateNewFeedSendStatus(oldId: oldFeedId, newId: nil)
            return
        }
        // 如果信息里有 newFeedId，说明某个动态刚刚创建，正在发送中
        if let feedId = notification.userInfo?["newFeedId"] as? Int {
            self.addNewFeedToList(newFeedId: feedId)
            self.newPage.scrollToRow(at: IndexPath(item: self.newPage.pinnedCounts, section: 0), at: .top, animated: false)
            return
        }
    }

    /// 添加用户发布的新动态
    func addNewFeed(_ notification: Notification) {
        // 2.解析通知发送的信息
        let notiInfo = notification.userInfo
        // 如果信息里同时有 oldId 和 newId，说明某个动态发送成功了
        if let newId = notiInfo?["newId"] as? Int, let oldId = notiInfo?["oldId"] as? Int {
            self.updateNewFeedSendStatus(oldId: oldId, newId: newId)
            return
        }
        // 如果信息里只有 oldId，说明某个动态发送失败了
        if let oldFeedId = notiInfo?["oldId"] as? Int {
            self.updateNewFeedSendStatus(oldId: oldFeedId, newId: nil)
            return
        }
        // 如果信息里有 newFeedId，说明某个动态刚刚创建，正在发送中
        if let feedId = notification.userInfo?["newFeedId"] as? Int {
            self.addNewFeedToList(newFeedId: feedId)
            self.setSelectedAt(0)
            self.newPage.scrollToRow(at: IndexPath(item: self.newPage.pinnedCounts, section: 0), at: .top, animated: false)
            /// 如果是转发的内容，就保持当前的视图结构不变，不做跳转
            if let isRepost = notification.userInfo?["isRepost"] as? Bool, isRepost == true {
                // 不跳转
            } else {
                TSRootViewController.share.tabbarVC?.selectedIndex = 0
            }
            return
        }
    }

    /// 更新某个新发动态的发送状态，newId 为 nil 表示动态发送失败
    func updateNewFeedSendStatus(oldId: Int, newId: Int?) {
        // 1.最新列表
        if let newFeedModel = newPage.datas.first(where: { $0.id["feedId"] == oldId }) {
            if let newId = newId {
                newFeedModel.id = .feed(feedId: newId)
                newFeedModel.sendStatus = .success
            } else {
                newFeedModel.sendStatus = .faild
            }
            newPage.reloadData()
        }
        // 2.关注列表
        if let newFeedModel = followPage.datas.first(where: { $0.id["feedId"] == oldId }) {
            if let newId = newId {
                newFeedModel.id = .feed(feedId: newId)
                newFeedModel.sendStatus = .success
            } else {
                newFeedModel.sendStatus = .faild
            }
            followPage.reloadData()
        }
    }

    /// 添加新创建的动态到列表上
    func addNewFeedToList(newFeedId feedId: Int) {
        // 1. 获取 feed object
        guard let feedObject = TSDatabaseMoment().getList(feedId) else {
            return
        }
        // 2.获取用户信息
        guard let userInfo = TSCurrentUserInfo.share.userInfo else {
            return
        }
        // 3.创建新动态的数据模型 newFeedModel
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
        avatarInfo.verifiedType = userInfo.verified?.type ?? ""
        avatarInfo.verifiedIcon = userInfo.verified?.icon ?? ""
        let pictures = Array(feedObject.pictures).map { PaidPictureModel(imageObject: $0) }
        let topicInfo = Array(feedObject.topics).map { TopicListModel(object: $0) }
        let rightTime = TSDate().dateString(.normal, nsDate: feedObject.create as NSDate)
        let newFeedModel = FeedListCellModel(feedId: feedId, userId: userInfo.userIdentity, userName: userInfo.name, avatarInfo: avatarInfo, content: feedObject.content, pictures: pictures, rightTime: rightTime, topicInfo: topicInfo)
        if let shortVideoOutputUrl = feedObject.shortVideoOutputUrl {
            newFeedModel.localVideoFileURL = shortVideoOutputUrl
        }
        if let videoURL = feedObject.videoURL {
            newFeedModel.videoURL = videoURL
        }
        /// 转发的内容
        newFeedModel.repostId = feedObject.repostID
        newFeedModel.repostType = feedObject.repostType
        newFeedModel.repostModel = feedObject.repostModel
        // 4.将 newFeedModel 添加到列表中
        // 新加入的内容为置顶内容的下一条，并滚动到该行
        newPage.datas.insert(newFeedModel, at: newPage.pinnedCounts)
        followPage.datas.insert(newFeedModel, at: followPage.pinnedCounts)
        newPage.insertRow(at: IndexPath(item: newPage.pinnedCounts, section: 0), with: .none)
        followPage.insertRow(at: IndexPath(item: followPage.pinnedCounts, section: 0), with: .none)
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
        self.playerView.playerControlView(CustomPlayerControlView(), playerModel: playModel)
        self.playerView.playerLayerGravity = ZFPlayerLayerGravity.resizeAspect
        self.playerView.hasDownload = true
        self.playerView.delegate = self
        self.playerView.autoPlayTheVideo()
        self.currentPlayingView = feedListView
        self.currentPlayingCell = feedListView.cellForRow(at: indexPath) as? FeedListCell
    }

    override func selectedPageChangedTo(index: Int) {
        var feedListView: FeedListActionView?
        switch index {
        case 0:
            feedListView = newPage
        case 1:
            feedListView = hotPage
        case 2:
            feedListView = followPage
        default:
            break
        }
        guard let currentPage = feedListView else {
            return
        }
        currentShowPage = currentPage
        if let _ = currentPage.getPlayVideoInVisiableCellIndexPath() {
            if currentPage == currentPlayingView {
                // 继续播放
                self.playerView.play()
            } else {
                // 获取新页面的可播放下标 有 而且当前播放播放的页面不是新页面 就播放新的 重置正在播放的
                self.playerView.pause()
            }
        } else {
            // 暂停播放
            self.playerView.pause()
        }
    }

    func rightItemClick() {
        let aggregateSearchVC = TSAggregateSearchVC()
        self.navigationController?.pushViewController(aggregateSearchVC, animated: true)
    }
    func zf_playerDownload(_ url: String!) {
        TSUtil.share().showDownloadVC(videoUrl: url)
    }
}

extension FeedPagesController: FeedListActionViewDelegate {
    func didClickVideoCell(_ feedListView: FeedListActionView, cellIndexPath: IndexPath, fatherViewTag: Int) {
        // 判断网络然后决定是否播放
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
            })
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        }
    }

    func canPlayVideoCell(_ feedListView: FeedListActionView, indexPath: IndexPath) {
        // 关闭了自动播放
//        if TSAppConfig.share.reachabilityStatus == .WIFI {
//            playVideoWith(feedListView, indexPath: indexPath)
//        }
    }
}

// MARK: - FeedListViewRefreshDelegate: 列表刷新代理
extension FeedPagesController: FeedListViewRefreshDelegate {

    // MARK: 代理方法
    /// 下拉刷新
    func feedListTable(_ table: FeedListActionView, refreshingDataOf tableIdentifier: String) {
        // 0.获取列表的类型
        guard let type = FeedListType(rawValue: tableIdentifier) else {
            return
        }
        // 1.如果在游客模式下，不用请求关注列表的数据
        if type == .follow && !TSCurrentUserInfo.share.isLogin {
            table.mj_header.endRefreshing()
            return
        }
        // 游客模式下不能刷新
        if self.isFirstLoadSuccess == true && !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            table.mj_header.endRefreshing()
            return
        }
        // 重置广告数据
        advertObjects = TSDatabaseManager().advert.getObjects(type: .feedListIn).map { FeedListCellModel(advert: $0) }
        // 2.发起网络请求
        FeedListNetworkManager.getTypeFeeds(type: tableIdentifier, after: nil) { [weak self] (model: FeedListResultsModel?, message: String?, status: Bool) in
            // 3.根据列表类型，对数据进行不同的处理
            var feedModels: [FeedListCellModel]?
            switch type {
            case .hot:
                table.curentPage = 0
                self?.processReloadHotDatas(model, complete: { (feedListCellModels, pinnedCounts) in
                    feedModels = feedListCellModels
                    table.pinnedCounts = pinnedCounts
                    if feedModels?.isEmpty == false {
                        self?.isFirstLoadSuccess = true
                    }
                    /// 请求成功的数据再刷新本地缓存
                    if status {
                        // 4.同步数据到数据库
                        self?.save(models: feedModels, type: type)
                    }
                    // 5.刷新 table 的界面
                    table.processRefresh(data: feedModels, message: message, status: status)
                })
            case .new:
                self?.processReloadNewDatas(model, complete: { (feedListCellModels, pinnedCounts) in
                    feedModels = feedListCellModels
                    table.pinnedCounts = pinnedCounts
                    /// 请求成功的数据再刷新本地缓存
                    if status {
                        // 4.同步数据到数据库
                        self?.save(models: feedModels, type: type)
                    }
                    // 5.刷新 table 的界面
                    table.processRefresh(data: feedModels, message: message, status: status)
                })
            case .follow:
                self?.processReloadFollowDatas(model, complete: { (feedListCellModels, pinnedCounts) in
                    feedModels = feedListCellModels
                    table.pinnedCounts = pinnedCounts
                    /// 请求成功的数据再刷新本地缓存
                    if status {
                        // 4.同步数据到数据库
                        self?.save(models: feedModels, type: type)
                    }
                    // 5.刷新 table 的界面
                    table.processRefresh(data: feedModels, message: message, status: status)
                })
            }
        }
    }

    /// 上拉加载
    func feedListTable(_ table: FeedListView, loadMoreDataOf tableIdentifier: String) {
        // 游客模式下不能加载
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            table.mj_footer.endRefreshing()
            table.mj_footer.isHidden = true
            return
        }

        // 1.发起网络请求
        var id: Int? = nil
        if tableIdentifier == "hot" {
            /// 热门的分页是hot字段分页,广告里边只有feedId
            /// 找到最后一条不是广告的动态,并获取他的hot值
            for model in table.datas.reversed() {
                if let adLink = model.id.link, adLink.isEmpty == false {
                    /// 广告
                } else {
                    id = model.hot
                    break
                }
            }
        } else {
            id = table.after
        }
        FeedListNetworkManager.getTypeFeeds(type: tableIdentifier, after: id) { [weak self] (model: FeedListResultsModel?, message: String?, status: Bool) in
            // 2.处理数据
            var feedModels: [FeedListCellModel]?
            if let model = model {
                feedModels = model.feeds.map { FeedListCellModel(feedListModel: $0) }
                // 3.如果是热门，要显示列表内广告
                if tableIdentifier == FeedListType.hot.rawValue {
                    self?.addAdvert(to: &feedModels!)
                }
            }
            table.processloadMore(data: feedModels, message: message, status: status)
        }
    }

    // MARK: 处理数据的方法。分开写，方便后面的人更改和理解

    /// 处理下拉刷新的热门数据
    func processReloadHotDatas(_ originalModel: FeedListResultsModel?, complete: @escaping ([FeedListCellModel]?, Int) -> Void) {
        guard let model = originalModel else {
            complete(nil, 0)
            return
        }
        var models: [FeedListCellModel] = []
        var pinnedCounts: Int = 0
        // 1.热门要显示置顶的动态
        let pinnedModels = model.pinned.map { (model) -> FeedListCellModel in
            let cellModel = FeedListCellModel(feedListModel: model)
            cellModel.showTopIcon = true // 显示置顶标签
            return cellModel
        }
        models += pinnedModels
        pinnedCounts = pinnedModels.count
        // 2.热门要显示普通动态
        var feedModels = model.feeds.map { FeedListCellModel(feedListModel: $0) }
        if pinnedModels.isEmpty {
            models += feedModels
        } else {
            var indexArray = [Int]()
            for (index, model) in feedModels.enumerated() {
                for pinned in pinnedModels {
                    if model.id["feedId"] == pinned.id["feedId"] {
                        indexArray.append(index)
                    }
                }
            }
            for (index, itemIndex) in indexArray.enumerated() {
                feedModels.remove(at: itemIndex - index)
            }
            models += feedModels
        }
        save(models: models, type: .hot)

        // 3.热门要显示列表内广告
        addAdvert(to: &models)
        complete(models, pinnedCounts)
    }

    /// 处理下拉刷新的最新数据
    func processReloadNewDatas(_ originalModel: FeedListResultsModel?, complete: @escaping ([FeedListCellModel]?, Int) -> Void) {
        guard let model = originalModel else {
            complete(nil, 0)
            return
        }
        var pinnedCounts: Int = 0
        var models: [FeedListCellModel] = []
        // 1.最新要显示置顶动态
        let pinnedModels = model.pinned.map { (model) -> FeedListCellModel in
            let cellModel = FeedListCellModel(feedListModel: model)
            cellModel.showTopIcon = true // 显示置顶标签
            return cellModel
        }
        models += pinnedModels
        pinnedCounts = pinnedModels.count
        // 2.最新要显示发送失败的动态
        models += getFaildFeedModels()
        // 3.最新要显示普通动态
        var feedModels = model.feeds.map { FeedListCellModel(feedListModel: $0) }
        if pinnedModels.isEmpty {
            models += feedModels
        } else {
            var indexArray = [Int]()
            for (index, model) in feedModels.enumerated() {
                for pinned in pinnedModels {
                    if model.id["feedId"] == pinned.id["feedId"] {
                        indexArray.append(index)
                    }
                }
            }
            for (index, itemIndex) in indexArray.enumerated() {
                feedModels.remove(at: itemIndex - index)
            }
            models += feedModels
        }
        complete(models, pinnedCounts)
    }

    /// 处理下拉刷新的关注数据
    func processReloadFollowDatas(_ originalModel: FeedListResultsModel?, complete: @escaping ([FeedListCellModel]?, Int) -> Void) {
        guard let model = originalModel else {
            complete(nil, 0)
            return
        }
        var models: [FeedListCellModel] = []

        // 1.关注要显示发送失败的动态
        models += getFaildFeedModels()
        // 2.关注要显示普通动态
        models += model.feeds.map { FeedListCellModel(feedListModel: $0) }
        complete(models, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.default.clearMemoryCache()
    }
}

// MARK: - UIScrollowDelegate
extension FeedPagesController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if TSCurrentUserInfo.share.isLogin == false {
            if scrollView.contentOffset.x > UIScreen.main.bounds.width {
                // 就不滚了 就显示页面
                scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width, y: 0), animated: true)
                // 当游客滑动到关注页面后
                TSRootViewController.share.guestJoinLoginVC()
                return
            }
        }
        super.scrollViewDidScroll(scrollView)
    }
}
