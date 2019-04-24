//
//  MyPostsView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的圈子 - 帖子

import UIKit

class MyPostsView: UIView {

    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["我发布的", "已置顶的", "置顶待审核"]

    /// 帖子列表视图
    var tables: [PostListActionView] = []
    /// 帖子列表类型数组
    /// 该分类标识已经用于其他地方判断，所以不要轻易修改
    let types: [String] = ["1", "2", "3"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {// 1.设置标签滚动视图
        labelCollectView.frame = bounds
        labelCollectView.titles = titles
        labelCollectView.shouldShowBlueLine = true
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = PostListActionView(frame: labelCollectView.collection.bounds, tableIdentifier: type)
            table.refreshDelegate = self
            table.mj_header.beginRefreshing()
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.childViews = tables
    }
}

extension MyPostsView: FeedListViewRefreshDelegate {

    /// 下拉刷新
    func feedListTable(_ table: FeedListView, refreshingDataOf tableIdentifier: String) {
        GroupNetworkManager.getMyPosts(type: tableIdentifier, offset: 0) { [weak self] (models, message, status) in
            guard self != nil else {
                return
            }
            var cellModels: [FeedListCellModel]?
            if let models = models {
                cellModels = models.map { FeedListCellModel(postModel: $0) }
            }
            table.processRefresh(data: cellModels, message: message, status: status)
        }
    }

    /// 上拉加载
    func feedListTable(_ table: FeedListView, loadMoreDataOf tableIdentifier: String) {
        GroupNetworkManager.getMyPosts(type: tableIdentifier, offset: table.datas.count) { [weak self] (models, message, status) in
            guard self != nil else {
                return
            }
            var cellModels: [FeedListCellModel]?
            if let models = models {
                cellModels = models.map { FeedListCellModel(postModel: $0) }
            }
            table.processloadMore(data: cellModels, message: message, status: status)
        }
    }
}
