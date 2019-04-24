//
//  QuoraTopicSearchView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  话题搜索结果页

import UIKit

class QuoraTopicSearchView: UIView {

    var isHomeSearch = false
    /// 搜索关键字（由外部给 QuoraTopicSearchView 赋值）
    var keyword = "" {
        didSet {
            table.mj_header.beginRefreshing()
            if isHomeSearch {
                TSDatabaseManager().quora.deleteByContent(content: keyword)
                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
            } else {
                // 将关键字保存在数据库中
                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .topic)
            }
        }
    }

    /// 话题列表
    var table: TSQuoraTopicsJoinTableView!
    /// 占位图
    var placeholderView: ButtonPlaceholderView!

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface

    /// 设置视图
    func setUI() {
        // 1.话题列表
        table = TSQuoraTopicsJoinTableView(frame: bounds, dataType: .search)
        table.refreshDelegate = self
        table.interactionDelegate = self
        table.separatorStyle = .none
        addSubview(table)
        // 占位图
        placeholderView = ButtonPlaceholderView(frame: bounds, buttonAction: { [weak self] in
            let topicApplyVC = TSTopicApplyController()
            self?.parentViewController?.navigationController?.pushViewController(topicApplyVC, animated: true)
        })
        placeholderView.set(buttonTitle: "显示_申请创建新话题".localized, labelText: "显示_未找到相关话题".localized)
        table.set(placeholderView: placeholderView, for: .empty)
    }
}

// MARK: - TSQuoraTopicsJoinTableRefreshDelegate: 话题列表刷新代理
extension QuoraTopicSearchView: TSQuoraTopicsJoinTableRefreshDelegate {
    /// 上拉刷新
    func topicTable(_ table: TSQuoraTopicsJoinTableView, refreshingDataOf type: TSQuoraTopicsJoinDataType) {
        TSQuoraNetworkManager.getAllTopics(after: nil, shouldGetFollowStatus: true, keyword: keyword) { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTopicsJoinTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTopicsJoinTableCellModel(model: $0) }
            }
            table.processRefresh(data: newDatas, message: message, status: status)
        }
    }

    /// 下拉加载
    func topicTable(_ table: TSQuoraTopicsJoinTableView, loadMoreDataOf type: TSQuoraTopicsJoinDataType) {
        // 过滤最后一个数据的话题 id 由于各种奇奇怪怪的原因获取不到的情况
        guard let after = table.datas.last?.id else {
            return
        }
        TSQuoraNetworkManager.getAllTopics(after: after, shouldGetFollowStatus: true, keyword: keyword) { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            var newDatas: [TSQuoraTopicsJoinTableCellModel]?
            // 获取数据成功，将 dataModel 转换成 cellModel
            if let datas = data {
                newDatas = datas.map { TSQuoraTopicsJoinTableCellModel(model: $0) }
            }
            table.processloadMore(data: newDatas, message: message, status: status)
        }
    }
}

// MARK: - TSQuoraTopicsJoinTableViewDelegate: 话题列表交互代理
extension QuoraTopicSearchView: TSQuoraTopicsJoinTableViewDelegate {
    /// 话题关注按钮点击事件
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

    /// cell 点击事件
    func topicTable(_ table: TSQuoraTopicsJoinTableView, didSelectRowAt indexPath: IndexPath, with cellModel: TSQuoraTopicsJoinTableCellModel) {
        self.parentViewController?.view.endEditing(true)
        // 跳转到话题详情页
        let topicId = cellModel.id
        let vc = TopicDetailController(topicId: topicId)
        vc.title = cellModel.title
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
