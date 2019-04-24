//
//  AllGroupController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  全部圈子
//
//  [注意事项] 这里的 tag view 相关逻辑是 copy 的资讯的

import UIKit

//enum TableRefreshStatus {
//    /// 没有刷新过
//    case none
//    /// 刷新网络错误
//    case error
//    /// 已经加载完所有数据
//    case end
//    /// 普通
//    case normal
//}
//
//class GroupListStatusModel {
//
//    var datas: [GroupListCellModel]?
//    var message: String?
//    var status: TableRefreshStatus = .none
//}

class AllGroupController: UIViewController {

    /// 导航栏右边按钮视图
    let rightNavView = GroupListRightNavView()
    /// 滚动视图
    let doubleCollection = DoubleCollectionsView(origin: .zero)

    /// tag数据
    var tagInfos: [ATagModel] = []
    /// 滚动视图上的子视图数据
    var tableInfos: [[GroupListCellModel]?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadDatas()
    }

    // MARK: - UI

    func setUI() {
        view.backgroundColor = .white
        title = "全部圈子"
        self.automaticallyAdjustsScrollViewInsets = false
        // 1.导航栏右边按钮视图
        rightNavView.searchButton.addTarget(self, action: #selector(searchButtonTaped), for: .touchUpInside)
        rightNavView.buildButton.addTarget(self, action: #selector(buildButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)

        // 2.滚动视图
        doubleCollection.rightButton.addTarget(self, action: #selector(showTagChooseVC), for: .touchUpInside)
        doubleCollection.bottomCollcetion.register(GroupListCollectionCell.self, forCellWithReuseIdentifier: GroupListCollectionCell.identifier)
        doubleCollection.bottomCollcetion.dataSource = self
        doubleCollection.doubleCollectionsDelegate = self
        view.addSubview(doubleCollection)
    }

    /// 点击了创建圈子按钮
    func buildButtonTaped() {
        // 游客触发登录
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 判断配置是否需要认证才可创建圈子，如果需要，检查用户是否已经经过了身份验证
        let verified = TSCurrentUserInfo.share.userInfo?.verified
        // 更新后台配置权限
        // 去认证
        let loadingAlertVC = TSIndicatorWindowTop(state: .loading, title: "提示信息_获取后台配置信息".localized)
        loadingAlertVC.show()
        TSRootViewController.share.updateLaunchConfigInfo { (status) in
            loadingAlertVC.dismiss()
            if status == true {
                let groupBuildNeedVerified = TSAppConfig.share.launchInfo?.groupBuildNeedVerified
                // 创建圈子需要认证，且还没有认证
                if groupBuildNeedVerified == true && nil == verified {
                    // 去认证
                    let alertVC = TSVerifyAlertController(title: "显示_提示".localized, message: "认证用户才能创建圈子，去认证？")
                    TSRootViewController.share.currentShowViewcontroller?.present(alertVC, animated: false, completion: nil)
                } else {
                    // 去创建圈子
                    let createVC = CreateGroupController.vc()
                    self.navigationController?.pushViewController(createVC, animated: true)
                }
            } else {
                // 网络不可用
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_网络错误".localized)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 点击了搜索按钮
    func searchButtonTaped() {
        let searchVC = GroupSearchController()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    /// 显示标签选择页面
    func showTagChooseVC() {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        let chooseTagController = SingleTagChooseController()
        chooseTagController.title = "全部圈子"
        let titles = tagInfos.map { $0.name }
        chooseTagController.set(titles: titles, selected: doubleCollection.currentIndex)
        chooseTagController.selectedBlock = { [weak self] (selectedIndex) in
            self?.doubleCollection.setSelected(at: selectedIndex)
        }
        navigationController?.pushViewController(chooseTagController, animated: true)
    }

    // MARK: - Data
    func loadDatas() {
        GroupNetworkManager.getGroupCategories { [weak self] (categories, message, status) in
            guard let categories = categories else {
                return
            }
            var models: [ATagModel] = [ATagModel.recommend()]
            for (index, category) in categories.enumerated() {
                let model = ATagModel(categoriesModel: category)
                model.index = index + 1
                models.append(model)
            }
            self?.tagInfos = models
            self?.tableInfos = [[GroupListCellModel]?](repeating: nil, count: models.count)
            self?.doubleCollection.set(titles: models.map { $0.name })
            self?.doubleCollection.bottomCollcetion.reloadData()
            self?.doubleCollection.setSelected(at: 0)
        }
    }

}

extension AllGroupController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableInfos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupListCollectionCell.identifier, for: indexPath) as! GroupListCollectionCell
        cell.table.refreshDelegate = self
        cell.reset(tableIdentifier: tagInfos[indexPath.row].tagID)
        return cell
    }

}

extension AllGroupController: DoubleCollectionsViewDelegate {

    /// 下方集合视图将要显示 cell
    func doubleCollections(_ view: DoubleCollectionsView, bottomCollection: UICollectionView, willDisplay cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let bottomCell = cell as? GroupListCollectionCell else {
            return
        }
        // 更新圈子列表的显示数据
        let datas = tableInfos[indexPath.row]
        bottomCell.table.datas = datas ?? []
        bottomCell.table.reloadData()
        // 如果 datas 是 nil，说明这个列表是第一次显示，所以要需要自动刷新
         if datas == nil {
            bottomCell.table.mj_header.beginRefreshing()
            return
        }
        if datas?.isEmpty == true {
            bottomCell.table.show(placeholderView: .empty)
            return
        }
    }
}

// MARK: - GroupListViewRefreshDelegate
extension AllGroupController: GroupListViewRefreshDelegate {

    /// 下拉刷新
    func groupListView(_ view: GroupListView, didRefreshWithIdentidier identifier: String) {

        guard let categoriesId = Int(view.tableIdentifier), let index = tagInfos.index(where: { $0.tagID == categoriesId }) else {
            return
        }

        // 1.如果是推荐类型
        let isRecommend = categoriesId == -9999
        if isRecommend {
            GroupNetworkManager.getRecommendGroups(offset: 0, complete: { [weak self] (models, message, status) in
                var cellModels: [GroupListCellModel]?
                if let models = models {
                    cellModels = models.map { GroupListCellModel(model: $0) }
                }
                view.processRefresh(newDatas: cellModels, errorMessage: message)
                self?.tableInfos[0] = view.datas
            })
            return
        }
        // 2.其他类型
        GroupNetworkManager.getAllGroups(categoriesId: categoriesId, keyword: nil, offset: 0) { [weak self] (models, message, status) in
            var cellModels: [GroupListCellModel]?
            if let models = models {
                cellModels = models.map { GroupListCellModel(model: $0) }
            }
            view.processRefresh(newDatas: cellModels, errorMessage: message)
            self?.tableInfos[index] = view.datas
        }
    }

    /// 上拉加载
    func groupListView(_ view: GroupListView, didLoadMoreWithIdentidier identifier: String) {
        guard let categoriesId = Int(view.tableIdentifier), let index = tagInfos.index(where: { $0.tagID == categoriesId }) else {
            return
        }
        // 1.如果是推荐类型
        let isRecommend = categoriesId == -9999
        if isRecommend {
            GroupNetworkManager.getRecommendGroups(offset: view.datas.count, complete: { [weak self] (models, message, status) in
                var cellModels: [GroupListCellModel]?
                if let models = models {
                    cellModels = models.map { GroupListCellModel(model: $0) }
                }
                view.processLoadMore(newDatas: cellModels, errorMessage: message)
                self?.tableInfos[0] = view.datas
            })
            return
        }
        // 2.其他类型
        GroupNetworkManager.getAllGroups(categoriesId: categoriesId, keyword: nil, offset: view.datas.count) { [weak self] (models, message, status) in
            var cellModels: [GroupListCellModel]?
            if let models = models {
                cellModels = models.map { GroupListCellModel(model: $0) }
            }
            view.processLoadMore(newDatas: cellModels, errorMessage: message)
            self?.tableInfos[index] = view.datas
        }
    }
}
