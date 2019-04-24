//
//  TSVersionCheck.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/11/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import MarkdownView

class TSVersionCheck: UIViewController {

    /// 整体白色背景视图的高度
    var whiteHeight: CGFloat = 349.0
    /// 整体白色背景的宽度
    var whiteWidth: CGFloat = 500 / 2.0
    /// 整体白色背景的内部视图与白色背景左右间距
    var inMargin: CGFloat = 30
    /// 有透明度的背景视图
    var bgView = UIView()
    /// 整体白色背景视图
    var whiteView = UIView()
    var detailView = MarkdownView()
    /// 顶部图片
    var topImage = UIImageView()
    /// 顶部图片以下的白色
    var bottomView = UIView()
    /// 发送给谁 主题文字
    var titleLabel = UILabel()
    /// 发送按钮
    var sureButton = UIButton(type: .custom)
    /// 关闭按钮
    var closeButton = UIButton(type: .custom)/// 当前的model
    var sendModel: AppVersionCheckModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        setUI()
    }

    func setUI() {
        whiteView.frame = CGRect(x: 0, y: 0, width: whiteWidth, height: whiteHeight)
        whiteView.backgroundColor = UIColor.clear
        whiteView.layer.cornerRadius = 10
        whiteView.clipsToBounds = true
        whiteView.centerY = ScreenHeight / 2.0
        whiteView.centerX = ScreenWidth / 2.0
        self.view.addSubview(whiteView)

        bottomView.frame = CGRect(x: 0, y: 40, width: whiteWidth, height: whiteHeight - 40)
        bottomView.backgroundColor = UIColor.white
        whiteView.addSubview(bottomView)

        topImage.frame = CGRect(x: 0, y: 0, width: whiteWidth, height: 241 / 2.0)
        topImage.clipsToBounds = true
        topImage.contentMode = .scaleAspectFill
        topImage.image = #imageLiteral(resourceName: "pic_update")
        whiteView.addSubview(topImage)

        /// 这里高度原本是16 但是避免文字显示不完整，扩大了 4 ，Y坐标就向上偏移 2
        titleLabel.frame = CGRect(x: 0, y: topImage.bottom + 22, width: whiteWidth, height: 20)
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.font = UIFont(name: "PingFangSC-Medium", size: 16)
        titleLabel.text = "发现新版本!"
        titleLabel.textAlignment = .center
        whiteView.addSubview(titleLabel)

        detailView.frame = CGRect(x: inMargin, y: titleLabel.bottom + 24, width: whiteWidth - inMargin * 2, height: 80)
        detailView.isScrollEnabled = true
        whiteView.addSubview(detailView)

        sureButton.frame = CGRect(x: inMargin, y: detailView.bottom + 27, width: whiteWidth - inMargin * 2, height: 35)
        sureButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sureButton.backgroundColor = TSColor.main.theme
        sureButton.setTitleColor(UIColor.white, for: .normal)
        sureButton.setTitle("立即更新", for: .normal)
        sureButton.clipsToBounds = true
        sureButton.layer.cornerRadius = 4
        sureButton.addTarget(self, action: #selector(sendBtnClick), for: UIControlEvents.touchUpInside)
        whiteView.addSubview(sureButton)

        closeButton.frame = CGRect(x: 0, y: whiteView.bottom + 37, width: 24, height: 24)
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 12
        closeButton.setImage(#imageLiteral(resourceName: "ico_update_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeBtnClick), for: UIControlEvents.touchUpInside)
        closeButton.centerX = whiteView.centerX
        self.view.addSubview(closeButton)
    }

    func sendBtnClick() {
        UIApplication.shared.openURL(URL(string: self.sendModel.link)!)
        hidSelf()
        /// 关闭App
        assert(false, "upload version")
    }

    func hidSelf() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    /// 关闭即为忽略当前版本
    func closeBtnClick() {
        TSCurrentUserInfo.share.lastIgnoreAppVesin = sendModel
        hidSelf()
    }

    public func show(vc: TSVersionCheck, presentVC: UIViewController) {
        if presentVC != nil {
            presentVC.addChildViewController(vc)
            presentVC.didMove(toParentViewController: presentVC)
            presentVC.view.addSubview(vc.view)
        }
    }

    func setVersionInfo(model: AppVersionCheckModel) {
        self.sendModel = model
        if model.is_forced {
            closeButton.isHidden = true
        } else {
            closeButton.isHidden = false
        }
        let content = model.description.ts_customMarkdownToStandard()
        self.detailView.load(markdown: content, enableImage: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
