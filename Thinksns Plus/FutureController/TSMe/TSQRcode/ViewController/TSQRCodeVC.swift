//
//  TSQRCodeVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit
import MonkeyKing
import Kingfisher

class TSQRCodeVC: TSViewController {
    ///供外部传值
    public var avatarStirng: String?
    public var nameString: String?
    public var introString: String?
    public var uidStirng: Int = -1
    public var shareImage: UIImage?
    let qrCodeUIScale: CGFloat = 147 / 375
    /// 右上角二维码扫描按钮
    fileprivate weak var saoyisaoBtn: UIButton!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = {[
            NSForegroundColorAttributeName: UIColor.black
        ]}()
        self.navigationController?.navigationBar.tintColor = UIColor(hex: 0x2b345c)
        self.navigationController?.navigationBar.shadowImage = nil
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0x2cb7da)
        self.navigationController?.navigationBar.titleTextAttributes = {[
            NSForegroundColorAttributeName: UIColor.white
        ]}()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(popToUserHomePage), name: NSNotification.Name(rawValue: "saoyisaouid"), object: nil)
        self.createSubView()
    }

    // MARK: - 处理导航栏视图
    fileprivate func createSubView() -> Void {
        self.view.backgroundColor = UIColor(hex: 0x2cb7da)
        // 1. navigationbar
        self.navigationItem.title = "扫一扫".localized
        let erweimaItem = UIButton(type: .custom)
        erweimaItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(erweimaItem, title: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: erweimaItem)
        self.saoyisaoBtn = erweimaItem
        self.saoyisaoBtn.setImage(UIImage(named: "ico_scan"), for: UIControlState.normal)
        self.saoyisaoBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.saoyisaoBtn.width - self.saoyisaoBtn.currentImage!.size.width, bottom: 0, right: 0)

        // 详情内容
        let bgView = UIView()
        bgView.frame = CGRect(x: 15, y: 12, width: ScreenWidth - 30, height: ScreenWidth - 24 + 74)
        bgView.backgroundColor = UIColor.white
        bgView.layer.borderColor = UIColor(hex: 0xdedede).cgColor
        bgView.layer.borderWidth = 0.5
        bgView.layer.cornerRadius = 5
        let faceImageView = UIImageView(frame: CGRect(x: 12, y: 20, width: 50, height: 50))
        faceImageView.clipsToBounds = true
        faceImageView.layer.cornerRadius = 25
        if avatarStirng != nil {
            faceImageView.kf.setImage(with: URL(string: avatarStirng!), placeholder: UIImage(named: "IMG_pic_default_secret"), options: nil, progressBlock: nil, completionHandler: nil)
            faceImageView.kf.setImage(with: URL(string: avatarStirng!), placeholder: UIImage(named: "IMG_pic_default_secret"), options: nil, progressBlock: nil) { (image, _, _, _) in
                if let image = image {
                    self.shareImage = image
                }
            }
        } else {
            faceImageView.image = UIImage(named: "IMG_pic_default_secret")
        }
        bgView.addSubview(faceImageView)

        let verifiedIcon = UIImageView(frame: CGRect(x: faceImageView.frame.width * 0.65 + faceImageView.left, y: faceImageView.frame.width * 0.65 + faceImageView.top, width: faceImageView.frame.width * 0.35, height: faceImageView.frame.height * 0.35))
        verifiedIcon.clipsToBounds = true
        verifiedIcon.contentMode = .scaleAspectFill
        verifiedIcon.layer.masksToBounds = true
        verifiedIcon.layer.cornerRadius = faceImageView.frame.height * 0.35 / 2.0
        bgView.addSubview(verifiedIcon)

        if TSCurrentUserInfo.share.userInfo?.verified?.type == nil {
            verifiedIcon.isHidden = true
        } else {
            verifiedIcon.isHidden = false
            if (TSCurrentUserInfo.share.userInfo?.verified?.icon.isEmpty)! {
                // 使用本地图片
                var imageName: String
                switch TSCurrentUserInfo.share.userInfo?.verified?.type {
                case "user"?:
                    imageName = "IMG_pic_identi_individual"
                case "org"?:
                    imageName = "IMG_pic_identi_company"
                default:
                    imageName = ""
                }
                verifiedIcon.image = UIImage(named: imageName)
            } else {
                // 加载后台返回图标
                let urlString = TSCurrentUserInfo.share.userInfo?.verified?.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let iconURL = URL(string: urlString ?? "")
                verifiedIcon.kf.setImage(with: iconURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            }
        }

        /// 提前生成分享图片，避免卡顿
        self.shareImage = faceImageView.image

        let nameLabel = UILabel(frame: CGRect(x: 74, y: 24, width: ScreenWidth - 110, height: 16))
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.text = nameString
        bgView.addSubview(nameLabel)

        let intromationLabel = UILabel(frame: CGRect(x: 74, y: 50, width: ScreenWidth - 110, height: 16))
        intromationLabel.font = UIFont.boldSystemFont(ofSize: 14)
        intromationLabel.textColor = UIColor(hex: 0x999999)
        intromationLabel.text = String(format: "简介：%@", (introString != nil) ? introString! : "这家伙很懒,什么都没留下".localized)
        bgView.addSubview(intromationLabel)

        var qrString = TSAppConfig.share.rootServerAddress + "redirect?target=" + ShareURL.user.rawValue + "\(uidStirng)"
        if let uidURL = (ShareURL.user.rawValue + "\(uidStirng)").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            qrString = TSAppConfig.share.rootServerAddress + "redirect?target=" + uidURL
        }
        let qrImageViewBgView = UIImageView(frame: CGRect(x: (bgView.width - (bgView.height - faceImageView.bottom - 120)) / 2, y: faceImageView.bottom + 47, width: bgView.height - faceImageView.bottom - 120, height: bgView.height - faceImageView.bottom - 120))
        qrImageViewBgView.layer.masksToBounds = true
        qrImageViewBgView.layer.borderColor = UIColor(hex: 0xdedede).cgColor
        qrImageViewBgView.layer.borderWidth = 0.5
        bgView.addSubview(qrImageViewBgView)

        _ = QRCodeView.GenerateQRCode(urlString: qrString, surperView: qrImageViewBgView, logo: UIImage(named: "IMG_pic_default_secret")!, logoSize: CGSize(width: 0, height: 0), cornerRadius: 280)

        //Base style for 椭圆 1
        let whiteView = UIView(frame: CGRect(x: 173, y: 265, width: 36, height: 36))
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.masksToBounds = true
        whiteView.layer.cornerRadius = 3
        whiteView.center = qrImageViewBgView.center
        bgView.addSubview(whiteView)

        //Base style for 椭圆 1
        let style = UIImageView(frame: CGRect(x: 173, y: 265, width: 30, height: 30))
        style.layer.masksToBounds = true
        style.layer.cornerRadius = 15
        style.center = qrImageViewBgView.center
        if avatarStirng != nil {
            style.kf.setImage(with: URL(string: avatarStirng!), placeholder: UIImage(named: "IMG_pic_default_secret"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            style.image = UIImage(named: "IMG_pic_default_secret")
        }
        bgView.addSubview(style)

        let lastLabel = UILabel(frame: CGRect(x: 0, y: qrImageViewBgView.bottom + 31, width: bgView.width, height: 15))
        lastLabel.backgroundColor = UIColor.clear
        lastLabel.textAlignment = NSTextAlignment.center
        lastLabel.font = UIFont.boldSystemFont(ofSize: 15)
        lastLabel.text = "扫描二维码，添加关注".localized
        lastLabel.textColor = UIColor(hex: 0xb3b3b3)
        bgView.addSubview(lastLabel)

        self.view.addSubview(bgView)
    }
    // MARK: - 导航栏右边按钮点击事件（事件有：1 扫一扫别人-跳转到用户主页 2 分享自己给别人-三方分享）
    func rightButtonClick() {
        let saoyisaoAlert = TSAlertController(title: nil, message: nil, style: .actionsheet)
        let scanAlertAction = TSAlertAction(title: "扫一扫", style: .default) { (action) in
            let isSuccess = TSSetUserInfoVC.checkCamearPermissions()
            guard isSuccess else {
                return
            }
            /// 扫一扫加好友
            let vc = QRCodeScanVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let shareAlertAction = TSAlertAction(title: "分享", style: .default) { (action) in
            var defaultContent = "默认分享内容".localized
            defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
            let intro = String(format: "%@", (self.introString != nil) ? self.introString! : defaultContent)
            let shareUidInt = self.uidStirng
            let shareUidString = String(shareUidInt)
            let shareView = ShareView()
            shareView.show(URLString: ShareURL.user.rawValue + "\(shareUidString)", image: self.shareImage, description: intro, title: self.nameString)
        }
        saoyisaoAlert.addAction(scanAlertAction)
        saoyisaoAlert.addAction(shareAlertAction)
        self.present(saoyisaoAlert, animated: false, completion: nil)
    }

    func popToUserHomePage(notice: Notification) {
        let userUid = notice.userInfo!["uid"] as! String
        let userHomPage = TSHomepageVC(Int(userUid)!)
        navigationController?.pushViewController(userHomPage, animated: true)
    }
}
