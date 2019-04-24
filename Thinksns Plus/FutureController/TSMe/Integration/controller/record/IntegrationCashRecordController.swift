//
//  IntegrationCashRecordController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  提现明细

import UIKit

class IntegrationCashRecordController: TSLabelViewController {

    // 充值记录
    let rechargeTable = IntegrationRecordTable(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64) ), tableIdentifier: "recharge")
    // 提取记录
    let cashTable = IntegrationRecordTable(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64) ), tableIdentifier: "cash")

    var selectedIndex: Int

    init(selectedIndex index: Int) {
        let height = UIScreen.main.bounds.height - 64
        selectedIndex = index
        super.init(labelTitleArray: ["充值记录"], scrollViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        blueLine.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        rechargeTable.refreshDelegate = self
        cashTable.refreshDelegate = self

        add(childView: rechargeTable, at: 0)
        add(childView: cashTable, at: 1)

        rechargeTable.mj_header.beginRefreshing()
        cashTable.mj_header.beginRefreshing()

        setSelectedAt(selectedIndex)
    }
}

extension IntegrationCashRecordController: IntegrationRecordTableRefreshDelegate {
    /// 下拉刷新
    func integrationRecordTable(_ view: IntegrationRecordTable, didRefreshWithIdentidier identifier: String) {
        IntegrationNetworkManager.getOrders(after: nil, action: identifier) { (models, message, status) in
        var cellModels: [IntegrationRecordCellModel]?
        if let datas = models {
            cellModels = datas.map { IntegrationRecordCellModel(model: $0) }
        }
        view.processRefresh(newDatas: cellModels, errorMessage: message)
        }
    }

    // 上拉加载更多
    func integrationRecordTable(_ view: IntegrationRecordTable, didLoadMoreWithIdentidier identifier: String) {
        IntegrationNetworkManager.getOrders(after: view.datas.last?.id, action: identifier) { (models, message, status) in
            var cellModels: [IntegrationRecordCellModel]?
            if let datas = models {
                cellModels = datas.map { IntegrationRecordCellModel(model: $0) }
            }
            view.processLoadMore(newDatas: cellModels, errorMessage: message)
        }
    }

}
