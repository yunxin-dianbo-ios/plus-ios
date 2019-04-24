//
//  GroupSearchView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子搜索视图

import UIKit

class GroupSearchView: GroupListActionView {
    var isHomeSearch = false
    /// 是否显示推荐圈子
    var isShowRecommendGroups: Bool = false
    /// 搜索关键词（由外部给 GroupSearchView 赋值）
    var keyword = "" {
        didSet {
            mj_header.beginRefreshing()
            if isHomeSearch {
                TSDatabaseManager().quora.deleteByContent(content: keyword)
                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
            } else {
                // 将关键字保存在数据库中
                TSDatabaseManager().group.saveSearchObject(content: keyword, type: .group)
            }
        }
    }

    /// 占位图
    var placeholderView: ButtonPlaceholderView!

    // MARK: UI
    override func setUI() {
        super.setUI()
        // 1.占位图
        placeholderView = ButtonPlaceholderView(frame: bounds, buttonAction: { [weak self] in
            // 跳转到创建圈子的页面
            // 判断配置是否需要认证才可创建圈子，如果需要，检查用户是否已经经过了身份验证
            if TSCurrentUserInfo.share.userInfo?.verified == nil && TSAppConfig.share.launchInfo?.groupBuildNeedVerified == true {
                let alertVC = TSVerifyAlertController(title: "显示_提示".localized, message: "认证用户才能创建圈子，去认证？")
                TSRootViewController.share.currentShowViewcontroller?.present(alertVC, animated: false, completion: nil)
                return
            }
            let buildGroupVC = CreateGroupController.vc()
            self?.parentViewController?.navigationController?.pushViewController(buildGroupVC, animated: true)
        })
        placeholderView.set(buttonTitle: "创建圈子", labelText: "未找到相关圈子，创建属于自己的圈子吧")
        set(placeholderView: placeholderView, for: .empty)
    }

    // MARK: Data
    override func refresh() {
        // 是否需要显示推荐圈子（没有圈子搜索记录的时候需要显示）
        if isShowRecommendGroups == true {
            GroupNetworkManager.getRecommendGroups(offset: 0) { (models, message, status) in
                var datas: [GroupListCellModel]?
                if let models = models {
                    datas = models.map { GroupListCellModel(model: $0) }
                }
                self.processRefresh(data: datas, message: message, status: status)
            }
        } else {
            GroupNetworkManager.getAllGroups(categoriesId: nil, keyword: keyword, limit: listLimit, offset: 0) { [weak self] (models, message, status) in
                var datas: [GroupListCellModel]?
                if let models = models {
                    datas = models.map { GroupListCellModel(model: $0) }
                }
                self?.processRefresh(data: datas, message: message, status: status)
            }
        }
    }

    override func loadMore() {
        GroupNetworkManager.getAllGroups(categoriesId: nil, keyword: keyword, limit: listLimit, offset: datas.count) { [weak self] (models, message, status) in
            var datas: [GroupListCellModel]?
            if let models = models {
                datas = models.map { GroupListCellModel(model: $0) }
            }
            self?.processloadMore(data: datas, message: message, status: status)
        }
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processRefresh(data: [GroupListCellModel]?, message: String?, status: Bool) {
        // 隐藏指示器
        dismissIndicatorA()
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        mj_footer.resetNoMoreData()
        // 获取数据失败，显示占位图或者 A 指示器
        if let message = message {
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 获取数据成功，更新数据
        guard let newDatas = data else {
            return
        }
        datas = newDatas
        // 如果数据为空，显示占位图
        if datas.isEmpty {
            show(placeholderView: .empty)
        }
        // 刷新界面
        reloadData()
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processloadMore(data: [GroupListCellModel]?, message: String?, status: Bool) {
        // 获取数据失败，显示"网络失败"的 footer
        if message != nil {
            mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        // 隐藏 A 指示器
        dismissIndicatorA()
        // 请求成功
        // 更新 dataSource，并刷新界面
        guard let newDatas = data else {
            mj_footer.endRefreshing()
            return
        }
        datas = datas + newDatas
        reloadData()
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if data!.count < listLimit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
    }
}
