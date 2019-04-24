//
//  TSQuoraSearchVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答搜索页面

import UIKit

class TSQuoraSearchVC: UIViewController {

    /// 搜索框
    let searchBar = TSSearchBarView()
    /// 展示视图
    var displayView = TSLabelCollectionView()
    /// 标题数组
    let titles = ["问答", "专题"]

    /// 问题搜索历史记录
    var questionsSearchHistoryList: QuoraSearchHistoryListView!
    /// 问题搜索结果
    var questionsSearchResultsList: QuoraQuestionsSearchView!

    /// 话题搜索历史记录视图
    var topicsSearchHistoryList: QuoraSearchHistoryListView!
    /// 话题搜索结果
    var topicSearchResultsList: QuoraTopicSearchView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
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
        // 展示视图
        displayView.shouldShowBlueLine = true
        displayView.frame = CGRect(x: 0, y: TSNavigationBarHeight + 1, width: view.frame.width, height: view.frame.height - (TSNavigationBarHeight + 1))
        view.addSubview(displayView)
        displayView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(1)
        }
        displayView.titles = titles
        // 问题搜索历史记录
        questionsSearchHistoryList = QuoraSearchHistoryListView(frame: displayView.collection.bounds, searchType: .question)
        questionsSearchHistoryList.historyDelegate = self
        // 问题搜索结果
        questionsSearchResultsList = QuoraQuestionsSearchView(frame: displayView.collection.bounds)
        // 话题搜索历史记录视图
        topicsSearchHistoryList = QuoraSearchHistoryListView(frame: displayView.collection.bounds, searchType: .topic)
        topicsSearchHistoryList.historyDelegate = self
        // 话题搜索结果
        topicSearchResultsList = QuoraTopicSearchView(frame: displayView.collection.bounds)

        // 将问题和话题的历史记录视图添加在展示视图上
        displayView.addChildViews([questionsSearchHistoryList, topicsSearchHistoryList])
    }

    // MARK: - Button click
    func cancelButtonTaped() {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension TSQuoraSearchVC: UITextFieldDelegate {

    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = searchBar.searchTextFiled.text, keyword != "" else {
            return false
        }
        view.endEditing(true)
        // 1.获取正在显示的视图坐标
        let index = displayView.selected
        // 2.如果是问题搜索
        if index == 0 {
            // 将问题搜索结果列表放置在展示视图上，同时把历史记录列表移除
            if questionsSearchResultsList.superview == nil {
                displayView.add(childView: questionsSearchResultsList, at: 0)
            }
            // 将搜索关键字传递给问题搜索列表
            questionsSearchResultsList.keyword = keyword
        }
        // 3.如果是话题搜索
        if index == 1 {
            // 将话题搜索结果列表放置在展示视图上，同时把历史记录列表移除
            if topicSearchResultsList.superview == nil {
                displayView.add(childView: topicSearchResultsList, at: 1)
            }
            // 将搜索关键字传递给话题搜索列表
            topicSearchResultsList.keyword = keyword
        }
        return true
    }
}

extension TSQuoraSearchVC: QuoraSearchHistoryListViewDelegate {
    /// 点击了历史记录列表的 cell 上的内容
    func historyListView(_ view: QuoraSearchHistoryListView, didSelectedCellWith historyContent: String) {
        // 1.将 cell 上的历史记录内容添加到搜索框上
        searchBar.searchTextFiled.text = historyContent
        // 2.发起搜索操作
        textFieldShouldReturn(searchBar.searchTextFiled)
    }
}
