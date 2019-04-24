//
//  MyGroupController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的圈子

import UIKit

class MyGroupController: UIViewController {

    /// 分页控制器
    let segmentControl = UISegmentedControl(items: ["圈子", "帖子"])
    /// 我的圈子
    let groupView = MyGroupsView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)))
    /// 我的帖子
    let postView = MyPostsView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)))

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TSKeyboardToolbar.share.keyboardstartNotice()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }
    func setUI() {
        // 分页控制器
        segmentControl.frame = CGRect(origin: .zero, size: CGSize(width: 125, height: 30))
        segmentControl.tintColor = TSColor.main.theme
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)

        navigationItem.titleView = segmentControl
        // 默认初始显示我的问题
        segmentControl.selectedSegmentIndex = 0
        view = groupView
    }

    /// 点击了分页控制器
    func segmentValueChanged() {
        let index = segmentControl.selectedSegmentIndex
        if index == 0 {
            view = groupView
        }
        if index == 1 {
            view = postView
        }
    }

}
