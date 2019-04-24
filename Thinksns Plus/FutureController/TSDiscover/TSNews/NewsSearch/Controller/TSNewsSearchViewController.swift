//
//  TSNewsSearchViewController.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct TSNewsSearchViewControllerUX {
    /// 搜索框的左间距
    static let searchViewMinX: CGFloat = 55
    /// 搜索框的高度
    static let searchViewHeight: CGFloat = 30
}

class TSNewsSearchViewController: TSViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // MARK: - property
    // MARK: userinterface
    /// 搜索的navigationUI
    fileprivate weak var searchBar: TSSearchBarView!
    fileprivate weak var searchField: UITextField!
    fileprivate weak var cancelBtn: UIButton!
    /// 列表
    let tableView = TSTableView(frame: CGRect.zero, style: .plain)
    // MARK: data
    /// 数据
    var searchResultArray: [NewsModel] = []
    /// 分页标记
    var maxID: Int = 0
    fileprivate let limit: Int = TSAppConfig.share.localInfo.limit
    /// 记录搜索关键字
    var keyWord: String = ""
    /// 缺省图
    private var occupiedView: UIImageView? = nil

    /// 缺省图
    private enum OccupiedType {
        case network
        case empty
    }
    // MARK: - lifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.isNavigationBarHidden = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutBaseControls()
        getRecommendNew()
    }
    // MARK: - UI
    func layoutBaseControls() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.makeSearchView()
        self.makeTableView()

        /// 缺省图
        self.occupiedView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
        self.occupiedView?.contentMode = UIViewContentMode.center
        self.occupiedView?.backgroundColor = .clear
    }

    func makeSearchView() {
        // 1. searchBar
        let searchBar = TSSearchBarView()
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.bottom.equalTo(self.view.snp.top).offset(TSNavigationBarHeight + 1)
        }
        self.searchBar = searchBar
        // 1.x 导航栏搜索框相关配置
        self.searchField = searchBar.searchTextFiled
        self.searchField.returnKeyType = .search
        searchField.delegate = self
        searchField.placeholder = ""
        self.cancelBtn = searchBar.rightButton
        self.cancelBtn.addTarget(self, action: #selector(rightButtonClicked), for: .touchUpInside)
        let line = UIView(frame: CGRect(x: 0, y: TSNavigationBarHeight, width: view.frame.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.highlight
        view.addSubview(line)
    }

    func makeTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.estimatedRowHeight = 95
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer.isHidden = true
        self.view.addSubview(self.tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(searchBar.snp.bottom)
        }
        searchField.becomeFirstResponder()
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
        self.navigationController?.pushViewController(detailVC, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }

    // MARK: - UITextFialdDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            self.keyWord = textField.text!
            self.tableView.mj_header.beginRefreshing()
        }
        textField.resignFirstResponder()
        return true
    }

    // MARK: - refresh
    func refresh() {
        self.maxID = 0
        self.search(keyWord: self.keyWord)
         self.tableView.mj_footer .endRefreshing()
        self.tableView.mj_footer.isHidden = true
    }

    func loadMore() {
        self.search(keyWord: self.keyWord)
    }

    // MARK: - actions
    func search(keyWord key: String) {
        TSNewsNetworkManager.getNewsListData(tagID: 0, maxID: self.maxID, limit: self.limit, isCheckCommend: false, searchKey: key) { [weak self](newsModels, error) in
            guard let WeakSelf = self else {
                return
            }
            if WeakSelf.maxID == 0 {
                self?.tableView.mj_header.endRefreshing()
                self?.searchResultArray.removeAll()
            } else {
                self?.tableView.mj_footer.endRefreshing()
            }
            guard error == nil, let newsList = newsModels else {
                if WeakSelf.maxID == 0 {
                    self?.showOccupiedView( .network)
                } else {
                    self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
                }
                self?.tableView.reloadData()
                return
            }
            WeakSelf.searchResultArray += newsList
            if WeakSelf.searchResultArray.isEmpty {
                self?.tableView.show(placeholderView: .empty)
            } else {
                self?.tableView.removePlaceholderViews()
                self?.maxID = WeakSelf.searchResultArray.last?.id ?? WeakSelf.maxID
                self?.tableView.mj_footer.isHidden = false
            }

            if newsList.count < WeakSelf.limit {
                self?.tableView.mj_footer.isHidden = true
            }
            self?.tableView.reloadData()
        }
    }

    override func rightButtonClicked() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
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
            self.tableView.addSubview(self.occupiedView!)
        }
        if !self.searchResultArray.isEmpty && self.occupiedView?.superview != nil {
            self.occupiedView?.removeFromSuperview()
        }
    }

    /// 获取推荐资讯列表
    func getRecommendNew() {
        TSNewsTaskManager().refreshNewsListData(tagID: -1) { [weak self] (news, _) in
            guard let weakSelf = self else {
                return
            }
            guard let news = news else {
                return
            }
            weakSelf.searchResultArray = news[0] + news[1]
            if weakSelf.searchResultArray.count > 3 {
                for (index, _) in weakSelf.searchResultArray.enumerated().reversed() {
                    if index < 3 {
                        break
                    }
                    weakSelf.searchResultArray.remove(at: index)
                }
            }
            /// 刷新列表数据
            weakSelf.tableView.reloadData()
        }
    }

    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
