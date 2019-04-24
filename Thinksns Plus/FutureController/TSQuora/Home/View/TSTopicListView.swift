//
//  TSTopicListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSTopicListView: UIView {
    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["全部专题", "我关注的"]

    /// 问答列表视图
    var tables: [TSQuoraTopicsJoinTableView] = []
    /// 问答列表类型数组
    let types: [TSQuoraTopicsJoinDataType] = [.all, .follow]
    /// 游客模式下获取数据的次数
    var visitorRefreshCount = 0

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
        labelCollectView.delegate = self
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = TSQuoraTopicsJoinTableView(frame: labelCollectView.collection.bounds, dataType: type)
            table.refreshDelegate = self
            table.interactionDelegate = self
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.childViews = tables
    }
}

// MARK: - TSQuoraTableRefreshDelegate: 话题列表刷新代理
extension TSTopicListView: TSQuoraTopicsJoinTableRefreshDelegate {
    // 上拉刷新
    func topicTable(_ table: TSQuoraTopicsJoinTableView, refreshingDataOf type: TSQuoraTopicsJoinDataType) {
        // 1.判断是否处于游客模式，如果是，拦截操作
        if TSCurrentUserInfo.share.isLogin == false {
            if visitorRefreshCount == 0 {
                visitorRefreshCount = 1
            } else {
                table.mj_header.endRefreshing()
                // 跳转到登录界面
                TSRootViewController.share.guestJoinLoginVC()
                return
            }
        }

        // 2.刷新“全部话题”
        if type == .all {
            TSQuoraNetworkManager.getAllTopics(after: 0, shouldGetFollowStatus: true, keyword: nil, complete: { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
                guard self != nil else {
                    return
                }
                self?.processRefresh(table: table, data: data, message: message, status: status)
            })
        }
        // 刷新“我关注的话题”
        if type == .follow {
            TSQuoraNetworkManager.getUserTopics(after: table.after, type: type.keyValue, complete: { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
                guard self != nil else {
                    return
                }
                // 我关注的话题，服务器不再返回关注状态，暂时先前端处理
                guard let dataList = data else {
                    return
                }
                for data in dataList {
                    data.isFollow = true
                }
                self?.processRefresh(table: table, data: dataList, message: message, status: status)
            })
        }
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processRefresh(table: TSQuoraTopicsJoinTableView, data: [TSQuoraTopicModel]?, message: String?, status: Bool) {
        var newDatas: [TSQuoraTopicsJoinTableCellModel]?
        // 获取数据成功，将 dataModel 转换成 cellModel
        if let datas = data {
            newDatas = datas.map { TSQuoraTopicsJoinTableCellModel(model: $0) }
        }
        table.processRefresh(data: newDatas, message: message, status: status)
    }

    // 下拉加载更多
    func topicTable(_ table: TSQuoraTopicsJoinTableView, loadMoreDataOf type: TSQuoraTopicsJoinDataType) {
        // 1.判断是否处于游客模式，如果是，拦截操作
        guard TSCurrentUserInfo.share.isLogin else {
            table.mj_footer.endRefreshing()
            // 跳转到登录界面
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        // 2.加载更多“全部话题”
        if type == .all {
            TSQuoraNetworkManager.getAllTopics(after: table.datas.count, shouldGetFollowStatus: true, keyword: nil, complete: { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
                guard self != nil else {
                    return
                }
                self?.processloadMore(table: table, data: data, message: message, status: status)
            })
        }
        // 加载更多“我关注的话题”
        if type == .follow {
            TSQuoraNetworkManager.getUserTopics(after: table.after, type: type.keyValue, complete: { [weak self] (data: [TSQuoraTopicModel]?, message: String?, status: Bool) in
                guard self != nil else {
                    return
                }
                // 我关注的话题，服务器不再返回关注状态，暂时先前端处理
                guard let dataList = data else {
                    return
                }
                for data in dataList {
                    data.isFollow = true
                }
                self?.processloadMore(table: table, data: dataList, message: message, status: status)
            })
        }
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processloadMore(table: TSQuoraTopicsJoinTableView, data: [TSQuoraTopicModel]?, message: String?, status: Bool) {
        var newDatas: [TSQuoraTopicsJoinTableCellModel]?
        // 获取数据成功，将 dataModel 转换成 cellModel
        if let datas = data {
            newDatas = datas.map { TSQuoraTopicsJoinTableCellModel(model: $0) }
        }
        table.processloadMore(data: newDatas, message: message, status: status)
    }

}

// MARK: - TSQuoraTopicsJoinTableViewDelegate: 话题列表交互事件
extension TSTopicListView: TSQuoraTopicsJoinTableViewDelegate {

    /// 点击了话题列表上的关注按钮
    func topicTable(_ table: TSQuoraTopicsJoinTableView, didSelectedFollowButton button: UIButton, at cell: TSQuoraTopicsJoinTableCell, with cellModel: TSQuoraTopicsJoinTableCellModel) {
        // 0.判断是否处于游客模式，如果是，拦截关注按钮的点击操作
        guard TSCurrentUserInfo.share.isLogin else {
            // 跳转到登录界面
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
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
        // 跳转到话题详情页
        let topicId = cellModel.id
        let vc = TopicDetailController(topicId: topicId)
        vc.title = cellModel.title
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TSLabelCollectionViewDelegate：标签滚动视图代理
extension TSTopicListView: TSLabelCollectionViewDelegate {

    /// 标签滚动视图将要滚动到某个页面
    func view(_ view: TSLabelCollectionView, willScrollowTo index: Int) -> Bool {
        guard TSCurrentUserInfo.share.isLogin == false && index == 1 else {
            return true
        }
        // 跳转到登录界面
        TSRootViewController.share.guestJoinLoginVC()
        return false
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
