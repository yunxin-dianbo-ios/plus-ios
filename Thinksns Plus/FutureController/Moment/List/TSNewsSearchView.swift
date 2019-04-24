//
//  TSNewsSearchView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSNewsSearchView: TSTableView, UITableViewDelegate, UITableViewDataSource {

    // MARK: data
    /// 数据
    var searchResultArray: [NewsModel] = []
    /// 分页标记
    var maxID: Int = 0
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    /// 搜索关键词（由外部给 QuoraQuestionsSearchView 赋值）
    var keyword = "" {
        didSet {
            mj_header.beginRefreshing()
            // 将关键字保存在数据库中
            TSDatabaseManager().quora.deleteByContent(content: keyword)
            TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
        }
    }
    /// 缺省图
    private var occupiedView: UIImageView? = nil
    /// 缺省图
    private enum OccupiedType {
        case network
        case empty
    }
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
        estimatedRowHeight = 95
        self.separatorStyle = .none
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TSNewsListCell
        if cell == nil {
            cell = TSNewsListCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        let model = searchResultArray[indexPath.row]
        cell!.cellData = model
        let isRead = TSCurrentUserInfo.share.newsViewStatus.isContains(newsId: model.id)
        cell!.updateCellStyle(isSelected: isRead)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newsObject = self.searchResultArray[indexPath.row]
        let detailVC = TSNewsDetailViewController(newsId: newsObject.id)
        TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsObject.id)
        self.parentViewController?.navigationController?.pushViewController(detailVC, animated: true)
        reloadRows(at: [indexPath], with: .none)
    }

    // MARK: - refresh
    override func refresh() {
        self.maxID = 0
        self.search(keyWord: keyword)
        mj_footer.endRefreshing()
        mj_footer.isHidden = true
    }

    override func loadMore() {
        self.search(keyWord: keyword)
    }

    // MARK: - actions
    func search(keyWord key: String) {
        TSNewsNetworkManager.getNewsListData(tagID: 0, maxID: self.maxID, limit: self.limit, isCheckCommend: false, searchKey: key) { [weak self](newsModels, error) in
            guard let WeakSelf = self else {
                return
            }
            if WeakSelf.maxID == 0 {
                self?.mj_header.endRefreshing()
                self?.searchResultArray.removeAll()
            } else {
                self?.mj_footer.endRefreshing()
            }
            guard error == nil, let newsList = newsModels else {
                if WeakSelf.maxID == 0 {
                    self?.showOccupiedView( .network)
                } else {
                    self?.mj_footer.endRefreshingWithWeakNetwork()
                }
                self?.reloadData()
                return
            }
            WeakSelf.searchResultArray += newsList
            if WeakSelf.searchResultArray.isEmpty {
                self?.show(placeholderView: .empty)
            } else {
                self?.removePlaceholderViews()
                self?.maxID = WeakSelf.searchResultArray.last?.id ?? WeakSelf.maxID
                self?.mj_footer.isHidden = false
            }
            if newsList.count < WeakSelf.limit {
                self?.mj_footer.isHidden = true
            }
            self?.reloadData()
        }
    }
    /// 显示缺省图
    ///
    /// - Parameter type: 缺省图显示类型
    private func showOccupiedView(_ type: OccupiedType) {
        switch type {
        case .network:
            self.occupiedView?.image = UIImage(named: "IMG_img_default_internet")
        case .empty:
            self.occupiedView?.image = UIImage(named: "IMG_img_default_nothing")
        }
        if self.occupiedView?.superview == nil {
            self.addSubview(self.occupiedView!)
        }
        if !self.searchResultArray.isEmpty && self.occupiedView?.superview != nil {
            self.occupiedView?.removeFromSuperview()
        }
    }

}
