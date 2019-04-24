//
//  TopicDetailQuoraListController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

// MARK: - 问题列表视图控制器
class TopicDetailQuoraListController: UIViewController {

    /// 问答列表
    var questionsListView: TopicDetailListView!
    /// 发布按钮
    var buttonForRelease = TSButton(type: .custom)

    /// 话题详情视图模型
    var topicDetailViewModel: TopicDetailControllerModel!
    /// 问题列表的数据
    var cellDatas: [[TSQuoraTableCellModel]] = []
    /// 初始选中状态
    var selectedIndex = -1
    /// 第一次
    var isFirstViewDidAppear = true
    /// 跳转动画代理
    var animatorManager: TopicDetailPresentationManager?

    init(topicDetailViewModel model: TopicDetailControllerModel, datas: [[TSQuoraTableCellModel]], selected: Int = 0) {
        super.init(nibName: nil, bundle: nil)
        topicDetailViewModel = model
        cellDatas = datas
        selectedIndex = selected
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 由于 collection 在 reloadData 之后不能马上更新 contentSize，所以只有在这里进行 collection 的偏移量设置
        if isFirstViewDidAppear {
            questionsListView.labelCollectView.selected = selectedIndex
            isFirstViewDidAppear = false
        }
        transitioningDelegate = nil
    }

    // MARK: - UI
    func setUI() {
        view.backgroundColor = UIColor.white
        // 1.问题列表
        // 这里的 24pt 是为了把 statusBar 的位置空出来
        questionsListView = TopicDetailListView(frame: CGRect(origin: CGPoint(x: 0, y: 24), size: CGSize(width: view.frame.width, height: view.frame.height - 24)), topicId: topicDetailViewModel.basicInfoModel.id, shouldAutoRefresh: false, isIndependentView: true)
        questionsListView.childDatas = cellDatas
        questionsListView.backButton.addTarget(self, action: #selector(backButtonTaped), for: .touchUpInside)
        view.addSubview(questionsListView)
        // 2.发布按钮
        buttonForRelease.setImage(UIImage(named: "IMG_channel_btn_suspension"), for: .normal)
        buttonForRelease.contentMode = .center
        buttonForRelease.sizeToFit()
        buttonForRelease.frame = CGRect(x: (UIScreen.main.bounds.width - buttonForRelease.frame.width) - 25, y: view.frame.height - buttonForRelease.frame.height - 25 - TSBottomSafeAreaHeight, width: buttonForRelease.frame.width, height: buttonForRelease.frame.height)
        buttonForRelease.addTarget(self, action: #selector(releaseButtonTaped), for: .touchUpInside)
        view.addSubview(buttonForRelease)
    }

    // MARK: - Button clickd

    /// 点击了发布按钮
    func releaseButtonTaped() {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            questionsListView.presentToLoginVC()
            return
        }
        // 2.跳转发布页面
        let topicModel = TSQuoraTopicModel(topicDetailModel: topicDetailViewModel)
        let questionEditVC = TSQuestionTitleEditController()
        questionEditVC.type = .topicPublish
        questionEditVC.currentTopic = topicModel
        navigationController?.pushViewController(questionEditVC, animated: true)
    }

    /// 点击了返回按钮
    func backButtonTaped() {
        // 发送通知，通知话题详情页的列表发生改变
        let userInfo: [String: Any] = ["datas": questionsListView.childDatas, "selectedIndex": questionsListView.labelCollectView.selected]
        NotificationCenter.default.post(name: NSNotification.Name.TopicDetailController.willDismiss, object: nil, userInfo: userInfo)
        // 返回上一页
        transitioningDelegate = animatorManager
        dismiss(animated: true, completion: nil)
    }
}
