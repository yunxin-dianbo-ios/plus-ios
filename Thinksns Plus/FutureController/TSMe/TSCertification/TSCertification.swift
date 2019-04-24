//
//  TSCertificationVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  认证管理类

import UIKit

class TSCertification {

    /// 认证类型
    enum CertificateType: String {
        /// 个人认证
        case personal = "user"
        /// 企业认证
        case enterprise = "org"
    }

    /// 认证流程视图控制器
    ///
    /// - Note: 用于用户处于未认证状态时，发起认证申请。
    ///
    /// - Parameter type: 认证类型
    /// - Returns: 认证流程视图控制器
    class func applicationFlowVC(type: CertificateType) -> UIViewController {
        switch type {
        case .enterprise:
            let vc = TSEnterpriseBasicInfoVC.basicInfoVC()
            return vc
        case .personal:
            let vc = TSPersonalBasicInfoVC.basicInfoVC()
            return vc
        }
    }

    /// 认证预览视图控制器
    ///
    /// - Note: 用于用户发起认证后，查看认证信息。
    ///
    /// - Parameter type: 认证类型
    /// - Returns: 认证流程视图控制器
    class func previewVC(type: CertificateType) -> UIViewController {
        let object = TSDatabaseManager().user.getCurrentUserCertificate()!
        // 判断是否显示"认证未通过"提示框
        let isShowPrompt = object.status != 1
        switch type {
        case .enterprise:
            let vc = TSEnterprisePreviewVC.previewVC()
            vc.isShowPrompt = isShowPrompt
            vc.model = object
            return vc
        case .personal:
            let vc = TSPersonalPreviewVC.previewVC()
            vc.isShowPrompt = isShowPrompt
            vc.model = object
            return vc
        }
    }

    /// 认证界面
    ///
    /// - Note: 内部判断：认证中/认证成功则进入认证预览页，否则进入认证流程页
    /// - Parameter type: 认证类型
    /// - Returns: 认证流程视图控制器 or 认证预览视图控制器
    class func certificatinVC(type: CertificateType) -> UIViewController {
        var vc: UIViewController
        // 获取认证信息
        let object = TSDatabaseManager().user.getCurrentUserCertificate()
        if object?.status == 0 || object?.status == 1 {
            // 认证中或已认证
            let certificateType = CertificateType(rawValue: object!.type)!
            vc = previewVC(type: certificateType)
        } else {
            // 未认证
            vc = applicationFlowVC(type: type)
        }
        return vc
    }
}
