//
//  TSHomeTabBarController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  首页标签控制器

import UIKit
import Photos
import TZImagePickerController
import SCRecorder

struct TSGuestAccessibleContent {
    struct TSHomeTabBarControllerAccessPermission {
        static let firstItem = true
        static let secondItem = true
        static let thirdItem = false
        static let fourthItem = false
    }
    struct TSDiscoverVCAccessPermission {
        static let shoppingItem = false
    }
}

class TSHomeTabBarController: UITabBarController, HomeTabBarCenterButtonDelegate, UITabBarControllerDelegate, TSBeforeReleaseViewDelegate, DemoCallManagerDelegate {

    let customTabBar = TSHomeTabBar()
    var thebfview: TSBeforeReleaseView!
    lazy var unreadCountNetworkManager = UnreadCountNetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setChildViewController()
        updateCurrentUserInfo()
        let _ = TSCurrentUserInfo.share.isFirstToWalletVC
        if TSCurrentUserInfo.share.isLogin {
            let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
            appDeleguate.getHyPassword()
        }
        DemoCallManager.shared().delegate = self
        DemoCallManager.shared().mainController = self
        unreadCountNetworkManager.unreadCount { [weak self] (_) in
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rootVC = TSRootViewController.share
        if rootVC.tabbarVC?.tabBar.frame.origin.y != UIScreen.main.bounds.size.height - 49 {
//            NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        }
        // NotificationCenter.default.addObserver(self, selector: #selector(changeView(_:)), name: NSNotification.Name.APNs.changeView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: NSNotification.Name.APNs.receiveNotice, object: nil)
        /// 点击音乐入口视图
        NotificationCenter.default.addObserver(self, selector: #selector(didClickMusicWindow), name: NSNotification.Name(rawValue: TSMusicPushToMusicPlayVCName), object: nil)
    }

    func changeStatuBar() {
//        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.bottom = TSUtil.share().statusHeight ?? 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Custom user interface
    /// 设置子视图控制器
    func setChildViewController() {
//        self.addChildViewController(TSMomentListVC(), "标题_首页".localized, "IMG_common_ico_bottom_home_normal", "IMG_common_ico_bottom_home_high")
        self.addChildViewController(FeedPagesController(), "标题_首页".localized, "IMG_common_ico_bottom_home_normal", "IMG_common_ico_bottom_home_high")

        self.addChildViewController(TSDiscoverViewController(), "标题_发现".localized, "IMG_common_ico_bottom_discover_normal", "IMG_common_ico_bottom_discover_high")

        let messageVC = MessageViewController(labelTitleArray: ["通知", "聊天"], scrollViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - self.tabBar.height), isChat: true)
        addChildViewController(messageVC, "标题_消息".localized, "IMG_common_ico_bottom_message_normal", "IMG_common_ico_bottom_message_high")

        self.addChildViewController(TSMeViewController(), "标题_我".localized, "IMG_common_ico_bottom_me_normal", "IMG_common_ico_bottom_me_high")

        customTabBar.tintColor = MainColor().theme
        customTabBar.centerButtonDelegate = self
        self.setValue(customTabBar, forKey: "tabBar")
    }

    // MARK: - Private
    /// 更新当前用户信息
    private func updateCurrentUserInfo() {
        if TSCurrentUserInfo.share.isLogin {
            TSDataQueueManager.share.userInfoQueue.getCurrentUserInfo(isQueryDB: true) { (userModel, _, status) in
                if status, let userModel = userModel {
                    TSCurrentUserInfo.share.userInfo = userModel
                }
            }
        }
        // 更新用户认证信息
        TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
    }

    // MARK: - Delegate
    // MARK: tabBarController delegate
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard TSCurrentUserInfo.share.isLogin == false else {
            return true
        }
        let viewJump: Bool
        switch viewController {
        case tabBarController.childViewControllers[0]:
            viewJump = TSGuestAccessibleContent.TSHomeTabBarControllerAccessPermission.firstItem
        case tabBarController.childViewControllers[1]:
            viewJump = TSGuestAccessibleContent.TSHomeTabBarControllerAccessPermission.secondItem
        case tabBarController.childViewControllers[2]:
            viewJump = TSGuestAccessibleContent.TSHomeTabBarControllerAccessPermission.thirdItem
        case tabBarController.childViewControllers[3]:
            viewJump = TSGuestAccessibleContent.TSHomeTabBarControllerAccessPermission.fourthItem
        default:
            fatalError("没有配置完整的主页标签控制器")
        }
        if viewJump == false {
            TSRootViewController.share.guestJoinLoginVC()
        }
        return viewJump
    }

    // MARK: HomeTabBarCenterButtonDelegate
    internal func tabbarCenterButtonTap(_ tabbar: TSHomeTabBar) {
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 显示顺序：文字、图片、投稿、签到(签到可能没有)、问答
        if TSAppConfig.share.localInfo.checkin == true {
            if TSAppConfig.share.launchInfo?.quoraSwitch == true {
                thebfview = TSBeforeReleaseView(frame: self.view.frame, images: [#imageLiteral(resourceName: "IMG_ico_word"), #imageLiteral(resourceName: "IMG_ico_potoablum"), #imageLiteral(resourceName: "IMG_ico_contribute"), #imageLiteral(resourceName: "IMG_ico_attendance"), #imageLiteral(resourceName: "IMG_ico_question"), #imageLiteral(resourceName: "IMG_ico_fatie"), #imageLiteral(resourceName: "ico_video")], titles: ["显示_文字".localized, "显示_图片".localized, "显示_投稿".localized, "显示_签到".localized, "显示_问答".localized, "显示_发帖".localized, "视频"])
            } else {
                thebfview = TSBeforeReleaseView(frame: self.view.frame, images: [#imageLiteral(resourceName: "IMG_ico_word"), #imageLiteral(resourceName: "IMG_ico_potoablum"), #imageLiteral(resourceName: "IMG_ico_contribute"), #imageLiteral(resourceName: "IMG_ico_attendance"), #imageLiteral(resourceName: "IMG_ico_fatie"), #imageLiteral(resourceName: "ico_video")], titles: ["显示_文字".localized, "显示_图片".localized, "显示_投稿".localized, "显示_签到".localized, "显示_发帖".localized, "视频"])
            }
            thebfview.tag = 250
        }
        if TSAppConfig.share.localInfo.checkin == false {
            if TSAppConfig.share.launchInfo?.quoraSwitch == true {
                thebfview = TSBeforeReleaseView(frame: self.view.frame, images: [#imageLiteral(resourceName: "IMG_ico_word"), #imageLiteral(resourceName: "IMG_ico_potoablum"), #imageLiteral(resourceName: "IMG_ico_contribute"), #imageLiteral(resourceName: "IMG_ico_question"), #imageLiteral(resourceName: "IMG_ico_fatie"), #imageLiteral(resourceName: "ico_video")], titles: ["显示_文字".localized, "显示_图片".localized, "显示_投稿".localized, "显示_问答".localized, "显示_发帖".localized, "视频"])
            } else {
                thebfview = TSBeforeReleaseView(frame: self.view.frame, images: [#imageLiteral(resourceName: "IMG_ico_word"), #imageLiteral(resourceName: "IMG_ico_potoablum"), #imageLiteral(resourceName: "IMG_ico_contribute"), #imageLiteral(resourceName: "IMG_ico_fatie"), #imageLiteral(resourceName: "ico_video")], titles: ["显示_文字".localized, "显示_图片".localized, "显示_投稿".localized, "显示_发帖".localized, "视频"])
            }
            thebfview.tag = 251
        }
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
            let navigation = TSNavigationController(rootViewController: releasePulseVC)
            self.present(navigation, animated: true, completion: nil)
        case "显示_图片".localized:
            checkPhotoAuthorizeStatus()
        case "显示_问答".localized:
            self.gotoQuoraPublish()
        case "显示_签到".localized:
            TSCheckinNetworkManager().getCheckinInformation(compelet: { (model, status) in
                guard status else {
                    return
                }
                let signinShowView = TSSigninShowView()
                signinShowView.loadObtainedData(data: model!)
                signinShowView.show()
            })
        case "显示_投稿".localized:
            // 去投稿
            TSNewsHelper.share.gotoNewsContribute(isNeedRequest: false)
        case "显示_发帖".localized:
            // 圈子 发帖
            self.gotoPostPublish()
        case "视频":
            checkShortVideoAuthorizeStatus()
        default:
            break
        }
    }
    /// 进入问答发布界面
    fileprivate func gotoQuoraPublish() -> Void {
        let questionEditVC = TSQuestionTitleEditController()
        questionEditVC.type = .addPublish
        let questionEditNC = TSNavigationController(rootViewController: questionEditVC)
        self.present(questionEditNC, animated: true, completion: nil)
        //self.selectedViewController?.navigationController?.pushViewController(questionEditVC, animated: true)
    }

    /// 去圈子发帖界面
    fileprivate func gotoPostPublish() -> Void {
        /// 圈外发帖
        let postPublishVC = PostPublishController(fromAdd: true)
        if let selectedNC = self.selectedViewController as? UINavigationController {
            selectedNC.pushViewController(postPublishVC, animated: true)
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
        let navigation = TSNavigationController(rootViewController: releasePulseVC)
        releasePulseVC.selectedPHAssets = assets as! [PHAsset]
        self.present(navigation, animated: true, completion: nil)
    }

    func showShortVideoPickerVC() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true) else {
            return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #视频选择列表页面
        /// item右上角蓝色的选中图片、视频拍摄按钮
        //            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")
        //        imagePickerVC.takeVideo = UIImage(named: "pic_shootvideo")
        /// #视频裁剪页面
        /// 返回按钮、视频长度截取左侧选择滑块、视频长度截取右侧选择滑块
        //        imagePickerVC.backImage = UIImage(named: "ico_title_back_black")
        //        imagePickerVC.editFaceLeft = UIImage(named: "pic_eft")
        //        imagePickerVC.editFaceRight = UIImage(named: "pic_right")
        /// #封面选择页面
        /// 封面选择滑块
        //        imagePickerVC.picCoverImage = UIImage(named: "pic_cover_frame")

        // 最大loading超时时间设置为3min，防止快速编辑的时候导出视频等待时间过长而loading消失
        imagePickerVC.timeout = 60 * 3
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

    /// 收到APNs 切换视图
    func changeView(_ noti: NSNotification) {
        // 关闭所有的视图
        for childVC in childViewControllers {
            if let navigationVC = childVC as? TSNavigationController {
                navigationVC.popToRootViewController(animated: false)
            }
        }
        selectedIndex = 2
    }
    /// 收到通知推送信息后,显示小红点,数据再进入[消息]页面时抓取
    func receiveNotice() {
        customTabBar.showBadge(.message)
    }
    // MARK: - 全局音乐悬浮窗口点击事件处理
    func didClickMusicWindow() {
        guard let nav = self.childViewControllers[selectedIndex] as? TSNavigationController else {
            return
        }
        let controllers = nav.viewControllers
        if controllers.contains(TSMusicPlayVC.shareMusicPlayVC) {
            nav.popToViewController(TSMusicPlayVC.shareMusicPlayVC, animated: true)
        } else {
            nav.pushViewController(TSMusicPlayVC.shareMusicPlayVC, animated: true)
        }
    }

    func getUserInfo(_ userId: String!, session currentSession: EMCallSession!) {
        let userid = Int(userId)
        let  userinfomodel = TSDatabaseManager().user.get(userid!)

        if userinfomodel != nil {
            let name = userinfomodel?.name ?? ""
            let avatarUrl = TSUtil.praseTSNetFileUrl(netFile:userinfomodel?.avatar)
            var params = [String: Any]()
            params.updateValue(name, forKey: "callName")
            params.updateValue(avatarUrl, forKey: "callFace")
            DemoCallManager.shared().makeCall(params, session: currentSession)
        } else {
            TSUserNetworkingManager().getUsersInfo(usersId: [userid!], complete: { (usermodel, textString, succuce) in
                if succuce && usermodel?.count != nil {
                    let userInfo: TSUserInfoModel = usermodel![0]
                    let name = userInfo.name
                    let avatarUrl = TSUtil.praseTSNetFileUrl(netFile:userInfo.avatar)
                    var params = [String: Any]()
                    params.updateValue(name, forKey: "callName")
                    params.updateValue(avatarUrl, forKey: "callFace")
                    DemoCallManager.shared().makeCall(params, session: currentSession)
                }
            })
        }
    }

    func getUserInfo(_ userId: String!, username aUsername: String!, type aType: EMCallType) {
        let userid = Int(userId)
        let  userinfomodel = TSDatabaseManager().user.get(userid!)

        if userinfomodel != nil {
            let name = userinfomodel?.name ?? ""
            let avatarUrl = TSUtil.praseTSNetFileUrl(netFile:userinfomodel?.avatar)
            var params = [String: Any]()
            params.updateValue(name, forKey: "callName")
            params.updateValue(avatarUrl, forKey: "callFace")
            DemoCallManager.shared().makeSendCall(params, username: aUsername, type: aType)
        } else {
            TSUserNetworkingManager().getUsersInfo(usersId: [userid!], complete: { (usermodel, textString, succuce) in
                if succuce && usermodel?.count != nil {
                    let userInfo: TSUserInfoModel = usermodel![0]
                    let name = userInfo.name
                    let avatarUrl = TSUtil.praseTSNetFileUrl(netFile:userInfo.avatar)
                    var params = [String: Any]()
                    params.updateValue(name, forKey: "callName")
                    params.updateValue(avatarUrl, forKey: "callFace")
                    DemoCallManager.shared().makeSendCall(params, username: aUsername, type: aType)
                }
            })
        }
    }
}

extension TSHomeTabBarController: TZImagePickerControllerDelegate {
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
        vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: videoURL as! URL)
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
}

extension TSHomeTabBarController: RecorderVCDelegate {
    func finishRecorder(recordSession: SCRecordSession, coverImage: UIImage) {
        let vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
        vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: recordSession, videoFileURL: nil)
        let nav = TSNavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension TSHomeTabBarController {
    /// 添加子控制器
    ///
    /// - Parameters:
    ///   - childController: 子控制器
    ///   - title: 子控制器显示的标题
    ///   - normalImageName: 子控制器在标签栏上默认情况下的图标
    ///   - selectedImageName: 子控制器在标签栏上选中情况下的图标
    func addChildViewController(_ childController: UIViewController, _ title: String, _ normalImageName: String, _ selectedImageName: String) {
        childController.title = title
        childController.tabBarItem.image = UIImage(named: normalImageName)?.withRenderingMode(.alwaysOriginal)
        childController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        childController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        let nav = TSNavigationController(rootViewController: childController)
        self.addChildViewController(nav)
    }
}
