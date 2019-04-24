//
//  FeedCollectionController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class FeedCollectionController: UIViewController {

    // 列表
    let table = FeedListActionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - 40)), tableIdentifier: "collection")

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        // 列表
        table.refreshDelegate = self
        view.addSubview(table)
    }
}

// MARK: - FeedListViewRefreshDelegate: 列表刷新代理
extension FeedCollectionController: FeedListViewRefreshDelegate {

    // MARK: 代理方法
    /// 下拉刷新
    func feedListTable(_ table: FeedListView, refreshingDataOf tableIdentifier: String) {
        FeedListNetworkManager.getCollectFeeds(after: 0) { (status, message, models) in
            var cellModels: [FeedListCellModel]?
            if let models = models {
                cellModels = models.map { FeedListCellModel(feedCollection: $0) }
            }
            table.processRefresh(data: cellModels, message: message, status: status)
        }
    }

    /// 上拉加载
    func feedListTable(_ table: FeedListView, loadMoreDataOf tableIdentifier: String) {
        FeedListNetworkManager.getCollectFeeds(after: table.datas.count) { (status, message, models) in
            var cellModels: [FeedListCellModel]?
            if let models = models {
                cellModels = models.map { FeedListCellModel(feedCollection: $0) }
            }
            table.processloadMore(data: cellModels, message: message, status: status)
        }
    }
}
