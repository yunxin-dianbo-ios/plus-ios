//
//  MyAnswersListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的回答

import UIKit

class MyAnswersListView: UIView {

    /// 标签滚动视图
    var labelCollectView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["全部", "被采纳", "被邀请", "其他"]

    /// 问答列表视图
    var tables: [QuoraAnswersListView] = []
    /// 问答列表类型数组
    let types: [String] = ["all", "adoption", "invitation", "other"]

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
        labelCollectView.leadingAndTralling = 10
        labelCollectView.titles = titles
        labelCollectView.shouldShowBlueLine = true
        addSubview(labelCollectView)
        // 2.设置问答列表视图
        for type in types {
            let table = QuoraAnswersListView(frame: labelCollectView.collection.bounds, tableIdentifier: type, shouldAutoRefresh: true)
            table.refreshDelegate = self
            table.interactionDelegate = self
            tables.append(table)
        }
        // 3.向标签滚动视图中添加问答列表视图
        labelCollectView.childViews = tables
    }

}

extension MyAnswersListView: QuoraAnswersListViewRefreshDelegate {
    /// 下拉刷新
    func answerTable(_ table: QuoraAnswersListView, refreshingDataOf tableIdentifier: String) {
        TSMineNetworkManager.getMyAnswers(type: tableIdentifier, after: nil) { [weak self] (datas: [TSAnswerListModel]?, message: String?, _) in
            guard self != nil else {
                return
            }
            table.processRefresh(newDatas: datas, errorMessage: message)
        }
    }

    /// 上拉加载
    func answerTable(_ table: QuoraAnswersListView, loadMoreDataOf tableIdentifier: String) {
        TSMineNetworkManager.getMyAnswers(type: tableIdentifier, after: table.datas.last?.id) { [weak self] (datas: [TSAnswerListModel]?, message: String?, _) in
            guard self != nil else {
                return
            }
            table.processLoadMore(newDatas: datas, errorMessage: message)
        }
    }
}

extension MyAnswersListView: QuoraAnswersListViewDelegate {

    /// 点击了回答 cell
    func answerTable(_ table: QuoraAnswersListView, didSelectRowAt indexPath: IndexPath, with tableIdentifier: String) {
        // 不需要处理围观，直接进入答案详情页
        let answer = table.datas[indexPath.row]
        let answerDetailVC = TSAnswerDetailController(answerId: answer.id)
        self.parentViewController?.navigationController?.pushViewController(answerDetailVC, animated: true)
    }
}
