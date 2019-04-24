//
//  JoinedGroupsController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class JoinedGroupsController: UIViewController {

    /// 列表
    let table = GroupListActionView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64), tableIdentifier: "join")

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        title = "我加入的"
        view = table
        table.refreshDelegate = self
        table.mj_header.beginRefreshing()
        table.backgroundColor = UIColor(hex: 0xededed)
    }

}

extension JoinedGroupsController: GroupListViewRefreshDelegate {

    /// 下拉刷新
    func groupListView(_ view: GroupListView, didRefreshWithIdentidier identifier: String) {
        GroupNetworkManager.getMyGroups(type: identifier, limit: TSAppConfig.share.localInfo.limit, offset: 0) { [weak self] (models, message, status) in
            guard self != nil else {
                return
            }
            var cellModels: [GroupListCellModel]?
            if let models = models {
                cellModels = models.map { GroupListCellModel(model: $0) }
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
                cellModels = models.map { GroupListCellModel(model: $0) }

            }
            view.processLoadMore(newDatas: cellModels, errorMessage: message)
        }
    }
}
