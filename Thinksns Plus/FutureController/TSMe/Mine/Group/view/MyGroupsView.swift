//
//  MyGroupsView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的圈子 - 圈子

import UIKit

class MyGroupsView: UIView {

    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["我加入的", "待审核的"]

    /// 问答列表视图
    var tables: [GroupListActionView] = []
    /// 问答列表类型数组
    let types: [String] = ["join", "audit"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        // 1.设置标签滚动视图
        labelCollectView.frame = bounds
        labelCollectView.titles = titles
        labelCollectView.shouldShowBlueLine = true
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = GroupListActionView(frame: labelCollectView.collection.bounds, tableIdentifier: type)
            table.refreshDelegate = self
            table.mj_header.beginRefreshing()
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.childViews = tables
    }
}

extension MyGroupsView: GroupListViewRefreshDelegate {
    /// 下拉刷新
    func groupListView(_ view: GroupListView, didRefreshWithIdentidier identifier: String) {
        GroupNetworkManager.getMyGroups(type: identifier, limit: TSAppConfig.share.localInfo.limit, offset: 0) { [weak self] (models, message, status) in
            guard self != nil else {
                return
            }
            var cellModels: [GroupListCellModel]?
            if let models = models {
                if identifier == "join" {
                    cellModels = models.map { GroupListCellModel(model: $0) }
                }
                if identifier == "audit" {
                    cellModels = models.map { GroupListCellModel(auditType: $0) }
                }
            }
            view.processRefresh(newDatas: cellModels, errorMessage: message)
        }
    }

    /// 上拉加载
    func groupListView(_ view: GroupListView, didLoadMoreWithIdentidier identifier: String) {
        GroupNetworkManager.getMyGroups(type: identifier, limit: TSAppConfig.share.localInfo.limit, offset: view.datas.count) { [weak self] (models, message, status) in
            guard self != nil else {
                return
            }
            var cellModels: [GroupListCellModel]?
            if let models = models {
                if identifier == "join" {
                    cellModels = models.map { GroupListCellModel(model: $0) }
                }
                if identifier == "audit" {
                    cellModels = models.map { GroupListCellModel(auditType: $0) }
                }
            }
            view.processLoadMore(newDatas: cellModels, errorMessage: message)
        }
    }
}
