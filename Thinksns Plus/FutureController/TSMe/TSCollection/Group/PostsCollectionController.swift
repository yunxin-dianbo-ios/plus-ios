//
//  PostsCollectionController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class PostsCollectionController: UIViewController {

    // 列表
    let table = PostListActionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - 40)), tableIdentifier: "collection")

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        // 列表
        table.refreshDelegate = self
        table.mj_header.beginRefreshing()

        view.addSubview(table)
    }
}

// MARK: - FeedListViewRefreshDelegate: 列表刷新代理
extension PostsCollectionController: FeedListViewRefreshDelegate {

    // MARK: 代理方法
    /// 下拉刷新
    func feedListTable(_ table: FeedListView, refreshingDataOf tableIdentifier: String) {
        GroupNetworkManager.getMyCollectPosts(offset: 0) { (models, message, status) in
            var cellModels: [FeedListCellModel]?
            if let models = models {
                cellModels = models.map { FeedListCellModel(postCollection: $0) }
            }
            table.processRefresh(data: cellModels, message: message, status: status)
        }
    }

    /// 上拉加载
    func feedListTable(_ table: FeedListView, loadMoreDataOf tableIdentifier: String) {

        GroupNetworkManager.getMyCollectPosts(offset: table.datas.count) { (models, message, status) in
            var cellModels: [FeedListCellModel]?
            if let models = models {
                cellModels = models.map { FeedListCellModel(postCollection: $0) }
            }
            table.processloadMore(data: cellModels, message: message, status: status)
        }
    }
}
