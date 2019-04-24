//
//  TSAggregateSearchVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSAggregateSearchVC: UIViewController {
    /// 搜索框
    let searchBar = TSSearchBarView()
    /// 展示视图
    var displayView = TSAgregateSearchCollectionsView()
    /// 标题数组
    let titles = ["动态", "文章", "用户", "圈子", "帖子", "问题", "专题", "话题"]
    /// 问题搜索历史记录
    var questionsSearchHistoryList: QuoraSearchHistoryListView!
    /// 问题搜索结果
    var questionsSearchResultsList: QuoraQuestionsSearchView!
    /// 专题搜索结果
    var topicSearchResultsList: QuoraTopicSearchView!
    /// 资讯搜索结果
    var newsSearchResultsList: TSNewsSearchView!
    /// 话题搜索结果
    var topicsSearchResultsList: TSTopicSearchView!
    /// 用户搜索结果
    var userSearchResultsList: TSUserSearchView!
    /// 帖子搜索结果
    var postsSearchResultsList: PostsSearchView!
    /// 圈子搜索结果
    var groupSearchResultsList: GroupSearchView!
    /// 热门列表
    let momentSearchResultsList = TSMomentSearchView(frame: CGRect(x: 0, y: TSNavigationBarHeight + 1, width: ScreenWidth, height: ScreenHeight - (TSNavigationBarHeight + 1)), tableIdentifier: "new")

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Custom user interface
    func setUI() {
        view.backgroundColor = UIColor.white
        // 搜索框
        searchBar.searchTextFiled.returnKeyType = .search
        searchBar.searchTextFiled.delegate = self
        searchBar.rightButton.addTarget(self, action: #selector(cancelButtonTaped), for: .touchUpInside)
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.bottom.equalTo(self.view.snp.top).offset(TSNavigationBarHeight)
        }
        let line = UIView(frame: CGRect(x: 0, y: TSNavigationBarHeight, width: view.frame.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.highlight
        view.addSubview(line)
        displayView.frame = CGRect(x: 0, y: TSNavigationBarHeight + 1, width: view.frame.width, height: view.frame.height - (TSNavigationBarHeight + 1))
        view.addSubview(displayView)
        displayView.delegate = self
        displayView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(1)
        }
        displayView.titles = titles
        // 问题搜索历史记录
        questionsSearchHistoryList = QuoraSearchHistoryListView(frame: CGRect(x: 0, y: TSNavigationBarHeight + 1, width: view.frame.width, height: view.frame.height - (TSNavigationBarHeight + 1)), searchType: .homeSearch)
        questionsSearchHistoryList.historyDelegate = self
        view.addSubview(questionsSearchHistoryList)
        // 问题搜索结果
        questionsSearchResultsList = QuoraQuestionsSearchView(frame: displayView.collection.bounds)
        questionsSearchResultsList.isHomeSearch = true
        // 专题搜索结果
        topicSearchResultsList = QuoraTopicSearchView(frame: displayView.collection.bounds)
        topicSearchResultsList.isHomeSearch = true
        // 资讯搜索结果
        newsSearchResultsList = TSNewsSearchView(frame: displayView.collection.bounds)
        // 话题搜索结果
        topicsSearchResultsList = TSTopicSearchView(frame: displayView.collection.bounds)
        // 用户搜索结果
        userSearchResultsList = TSUserSearchView(frame: displayView.collection.bounds)
        // 帖子搜索结果
        postsSearchResultsList = PostsSearchView(frame: displayView.collection.bounds, tableIdentifier: "search")
        postsSearchResultsList.isHomeSearch = true
        postsSearchResultsList.searchType = .postOutGroup
        // 圈子搜索结果
        groupSearchResultsList = GroupSearchView(frame: displayView.collection.bounds, tableIdentifier: "search")
        groupSearchResultsList.isHomeSearch = true
        // 动态搜索结果
        momentSearchResultsList.frame = displayView.collection.bounds
        displayView.addChildViews([momentSearchResultsList, newsSearchResultsList, userSearchResultsList, groupSearchResultsList, postsSearchResultsList, questionsSearchResultsList, topicSearchResultsList, topicsSearchResultsList])
    }
    // MARK: - Button click
    func cancelButtonTaped() {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension TSAggregateSearchVC: UITextFieldDelegate {
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = searchBar.searchTextFiled.text, keyword != "" else {
            return false
        }
        questionsSearchHistoryList.isHidden = true
        view.endEditing(true)
        // 1.获取正在显示的视图坐标
        let index = displayView.selected
        if index == 0 {
            // 将搜索关键字传递给问题搜索列表
            momentSearchResultsList.keyword = keyword
        }
        if index == 1 {
            // 将搜索关键字传递给问题搜索列表
            newsSearchResultsList.keyword = keyword
        }
        if index == 2 {
            // 将搜索关键字传递给问题搜索列表
            userSearchResultsList.keyword = keyword
        }
        if index == 3 {
            // 将搜索关键字传递给问题搜索列表
            groupSearchResultsList.keyword = keyword
        }
        if index == 4 {
            // 将搜索关键字传递给问题搜索列表
            postsSearchResultsList.keyword = keyword
        }
        if index == 5 {
            // 将搜索关键字传递给问题搜索列表
            questionsSearchResultsList.keyword = keyword
        }
        // 3.如果是专题搜索
        if index == 6 {
            // 将搜索关键字传递给话题搜索列表
            topicSearchResultsList.keyword = keyword
        }
        if index == 7 {
            // 将搜索关键字传递给问题搜索列表
            topicsSearchResultsList.keyword = keyword
        }
        return true
    }
}

extension TSAggregateSearchVC: QuoraSearchHistoryListViewDelegate {
    /// 点击了历史记录列表的 cell 上的内容
    func historyListView(_ view: QuoraSearchHistoryListView, didSelectedCellWith historyContent: String) {
        // 1.将 cell 上的历史记录内容添加到搜索框上
        searchBar.searchTextFiled.text = historyContent
        // 2.发起搜索操作
        textFieldShouldReturn(searchBar.searchTextFiled)
    }
}

extension TSAggregateSearchVC: TSAgregateSearchCollectionsViewDelegate {
    @objc func view(_ view: TSAgregateSearchCollectionsView, didSelected labelButton: UIButton, at index: Int) {
        searchBar.searchTextFiled.resignFirstResponder()
        guard let keyword = searchBar.searchTextFiled.text, keyword != "" else {
            return
        }
        questionsSearchHistoryList.isHidden = true
        view.endEditing(true)
        if index == 0 {
            // 将搜索关键字传递给问题搜索列表
            momentSearchResultsList.keyword = keyword
        }
        if index == 1 {
            // 将搜索关键字传递给问题搜索列表
            newsSearchResultsList.keyword = keyword
        }
        if index == 2 {
            // 将搜索关键字传递给问题搜索列表
            userSearchResultsList.keyword = keyword
        }
        if index == 3 {
            // 将搜索关键字传递给问题搜索列表
            groupSearchResultsList.keyword = keyword
        }
        if index == 4 {
            // 将搜索关键字传递给问题搜索列表
            postsSearchResultsList.keyword = keyword
        }
        if index == 5 {
            // 将搜索关键字传递给问题搜索列表
            questionsSearchResultsList.keyword = keyword
        }
        // 3.如果是专题搜索
        if index == 6 {
            // 将搜索关键字传递给话题搜索列表
            topicSearchResultsList.keyword = keyword
        }
        if index == 7 {
            // 将搜索关键字传递给问题搜索列表
            topicsSearchResultsList.keyword = keyword
        }
    }
}



