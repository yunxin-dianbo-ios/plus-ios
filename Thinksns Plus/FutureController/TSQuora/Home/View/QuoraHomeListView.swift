//
//  QuoraHomeListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  主页 问答列表

import UIKit
import SnapKit

class QuoraHomeListView: UIView {

    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["热门", "精选", "悬赏", "最新", "全部"]

    /// 发布按钮
    var buttonForRelease = TSButton(type: .custom)
    /// 问答列表视图
    var tables: [QuoraListView] = []
    /// 问答列表类型数组
    let types: [String] = ["hot", "excellent", "reward", "new", "all"]
    /// 游客模式下获取数据的次数
    var visitorRefreshCount: [String: Int] = ["hot": 0, "excellent": 0, "reward": 0, "new": 0, "all": 0]

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
        labelCollectView.leadingAndTralling = 20
        labelCollectView.titles = titles
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = QuoraListView(frame: labelCollectView.collection.bounds, tableIdentifier: type, shouldAutoRefresh: true)
            table.refreshDelegate = self
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.childViews = tables
        // 4.发布按钮
        buttonForRelease.setImage(UIImage(named: "IMG_channel_btn_suspension"), for: .normal)
        buttonForRelease.contentMode = .center
        buttonForRelease.sizeToFit()
        buttonForRelease.frame = CGRect(x: (UIScreen.main.bounds.width - buttonForRelease.frame.width) - 25, y: frame.height - buttonForRelease.frame.height - 25 - TSBottomSafeAreaHeight, width: buttonForRelease.frame.width, height: buttonForRelease.frame.height)
        buttonForRelease.addTarget(self, action: #selector(releaseButtonTaped), for: .touchUpInside)
        addSubview(buttonForRelease)
    }

    /// 点击了发布按钮
    func releaseButtonTaped() {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.进入发布界面
        let questionEditVC = TSQuestionTitleEditController()
        self.parentViewController?.navigationController?.pushViewController(questionEditVC, animated: true)
    }
}

// MARK: - TSQuoraTableRefreshDelegate 问答列表刷新代理
extension QuoraHomeListView: TSQuoraTableRefreshDelegate {
    // 上拉刷新
    func table(_ table: TSQuoraTableView, refreshingDataOf tableIdentifier: String) {
        // 0.判断是否处于游客模式，如果是，拦截操作
        if TSCurrentUserInfo.share.isLogin == false {
            if visitorRefreshCount[tableIdentifier] == 0 {
                visitorRefreshCount[tableIdentifier] = 1
            } else {
                table.mj_header.endRefreshing()
                // 跳转到登录界面
                TSRootViewController.share.guestJoinLoginVC()
                return
            }
        }

        // 1.发起刷新操作
        TSQuoraNetworkManager.getAllQuoras(subject: nil, offset: 0, type: tableIdentifier) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
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
        guard TSCurrentUserInfo.share.isLogin else {
            table.mj_footer.endRefreshing()
            // 跳转到登录界面
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        // 1.发起下拉加载操作
        TSQuoraNetworkManager.getAllQuoras(subject: nil, offset: table.datas.count, type: tableIdentifier) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
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
