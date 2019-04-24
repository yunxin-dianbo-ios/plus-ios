//
//  InGroupSearchVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈内搜索

import UIKit

class InGroupSearchVC: UIViewController, GroupSearchHistoryListViewDelegate {
    /// 搜索框
    let searchBar = TSSearchBarView()
    /// 帖子搜索结果
    var postsSearchResultsList = PostsSearchView(frame: CGRect(x: 0, y: TSNavigationBarHeight + 1, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (TSNavigationBarHeight + 1)), tableIdentifier: "search", isHshowCircle: false, isCircleOutSearch: false)
    /// 帖子搜索历史记录
    var postSearchHistoryList: GroupSearchHistoryView!
    /// 圈子 Id
    var groupId = 0

    init(groupId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.groupId = groupId
        setUI()
        postsSearchResultsList.groupId = groupId
        postsSearchResultsList.searchType = .postInGroup
        self.postsSearchResultsList.fromGroupFlag = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    func setUI() {
        view.backgroundColor = UIColor.white

        // 1.搜索框
        searchBar.searchTextFiled.returnKeyType = .search
        searchBar.searchTextFiled.delegate = self
        searchBar.rightButton.addTarget(self, action: #selector(cancelButtonTaped), for: .touchUpInside)
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.bottom.equalTo(self.view.snp.top).offset(TSNavigationBarHeight)
        }
        let line = UIView(frame: CGRect(x: 0, y: TSNavigationBarHeight, width: view.frame.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.highlight
        view.addSubview(line)
        // 2.搜索结果视图
//        postsSearchResultsList.groupId = groupId
//        view.addSubview(postsSearchResultsList)
        // 如果没有圈子搜索历史，就直接显示推荐的圈子
        let groupSearchHistory = Array(TSDatabaseManager().group.getSearObjects(type: .postInGroup, groupID: self.groupId))
        // 3.帖子搜索历史记录
        postSearchHistoryList = GroupSearchHistoryView(frame: CGRect(x: 0, y: TSNavigationBarHeight + 1, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (TSNavigationBarHeight + 1)), searchType: .postInGroup, groupID: groupId)
        postSearchHistoryList.historyDelegate = self
        if groupSearchHistory.count == 0 {
            postsSearchResultsList.groupId = groupId
            view.addSubview(postsSearchResultsList)
        } else {
            // 7.将问题和话题的历史记录视图添加在展示视图上
            view.addSubview(postSearchHistoryList)
        }
    }

    func cancelButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
    func historyListView(_ view: GroupSearchHistoryView, didSelectedCellWith historyContent: String) {
        // 1.将 cell 上的历史记录内容添加到搜索框上
        searchBar.searchTextFiled.text = historyContent
        // 2.发起搜索操作
        textFieldShouldReturn(searchBar.searchTextFiled)
    }
}

extension InGroupSearchVC: UITextFieldDelegate {

    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = searchBar.searchTextFiled.text, keyword != "" else {
            return false
        }
        view.endEditing(true)
        // 将搜索结果列表放置在展示视图上，同时把历史记录列表移除
        if postsSearchResultsList.superview == nil {
            view.addSubview(postsSearchResultsList)
        }
        // 将搜索关键字传递给问题搜索列表
        postsSearchResultsList.keyword = keyword
        return true
    }
}
