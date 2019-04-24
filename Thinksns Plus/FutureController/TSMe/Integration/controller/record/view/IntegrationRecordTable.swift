//
//  IntegrationRecordTable.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/19.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol IntegrationRecordTableRefreshDelegate: class {
    /// 下拉刷新
    func integrationRecordTable(_ view: IntegrationRecordTable, didRefreshWithIdentidier identifier: String)
    /// 上拉加载
    func integrationRecordTable(_ view: IntegrationRecordTable, didLoadMoreWithIdentidier identifier: String)
}

class IntegrationRecordTable: TSTableView {

    var refreshDelegate: IntegrationRecordTableRefreshDelegate?

    var tableIdentifier = ""
    var datas: [IntegrationRecordCellModel] = []
    var listLimit = TSAppConfig.share.localInfo.limit

    init(frame: CGRect, tableIdentifier: String) {
        super.init(frame: frame, style: .plain)
        self.tableIdentifier = tableIdentifier
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSuperUI() {
        super.setSuperUI()
        setUI()
    }

    func setUI() {
        delegate = self
        dataSource = self
        backgroundColor = UIColor(hex: 0xf4f5f5)

        register(UINib(nibName: "IntegrationRecordCell", bundle: nil), forCellReuseIdentifier: IntegrationRecordCell.identifier)
        tableFooterView = UIView()
        estimatedRowHeight = 250
    }

    override func loadMore() {
        refreshDelegate?.integrationRecordTable(self, didLoadMoreWithIdentidier: tableIdentifier)
    }

    override func refresh() {
        refreshDelegate?.integrationRecordTable(self, didRefreshWithIdentidier: tableIdentifier)
    }

    /// 处理下拉刷新的界面刷新
    func processRefresh(newDatas: [IntegrationRecordCellModel]?, errorMessage: String?) {
        // 隐藏指示器
        dismissIndicatorA()
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        mj_footer.resetNoMoreData()
        // 获取数据失败，显示占位图或者 A 指示器
        if let message = errorMessage {
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 获取数据成功，更新数据
        guard let newDatas = newDatas else {
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

    /// 处理上拉加载的数据的界面刷新
    func processLoadMore(newDatas: [IntegrationRecordCellModel]?, errorMessage: String?) {
        // 获取数据失败，显示"网络失败"的 footer
        if errorMessage != nil {
            mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        // 隐藏 A 指示器
        dismissIndicatorA()
        // 请求成功
        // 更新 datas，并刷新界面
        guard let newDatas = newDatas else {
            mj_footer.endRefreshing()
            return
        }
        datas = datas + newDatas
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if newDatas.count < listLimit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
        reloadData()
    }

}

extension IntegrationRecordTable: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        if mj_footer != nil {
            mj_footer.isHidden = datas.count < listLimit
        }
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IntegrationRecordCell.identifier) as! IntegrationRecordCell
        cell.selectionStyle = .none
        cell.load(model: datas[indexPath.row])
        return cell
    }

}

extension IntegrationRecordTable: UITableViewDelegate {
}
