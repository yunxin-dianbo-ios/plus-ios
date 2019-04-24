//
//  QuoraQuestionsSearchView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问题搜索页

import UIKit

class QuoraQuestionsSearchView: TSTableView {

    var isHomeSearch = false
    /// 搜索关键词（由外部给 QuoraQuestionsSearchView 赋值）
    var keyword = "" {
        didSet {
            mj_header.beginRefreshing()
            if isHomeSearch {
                TSDatabaseManager().quora.deleteByContent(content: keyword)
                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .homeSearch)
            } else {
                // 将关键字保存在数据库中
                TSDatabaseManager().quora.saveSearchObject(content: keyword, type: .question)
            }
        }
    }

    /// 搜索结果
    var datas: [TSQuoraDetailModel] = []

    /// 占位图
    var placeholderView: ButtonPlaceholderView!

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
        estimatedRowHeight = 44
        self.separatorStyle = .none
        register(UINib(nibName: "QuestionsSearchResultCell", bundle: nil), forCellReuseIdentifier: QuestionsSearchResultCell.identifier)
        // 占位图
        placeholderView = ButtonPlaceholderView(frame: bounds, buttonAction: {
            // 跳转到问题发布页
            let questionPublishVC = TSQuestionTitleEditController()
            questionPublishVC.type = .searchPublish
            questionPublishVC.searchKeyword = self.keyword
            self.parentViewController?.navigationController?.pushViewController(questionPublishVC, animated: true)
        })
        placeholderView.set(buttonTitle: "去提问", labelText: "未找到相关问题，去提问？")
        set(placeholderView: placeholderView, for: .empty)
    }

    // MARK: Data
    override func refresh() {
        TSQuoraNetworkManager.getAllQuoras(subject: keyword, offset: 0, type: "all") { [weak self] (datas: [TSQuoraDetailModel]?, message: String?, status: Bool) in
            self?.processRefresh(data: datas, message: message, status: status)
        }
    }

    override func loadMore() {
        TSQuoraNetworkManager.getAllQuoras(subject: keyword, offset: datas.count, type: "all") { [weak self] (datas: [TSQuoraDetailModel]?, message: String?, status: Bool) in
            self?.processloadMore(data: datas, message: message, status: status)
        }
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processRefresh(data: [TSQuoraDetailModel]?, message: String?, status: Bool) {
        // 隐藏指示器
        dismissIndicatorA()
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        mj_footer.resetNoMoreData()
        // 获取数据失败，显示占位图或者 A 指示器
        if let message = message {
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 获取数据成功，更新数据
        guard let newDatas = data else {
            return
        }
        datas = newDatas
        // 如果数据为空，显示占位图
        if datas.isEmpty {
            show(placeholderView: .empty)
        }
        // 刷新界面
        reloadData()
    }

    /// 处理下拉刷新的数据，并更新界面 UI
    func processloadMore(data: [TSQuoraDetailModel]?, message: String?, status: Bool) {
        // 获取数据失败，显示"网络失败"的 footer
        if message != nil {
            mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        // 隐藏 A 指示器
        dismissIndicatorA()
        // 请求成功
        // 更新 dataSource，并刷新界面
        guard let newDatas = data else {
            mj_footer.endRefreshing()
            return
        }
        datas = datas + newDatas
        reloadData()
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if data!.count < TSAppConfig.share.localInfo.limit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
    }
}

extension QuoraQuestionsSearchView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        if mj_footer != nil {
            mj_footer.isHidden = datas.count < TSAppConfig.share.localInfo.limit
        }
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: QuestionsSearchResultCell.identifier, for: indexPath) as! QuestionsSearchResultCell
        cell.labelForTitle.text = datas[indexPath.row].title
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.parentViewController?.view.endEditing(true)
        // 跳转到问题详情页
        let model = datas[indexPath.row]
        let quoraDetailVC = TSQuoraDetailController()
        quoraDetailVC.questionId = model.id
        parentViewController?.navigationController?.pushViewController(quoraDetailVC, animated: true)
    }

}
