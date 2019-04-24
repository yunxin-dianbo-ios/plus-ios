//
//  TSRootViewController+Launch.swift
//  ThinkSNS +
//
//  Created by lip on 2017/5/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  处理程序启动后需要执行的操作

import UIKit
import ObjectMapper

extension TSRootViewController {

    /// 更新启动配置信息
    func updateLaunchConfigInfo(complete: @escaping (Bool) -> Void) {
        TSSystemNetworkManager.getLaunchInfo { [unowned self] (data, _) in
            guard let data = data else {
                TSLogCenter.log.debug("result 为 true，没有 data")
                return
            }
            // 1.获取钱包配置 钱包需要单独处理
             TSAppConfig.share.walletInfo = TSWalletConfigModel(initialConfig: data)
            // 2.更新
            TSAppConfig.share.launchInfo = Mapper<TSAppSettingInfoModel>().map(JSONObject: data)
            if TSAppConfig.share.launchInfo != nil {
                TSAppConfig.share.updateLocalInfo()
                complete(true)
            } else {
                complete(false)
            }
        }
    }

    /// 设置启动页广告图
    /// [待修改] 历史原因广告是单独处理的,后续需要都使用 TSAppconfig 来处理
    func showAdvert() {
        // 1.获取启动页广告
        let launchAdverts = TSDatabaseManager().advert.getObjects(type: .launch)
        if launchAdverts.isEmpty {
            TSLogCenter.log.debug("启动页广告的数据为0")
            return
        }
        // 2.显示启动页
        var models = launchAdverts.map { TSAdverLaunchModel(object: $0) }
        /// 倒序一下，后台配置的是依据等级往后排。
        models = models.reversed()
        // 3.设置第一个广告位不可跳过
        var newModel = models[0]
        newModel.canSkip = false
        models[0] = newModel
        // 4.显示广告
        advert.setAdert(models: models)
        view.addSubview(advert)
        advert.starAnimation()
    }

    /// 检测版本号信息(返回一个数组)
    func getVersionData() {
        TSSystemNetworkManager.getVersionData { (data, result) in
            guard result, let data = data else {
                return
            }
            /// 更新本次启动获取版本信息标识
            self.didUpdateAppVersionInfo = true
            if data.isEmpty {
                TSCurrentUserInfo.share.lastCheckAppVesin = nil
                return
            } else {
                let newVersion = data[0]
                TSCurrentUserInfo.share.lastCheckAppVesin = newVersion
                self.checkAppVersion(lastCheckModel: newVersion)
            }
        }
    }
}
