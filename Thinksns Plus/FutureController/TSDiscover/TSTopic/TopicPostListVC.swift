//
//  TopicPostListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController
import ZFPlayer

class TopicPostListVC: UIViewController, TSBeforeReleaseViewDelegate, TZImagePickerControllerDelegate, ZFPlayerDelegate {

    enum PostsType: String {
        /// 最新帖子
        case latest = "latest_post"
        /// 最新回复
        case reply = "latest_reply"
    }

    /// 话题 id
    var groupId = 0
    /// 帖子类型
    var postsType = PostsType.latest
    /// 左边视图
    let leftView = UIView()
    /// 导航视图
    let navView = TopicListNavView()
    /// header view
    let headerView = TopicListHeaderView()
    /// 数据 model
    var model = PostListControllerModel()
    /// 数据 model
    var topicListModel = TopicListControllerModel()
    /// 列表视图
    let table = TopicFeedListView(frame: UIScreen.main.bounds, tableIdentifier: "topicPostlist")
    /// 发布按钮
    var buttonForRelease = TSButton(type: .custom)
    // 发布按钮大小
    let publishbuttonSize: CGFloat = 49
    /// 发布视图
    var thebfview: TSBeforeReleaseView!
    /// 蒙板视图（当右边视图显示时，用来遮挡左边视图的蒙板）
    let maskView = UIControl()
    var playerView: ZFPlayerView!
    var isPlaying = false
    /// 当前正在播放视频的视图
    var currentPlayingView: TopicFeedListView?
    /// 当前正在播放视频的cell
    var currentPlayingCell: FeedListCell?
    var groupModel = GroupModel()
    var topicModel = TopicModel()

    init(groupId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.groupId = groupId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNotification()
        loading()
        setUI()
        loadData()
        setPlayerView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController?.viewControllers.count == 1 && self.playerView != nil && self.isPlaying {
            self.isPlaying = false
            self.playerView.playerPushedOrPresented = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didClickShortVideoShareBtn(_:)), name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
        self.navigationController?.navigationBar.isHidden = true
        // 更新导航栏右方按钮的位置
        navView.updateRightButtonFrame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
        /// 销毁创建话题页面
        dismissCreatTopicVC()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
        // 更新状态栏的颜色
        UIApplication.shared.statusBarStyle = .default
        if self.navigationController?.viewControllers.count == 2 && self.playerView != nil && self.playerView.isPauseByUser == false {
            self.isPlaying = true
            self.playerView.playerPushedOrPresented = true
        } else {
            self.playerView.resetPlayer()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didClickShortVideoShareBtn"), object: nil)
    }

    // MARK: - 销毁创建话题页面
    func dismissCreatTopicVC() {
        if let vcs = self.navigationController?.viewControllers {
            let vcArray = NSMutableArray(array: vcs)
            for item in vcArray {
                if item is CreatTopicVC {
                    vcArray.remove(item)
                    break
                }
            }
            self.navigationController?.setViewControllers(vcArray as! [UIViewController], animated: false)
        }
    }

    // MARK: - UI

    func setUI() {
        view.backgroundColor = .white
        // 1.加载左边视图
        leftView.frame = UIScreen.main.bounds
        // 1.1 导航视图
        navView.delegate = self
        // 1.2 帖子 table
//        table.groupId = groupId
        table.showTopics = false
        table.cellTopicId = groupId
        table.mj_header = nil
        table.refreshDelegate = self
        table.feedListViewDelegate = self
        table.scrollDelegate = self
        table.set(placeholderContentInset: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        // 1.3 header 视图
        headerView.set(taleView: table)
        headerView.delegate = self
        // 3.发布按钮
        buttonForRelease.setImage(UIImage(named: "ico_topic_release"), for: .normal)
        buttonForRelease.contentMode = .center
        buttonForRelease.sizeToFit()
        buttonForRelease.frame = CGRect(x: UIScreen.main.bounds.width - self.publishbuttonSize - 25, y: view.frame.height - self.publishbuttonSize - 25 - TSBottomSafeAreaHeight, width: self.publishbuttonSize, height: self.publishbuttonSize)
        buttonForRelease.addTarget(self, action: #selector(releaseButtonTaped), for: .touchUpInside)

        leftView.addSubview(table)
        leftView.addSubview(navView)
        leftView.addSubview(buttonForRelease)
        view.addSubview(leftView)
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

    // MARK: - Data
    func loadData() {

        // 获取话题详情信息
        TSUserNetworkingManager().getTopicInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.topicModel = model
            self?.loadTopic(model: TopicListControllerModel(topicModel: model))
            // 2.加载帖子视图
            self?.refresh()
        }
    }

    func loadTopic(model: TopicListControllerModel) {
        self.topicListModel = model
        // 1.加载 section view
        let sectionModel = FilterSectionViewModel()
        sectionModel.countInfo = "\(model.postCount)条动态 \(model.followCount)人关注"
        sectionModel.followStatus = model.followStatus
        sectionModel.hidFolloeButton = model.ownerUserId == TSCurrentUserInfo.share.userInfo?.userIdentity ? true : false
        table.sectionViewType = .topic(sectionModel, self)
        // 2.加载 header 视图
        headerView.load(contentModel: model)
        navView.setTitle(model.name)
        // 4.table
//        table.role = model.role
        table.reloadData()
    }

    // MARK: - Action
    /// 点击了发布按钮
    func releaseButtonTaped() {
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 显示顺序：文字、图片、视图
        thebfview = TSBeforeReleaseView(frame: self.view.frame, images: [#imageLiteral(resourceName: "IMG_ico_word"), #imageLiteral(resourceName: "IMG_ico_potoablum"), #imageLiteral(resourceName: "ico_video")], titles: ["显示_文字".localized, "显示_图片".localized, "视频"])
        thebfview.tag = 250
        thebfview.TSBeforeReleaseViewDelegate = self
        self.view.addSubview(thebfview)
    }

    // TSBeforeReleaseViewDelegate
    func indexOfBtnArray(_ releaseView: TSBeforeReleaseView, _ index: Int?, _ title: String?) {
        // let index = index
        guard let title = title else {
            return
        }
        switch title {
        case "显示_文字".localized:
            let releasePulseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
            let chooseTopic: TopicCommonModel = TopicCommonModel(topicModel: topicModel)
            releasePulseVC.topics.append(chooseTopic)
            releasePulseVC.chooseModel = chooseTopic
            let navigation = TSNavigationController(rootViewController: releasePulseVC)
            self.present(navigation, animated: true, completion: nil)
        case "显示_图片".localized:
            checkPhotoAuthorizeStatus()
        case "视频":
            checkShortVideoAuthorizeStatus()
        default:
            break
        }
    }

    /// 查看相册授权，显示相册查看器
    func checkPhotoAuthorizeStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied, .restricted:
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [weak self] (newState) in
                if newState == .authorized {
                    self?.showImagePickerVC()
                }
            })
        case .authorized:
            showImagePickerVC()
        }
    }

    func checkShortVideoAuthorizeStatus() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        let audioStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if photoStatus == .authorized && cameraStatus == .authorized && audioStatus == .authorized {
            showShortVideoPickerVC()
            return
        }
        if photoStatus == .notDetermined && cameraStatus == .notDetermined && audioStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ [weak self] (newState) in
                guard newState == .authorized else {
                    return
                }
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                    guard granted == true else {
                        return
                    }
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { [weak self] (granted) in
                        guard granted == true else {
                            return
                        }
                        self?.showShortVideoPickerVC()
                    })
                })
            })
            return
        }
        if photoStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ [weak self] (newState) in
                guard newState == .authorized else {
                    return
                }
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                    guard granted == true else {
                        return
                    }
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { [weak self] (granted) in
                        guard granted == true else {
                            return
                        }
                        self?.showShortVideoPickerVC()
                    })
                })
            })
            return
        }
        if cameraStatus == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                guard granted == true else {
                    return
                }
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { [weak self] (granted) in
                    guard granted == true else {
                        return
                    }
                    self?.showShortVideoPickerVC()
                })
            })
            return
        }
        if audioStatus == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { [weak self] (granted) in
                guard granted == true else {
                    return
                }
                self?.showShortVideoPickerVC()
            })
            return
        }
        switch photoStatus {
        case .denied, .restricted:
            // 2.取消了授权
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
        case .notDetermined:
            break
        case .authorized:
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                let appName = TSAppConfig.share.localInfo.appDisplayName
                TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    if UIApplication.shared.canOpenURL(url!) {
                        UIApplication.shared.openURL(url!)
                    }
                })
            case .notDetermined:
                break
            case .authorized:
                switch audioStatus {
                case .denied, .restricted:
                    // 2.取消了授权
                    let appName = TSAppConfig.share.localInfo.appDisplayName
                    TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                        let url = URL(string: UIApplicationOpenSettingsURLString)
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.openURL(url!)
                        }
                    })
                case .notDetermined:
                    break
                case .authorized:
                    showShortVideoPickerVC()
                }
            }
        }
    }

    func showImagePickerVC() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self, mainColor: TSColor.main.theme)
            else {
                return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #图片选择列表页面
        /// item右上角蓝色的选中图片
//            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")

        //设置默认为中文，不跟随系统
        imagePickerVC.preferredLanguage = "zh-Hans"
        imagePickerVC.maxImagesCount = 9
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowPickingImage = true
        imagePickerVC.allowPickingGif = true
        imagePickerVC.allowPickingMultipleVideo = true
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
    }

    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        let releasePulseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: photos.isEmpty)
        let chooseTopic: TopicCommonModel = TopicCommonModel(topicModel: topicModel)
        releasePulseVC.topics.append(chooseTopic)
        releasePulseVC.chooseModel = chooseTopic
        let navigation = TSNavigationController(rootViewController: releasePulseVC)
        releasePulseVC.selectedPHAssets = assets as! [PHAsset]
        self.present(navigation, animated: true, completion: nil)
    }

    func showShortVideoPickerVC() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true) else {
            return
        }
        imagePickerVC.isSelectOriginalPhoto = false
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingVideo = true
        imagePickerVC.allowPickingImage = false
        imagePickerVC.allowPickingGif = false
        imagePickerVC.allowPickingMultipleVideo = false
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
    }

    // MARK: - Notification

    func setNotification() {
        // 监听“圈内搜索点击了’去发帖‘按钮”
        NotificationCenter.default.addObserver(self, selector: #selector(inGroupSearchReleaseButtonTaped(_:)), name: NSNotification.Name.Post.SearchReleasePost, object: nil)
        // 圈子信息更新
        NotificationCenter.default.addObserver(self, selector: #selector(notiResReloadGroupInfo(noti:)), name: NSNotification.Name.Group.uploadGroupInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showReleaseButtonAnimation(notice:)), name: NSNotification.Name(rawValue: "showReleaseButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideReleaseButtonAnimation(notice:)), name: NSNotification.Name(rawValue: "hideReleaseButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTopicDetail), name: NSNotification.Name(rawValue: "reloadTopicDetailVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addNewFeed(_:)), name: NSNotification.Name.Moment.TopicAddNew, object: nil)
    }

    /// 圈内搜索点击了“去发帖“按钮
    func inGroupSearchReleaseButtonTaped(_ noti: Notification) {
        guard let notiGroupId = noti.userInfo?["groupId"] as? Int, notiGroupId == groupId else {
            return
        }
        releaseButtonTaped()
    }

    func notiResReloadGroupInfo(noti: Notification) {
        let notiInfo = noti.object as! Dictionary<String, Any>
        if let notiGroupId: Int = notiInfo["groupId"] as? Int, let type: String = notiInfo["type"] as? String, let count: Int = notiInfo["count"] as? Int {
            if self.groupId == notiGroupId {
                if type == "removeMember" {
                    self.model.memberCount = self.model.memberCount - count
                } else if type == "removeBlack" {
                    self.model.blackCount = self.model.blackCount - count
                } else if type == "addBlack" {
                    self.model.blackCount = self.model.blackCount + count
                }
            }
        }
        /// 更新圈子信息
        // editGroupInfo
        if let notiGroupId: Int = notiInfo["groupId"] as? Int, let type: String = notiInfo["type"] as? String, let groupModel: GroupModel = notiInfo["groupModel"] as? GroupModel {
            if self.groupId == notiGroupId && type == "editGroupInfo" {
                self.model = PostListControllerModel(groupModel: groupModel)
                // 1.加载 section view
                let sectionModel = FilterSectionViewModel()
                sectionModel.countInfo = "\(model.postCount)条动态"
                table.sectionViewType = .topic(sectionModel, self)
                // 2.加载 header 视图
//                headerView.load(contentModel: model)
                // 4.table
//                table.role = model.role
                table.reloadData()
            }
        }
    }

    /// 视频选择代理
    func imagePickerControllerDidClickTakePhotoBtn(_ picker: TZImagePickerController!) {
        // 进入视频录制
        // 视频录制完毕后 进入发布页面
        let vc = RecorderViewController(minDuration: TSAppConfig.share.localInfo.postMomentsRecorderVideoMinDuration, maxDuration: TSAppConfig.share.localInfo.postMomentsRecorderVideoMaxDuration)
        vc.delegate = self
        let nav = TSNavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    func imagePickerController(_ picker: TZImagePickerController!, didFinishEditVideoCover coverImage: UIImage!, videoURL: Any!) {
        TSLogCenter.log.debug(coverImage)
        TSLogCenter.log.debug(videoURL)
        let vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
        vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: videoURL as? URL)
        let chooseTopic: TopicCommonModel = TopicCommonModel(topicModel: topicModel)
        vc.topics.append(chooseTopic)
        vc.chooseModel = chooseTopic
        let nav = TSNavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    // 视频长度超过5分钟少于4秒钟的都不显示
    func isAssetCanSelect(_ asset: Any!) -> Bool {
        guard let asset = asset as? PHAsset else {
            return false
        }
        if asset.mediaType == .video {
            return asset.duration < 5 * 60 && asset.duration > 3
        } else {
            return true
        }
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
}

extension TopicPostListVC: RecorderVCDelegate {
    func finishRecorder(recordSession: SCRecordSession, coverImage: UIImage) {
        let vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
        vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: recordSession, videoFileURL: nil)
        let chooseTopic: TopicCommonModel = TopicCommonModel(topicModel: topicModel)
        vc.topics.append(chooseTopic)
        vc.chooseModel = chooseTopic
        let nav = TSNavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension TopicPostListVC: LoadingViewDelegate {

    func reloadingButtonTaped() {
        loadData()
    }

    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}

extension TopicPostListVC: TopicFeedListViewDelegate {
    func didClickVideoCell(_ feedListView: TopicFeedListView, cellIndexPath: IndexPath, fatherViewTag: Int) {
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
            present(alert, animated: false, completion: nil)
        } else if TSAppConfig.share.reachabilityStatus == .NotReachable {
            // 弹窗 然后继续播放
            let alert = TSAlertController(title: "提示", message: "网络未连接，请检查网络", style: .actionsheet, sheetCancelTitle: "停止播放")
            let action = TSAlertAction(title:"继续播放", style: .default, handler: { [weak self] (_) in
                self?.playVideoWith(feedListView, indexPath: cellIndexPath)
            })
            alert.addAction(action)
            present(alert, animated: false, completion: nil)
        }
    }

    func canPlayVideoCell(_ feedListView: TopicFeedListView, indexPath: IndexPath) {
        // 关闭了自动播放
        //        if TSAppConfig.share.reachabilityStatus == .WIFI {
        //            playVideoWith(feedListView, indexPath: indexPath)
        //        }
    }
}

// MARK: - 帖子列表刷新代理事件
extension TopicPostListVC: FeedListViewRefreshDelegate {
    /// 上拉加载
    func feedListTable(_ table: FeedListView, loadMoreDataOf tableIdentifier: String) {
        TSUserNetworkingManager().getTopicMomentList(topicID: groupId, offset:   self.table.datas.last?.index) { [weak self] (model, message, status) in
            self?.navView.indicator.dismiss()
            var datas: [FeedListCellModel]?
            if let model = model {
                datas = []
                datas?.append(contentsOf: model.map { FeedListCellModel(feedListModel: $0) })
            } else {
                self?.table.curentPage = (self?.table.curentPage)! - 1
            }
            self?.table.processloadMore(data: datas, message: nil, status: true)
        }
    }
}
// MARK: - 帖子列表滚动代理事件
extension TopicPostListVC: FeedListViewScrollowDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2.更新导航视图的动画效果
        // 这里需要把 offset 处理一下，移除 headerView 引起的 table inset 偏移的影响
        let offset = -(scrollView.contentOffset.y + headerView.stretchModel.headerHeightMin)
        // 3.当下拉到一定程度的时候，发起下拉刷新操作
        if offset > (TSStatusBarHeight + 25) {
            // 如果下拉刷新正在进行，就什么都不做
            if navView.indicator.isAnimating {
                return
            }
            // 发起下拉刷新操作
            refresh()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1.更新 header view 的动画效果
        headerView.updateChildviews(tableOffset: scrollView.contentOffset.y)
        let offset = -(scrollView.contentOffset.y + headerView.stretchModel.headerHeightMin)
        navView.updateChildView(offset: offset, buttonKeepBlack: topicModel.avatar == nil)
    }

    // 下拉刷新
    func refresh() {
        navView.indicator.starAnimationForFlowerGrey() // 显示小菊花
        self.table.curentPage = 0

        // 获取话题下动态列表
        TSUserNetworkingManager().getTopicMomentList(topicID: groupId, offset: nil) { [weak self] (model, message, status) in
                self?.navView.indicator.dismiss()
            self?.navView.indicator.dismiss()
            var datas: [FeedListCellModel] = []
            if let model = model {
                datas += self?.getFaildTopicFeedModels() ?? []
                datas.append(contentsOf: model.map { FeedListCellModel(feedListModel: $0) })
            }
            self?.table.processRefresh(data: datas, message: nil, status: true)
        }

        // 获取话题详情信息
        TSUserNetworkingManager().getTopicInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.topicModel = model
            self?.loadTopic(model: TopicListControllerModel(topicModel: model))
        }
    }

    /// 处理下拉刷新的关注数据
    func processReloadFollowDatas(_ originalModel: FeedListResultsModel?, complete: @escaping ([FeedListCellModel]?, Int) -> Void) {
        guard let model = originalModel else {
            complete(nil, 0)
            return
        }
        var models: [FeedListCellModel] = []
        // 1.关注要显示发送失败的动态
        models += self.getFaildFeedByTopicModels()
        // 2.关注要显示普通动态
        models += model.feeds.map { FeedListCellModel(feedListModel: $0) }
        complete(models, 0)
    }
    /// 获取数据库中发送失败的动态
    func getFaildFeedByTopicModels() -> [FeedListCellModel] {
        let faildMoments = TSDatabaseManager().moment.getFaildSendMomentsByTopicId(topicId: groupId).map { FeedListCellModel(faildMoment: $0) }
        return faildMoments
    }

    // 下拉刷新
    func refreshTopicDetail() {
        navView.indicator.starAnimationForFlowerGrey() // 显示小菊花
        self.table.curentPage = 0
        // 获取话题详情信息
        TSUserNetworkingManager().getTopicInfo(groupId: groupId) { [weak self] (model, message, status) in
             self?.navView.indicator.dismiss()
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.topicModel = model
            self?.loadTopic(model: TopicListControllerModel(topicModel: model))
        }
    }
}

// MARK: - 导航栏视图代理事件
extension TopicPostListVC: TopicListNavViewDelegate {

    /// 返回按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedLeftButton: TSButton) {
        TSUtil.popViewController(currentVC: self, animated: true)
    }

    /// 更多按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedRightButton: TSButton) {
        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
        if topicListModel.ownerUserId == TSCurrentUserInfo.share.userInfo?.userIdentity {
            let action = TSAlertAction(title: "编辑", style: .default, handler: { [weak self] (_) in
                guard let model = self?.topicListModel else {
                    return
                }
                let creatVC = CreatTopicVC()
                creatVC.isEditPush = true
                creatVC.topicListModel = model
                self?.navigationController?.pushViewController(creatVC, animated: true)
            })
            alert.addAction(action)
        } else {
            let action = TSAlertAction(title: "举报", style: .default, handler: { [weak self] (_) in
                guard let model = self?.topicModel else {
                    return
                }
                let informModel = ReportTargetModel(topic: model)
                let informVC = ReportViewController(reportTarget: informModel)
                self?.navigationController?.pushViewController(informVC, animated: true)
            })
            alert.addAction(action)
        }
        present(alert, animated: false, completion: nil)
        return
    }

    /// 分享按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedShareButton: UIButton) {
        guard let image = headerView.bgImageView.image else {
            return
        }
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let shareView = ShareView()
        var url = ShareURL.groupsList.rawValue
        url.replaceAll(matching: "replacegroup", with: "\(model.id)")
        url.replaceAll(matching: "replacefetch", with: postsType.rawValue)
        let shareContent = model.intro.count > 0 ? model.intro : defaultContent
        let shareTitle = model.name.count > 0 ? model.name : TSAppSettingInfoModel().appDisplayName + " " + "帖子"
        shareView.show(URLString: url, image: image, description: shareContent, title: shareTitle)
    }
}

// MARK: - header 代理事件
extension TopicPostListVC: TopicListHeaderViewDelegate {
    /// 跳转到话题参与者列表页面
    func jumpToMenberListVC(_ topicListHeaderView: TopicListHeaderView, topicId: Int) {
        let menberList = TopicMenberListVC(topicId: topicId)
        self.navigationController?.pushViewController(menberList, animated: true)
    }
}

// MARK: - 带有过滤列表了弹窗的 section view 代理
extension TopicPostListVC: FilterSectionViewDelegate {
    /// 选择了一种过滤类型
    func filterSectionView(_ view: FilterSectionView, didSeleteNewAtIndex index: Int) {
    }

    /// 关注和取消关注
    func followButtonClick(_ view: FilterSectionView, button: UIButton) {
        if topicListModel.ownerUserId == TSCurrentUserInfo.share.userInfo?.userIdentity {
            return
        }
        TSUserNetworkingManager().followOrUnfollowTopic(topicId: groupId, follow: !view.model.followStatus) { (_ msg, _ status) in
            if status {
                if view.model.followStatus {
                    self.topicModel.followCount = self.topicModel.followCount - 1
                } else {
                    self.topicModel.followCount = self.topicModel.followCount + 1
                }
                self.topicModel.followStatus = !self.topicModel.followStatus
                self.loadTopic(model: TopicListControllerModel(topicModel: self.topicModel))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTopicList"), object: nil, userInfo: ["topicId": "\(self.groupId)", "follow": view.model.followStatus ? "0" : "1"])
            }
        }
    }
}

// MARK: - 黑名单相关
extension TopicPostListVC {
    /// 黑名单权限检测
    fileprivate func isBlack() -> Bool {
        // 当前用户权限检测：黑名单用户 不可点赞 和 评论、举报圈子
        guard let roleType = GroupMemberModel.memberRoleTypeWithMemberType(self.groupModel.getRoleInfo()) else {
            return false
        }
        return roleType == .black
    }
    /// 黑名单处理
    fileprivate func blackProcess() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子黑名单".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
}

// MARK: - 显示隐藏发布按钮
extension TopicPostListVC {
    func showReleaseButtonAnimation(notice: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.buttonForRelease.frame = CGRect(x: UIScreen.main.bounds.width - self.publishbuttonSize - 25, y: self.view.frame.height - self.publishbuttonSize - 25 - TSBottomSafeAreaHeight, width: self.publishbuttonSize, height: self.publishbuttonSize )
        }
    }
    func hideReleaseButtonAnimation(notice: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.buttonForRelease.frame = CGRect(x: UIScreen.main.bounds.width - self.publishbuttonSize - 25, y: self.view.frame.height, width: 0, height: 0)
        }
    }
}

// MARK: - 追加新发布的动态
extension TopicPostListVC {
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
            table.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            return
        }
    }

    /// 更新某个新发动态的发送状态，newId 为 nil 表示动态发送失败
    func updateNewFeedSendStatus(oldId: Int, newId: Int?) {
        // 1.最新列表
        if let newFeedModel = table.datas.first(where: { $0.id["feedId"] == oldId }) {
            if let newId = newId {
                newFeedModel.id = .feed(feedId: newId)
                newFeedModel.sendStatus = .success
            } else {
                newFeedModel.sendStatus = .faild
            }
            table.reloadData()
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
        table.datas.insert(newFeedModel, at: 0)
        table.processRefresh(data: table.datas, message: nil, status: true)
        table.reloadData()
    }

    /// 获取数据库中发送失败的动态
    func getFaildTopicFeedModels() -> [FeedListCellModel] {
        var topicFeedList: [FeedListCellModel] = []
        let faildMoments = TSDatabaseManager().moment.getFaildSendMoments().map { FeedListCellModel(faildMoment: $0) }
        for item in faildMoments {
            for topicItem in item.topics {
                if topicItem.topicId == groupId {
                    topicFeedList.insert(item, at: 0)
                    continue
                }
            }
        }
        return topicFeedList
    }

    func playVideoWith(_ feedListView: TopicFeedListView, indexPath: IndexPath) {
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
    func zf_playerDownload(_ url: String!) {
        TSUtil.share().showDownloadVC(videoUrl: url)
    }
}
