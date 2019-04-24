//
//  TSTopicSearchView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Alamofire

class TSTopicSearchView: TSTableView, UITableViewDelegate, UITableViewDataSource {
    /// 上一个联想请求
    private var lastRequest: DataRequest?
    /// 数据源
    var topicSource: [TopicListModel] = []
    /// 搜索关键词（由外部给 QuoraQuestionsSearchView 赋值）
    var keyword = "" {
        didSet {
            mj_header.beginRefreshing()
            TSDatabaseManager().quora.deleteByContent(content: keyword)
            TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
        }
    }
    /// 占位图
    var occupiedView: UIImageView? = nil
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: UI
    func setUI() {
        delegate = self
        dataSource = self
        rowHeight = 50
        self.separatorStyle = .none
        register(UINib(nibName: "TopicSearchCell", bundle: nil), forCellReuseIdentifier: TopicSearchCell.identifier)
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        switch type {
        case .empty:
            self.show(placeholderView: .empty)
        case .network:
            self.show(placeholderView: .network)
        }
    }

    // MARK: - refresh
    override func refresh() {
        lastRequest = TSUserNetworkingManager().getTopicListThink(index: nil, keyWordString: keyword, limit: 20, direction: nil, only: nil) { (topicModel, networkError) in
            self.processRefresh(datas: topicModel, message: networkError)
        }
    }

    override func loadMore() {
        guard keyword != "", topicSource.count != 0 else {
            // 1.不输入搜索内容，显示的是后台推荐用户，后台推荐用户没有分页
            mj_footer.endRefreshingWithNoMoreData()
            return
        }

        TSUserNetworkingManager().getTopicList(index: topicSource.last?.topicId, keyWordString: keyword, limit: 20, direction: nil, only: nil) { (topicModel, networkError) in
            guard let datas = topicModel else {
                self.mj_footer.endRefreshing()
                return
            }
            if datas.count < 20 {
                self.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.mj_footer.endRefreshing()
            }
            self.topicSource = self.topicSource + datas
            self.reloadData()
        }
    }

    func processRefresh(datas: [TopicListModel]?, message: NetworkError?) {
        mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            topicSource = datas
            if topicSource.isEmpty {
                showOccupiedView(type: .empty)
            }
        }
        // 获取数据失败
        if message != nil {
            topicSource = []
            showOccupiedView(type: .network)
        }
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        reloadData()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mj_footer.isHidden = topicSource.count < 20
        if !topicSource.isEmpty {
            self.removePlaceholderViews()
        }
        return topicSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopicSearchCell.identifier, for: indexPath) as! TopicSearchCell
        cell.setInfo(model: topicSource[indexPath.row], keyword: keyword)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postListVC = TopicPostListVC(groupId: topicSource[indexPath.row].topicId)
        self.parentViewController?.navigationController?.pushViewController(postListVC, animated: true)
    }

}
