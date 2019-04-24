//
//  IntegrationCashRecordTable.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol IntegrationCashRecordRefreshDelegate: class {
    /// 下拉刷新
    func integrationRecordTable(_ view: IntegrationCashRecordTable, didRefreshWithIdentidier identifier: String)
    /// 上拉加载
    func integrationRecordTable(_ view: IntegrationCashRecordTable, didLoadMoreWithIdentidier identifier: String)
}

class IntegrationCashRecordTable: TSTableView {

    var tableIdentifier = ""
    var refreshDelegate: IntegrationCashRecordRefreshDelegate?
    var datas: [IntegrationCashRecordCellModel] = []
    var listLimit = 20

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
        register(UINib(nibName: "IntegrationCashRecordCell", bundle: nil), forCellReuseIdentifier: IntegrationCashRecordCell.identifier)

    }

    override func refresh() {
        refreshDelegate?.integrationRecordTable(self, didRefreshWithIdentidier: tableIdentifier)
    }

    override func loadMore() {
        refreshDelegate?.integrationRecordTable(self, didLoadMoreWithIdentidier: tableIdentifier)
    }

    /// 处理下拉刷新的界面刷新
    func processRefresh(newDatas: [IntegrationCashRecordCellModel]?, errorMessage: String?) {
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
    func processLoadMore(newDatas: [IntegrationCashRecordCellModel]?, errorMessage: String?) {
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

extension IntegrationCashRecordTable: UITableViewDataSource {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: IntegrationCashRecordCell.identifier, for: indexPath) as! IntegrationCashRecordCell
        cell.load(model: datas[indexPath.row])
        return cell
    }
}

extension IntegrationCashRecordTable: UITableViewDelegate {

}
