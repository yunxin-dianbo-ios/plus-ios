//
//  GroupSearchController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子搜索视图控制器

import UIKit

class GroupSearchController: UIViewController {

    /// 搜索框
    let searchBar = TSSearchBarView()
    /// 展示视图
    var displayView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["圈子", "帖子"]
    /// 帖子搜索历史记录
    var postSearchHistoryList: GroupSearchHistoryView!
    /// 帖子搜索结果
    var postsSearchResultsList: PostsSearchView!

    /// 圈子搜索历史记录视图
    var groupSearchHistoryList: GroupSearchHistoryView!
    /// 圈子搜索结果
    var groupSearchResultsList: GroupSearchView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        TSKeyboardToolbar.share.keyboardstartNotice()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        TSKeyboardToolbar.share.keyboarddisappear()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }

    // MARK: - Custom user interface

    func setUI() {
        view.backgroundColor = UIColor.white
        // 1.搜索框
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
        // 2.展示视图
        displayView.shouldShowBlueLine = true
        displayView.frame = CGRect(x: 0, y: TSNavigationBarHeight + 1, width: view.frame.width, height: view.frame.height - (TSNavigationBarHeight + 1))
        view.addSubview(displayView)
        displayView.titles = titles
        // 3.帖子搜索历史记录
        postSearchHistoryList = GroupSearchHistoryView(frame: displayView.collection.bounds, searchType: .postOutGroup)
        postSearchHistoryList.historyDelegate = self
        // 4.帖子搜索结果
        postsSearchResultsList = PostsSearchView(frame: displayView.collection.bounds, tableIdentifier: "search")
        postsSearchResultsList.searchType = .postOutGroup
        // 5.圈子搜索历史记录视图
        groupSearchHistoryList = GroupSearchHistoryView(frame: displayView.collection.bounds, searchType: .group)
        groupSearchHistoryList.historyDelegate = self
        // 6.圈子搜索结果
        groupSearchResultsList = GroupSearchView(frame: displayView.collection.bounds, tableIdentifier: "search")
        // 如果没有圈子搜索历史，就直接显示推荐的圈子
        let groupSearchHistory = Array(TSDatabaseManager().group.getSearObjects(type: .group))
        if groupSearchHistory.count == 0 {
            groupSearchResultsList.isShowRecommendGroups = true
            displayView.addChildViews([groupSearchResultsList, postSearchHistoryList])
            groupSearchResultsList.mj_header.beginRefreshing()
        } else {
            // 7.将问题和话题的历史记录视图添加在展示视图上
            displayView.addChildViews([groupSearchHistoryList, postSearchHistoryList])
        }
    }

    // MARK: - Button click
    func cancelButtonTaped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GroupSearchController: UITextFieldDelegate {

    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = searchBar.searchTextFiled.text, keyword != "" else {
            return false
        }
        view.endEditing(true)
        // 1.获取正在显示的视图坐标
        let index = displayView.selected
        // 2.如果是圈子搜索
        if index == 0 {
            // 将圈子搜索结果列表放置在展示视图上，同时把历史记录列表移除
            groupSearchResultsList.isShowRecommendGroups = false
            if groupSearchResultsList.superview == nil {
                displayView.add(childView: groupSearchResultsList, at: 0)
            }
            // 将搜索关键字传递给问题搜索列表
            groupSearchResultsList.keyword = keyword
        }
        // 3.如果是帖子搜索
        if index == 1 {
            // 将话题搜索结果列表放置在展示视图上，同时把历史记录列表移除
            if postsSearchResultsList.superview == nil {
                displayView.add(childView: postsSearchResultsList, at: 1)
            }
            // 将搜索关键字传递给问题搜索列表
            postsSearchResultsList.keyword = keyword
        }
        return true
    }
}

extension GroupSearchController: GroupSearchHistoryListViewDelegate {
    /// 点击了历史记录列表的 cell 上的内容
    func historyListView(_ view: GroupSearchHistoryView, didSelectedCellWith historyContent: String) {
        // 1.将 cell 上的历史记录内容添加到搜索框上
        searchBar.searchTextFiled.text = historyContent
        // 2.发起搜索操作
        textFieldShouldReturn(searchBar.searchTextFiled)
    }
}
