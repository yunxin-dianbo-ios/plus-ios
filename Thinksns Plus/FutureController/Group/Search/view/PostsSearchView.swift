//
//  PostsSearchView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  帖子搜索视图

import UIKit

class PostsSearchView: PostListActionView {
    var isHomeSearch = false
    /// 是否显示圈子的来源
    var isHshowCircleTag: Bool = true
    var searchType: GroupSearchHistoryObject.SearchType = .postInGroup
    /// 搜索关键词（由外部给 PostsSearchView 赋值）
    var keyword = "" {
        didSet {
            mj_header.beginRefreshing()
            if isHomeSearch {
                TSDatabaseManager().quora.deleteByContent(content: keyword)
                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
            } else {
                // 将关键字保存在数据库中
                TSDatabaseManager().group.saveSearchObject(content: keyword, type: searchType, groupID: self.groupId)
            }
        }
    }

    /// 占位图
    var placeholderView: ButtonPlaceholderView!
    // 是否是圈外搜索
    var isCircleOutSearch = true
    // MARK: - 生命周期
     init(frame: CGRect, tableIdentifier identifier: String, isHshowCircle: Bool = true, isCircleOutSearch: Bool = true) {
       super.init(frame: frame, tableIdentifier: identifier)
       self.isHshowCircleTag = isHshowCircle
       self.isCircleOutSearch = isCircleOutSearch
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI
    override func setUI() {
        super.setUI()
        // 1.占位图
        placeholderView = ButtonPlaceholderView(frame: bounds, buttonAction: { [weak self] in
            // 跳转到问题发布页
            // 1.1 如果没有 groupId，就是圈外搜索
            guard (self?.isCircleOutSearch)! else {
                // 1.2 如果有 groupId，就是圈内搜索
                NotificationCenter.default.post(name: NSNotification.Name.Post.SearchReleasePost, object: nil, userInfo: ["groupId": self?.groupId ?? 0])
                return
            }
            /// 则去圈外发帖
            let publishVC = PostPublishController(groupId: nil, groupName: nil)
            self?.parentViewController?.navigationController?.pushViewController(publishVC, animated: true)
            return
        })
        placeholderView.set(buttonTitle: "去发帖", labelText: "未找到相关帖子~")
        set(placeholderView: placeholderView, for: .empty)

        // 2.单页限制
        listLimit = TSAppConfig.share.localInfo.limit
    }

    // MARK: Data
    override func refresh() {
        if keyword .isEmpty {
            if mj_header != nil {
                if mj_header.isRefreshing() {
                    mj_header.endRefreshing()
                }
            }
            return
        }
        GroupNetworkManager.searchPost(keyword: keyword, groupId: self.isCircleOutSearch ? nil : groupId, offset: 0, limit: TSAppConfig.share.localInfo.limit) { [weak self] (models, message, status) in
            var datas: [FeedListCellModel]?
            if let models = models {
                // 需要显示来自圈子的名称，所以使用了该方法
                if (self?.isHshowCircleTag)! {
                    //要显示工具栏
                   datas = models.map { FeedListCellModel(postCollection: $0) }
                    // datas = models.map { FeedListCellModel(postModel: $0) }
                } else {
                    datas = models.map { FeedListCellModel(postModel: $0) }
                }

            }
       self?.processRefresh(data: datas, message: message, status: status)
        }
    }

    override func loadMore() {
        GroupNetworkManager.searchPost(keyword: keyword, groupId: self.isCircleOutSearch ? nil : groupId, offset: datas.count, limit: TSAppConfig.share.localInfo.limit) { [weak self] (models, message, status) in
            var datas: [FeedListCellModel]?
            if let models = models {
                // 需要显示来自圈子的名称，所以使用了该方法
                datas = models.map { FeedListCellModel(postCollection: $0) }
            }
            self?.processloadMore(data: datas, message: message, status: status)
        }
    }

}
