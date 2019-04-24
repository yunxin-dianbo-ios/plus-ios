//
//  RankListController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜

import UIKit

class RankListController: UIViewController {

    /// 标签滚动视图
    var labelCollection = TSLabelCollectionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)))

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - UI
    func setUI() {
        title = "排行榜"
        // 1.标签滚动视图
        var titles = ["用户", "问答", "动态", "资讯"]
        if !TSAppConfig.share.localInfo.quoraSwitch {
        titles = ["用户", "动态", "资讯"]
        }
        labelCollection.leadingAndTralling = 32
        labelCollection.titles = titles
        labelCollection.shouldShowBlueLine = true
        // 2.列表视图
        // 用户排行榜的榜单类型
        var userRankTypes: [RankListManager.RankType] = []
        if TSAppConfig.share.localInfo.checkin {
            userRankTypes = [.fans, .wealth, .income, .attendance, .communityExperts, .quoraExperts]
        } else {
            userRankTypes = [.fans, .wealth, .income, .communityExperts, .quoraExperts]
        }
        // 问答排行榜的榜单类型
        let quoraRankTypes: [RankListManager.RankType] = [.answerToday, .answerWeek, .answerMonth]
        // 动态排行榜的榜单类型
        let feedRankTypes: [RankListManager.RankType] = [.feedToday, .feedWeek, .feedMonth]
        // 资讯排行榜的榜单类型
        let newsRankTypes: [RankListManager.RankType] = [.newsToday, .newsWeek, .newsMonth]
        // 按显示顺序将排行榜信息放在数组 rankTypes 中
        var allRankTypes = [userRankTypes.map { $0.rawValue }, quoraRankTypes.map { $0.rawValue }, feedRankTypes.map { $0.rawValue }, newsRankTypes.map { $0.rawValue }]
        if !TSAppConfig.share.localInfo.quoraSwitch {
            if TSAppConfig.share.localInfo.checkin {
                userRankTypes = [.fans, .wealth, .income, .attendance, .communityExperts]
            } else {
                userRankTypes = [.fans, .wealth, .income, .communityExperts]
            }
            allRankTypes = [userRankTypes.map { $0.rawValue }, feedRankTypes.map { $0.rawValue }, newsRankTypes.map { $0.rawValue }]
        }
        var tables: [RankListView] = []
        // 根据 rankTypes 按顺序生成排行榜总览列表
        for rankTypes in allRankTypes {
            let table = RankListView(frame: labelCollection.collection.bounds, rankTypes: rankTypes, shouldAutoRefresh: true)
            table.refreshDelegate = self
            table.interactionDelegate = self
            tables.append(table)
        }

        labelCollection.addChildViews(tables)
        view.addSubview(labelCollection)
    }

}

// MARK: - RankListViewRefreshDelegate: 排行榜总览表刷新代理事件
extension RankListController: RankListViewRefreshDelegate {
    // 下拉刷新
    func rankTable(_ table: RankListView, refreshing rankTypes: [String]) {
        // 1.将 rankTypes 从 [String] 类型转换成 [RankListManager.RankType] 类型
        let types = rankTypes.flatMap { RankListManager.RankType(rawValue: $0) }
        // 2.通过 types 发起网络请求，获数据
        RankListManager.getRrankLists(rankTypes: types, offset: 0) { (datas: [[TSUserInfoModel]]?, message: String?, _) in
            var cellModels: [RankListPreviewCellModel]?
            // 解析数据
            if let datas = datas {
                cellModels = []
                for type in rankTypes {
                    let index = Int(rankTypes.index(of: type)!)
                    let models = datas[index]
                    let cellModel = RankListPreviewCellModel(models: models, title: type)
                    cellModels?.append(cellModel)
                }
            }
            table.processRefresh(newDatas: cellModels?.filter { !$0.userInfos.isEmpty }, errorMessage: message)
        }
    }
}

// MARK: - RankListViewDelegate: 排行榜总览表交互代理事件
extension RankListController: RankListViewDelegate {
    // 点击了总览表的某个榜单
    func rankTable(_ table: RankListView, didSelectRowAt indexPath: IndexPath, with cellModel: RankListPreviewCellModel) {
        guard let rankType = RankListManager.RankType(rawValue: cellModel.title) else {
            return
        }
        // 跳转到单个排行榜页面
        let detailVC = RankListDetailController(type: rankType)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
