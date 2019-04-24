//
//  TSMeViewController.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  【我】的页面

import UIKit
import RealmSwift

class TSMeViewController: TSViewController, didMeSelectCellDelegate, SendSuccessImageDelegate, TSFansAndFollowVCProtocol, TSCustomAcionSheetDelegate {
    //二维码按钮
    fileprivate weak var erweimaButton: UIButton!
    /// 系统消息按钮
    var meMessageButton = TSImageButton()
    /// 显示的这个页面UI
    weak var meView: TSMeTableview!
    /// 用户信息通知口令
    var userInfoToken: NotificationToken? = nil
    /// 用户认证信息通知口令
    var userCertificateToken: NotificationToken? = nil
    /// 页面展示标题数据

    var tableViewTitleSource = [["个人主页", "用户认证", "我的\(TSAppConfig.share.localInfo.goldName)"], ["我的文章", "我的圈子", "我的收藏", "我的问答"], ["草稿箱", "设置"]]

    /// 页面展示的图片数据
    var tableViewImgSource = [[#imageLiteral(resourceName: "IMG_ico_me_homepage"), #imageLiteral(resourceName: "IMG_ico_me_identification"), #imageLiteral(resourceName: "IMG_ico_me_integral.png")], [ #imageLiteral(resourceName: "IMG_ico_me_contribute"), #imageLiteral(resourceName: "IMG_ico_me_circle"), #imageLiteral(resourceName: "IMG_ico_me_collect"), #imageLiteral(resourceName: "IMG_ico_me_q&a")], [#imageLiteral(resourceName: "IMG_ico_me_draft"), #imageLiteral(resourceName: "IMG_ico_me_setting")]]
    /// 仅仅是更新了头像

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        if TSAppConfig.share.localInfo.showOnlyIAP {
            if TSAppConfig.share.localInfo.quoraSwitch {
                tableViewTitleSource = [["个人主页", "用户认证", "我的\(TSAppConfig.share.localInfo.goldName)"], ["我的文章", "我的圈子", "我的收藏", "我的问答"], ["草稿箱", "设置"]]
                tableViewImgSource = [[#imageLiteral(resourceName: "IMG_ico_me_homepage"), #imageLiteral(resourceName: "IMG_ico_me_identification"), #imageLiteral(resourceName: "IMG_ico_me_integral.png")], [ #imageLiteral(resourceName: "IMG_ico_me_contribute"), #imageLiteral(resourceName: "IMG_ico_me_circle"), #imageLiteral(resourceName: "IMG_ico_me_collect"), #imageLiteral(resourceName: "IMG_ico_me_q&a")], [#imageLiteral(resourceName: "IMG_ico_me_draft"), #imageLiteral(resourceName: "IMG_ico_me_setting")]]
            } else {
                tableViewTitleSource = [["个人主页", "用户认证", "我的\(TSAppConfig.share.localInfo.goldName)"], ["我的文章", "我的圈子", "我的收藏"], ["草稿箱", "设置"]]
                tableViewImgSource = [[#imageLiteral(resourceName: "IMG_ico_me_homepage"), #imageLiteral(resourceName: "IMG_ico_me_identification"), #imageLiteral(resourceName: "IMG_ico_me_integral.png")], [ #imageLiteral(resourceName: "IMG_ico_me_contribute"), #imageLiteral(resourceName: "IMG_ico_me_circle"), #imageLiteral(resourceName: "IMG_ico_me_collect")], [#imageLiteral(resourceName: "IMG_ico_me_draft"), #imageLiteral(resourceName: "IMG_ico_me_setting")]]
            }
        } else {
            if TSAppConfig.share.localInfo.quoraSwitch {
                tableViewTitleSource = [["个人主页", "用户认证", "钱包", "我的\(TSAppConfig.share.localInfo.goldName)"], ["我的文章", "我的圈子", "我的收藏", "我的问答"], ["草稿箱", "设置"]]
                tableViewImgSource = [[#imageLiteral(resourceName: "IMG_ico_me_homepage"), #imageLiteral(resourceName: "IMG_ico_me_identification"), #imageLiteral(resourceName: "IMG_ico_me_wallet"), #imageLiteral(resourceName: "IMG_ico_me_integral.png")], [ #imageLiteral(resourceName: "IMG_ico_me_contribute"), #imageLiteral(resourceName: "IMG_ico_me_circle"), #imageLiteral(resourceName: "IMG_ico_me_collect"), #imageLiteral(resourceName: "IMG_ico_me_q&a")], [#imageLiteral(resourceName: "IMG_ico_me_draft"), #imageLiteral(resourceName: "IMG_ico_me_setting")]]
            } else {
                tableViewTitleSource = [["个人主页", "用户认证", "钱包", "我的\(TSAppConfig.share.localInfo.goldName)"], ["我的文章", "我的圈子", "我的收藏"], ["草稿箱", "设置"]]
                tableViewImgSource = [[#imageLiteral(resourceName: "IMG_ico_me_homepage"), #imageLiteral(resourceName: "IMG_ico_me_identification"), #imageLiteral(resourceName: "IMG_ico_me_wallet"), #imageLiteral(resourceName: "IMG_ico_me_integral.png")], [ #imageLiteral(resourceName: "IMG_ico_me_contribute"), #imageLiteral(resourceName: "IMG_ico_me_circle"), #imageLiteral(resourceName: "IMG_ico_me_collect")], [#imageLiteral(resourceName: "IMG_ico_me_draft"), #imageLiteral(resourceName: "IMG_ico_me_setting")]]
            }
        }
        setQRCodeButton()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 1.监听音乐消失动画
        NotificationCenter.default.addObserver(self, selector: #selector(ifViewHiden), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
        // 2.判断音乐按钮是否显示，更改音乐按的颜色
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        if isMusicButtonShow {
            TSMusicPlayStatusView.shareView.reSetImage(white: false)
            if navigationItem.rightBarButtonItems?.count == 1 {
                let nilbar =
                        UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                navigationItem.rightBarButtonItems?.insert(nilbar, at: 0)
            }
        }
        // 3.更新认证信息
        // [长期注释] 原定逻辑是收到认证通知后再更新认证信息，但由于目前后台通知推送并没有完成，故暂时在这里刷新认证信息，请与后台通知推送完成后及时修改
        // [补充说明] 后台不会给到认证审核通过的推送.且后台推送有一定改了丢失,或者用户离线时发送推送.
        TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
        UnreadCountNetworkManager.share.unreadCountVer2 {[weak self] (model) in
            self?.meView.showMeHeader.fansBage.setlabelNumbers(model.following)
            self?.meView.showMeHeader.friendBage.setlabelNumbers(model.mutual)
            self?.meView.meTableView.reloadData()
        }
        meView.meTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self)
        TSUserNetworkingManager().getCurrentUserInfo { [weak self] (model, _, status) in
            if status, let model = model, let weakSelf = self {
                TSCurrentUserInfo.share.userInfo = model
                // 更新头视图-用户信息
                weakSelf.meView.showMeHeader.changeUserInfoData()
                // 更新tableview💰显示
                weakSelf.meView.meTableView.reloadData()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        userInfoToken?.invalidate()
        userCertificateToken?.invalidate()
    }

    // MARK: - 设置扫码按钮（设置右上角按钮）
    func setQRCodeButton() {
        let erweimaItem = UIButton(type: .custom)
        erweimaItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(erweimaItem, title: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: erweimaItem)
        self.erweimaButton = erweimaItem
        self.erweimaButton.setImage(UIImage(named: "ico_code"), for: UIControlState.normal)
        self.erweimaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.erweimaButton.width - (self.erweimaButton.currentImage?.size.width)!, bottom: 0, right: 0)
    }

    // MARK: - UI
    func setUI() {
        let meView = TSMeTableview(frame: CGRect.zero, dataSource: tableViewTitleSource, imageDataSource: tableViewImgSource)
        meView.meTableView.sectionFooterHeight = 15
        // sectionHeaderHeight  not work
        meView.meTableView.sectionHeaderHeight = 15
        meView.didMeSelectCellDelegate = self
        self.meView = meView
        self.view.addSubview(meView)
        meView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0))
        }
    }

    // MARK: - 回调点击的cell，进行跳转
    func didSelectCell(indexPath: IndexPath) {
        let cellTitel = tableViewTitleSource[indexPath.section][indexPath.row]
        switch cellTitel {
        case "个人主页":
            navigationController?.pushViewController(TSHomepageVC(TSCurrentUserInfo.share.userInfo!.userIdentity), animated: true)
        case "我的收藏":
            let collectionVC = TSCollectionVC()
            navigationController?.pushViewController(collectionVC, animated: true)
        case "意见反馈":
            let vc = TSFeedBackViewController()
            navigationController?.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(vc, animated: true)
        case "钱包":
            let wallet = WalletHomeController.vc()
            navigationController?.pushViewController(wallet, animated: true)
        case "设置":
            navigationController?.pushViewController(TSSettingVC(nibName: "TSSettingVC", bundle: nil), animated: true)
        case "用户认证":
            certificateTaped()
        case "我的文章":
            let vc = MyNewsController()
            navigationController?.pushViewController(vc, animated: true)
        case "我的问答":
            let vc = MyQuoraController()
            navigationController?.pushViewController(vc, animated: true)
        case "我的圈子":
            let vc = MyGroupController()
            navigationController?.pushViewController(vc, animated: true)
        case "我的好友":
            let vc = TSFriendsListVC()
            navigationController?.pushViewController(vc, animated: true)
        case "购买的音乐":
            let vc = MyMusicController()
            navigationController?.pushViewController(vc, animated: true)
        case "我的\(TSAppConfig.share.localInfo.goldName)":
            let vc = IntegrationHomeController.vc()
            navigationController?.pushViewController(vc, animated: true)
        case "草稿箱":
            let draftVC = TSDraftController()
            self.navigationController?.pushViewController(draftVC, animated: true)
        default:
            break
        }
    }

    /// 认证点击事件
    func certificateTaped() {
        // 1.获取用户的认证信息
        let certificateObject = TSDatabaseManager().user.getCurrentUserCertificate()
        // 2.判断用户的认证状态
        if certificateObject?.status == 1 || certificateObject?.status == 0 {
            // 2.1 如果用户正在审核中，或者审核已经通过了，跳转到 认证信息预览页
            let type = TSCertification.CertificateType(rawValue:certificateObject!.type)! // 认证类型
            let previewVC = TSCertification.previewVC(type: type)
            navigationController?.pushViewController(previewVC, animated: true)
        } else {
            // 2.2 如果用户未通过审核或者未进行审核，弹窗让用户选择认证方式
            let alert = TSCustomActionsheetView(titles: ["选择_个人认证".localized, "选择_企业认证".localized])
            alert.delegate = self
            alert.show()
        }
    }

    // MARK: - TSMeTableViewHeaderDelegate
    // 回调点击头视图的view的index，进行跳转
    func didHeader(index: MeHeaderView) {
        switch index {
        case .user:
            let setUserInfoViewController = TSSetUserInfoVC(nibName: "TSSetUserInfoVC", bundle: nil)
            navigationController?.pushViewController(setUserInfoViewController, animated: true)
            setUserInfoViewController.delegate = self
            setUserInfoViewController.userModel = TSDatabaseManager().user.getCurrentUser()?.convert()
            break
        case .fans:
            let fansAndFollowVC = TSFansAndFollowVC(userIdentity: (TSCurrentUserInfo.share.userInfo?.userIdentity)!)
            fansAndFollowVC.setSelectedAt(0)
            if let navigationController = navigationController {
                navigationController.pushViewController(fansAndFollowVC, animated: true)
                fansAndFollowShowFansVC()
            }
            break
        case .follow:
            let fansAndFollowVC = TSFansAndFollowVC(userIdentity: (TSCurrentUserInfo.share.userInfo?.userIdentity)!)
            fansAndFollowVC.setSelectedAt(1)
            fansAndFollowVC.delegate = self
            if let navigationController = navigationController {
                navigationController.pushViewController(fansAndFollowVC, animated: true)
            }
        case .friend:
            let vc = TSFriendsListVC()
            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }

    func fansAndFollowShowFansVC() {
        // UI显示相关 清0
        self.meView.showMeHeader.fansBage.setlabelNumbers(0)
        // 隐藏掉 我的页面的 小红点
        TSRootViewController.share.tabbarVC?.customTabBar.hiddenBadge(.myCenter)
    }

    /// 上传成功后的头像返回到上个界面
    func sendImageWithTemplate(image: UIImage) {
        TSUserNetworkingManager().getCurrentUserInfo { [weak self] (model, _, status) in
            if status, let model = model, let weakSelf = self {
                TSCurrentUserInfo.share.userInfo = model
                // 更新头视图-用户信息
                weakSelf.meView.showMeHeader.changeUserInfoData()
                // 更新tableview💰显示
                weakSelf.meView.meTableView.reloadData()
            }
        }
    }

    // MARK: - TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if title == "选择_个人认证".localized {
            // 跳转到个人认证申请页
            let vc = TSCertification.applicationFlowVC(type: .personal)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if title == "选择_企业认证".localized {
            // 跳转到企业认证申请页
            let vc = TSCertification.applicationFlowVC(type: .enterprise)
            navigationController?.pushViewController(vc, animated: true)
            return
        }

    }

    // MARK: - Music view hide barbutton displacement
    func ifViewHiden() {
        guard let count = navigationItem.rightBarButtonItems?.count else {
            return
        }
        if count > 1 {
            navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }

    // MAKR: - Other
    // MARK: - 扫码按钮点击事件（右上角按钮点击事件）
    func rightButtonClick() {
        let qrCodeVC = TSQRCodeVC()
        qrCodeVC.avatarStirng = TSUtil.praseTSNetFileUrl(netFile: TSCurrentUserInfo.share.userInfo?.avatar)
        qrCodeVC.nameString = TSCurrentUserInfo.share.userInfo?.name
        qrCodeVC.introString = TSCurrentUserInfo.share.userInfo?.bio
        qrCodeVC.uidStirng = (TSCurrentUserInfo.share.userInfo?.userIdentity)!
        self.navigationController?.pushViewController(qrCodeVC, animated: true)
    }
}
