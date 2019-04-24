//
//  MyFollowQuora.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的问答 - 关注

import UIKit

class MyFollowQuora: UIView {
    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["问题", "专题"]

    /// 问题列表
    var questionsListView: TSQuoraTableView!
    /// 话题列表
    var topicListView: TSQuoraTopicsJoinTableView!

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
        labelCollectView.leadingAndTralling = 26
        labelCollectView.titles = titles
        labelCollectView.shouldShowBlueLine = true
        addSubview(labelCollectView)
        // 2.设置话题列表
        topicListView = TSQuoraTopicsJoinTableView(frame: labelCollectView.collection.bounds, dataType: .follow)
        topicListView.refreshDelegate = self
        topicListView.interactionDelegate = self
        // 3.设置问题列表
        questionsListView = TSQuoraTableView(frame: labelCollectView.collection.bounds, tableIdentifier: "follow", shouldAutoRefresh: true)
        questionsListView.refreshDelegate = self
        questionsListView.interactionDelegate = self
        // 4.向标签滚动视图中添加话题和问题列表
        labelCollectView.childViews = [questionsListView, topicListView]
    }

}

// MARK: - TSQuoraTableRefreshDelegate: 问题列表刷新代理
extension MyFollowQuora: TSQuoraTableRefreshDelegate {
    /// 下拉刷新
    func table(_ table: TSQuoraTableView, refreshingDataOf tableIdentifier: String) {
        TSQuoraNetworkManager.getAllQuoras(subject: nil, offset: 0, type: tableIdentifier) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTableCellModel(TitleAndFollow: $0) }
            }
            table.processRefresh(newDatas: newDatas, errorMessage: message)
        }
    }

    /// 上拉加载
    func table(_ table: TSQuoraTableView, loadMoreDataOf tableIdentifier: String) {
        TSQuoraNetworkManager.getAllQuoras(subject: nil, offset: table.datas.count, type: tableIdentifier) { [weak self] (data: [TSQuoraDetailModel]?, message: String?, _) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTableCellModel(TitleAndFollow: $0) }
            }
            table.processLoadMore(newDatas: newDatas, errorMessage: message)
        }
    }
}

// MARK: - TSQuoraTableViewDelegate: 问题列表交互代理
extension MyFollowQuora: TSQuoraTableViewDelegate {
    /// 点击了问题列表的 cell
    func table(_ table: TSQuoraTableView, didSelectTitleAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel) {
        // 进入问答详情页
        let quoraDetailVC = TSQuoraDetailController()
        quoraDetailVC.questionId = cellModel.id
        self.parentViewController?.navigationController?.pushViewController(quoraDetailVC, animated: true)
    }
}

// MARK: - TSQuoraTopicsJoinTableRefreshDelegate: 话题列表刷新代理
extension MyFollowQuora: TSQuoraTopicsJoinTableRefreshDelegate {
    /// 下拉刷新
    func topicTable(_ table: TSQuoraTopicsJoinTableView, refreshingDataOf type: TSQuoraTopicsJoinDataType) {
        TSQuoraNetworkManager.getUserTopics(after: table.after, type: type.keyValue, complete: { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTopicsJoinTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = []
                for data in datas {
                    let newData = TSQuoraTopicsJoinTableCellModel(model: data)
                    // 请求我关注的话题的接口，并没有返回关注状态，所以这里需要手动设置关注状态
                    newData.isFollowed = true
                    newDatas?.append(newData)
                }
            }
            table.processRefresh(data: newDatas, message: message, status: status)
        })
    }

    /// 话题列表上拉加载
    func topicTable(_ table: TSQuoraTopicsJoinTableView, loadMoreDataOf type: TSQuoraTopicsJoinDataType) {
        TSQuoraNetworkManager.getUserTopics(after: table.after, type: type.keyValue, complete: { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTopicsJoinTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTopicsJoinTableCellModel(model: $0) }
            }
            table.processloadMore(data: newDatas, message: message, status: status)
        })
    }
}

// MARK: - TSQuoraTopicsJoinTableViewDelegate: 话题列表交互代理
extension MyFollowQuora: TSQuoraTopicsJoinTableViewDelegate {
    /// 话题 cell 点击事件
    func topicTable(_ table: TSQuoraTopicsJoinTableView, didSelectRowAt indexPath: IndexPath, with cellModel: TSQuoraTopicsJoinTableCellModel) {
        // 跳转到话题详情页
        let topicId = cellModel.id
        let vc = TopicDetailController(topicId: topicId)
        vc.title = cellModel.title
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func topicTable(_ table: TSQuoraTopicsJoinTableView, didSelectedFollowButton button: UIButton, at cell: TSQuoraTopicsJoinTableCell, with cellModel: TSQuoraTopicsJoinTableCellModel) {
        // 1.改变关注按钮的选中状态和关注数量
        cellModel.isFollowed = !cellModel.isFollowed
        cellModel.followCount += cellModel.isFollowed ? 1 : -1
        let indexPath = table.indexPath(for: cell)!
        table.datas[indexPath.row] = cellModel
        table.reloadRow(at: indexPath, with: .none)
        // 2.发起 关注/取消关注的网络请求
        if cellModel.isFollowed {
            // 关注
            TSQuoraNetworkManager.follow(topicId: cellModel.id, complete: nil)
        } else {
            // 取消关注
            TSQuoraNetworkManager.unFollow(topicId: cellModel.id, complete: nil)
        }
    }
}
