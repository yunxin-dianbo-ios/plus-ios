//
//  TSNewsRootViewController.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct TSNewsRootViewControllerUX {

}

class TSNewsRootViewController: TSViewController, UIScrollViewDelegate, TSNewTagScrollViewDelegate, TSNewsTagSettingVCDelegate {
    /// 头部可滑动的标签选择视图
    var tagScrollView: TSNewTagScrollView? = nil
    /// 主视图
    var rootScrollView: UIScrollView? = nil
    /// 点击展示话题选择页面的按钮
    var tagSelectButton: TSImageButton? = nil
    /// 标签编辑页面
    var tagSettingVC: TSNewsTagSettingVC? = nil
    /// 标签数据
    var allTags: TSNewsAllTagsModel? = nil
    /// 列表内广告数据
    /// 从数据库的数据复制
    var advertObjects: [TSAdvertObject]!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "资讯".localized
        self.initControls()
        advertObjects = TSDatabaseManager().advert.getObjects(type: .newsListIn)
        self.loadTags()
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
        // 认证状态请求，用于更新没有认证时更新认证
        if nil == TSCurrentUserInfo.share.userInfo?.verified {
            TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
        }
    }

    // MARK: - loadUI
    // MARK: 初始化基本控件
    func initControls() {
        // 导航栏右侧按钮
        self.initialRightBarItems()

        /// 点击展示标签编辑页的按钮
        self.tagSelectButton = TSImageButton(frame: CGRect.zero)
        self.tagSelectButton?.center = CGPoint(x: ScreenSize.ScreenWidth - ((self.tagSelectButton?.frame.width)! / 2), y: (self.tagSelectButton?.frame.height)! / 2)
        self.tagSelectButton?.setImage(UIImage(named: "IMG_sec_nav_arrow"), for: UIControlState.normal)
        self.tagSelectButton?.backgroundColor = .white
        self.tagSelectButton?.layer.shadowColor = UIColor.white.cgColor
        self.tagSelectButton?.layer.shadowOffset = CGSize(width: -8, height: 0)
        self.tagSelectButton?.layer.shadowRadius = 3
        self.tagSelectButton?.layer.shadowOpacity = 3
        self.tagSelectButton?.addTarget(self, action: #selector(showTagSettingView), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.tagSelectButton!)

        /// 顶部可滑动的标签栏
        self.tagScrollView = TSNewTagScrollView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth - (self.tagSelectButton?.frame.width)!, height: (self.tagSelectButton?.frame.height)!))
        self.tagScrollView?.delegate = self
        self.view.addSubview(self.tagScrollView!)

        /// 左右滑动的列表根视图
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height)! + 20
        self.rootScrollView = UIScrollView(frame: CGRect(x: 0, y: (self.tagScrollView?.frame.maxY)!, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - navigationBarHeight - (self.tagScrollView?.frame.maxY)!))
        self.rootScrollView?.backgroundColor = TSColor.inconspicuous.background
        self.rootScrollView?.delegate = self
        self.rootScrollView?.isPagingEnabled = true
        self.rootScrollView?.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.rootScrollView!)

        let grayLine = UIView(frame: CGRect(x: 0, y: (self.tagScrollView?.frame.maxY)! - 1, width: ScreenSize.ScreenWidth, height: 1))
        grayLine.backgroundColor = TSColor.inconspicuous.disabled
        self.view.addSubview(grayLine)

        self.tagSettingVC = TSNewsTagSettingVC(WithRootViewController: self)
        self.tagSettingVC?.delegate = self
        self.addChildViewController(self.tagSettingVC!)

        self.view.bringSubview(toFront: self.tagSelectButton!)
        self.view.bringSubview(toFront: self.rootScrollView!)
        self.view.bringSubview(toFront: grayLine)
    }

    func initialRightBarItems() -> Void {
        // 完全自定义，使其符合UI间距要求
        let rightItemView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 44))
        let searchBtn = UIButton(type: .custom)
        rightItemView.addSubview(searchBtn)
        searchBtn.addTarget(self, action: #selector(searchBarItemClick), for: .touchUpInside)
        searchBtn.setImage(UIImage(named: "IMG_ico_search"), for: .normal)
        searchBtn.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalTo(rightItemView)
            make.trailing.equalTo(rightItemView.snp.centerX)
        }
        let editBtn = UIButton(type: .custom)
        rightItemView.addSubview(editBtn)
        editBtn.addTarget(self, action: #selector(editBarItemClick), for: .touchUpInside)
        editBtn.setImage(UIImage(named: "IMG_ico_news_contribute"), for: .normal)
        editBtn.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalTo(rightItemView)
            make.leading.equalTo(rightItemView.snp.centerX).offset(10)
        }
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightItemView)]
    }

    func addChlidVC() {
        /** =================================================== **
         *  ① 资讯第一个分类永远是“推荐”
         *  ② 子控制器的视图采用“懒加载”方式加载在主视图上：初始化时，只加载第一个子控制器的视图
         *  ③ 其余的子控制器的视图在滑动到对应位置时再加载
         ** =================================================== **/
        for object in (self.allTags?.markedTags)! {
            let listVC = TSNewsListViewController(rootViewController: self)
            listVC.tagID = object.tagID
            self.addChildViewController(listVC)
            if object.name == "推荐" {
                listVC.view.tag = -1 /// 添加标记 用于重新刷新界面的时候清空以前的视图
                self.rootScrollView?.addSubview(listVC.view)
            }
        }

        self.rootScrollView?.contentSize = CGSize(width: ScreenSize.ScreenWidth * CGFloat((self.allTags?.markedTags)!.count), height: 0)
    }
    /// 编辑栏目后刷新主视图UI
    func reloadChildVCS() {
        /// 清空子控件
        for vc in self.childViewControllers {
            if vc.view.tag != 9_999 {
                vc.removeFromParentViewController()
            }
        }
        /// 清空列表视图
        for view in (self.rootScrollView?.subviews)! {
            if view.tag == -1 {
                view.removeFromSuperview()
            }
        }
        /// 重置列表滑动视图的偏移位置
        self.rootScrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)

        self.addChlidVC()
    }
    // MARK: - TSNewTagScrollViewDelegate
    func selectedTag(WithTagIndex index: Int) {
        self.rootScrollView?.setContentOffset(CGPoint(x: ScreenSize.ScreenWidth * CGFloat(index), y: 0), animated: false)
        self.scrollViewDidEndScrollingAnimation(self.rootScrollView!)
    }
    // MARK: - scrollviewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tagScrollView?.setTitleButtonStyle(WithContentOffSetXPoint: scrollView.contentOffset.x)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(scrollView)
        self.tagScrollView?.setButtonOffSet(scrollViewContentOffSetX: scrollView.contentOffset.x)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let VCIndex = (self.rootScrollView?.contentOffset.x)! / ScreenSize.ScreenWidth
        /**
         * 注意：在添加列表子控制器前添加了tagSettingVC这个子控制器 所以这里
         * 的懒加载数组序号应该整体右移，且当子控制器为tagSettingVC的时候不执行添加
         * 操作
         **/
        let childVC = self.childViewControllers[Int(VCIndex + 1)]
        if childVC.view.superview != nil {
            return
        }
        /// tagSettingVC 的view tag值
        if childVC.view.tag == 9_999 {
            return
        }
        childVC.view.frame = (self.rootScrollView?.bounds)!
        childVC.view.tag = -1 /// 添加标记 用于重新刷新界面的时候清空以前的视图
        self.rootScrollView?.addSubview(childVC.view)
    }
    // MARK: - TSNewsTagSettingVCDelegate
    func tagSettingVC(settingVC: TSNewsTagSettingVC, finishedModifyTags tags: TSNewsAllTagsModel) {
        self.allTags = tags
        self.tagScrollView?.updateTags(WithTags: (self.allTags?.markedTags)!)
        self.reloadChildVCS()
    }
    // MARK: - actions
    func showTagSettingView() {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        self.view.addSubview((self.tagSettingVC?.view)!)
        self.tagSettingVC?.showView()
    }
    // Mark: - 导航栏右侧响应
    /// 搜索按钮点击响应
    @objc private func searchBarItemClick() -> Void {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        let searchVC = TSNewsSearchViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    /// 资讯投稿按钮点击响应
    @objc private func editBarItemClick() -> Void {
        TSNewsHelper.share.gotoNewsContribute(isNeedRequest: true)
    }

    // MARK: - datas
    func loadTags() {
        TSNewsTaskManager().star { (model, _) in
            if model == nil {
                return
            }
            self.allTags = model
            /// 开始布局
            self.tagScrollView?.updateTags(WithTags: (self.allTags?.markedTags)!)
            self.tagSettingVC?.setDatas(data: self.allTags!)
            self.addChlidVC()
        }
    }

    func ifViewHiden() {
        guard let count = navigationItem.rightBarButtonItems?.count else {
            return
        }
        if count > 1 {
            navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }
}

// 下面的扩展部分，在资讯稳定之后可考虑删除，现在已使用TSNewsHelper代替
extension TSNewsRootViewController {

    /// 去认证处理
    fileprivate func gotoNewsContributeProcess() -> Void {
        // 1.登录判断
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        // 2.投稿认证 与 投稿付费 判断处理
        let configInfo = TSAppConfig.share.localInfo
        // 2.1 不需要投稿认证 和 投稿付费
        if !configInfo.newsContributeVerified && !configInfo.newsContributePay {
            // 去投稿页
            self.gotoNewsContribute()
            return
        }
        // 2.2 需要投稿认证 不需要投稿付费
        if configInfo.newsContributeVerified && !configInfo.newsContributePay {
            // 认证判断处理
            if nil == TSCurrentUserInfo.share.userInfo?.verified {
                // 去进行认证请求
                self.newsContributeVerifiedRequest(complete: { [weak self](verified) in
                    // 认证结果处理
                    self?.newsContributeVerifiedProcess(verified: verified, verifiedAction: {
                        // 去投稿页
                        self?.gotoNewsContribute()
                    })
                })
            } else {
                self.newsContributeVerifiedProcess(verified: true, verifiedAction: { () in
                    // 去投稿页
                    self.gotoNewsContribute()
                })
            }
            return
        }
        // 2.3 不需要投稿认证 需要投稿付费
        if !configInfo.newsContributeVerified && configInfo.newsContributePay {
            self.newsContributePayProcess(payPrice: configInfo.newsContributeAmount)
            return
        }
        // 2.4 需要投稿认证 需要投稿付费
        if configInfo.newsContributeVerified && configInfo.newsContributePay {
            let payAmount = configInfo.newsContributeAmount
            // 2.4.1 认证处理
            // 认证判断处理
            if nil == TSCurrentUserInfo.share.userInfo?.verified {
                // 去进行认证请求
                self.newsContributeVerifiedRequest(complete: { [weak self](verified) in
                    // 认证结果处理
                    self?.newsContributeVerifiedProcess(verified: verified, verifiedAction: {
                        // 投稿付费处理
                        self?.newsContributePayProcess(payPrice: payAmount)
                    })
                })
            } else {
                self.newsContributeVerifiedProcess(verified: true, verifiedAction: { () in
                    // 2.4.2 投稿付费处理
                    self.newsContributePayProcess(payPrice: payAmount)
                })
            }
            return
        }
    }

    /// 去投稿页
    fileprivate func gotoNewsContribute() -> Void {
        let editVC = TSNewsWebEditorController()
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    /// 认证请求判断处理
    fileprivate func newsContributeVerifiedRequest(complete: @escaping((_ verified: Bool) -> Void)) -> Void {
        // 获取用户认证状态
        let alert = TSIndicatorWindowTop(state: .loading, title: "认证状态请求中")
        alert.show()
        TSUserNetworkingManager().getCurrentUserInfo { (currentUser, msg, status) in
            alert.dismiss()
            guard status, let currentUser = currentUser else {
                let title = String(format: "认证状态请求失败, %@", msg ?? "请检查你的网络")
                let alert = TSIndicatorWindowTop(state: .faild, title: title)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            let verified: Bool = (nil != currentUser.verified) ? true : false
            complete(verified)
        }
    }
    /// 认证判断处理
    /// verifiedAction 已认证的响应
    fileprivate func newsContributeVerifiedProcess(verified: Bool, verifiedAction: (() -> Void)?) -> Void {
        if verified {
            // 已认证
            verifiedAction?()
        } else {
            // 未认证、认证中
            let alertVC = TSAlertController(title: "显示_提示".localized, message: "提示信息_投稿认证".localized, style: .actionsheet)
            let personalIdentyAction = TSAlertAction(title: "选择_个人认证".localized, style: .default, handler: { (_) in
                // 跳转到个人认证申请页(处理了认证中)
                let vc = TSCertification.certificatinVC(type: .personal)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            let enterpriseIdentyAction = TSAlertAction(title: "选择_企业认证".localized, style: .default, handler: { (_) in
                // 跳转到企业认证申请页(处理了认证中)
                let vc = TSCertification.certificatinVC(type: .enterprise)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alertVC.addAction(personalIdentyAction)
            alertVC.addAction(enterpriseIdentyAction)
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 投稿付费处理
    fileprivate func newsContributePayProcess(payPrice: Int) -> Void {
        // 第一次投稿时的支付提示判断
        if TSCurrentUserInfo.share.userInfo!.isShowedNewsContributePayPrompt {
            // 去投稿页
            self.gotoNewsContribute()
        } else {
            // 修改弹窗标记 且数据库也要修改
            TSCurrentUserInfo.share.userInfo!.isShowedNewsContributePayPrompt = true
            let message: String = "提示信息_投稿支付_金额前".localized + "\(payPrice)" + TSAppConfig.share.localInfo.goldName + "提示信息_投稿支付_金额后".localized
            let alertVC = TSAlertController(title: "显示_提示".localized, message: message, style: .actionsheet)
            let payAction = TSAlertAction(title: "选择_继续投稿".localized, style: .default, handler: { (_) in
                // 去投稿页
                self.gotoNewsContribute()
            })
            alertVC.addAction(payAction)
            self.present(alertVC, animated: false, completion: nil)
        }
    }
}

// MARK: - TSCustomAcionSheetDelegate

extension TSNewsRootViewController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 200 {     // tag == 200，认证选择
            switch index {
            case 0:
                // 跳转到个人认证申请页
                let vc = TSCertification.certificatinVC(type: .personal)
                navigationController?.pushViewController(vc, animated: true)
            default:
                // 跳转到企业认证申请页
                let vc = TSCertification.certificatinVC(type: .enterprise)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
