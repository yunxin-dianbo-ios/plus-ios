//
//  MyNewsController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的投稿

import UIKit

class MyNewsController: UIViewController {

    /// 标签滚动视图
    var labelScollow: TSLabelCollectionView!
    /// 已发布列表
    var publishedList: NewsListView!
    /// 投稿中列表
    var waitApprovalList: NewsListView!
    /// 被驳回列表
    var faildPublishList: NewsListView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        /// 添加投稿中的资讯修改成功的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(updatedContributingNewsNotificationProcess(_:)), name: NSNotification.Name.ContributingNewsUpdated, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI

    func setUI() {
        title = "我的投稿"
        // 标签滚动视图
        labelScollow = TSLabelCollectionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)))
        labelScollow.titles = ["已发布", "投稿中", "被驳回"]
        labelScollow.shouldShowBlueLine = true
        //  已发布列表
        publishedList = NewsListView(identifier: "已发布", frame: labelScollow.collection.bounds, cellType: .publish)
        publishedList.refreshDelegate = self
        publishedList.interActDelegate = self
        //  投稿中列表
        waitApprovalList = NewsListView(identifier: "投稿中", frame: labelScollow.collection.bounds, cellType: .unPublish)
        waitApprovalList.refreshDelegate = self
        waitApprovalList.interActDelegate = self
        //  被驳回列表
        faildPublishList = NewsListView(identifier: "被驳回", frame: labelScollow.collection.bounds, cellType: .unPublish)
        faildPublishList.refreshDelegate = self
        faildPublishList.interActDelegate = self

        labelScollow.addChildViews([publishedList, waitApprovalList, faildPublishList])
        view.addSubview(labelScollow)
    }

}

// MARK: - NewsListViewRefreshDelegate: 资讯刷新代理
extension MyNewsController: NewsListViewRefreshDelegate {

    /// 下拉刷新
    func table(view: NewsListView, refreshWith identifier: String) {
        let typeId = getTypeIdWith(tableViewIdentifier: identifier)
        TSMineNetworkManager.getMyNews(type: typeId, after: nil) { [weak self] (datas: [NewsDetailModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            view.processRefresh(data: datas, message: message, status: status)
        }
    }

    /// 上拉加载
    func table(view: NewsListView, loadMoreWith identifier: String) {
        let typeId = getTypeIdWith(tableViewIdentifier: identifier)
        TSMineNetworkManager.getMyNews(type: typeId, after: view.datas.last?.id) { [weak self] (data: [NewsDetailModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            view.processloadMore(data: data, message: message, status: status)
        }
    }

    /// 通过列表 id 获取网络请求的 type id
    func getTypeIdWith(tableViewIdentifier: String) -> Int {
        var type: Int!
        switch tableViewIdentifier {
        case "已发布":
            type = 0
        case "投稿中":
            type = 1
        case "被驳回":
            type = 3
        default:
            break
        }
        return type
    }
}

// MARK: - NewsListViewInteractDelegate: 资讯列表交互代理
extension MyNewsController: NewsListViewInteractDelegate {

    /// cell 点击事件
    func table(view: NewsListView, didSelectedCellAt indexPath: IndexPath, with identifier: String) {
        if identifier == "已发布" {
            // 跳转到资讯详情页
            let newsObject = view.datas[indexPath.row]
            let newsDetailVC = TSNewsDetailViewController(newsId: newsObject.id)
            TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsObject.id)
            navigationController?.pushViewController(newsDetailVC, animated: true)
        } else if identifier == "投稿中" {
            // 跳转到投稿中的资讯详情页
            let newsObject = view.datas[indexPath.row]
            let newsDetailVC = TSContributingNewsDetailVC(newsId: newsObject.id)
            TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsObject.id)
            self.navigationController?.pushViewController(newsDetailVC, animated: true)
        } else if identifier == "被驳回" {
            // 如果是被驳回的投稿，可以重新编辑，但超过3次被驳回就不可再编辑
            // 1.判断是否超过 3 次驳回
            let newsObject = view.datas[indexPath.row]
            if newsObject.verifyCount > 3 {
                return
            }
            // 2.少于 3 次可跳转咨询编辑页
            let editVC = TSNewsWebEditorController(updateModel: newsObject)
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
}

// MARK: - Notification

extension MyNewsController {

    /// 修改投稿中的资讯通知处理
    @objc fileprivate func updatedContributingNewsNotificationProcess(_ notification: Notification) -> Void {
        guard let newsId: Int = notification.object as? Int else {
            return
        }
        // 判断当前的被驳回列表中是否有该资讯
        for (index, rejectNews) in self.faildPublishList.datas.enumerated() {
            if newsId == rejectNews.id {
                self.faildPublishList.datas.remove(at: index)
                break
            }
        }
        self.faildPublishList.reloadData()
    }

}
