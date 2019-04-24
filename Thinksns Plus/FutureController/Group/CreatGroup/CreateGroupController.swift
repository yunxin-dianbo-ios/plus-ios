//
//  CreateGroupController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  创建圈子 视图控制器

import UIKit

class CreateGroupController: GroupBasicController {

    class func vc() -> CreateGroupController {
        GroupBasicController.type = .create
        let sb = UIStoryboard(name: "GroupBasicController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! GroupBasicController
        let subVC = vc as! CreateGroupController
        return subVC
    }

    // MARK: - UI
    override func setUI() {
        super.setUI()
        title = "创建圈子"
        // 导航栏右方按钮
        rightButton.setTitle("创建", for: .normal)
        rightButton.sizeToFit()
        rightButton.addTarget(self, action: #selector(rightButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.isEnabled = false
    }

    // MARK: - Action

    /// 用户操作了界面
    override func userOperated() {
        // 检查用户输入的数据，是否满足创建圈子的条件，如果满足，就让创建按钮可点
        rightButton.isEnabled = model.canBuildGroup()
    }

    /// 创建圈子
    func rightButtonTaped() {
        view.endEditing(true)
        // 1.获取 model 中的数据
        guard let coverImage = model.coverImage, let locationInfo = model.locationInfo else {
            return
        }
        // 2.获取定位数据
        var localInfo: (String, String, String, String)?
        switch locationInfo {
        case .unshow:
            localInfo = nil
        case .location(let location, let latitude, let longtitude, let geohash):
            localInfo = (location, latitude, longtitude, geohash)
        }
        // 3.发起网络请求
        let alert = TSIndicatorWindowTop(state: .loading, title: "创建中...")
        alert.show()
        GroupNetworkManager.buildGroup(category: model.categoryId, cover: coverImage, name: model.name, tags: model.tagIds, mode: model.mode, intro: model.intro, notice: model.notice, money: model.money, allowFeed: model.allowFeed, locationInfo: localInfo) { [weak self] (message, status) in
            alert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            // 如果创建圈子成功，返回上一页
            if status {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

}
