//
//  MyQuestionsListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的问答 - 提问

import UIKit

class MyQuestionsListView: UIView {

    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["全部", "邀请", "悬赏", "其他"]

    /// 问答列表视图
    var tables: [QuoraListView] = []
    /// 问答列表类型数组
    let types: [String] = ["all", "invitation", "reward", "other"]

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    func setUI() {
        // 1.设置标签滚动视图
        labelCollectView.frame = bounds
        labelCollectView.titles = titles
        labelCollectView.shouldShowBlueLine = true
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = QuoraListView(frame: labelCollectView.collection.bounds, tableIdentifier: type, shouldAutoRefresh: true)
            table.refreshDelegate = self
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.childViews = tables
    }
}

// MARK: - TSQuoraTableRefreshDelegate 问答列表刷新代理
extension MyQuestionsListView: TSQuoraTableRefreshDelegate {
    // 上拉刷新
    func table(_ table: TSQuoraTableView, refreshingDataOf tableIdentifier: String) {
        TSMineNetworkManager.getMyQuestions(type: tableIdentifier, after: nil) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
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
        TSMineNetworkManager.getMyQuestions(type: tableIdentifier, after: table.datas.last?.id) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
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
