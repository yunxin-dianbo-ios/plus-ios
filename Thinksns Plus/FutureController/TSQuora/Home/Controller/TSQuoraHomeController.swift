//
//  TSQuoraHomeController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答主页

import UIKit

class TSQuoraHomeController: TSViewController {

    /// 问答视图
    let quoraView = QuoraHomeListView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight)))

    /// 话题视图
    let topicView = TSTopicListView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight)))

    /// 标题按钮
    let segmentControl = UISegmentedControl(items: ["问答", "专题"])

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        // 问答视图
        self.view.backgroundColor = UIColor.white
        // 导航栏右侧按钮进入问题详情页
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_ico_search"), style: .plain, target: self, action: #selector(rightItemClick))
        // 标题按钮
        segmentControl.frame = CGRect(origin: .zero, size: CGSize(width: 125, height: 30))
        segmentControl.tintColor = TSColor.main.theme
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentSelectedIndexChanged), for: .valueChanged)
        navigationItem.titleView = segmentControl

        // 设置视图初始状态
        segmentControl.selectedSegmentIndex = 0
        segmentSelectedIndexChanged()
    }

    // MARK: - Click Action

    /// 点了导航栏右边按钮
    func rightItemClick() -> Void {
        // 登录判断
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 跳转搜索页面
        let vc = TSQuoraSearchVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 分段控制器的选中状态发生了改变
    func segmentSelectedIndexChanged() {
        print(segmentControl.selectedSegmentIndex)
        let selectedIndex = segmentControl.selectedSegmentIndex
        // 问答
        if selectedIndex == 0 {
            view = quoraView
        }
        // 话题
        if selectedIndex == 1 {
            view = topicView
        }
    }
}
