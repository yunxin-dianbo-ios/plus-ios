//
//  TSQuoraController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的问答

import UIKit

class MyQuoraController: TSViewController {

    /// 分页控制器
    let segmentControl = UISegmentedControl(items: ["提问", "回答", "关注"])
    /// 提问列表
    var questionsListView: MyQuestionsListView!
    /// 回答列表
    var answerListView: MyAnswersListView!
    /// 关注列表
    var followListView: MyFollowQuora!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - UI
    func setUI() {
        // 1.分页控制器
        segmentControl.frame = CGRect(origin: .zero, size: CGSize(width: 188, height: 30))
        segmentControl.tintColor = TSColor.main.theme
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)

        let childFrame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64))
        // 2.提问列表
        questionsListView = MyQuestionsListView(frame: childFrame)
        // 3.回答列表
        answerListView = MyAnswersListView(frame: childFrame)
        // 4.关注列表
        followListView = MyFollowQuora(frame: childFrame)

        navigationItem.titleView = segmentControl
        // 默认初始显示我的问题
        segmentControl.selectedSegmentIndex = 0
        view = questionsListView
    }

    /// 点击了分页控制器
    func segmentValueChanged() {
        let index = segmentControl.selectedSegmentIndex
        if index == 0 {
            view = questionsListView
        }
        if index == 1 {
            view = answerListView
        }
        if index == 2 {
            view = followListView
        }
    }

}
