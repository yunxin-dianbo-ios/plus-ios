//
//  TSNewsHelper.swift
//  ThinkSNS +
//
//  Created by 小唐 on 27/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯小助手，用于将资讯中一些不便于放置和归类的代码进行归类处理

import Foundation
import PKHUD

class TSNewsHelper {
    /// 单例
    static let share: TSNewsHelper = TSNewsHelper()
    private init() {
    }

}

// MARK: - 资讯投稿的入口判断处理

extension TSNewsHelper {

    // MARK: - Internal Function

    /// 去投稿 - (内部处理判断)
    /// - isNeedRequest, 是否需要请求认证信息，默认为true，当未认证时需要请求。有些地方先更新了认证信息，这里就可以不用再请求认证信息了
    ///     比如：主页的发布按钮响应中，会先更新认证信息，然后发布页面动画响应并消失，最后再响应投稿处理
    func gotoNewsContribute(isNeedRequest: Bool = true) -> Void {
        self.newsContributeLimitProcess(isNeedRequest: isNeedRequest)
    }

    /// 认证信息更新：仅针对未认证的情况; 如果已认证，则不需要更新
    func updateVerified(complete: @escaping ((_ verified: Bool?) -> Void)) -> Void {
        // 提示的两种类型：全屏转圈与提示、导航栏转圈与提示
        // 暂时先不考虑全屏转圈，调用处通过是否可用来确定调用页面的交互性。

        // 登录判断
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 已认证判断处理
        if nil != TSCurrentUserInfo.share.userInfo?.verified {
            complete(true)
            return
        }
        // 获取用户认证状态
        let alert = TSIndicatorWindowTop(state: .loading, title: "认证状态请求中")
        alert.show()
        TSUserNetworkingManager().getCurrentUserInfo { (currentUser, msg, status) in
            alert.dismiss()
            guard status, let currentUser = currentUser else {
                let title = String(format: "认证状态请求失败, %@", msg ?? "请检查你的网络")
                let alert = TSIndicatorWindowTop(state: .faild, title: title)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                complete(nil)
                return
            }
            let verified: Bool = (nil != currentUser.verified) ? true : false
            complete(verified)
        }
    }

    // MARK: - Private Function

    /// 资讯投稿前的判断处理
    fileprivate func newsContributeLimitProcess(isNeedRequest: Bool = true) -> Void {
        // 1.登录判断
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.投稿的条件处理：投稿认证 与 投稿付费 的判断处理
        let configInfo = TSAppConfig.share.localInfo
        let contributeLimit = TSAppConfig.share.localInfo.newContributeLimitType
        let payAmount = configInfo.newsContributeAmount
        switch contributeLimit {
        case .none:
            // 2.1无限制 - 去投稿
            self.gotoNewsContributePage()
        case .onlyPay:
            // 2.2仅投稿付费
            self.newsContributePayProcess(payPrice: payAmount)
        case .onlyVerified:
            // 2.3仅认证
            self.newsContributeVerifiedProcess(isNeedRequest: isNeedRequest, verifiedAction: {
                self.gotoNewsContributePage()   // 去投稿页
            })
        case .verifiedAndPay:
            // 2.4 认证 且 投稿付费
            // 认证处理
            self.newsContributeVerifiedProcess(isNeedRequest: isNeedRequest, verifiedAction: {
                // 投稿付费处理
                self.newsContributePayProcess(payPrice: payAmount)
            })
        }
    }

    /// 获取当前的导航控制器
    fileprivate func getCurrentNavigationController() -> UINavigationController? {
        return TSRootViewController.share.tabbarVC?.selectedViewController as? UINavigationController
    }
    /// 去投稿页
    fileprivate func gotoNewsContributePage() -> Void {
        let editVC = TSNewsWebEditorController()
        if let nc = TSRootViewController.share.tabbarVC?.selectedViewController as? UINavigationController {
            nc.pushViewController(editVC, animated: true)
        }
    }

    /// 认证判断处理
    fileprivate func newsContributeVerifiedProcess(isNeedRequest: Bool = true, verifiedAction: (() -> Void)?) -> Void {
        let verifiedInfo = TSCurrentUserInfo.share.userInfo?.verified
        // 1. 已认证处理
        if nil != verifiedInfo {
            verifiedAction?()
            return
        }
        // 2. 未认证，且不需要重新请求认证信息
        if !isNeedRequest {
            // 去认证
            self.gotoVerify()
            return
        }
        // 3. 未认证，且需要重新请求认证信息
        self.newsContributeVerifiedRequest { [weak self](verified) in
            if verified {
                verifiedAction?()
            } else {
                self?.gotoVerify()
            }
        }
    }
    /// 认证请求判断处理
    fileprivate func newsContributeVerifiedRequest(complete: @escaping((_ verified: Bool) -> Void)) -> Void {
        // 提示的两种类型：全屏转圈与提示、导航栏转圈与提示
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
    /// 去认证 弹窗
    fileprivate func gotoVerify() -> Void {
        // 未认证、认证中
        let alertVC = TSAlertController(title: "显示_提示".localized, message: "提示信息_投稿认证".localized, style: .actionsheet)
        let personalIdentyAction = TSAlertAction(title: "选择_个人认证".localized, style: .default, handler: { (_) in
            // 跳转到个人认证申请页(处理了认证中)
            let vc = TSCertification.certificatinVC(type: .personal)
            self.getCurrentNavigationController()?.pushViewController(vc, animated: true)
        })
        let enterpriseIdentyAction = TSAlertAction(title: "选择_企业认证".localized, style: .default, handler: { (_) in
            // 跳转到企业认证申请页(处理了认证中)
            let vc = TSCertification.certificatinVC(type: .enterprise)
            self.getCurrentNavigationController()?.pushViewController(vc, animated: true)
        })
        alertVC.addAction(personalIdentyAction)
        alertVC.addAction(enterpriseIdentyAction)
        TSRootViewController.share.currentShowViewcontroller?.present(alertVC, animated: false, completion: nil)
    }

    /// 投稿付费处理
    fileprivate func newsContributePayProcess(payPrice: Int) -> Void {
        // 第一次投稿时的支付提示判断
        if TSCurrentUserInfo.share.userInfo!.isShowedNewsContributePayPrompt {
            // 去投稿页
            self.gotoNewsContributePage()
        } else {
            // 修改弹窗标记 且数据库也要修改
            TSCurrentUserInfo.share.userInfo!.isShowedNewsContributePayPrompt = true
            let message: String = "提示信息_投稿支付_金额前".localized + "\(payPrice)" + TSAppConfig.share.localInfo.goldName + "提示信息_投稿支付_金额后".localized
            let alertVC = TSAlertController(title: "显示_提示".localized, message: message, style: .actionsheet)
            let payAction = TSAlertAction(title: "选择_继续投稿".localized, style: .default, handler: { (_) in
                // 去投稿页
                self.gotoNewsContributePage()
            })
            alertVC.addAction(payAction)
            TSRootViewController.share.currentShowViewcontroller?.present(alertVC, animated: false, completion: nil)
        }
    }

}
