//
//  TopicDetailListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  某个话题的问题列表

import UIKit

protocol TopicDetailListViewDelegate: class {
    func qustionsListView(_ view: TopicDetailListView, didSelected labelButton: UIButton, at index: Int)
}

class TopicDetailListView: UIView {
    /// 是否是独立的页面,独立页面在iPhoneX下需要对顶部进行调整
    var isIndependentView: Bool = false
    /// 话题 id
    var topicId: Int!
    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["热门", "精选", "悬赏", "最新", "全部"]
    /// 子视图中 table 的 bounces
    var childTablesBounces: Bool = true {
        didSet {
            changeChildTablesBounces()
        }
    }
    /// 子视图的数据
    var childDatas: [[TSQuoraTableCellModel]] {
        set(newDatas) {
            guard newDatas.count == tables.count else {
                return
            }
            updateChildViewsDatas(newDatas: newDatas)
        }
        get {
            return tables.map { $0.datas }
        }
    }

    /// 代理
    weak var delegate: TopicDetailListViewDelegate?

    /// 返回按钮
    let backButton = UIButton(type: .custom)
    /// 问答列表视图
    var tables: [QuoraListView] = []
    /// 问答列表类型数组
    let types: [String] = ["hot", "excellent", "reward", "new", "all"]
    /// 游客模式下获取数据的次数
    var visitorRefreshCount: [String: Int] = ["hot": 0, "excellent": 0, "reward": 0, "new": 0, "all": 0]
    /// 子视图是否可以滚动
    var childViewsScrollEnable = true {
        didSet {
            // 遍历子视图
            for childView in labelCollectView.childViews {
                // 将 table 滚动效果禁止
                if let tableView = childView as? UITableView {
                    tableView.isScrollEnabled = childViewsScrollEnable
                }
            }
        }
    }

    // MARK: - Lifecycle

    /// 通过话题 id 初始化，所有 table 有第一次自动刷新
    ///
    /// - Parameters:
    ///   - frame: 界面大小
    ///   - id: 话题 id
    init(frame: CGRect, topicId id: Int, shouldAutoRefresh: Bool = true, isIndependentView: Bool = false) {
        super.init(frame: frame)
        topicId = id
        self.isIndependentView = isIndependentView
        setUI(shouldAutoRefresh: shouldAutoRefresh)
    }

    /// 通过 tables 的 cellModels 来初始化，所有 table 将不自动刷新，只是直接展示传入的 cellModels 数据
    ///
    /// - Parameters:
    ///   - frame: 界面大小
    ///   - datas: 元素是 [TSQuoraTableCellModel] 的数组
    init(frame: CGRect, childDatas datas: [[TSQuoraTableCellModel]]) {
        super.init(frame: frame)
        setUI(shouldAutoRefresh: false)
        childDatas = datas
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Custom user interface
    func setUI(shouldAutoRefresh: Bool) {
        // 1.设置标签滚动视图
        labelCollectView.frame = bounds
        if TSUserInterfacePrinciples.share.isiphoneX() == true && self.isIndependentView == true {
            labelCollectView.frame = CGRect(x: 0, y: TSTopAdjustsScrollViewInsets, width: ScreenWidth, height: self.height - TSTopAdjustsScrollViewInsets)
        }
        labelCollectView.leadingAndTralling = 50
        labelCollectView.titles = titles
        labelCollectView.delegate = self
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = QuoraListView(frame: labelCollectView.collection.bounds, tableIdentifier: type, shouldAutoRefresh: shouldAutoRefresh)
            table.refreshDelegate = self
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.addChildViews(tables)
        // 4.返回按钮
        backButton.setImage(UIImage(named: "IMG_topbar_back"), for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: 64)
        labelCollectView.labelsView.addSubview(backButton)
        backButton.centerY = labelCollectView.labelsView.centerY
    }

    /// 修改子视图中 table 的 bounces
    func changeChildTablesBounces() {
        for childView in labelCollectView.childViews {
            guard let childTableView = childView as? UITableView else {
                continue
            }
            childTableView.bounces = childTablesBounces
        }
    }

    /// 更新子视图数据
    func updateChildViewsDatas(newDatas: [[TSQuoraTableCellModel]]) {
        // 遍历数组
        for index in 0..<newDatas.count {
            let newData = newDatas[index]
            let table = tables[index]
            if newData.isEmpty {
                // 如果数据为空，加载一次数据
                table.mj_header.beginRefreshing()
            } else {
                // 如果数据不为空
                table.datas = newData
                table.reloadData()
            }
        }
    }

}

// MARK: - TSQuoraTableRefreshDelegate 问答列表刷新代理
extension TopicDetailListView: TSQuoraTableRefreshDelegate {

    /// 跳转到登录页面
    func presentToLoginVC() {
        /*
         这里不用 TSRootViewController.share.guestJoinLoginVC() 是因为这个方法跳转不过去，
         所以特别写了一个单独的方法。
         */
        let login = TSLoginVC(isHiddenDismissButton: false, isHiddenGuestLoginButton: true)
        let loginVC = TSNavigationController(rootViewController: login)
        parentViewController?.present(loginVC, animated: true, completion: nil)
    }

    // 上拉刷新
    func table(_ table: TSQuoraTableView, refreshingDataOf tableIdentifier: String) {
        // 0.判断是否处于游客模式，如果是，拦截操作
        if TSCurrentUserInfo.share.isLogin == false {
            if visitorRefreshCount[tableIdentifier] == 0 {
                visitorRefreshCount[tableIdentifier] = 1
            } else {
                table.mj_header.endRefreshing()
                // 跳转到登录界面
                presentToLoginVC()
                return
            }
        }

        // 1.发起刷新网络请求
        TSQuoraNetworkManager.getTopicQuoras(topicId: topicId, subject: nil, offset: 0, type: tableIdentifier) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTableCellModel(model: $0) }
            }
            table.processRefresh(newDatas: newDatas, errorMessage: message)
        }
    }

    // 下拉加载更多
    func table(_ table: TSQuoraTableView, loadMoreDataOf tableIdentifier: String) {
        // 0.判断是否处于游客模式，如果是，拦截操作
        if TSCurrentUserInfo.share.isLogin == false {
            if visitorRefreshCount[tableIdentifier] == 0 {
                visitorRefreshCount[tableIdentifier] = 1
            } else {
                table.mj_footer.endRefreshing()
                // 跳转到登录界面
                presentToLoginVC()
                return
            }
        }

        // 1.发起刷新网络请求
        TSQuoraNetworkManager.getTopicQuoras(topicId: topicId, subject: nil, offset: table.datas.count, type: tableIdentifier) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTableCellModel(model: $0) }
            }
            table.processLoadMore(newDatas: newDatas, errorMessage: message)
        }
    }
}

// MARK: - TSLabelCollectionViewDelegate: 标签视图 交互代理事件
extension TopicDetailListView: TSLabelCollectionViewDelegate {
    func view(_ view: TSLabelCollectionView, didSelected labelButton: UIButton, at index: Int) {
        delegate?.qustionsListView(self, didSelected: labelButton, at: index)
    }
}
