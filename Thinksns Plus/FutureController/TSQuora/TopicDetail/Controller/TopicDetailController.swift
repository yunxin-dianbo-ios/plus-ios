//
//  TopicDetailController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  某个话题的问答列表

import UIKit

extension Notification.Name {

    /// 话题详情相关
    public struct TopicDetailController {
        /// 问题话题详情页点击了展开按钮
        public static let unfold = NSNotification.Name(rawValue: "com.ts-plus.notification.quora.topicDetail.unfold")
        /// dismiss 效果
        public static let dismiss = NSNotification.Name(rawValue: "com.ts-plus.notification.quora.transitionAnimation.dismiss")
        /// will dismiss
        public static let willDismiss = NSNotification.Name(rawValue: "com.ts-plus.notification.quora.transitionAnimation.willDismiss")
    }
}

class TopicDetailController: TSViewController {

    /// 话题 id
    var topicId: Int = -1
    /// 话题详情视图模型
    var topicDetailViewModel: TopicDetailControllerModel!

    /// 问答列表
    var questionsListView: TopicDetailListView!
    /// 话题详情列表
    var table = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
    /// 发布按钮
    var buttonForRelease = TSButton(type: .custom)

    /// 问答列表在屏幕上的坐标
    var questionsListViewOriginalY: CGFloat {
        let listOrinal = questionsListView.convert(questionsListView.origin, to: table)
        return listOrinal.y
    }
    /// 跳转动画代理
    var animatorManager: TopicDetailPresentationManager = {
        let manager = TopicDetailPresentationManager()
        return manager
    }()

    /// 问答列表 cell 重用标识
    let questionsListViewIdentifier = "QuestionsListView"
    /// 是否已经点击 展开更多 简洁按钮
    var showMoreIntro = false

    // MARK: - Lifecycle
    init(topicId id: Int) {
        super.init(nibName: nil, bundle: nil)
        topicId = id
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TopicDetailController.dismiss, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TopicDetailController.unfold, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TopicDetailController.willDismiss, object: nil)
    }

    override func viewDidLoad() {
        setNotification()
        super.viewDidLoad()
        // 显示点加载动画
        loading()
        setUI()
        loadData()
    }

    // MARK: - Custom user interface
    func setUI() {
        // 1.问题列表
        // 该页面的标签栏贴顶部,不能直接调整标签栏的配置
        questionsListView = TopicDetailListView(frame:
            CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight), topicId: topicId, shouldAutoRefresh: true, isIndependentView: false)
        questionsListView.labelCollectView.labelsHeight = 64
        questionsListView.childTablesBounces = false
        questionsListView.delegate = self
        questionsListView.backButton.isHidden = true
        questionsListView.childViewsScrollEnable = false
        // 2.话题详情列表
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
        table.estimatedRowHeight = 300
        table.separatorStyle = .none
        // 注册基础信息 cell
        table.register(UINib(nibName: "TSQuoraTopicsJoinTableCell", bundle: nil), forCellReuseIdentifier: TSQuoraTopicsJoinTableCell.identifier)
        // 注册简介 cell
        table.register(QuoraTopicDetailIntroLabelCell.self, forCellReuseIdentifier: QuoraTopicDetailIntroLabelCell.identifier)
        // 注册专家 cell
        table.register(QuoraTopicDetailExpertsCell.self, forCellReuseIdentifier: QuoraTopicDetailExpertsCell.identifier)
        // 注册一个 cell 来放置 questionsListView 问答列表
        table.register(UITableViewCell.self, forCellReuseIdentifier: questionsListViewIdentifier)
        // 注册分割线 cell
        table.register(StackSeperatorCell.self, forCellReuseIdentifier: StackSeperatorCell.identifier)
        view.addSubview(table)
        // 3.分享按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_ico_quora_share"), style: .plain, target: self, action: #selector(shareButtonTaped))
        // 4.发布按钮
        buttonForRelease.setImage(UIImage(named: "IMG_channel_btn_suspension"), for: .normal)
        buttonForRelease.contentMode = .center
        buttonForRelease.sizeToFit()
        // - 25 - 64
        buttonForRelease.frame = CGRect(x: (UIScreen.main.bounds.width - buttonForRelease.frame.width) - 25, y: view.frame.height - buttonForRelease.frame.height - 89 - TSBottomSafeAreaHeight, width: buttonForRelease.frame.width, height: buttonForRelease.frame.height)
        buttonForRelease.addTarget(self, action: #selector(releaseButtonTaped), for: .touchUpInside)
        view.addSubview(buttonForRelease)
    }

    /// 点击了发布按钮
    func releaseButtonTaped() {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.跳转发布页面
        let topicModel = TSQuoraTopicModel(topicDetailModel: topicDetailViewModel)
        let questionEditVC = TSQuestionTitleEditController()
        questionEditVC.type = .topicPublish
        questionEditVC.currentTopic = topicModel
        self.navigationController?.pushViewController(questionEditVC, animated: true)
    }

    /// 点击了分享按钮
    func shareButtonTaped() {
        guard let topicBasicInfo = topicDetailViewModel.basicInfoModel else {
            return
        }
        guard let detailInfo = topicDetailViewModel.introModel else {
            return
        }
        var image = UIImage(named: "IMG_icon")
        if let imageURL = topicBasicInfo.imageURL {
            image = UIImage(named: imageURL)
        }
        let title = topicBasicInfo.title.count > 0 ? topicBasicInfo.title : TSAppSettingInfoModel().appDisplayName + " " + "问答"
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let description = detailInfo.introl.count > 0 ? detailInfo.introl : defaultContent
        let shareView = ShareView()
        var url = ShareURL.topics.rawValue
        url.replaceAll(matching: "replacetopic", with: "\(topicBasicInfo.id)")
        shareView.show(URLString: url, image: image, description: description, title: title)
    }

    /// 跳转到问题列表视图控制器
    func presentToQustionsListView(index: Int) {
        animatorManager.presentOffsetY = questionsListViewOriginalY - table.contentOffset.y
        let qustionsVC = TopicDetailQuoraListController(topicDetailViewModel: topicDetailViewModel, datas: questionsListView.childDatas, selected: index)
        let nav = TSNavigationController(rootViewController: qustionsVC)
        nav.modalTransitionStyle = .coverVertical
        nav.transitioningDelegate = animatorManager
        present(nav, animated: true, completion: nil)
    }

    // MARK: - Data
    func loadData() {
        // 获取话题信息数据
        TSQuoraNetworkManager.getTopicInfo(topicId: topicId) { [weak self] (data: TSQuoraTopicModel?, _, _) in
            // 1.获取话题信息失败
            guard let model = data else {
                self?.loadFaild(type: .network)
                return
            }
            // 2.获取话题信息成功
            self?.endLoading()
            self?.topicDetailViewModel = TopicDetailControllerModel(model: model)
            self?.table.reloadData()
        }
    }

    override func reloadingButtonTaped() {
        loadData()
    }

    // MARK: - Notification
    func setNotification() {
        /// 监测回答列表将要 dissmiss，同步两个问题列表的数据
        NotificationCenter.default.addObserver(self, selector: #selector(willDissmissQustionsListView(notification:)), name: NSNotification.Name.TopicDetailController.willDismiss, object: nil)
        /// 监测问答列表已经 dismiss，更新 table 的偏移量
        NotificationCenter.default.addObserver(self, selector: #selector(dismissQuestionsListView), name: NSNotification.Name.TopicDetailController.dismiss, object: nil)
        /// 监测点击了展开按钮
        NotificationCenter.default.addObserver(self, selector: #selector(unfoldButtonTaped), name: NSNotification.Name.TopicDetailController.unfold, object: nil)
    }

    /// 点击了话题简介上的展开按钮
    func unfoldButtonTaped() {
        showMoreIntro = true
        // cell 中更新约束后，需要刷新一下界面
        table.reloadData()
    }

    /// 监测问答列表已经 dismiss，更新 table 的偏移量
    func dismissQuestionsListView() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { [weak self] in
            self?.table.contentOffset = CGPoint(x: 0, y: 0)
        }, completion: nil)
    }

    /// 监测回答列表将要 dissmiss，同步两个问题列表的数据
    func willDissmissQustionsListView(notification: Notification) {
        let selectedIndex = notification.userInfo?["selectedIndex"] as? Int
        let datas = notification.userInfo?["datas"] as? [[TSQuoraTableCellModel]]
        guard let newIndex = selectedIndex, let newDatas = datas else {
            return
        }
        questionsListView.childDatas = newDatas
        questionsListView.labelCollectView.selected = newIndex
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicDetailController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard topicDetailViewModel != nil else {
            return 0
        }
        // +1 是因为最后一个 cell 放 questionsListView 问答列表，问答列表的数据由问答列表内部保存。
        return topicDetailViewModel.dataArrays.count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 最后一个 cell 是问题列表所在的 cell，这个 cell 手动返回高度，其它 cell 动态计算高度
        guard indexPath.row != topicDetailViewModel.dataArrays.count else {
            return questionsListView.frame.height
        }
        /// 分割线 cell 也是单独计算的
        if let cellModel = topicDetailViewModel.dataArrays[indexPath.row] as? QuoraStackCellModel {
            return cellModel.cellHeight
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1.如果是最后一个 cell，将问答列表放置在最后一个 cell 中
        if indexPath.row == topicDetailViewModel.dataArrays.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: questionsListViewIdentifier, for: indexPath)
            // 判断问答列表有无父视图，如果没有，就将问答列表放在 cell 中
            if questionsListView.superview == nil {
                cell.contentView.addSubview(questionsListView)
            }
            return cell
        }
        // 获取数据
        let cellModel = topicDetailViewModel.dataArrays[indexPath.row]
        var cell: UITableViewCell!
        // 2.加载基础信息 cell
        if let basicInfoModel = cellModel as? TSQuoraTopicsJoinTableCellModel {
            let basicInfoCell = tableView.dequeueReusableCell(withIdentifier: TSQuoraTopicsJoinTableCell.identifier, for: indexPath) as! TSQuoraTopicsJoinTableCell
            basicInfoCell.setInfo(model: basicInfoModel)
            basicInfoCell.delegate = self
            basicInfoCell.separatorLine.isHidden = true
            cell = basicInfoCell
        }
        // 3.加载简介 cell
        if let introlModel = cellModel as? QuoraTopicDetailIntroLabelCellModel {
            let introlCell = tableView.dequeueReusableCell(withIdentifier: QuoraTopicDetailIntroLabelCell.identifier, for: indexPath) as! QuoraTopicDetailIntroLabelCell
            introlCell.showMoreIntro = showMoreIntro
            introlCell.model = introlModel
            cell = introlCell
        }
        // 4.加载专家 cell
        if let expertsModel = cellModel as? QuoraTopicDetailExpertsCellModel {
            let expertsCell = tableView.dequeueReusableCell(withIdentifier: QuoraTopicDetailExpertsCell.identifier, for: indexPath) as! QuoraTopicDetailExpertsCell
            expertsCell.model = expertsModel
            cell = expertsCell
        }
        // 5.加载分割线 cell
        if let model = cellModel as? StackSeperatorCellModel {
            let seperatorCell = StackSeperatorCell.cellForm(table: tableView, at: indexPath, with: model)
            cell = seperatorCell
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        // 如果是专家头像 cell
        if cell.isKind(of: QuoraTopicDetailExpertsCell.self) {
            let expertsList = TopicExpertsListController(topicId: topicId)
            navigationController?.pushViewController(expertsList, animated: true)
        }
    }

}

// MARK: - UIScrollViewDelegate
extension TopicDetailController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > 1 else {
            return
        }
        // 1.取得偏移量
        let offsetY = scrollView.contentOffset.y
        // 2.获取 scrollow 的偏移量和问题列表的偏移量的差值，判断是否滑动到了问题列表
        let willAccessQuestionsListView = abs(offsetY - questionsListViewOriginalY) < 1
        // 3.根据 scrollow 的偏移量决定是否需要跳转到问题列表
        if willAccessQuestionsListView {
            presentToQustionsListView(index: questionsListView.labelCollectView.selected)
        } else if offsetY > questionsListViewOriginalY {
            scrollView.setContentOffset(CGPoint(x: 0, y: questionsListViewOriginalY), animated: false)
        }
    }
}

// MARK: - TSQuoraTopicsJoinTableCellDelegate: 关注按钮点击代理
extension TopicDetailController: TSQuoraTopicsJoinTableCellDelegate {
    /// 点击了话题关注按钮
    func cell(_ cell: TSQuoraTopicsJoinTableCell, didSelectedFollowButton button: UIButton, cellModel: TSQuoraTopicsJoinTableCellModel) {
        // 0.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 1.改变关注按钮的选中状态和关注数量
        cellModel.isFollowed = !cellModel.isFollowed
        cellModel.followCount += cellModel.isFollowed ? 1 : -1
        topicDetailViewModel.basicInfoModel = cellModel
        let indexPath = table.indexPath(for: cell)!
        table.reloadRow(at: indexPath, with: .none)
        // 2.发起 关注/取消关注的网络请求
        if button.isSelected {
            // 关注
            TSQuoraNetworkManager.follow(topicId: topicId, complete: nil)
        } else {
            // 取消关注
            TSQuoraNetworkManager.unFollow(topicId: topicId, complete: nil)
        }
    }
}

// MARK: - TopicDetailListViewDelegate: 问题列表代理
extension TopicDetailController: TopicDetailListViewDelegate {
    /// 点击了问题列表上的标签按钮
    func qustionsListView(_ view: TopicDetailListView, didSelected labelButton: UIButton, at index: Int) {
        presentToQustionsListView(index: index)
    }
}
