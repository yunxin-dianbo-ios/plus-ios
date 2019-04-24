//
//  IntegrationRecordController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/18.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class IntegrationRecordController: UIViewController {

    let table = IntegrationRecordTable(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)), tableIdentifier: "")
    let ruleButton = UIButton(type: .custom)

    /// 积分规则
    var rule = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
    }

    func setUI() {
        title = "\(TSAppConfig.share.localInfo.goldName)明细"

        // 1.列表
        table.refreshDelegate = self
        table.mj_header.beginRefreshing()

        // 2.规则按钮
        ruleButton.frame = CGRect(x: (UIScreen.main.bounds.width - 120) / 2, y: UIScreen.main.bounds.height - 35 - 26 - TSNavigationBarHeight - TSBottomSafeAreaHeight, width: 120, height: 35)
        ruleButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        ruleButton.layer.cornerRadius = 18
        ruleButton.clipsToBounds = true
        ruleButton.backgroundColor = TSColor.main.theme
        ruleButton.setTitle("\(TSAppConfig.share.localInfo.goldName)规则", for: .normal)
        ruleButton.setImage(UIImage(named: "ico_wallet_rules_white"), for: .normal)
        ruleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        ruleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        ruleButton.addTarget(self, action: #selector(ruleButtonTaped), for: .touchUpInside)

        view.addSubview(table)
        view.addSubview(ruleButton)
    }

    // 积分规则被点击
    func ruleButtonTaped() {
        let vc = RuleShowViewController()
        vc.ruleMarkdownStr = rule
        vc.title = String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func loadData() {
        ruleButton.isHidden = true
        /// 如果等于 "" 那么就请求一次启动信息接口
        if TSAppConfig.share.localInfo.currency_recharge_rule == "" {
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                self.ruleButton.isHidden = false
                if status == true {
                    self.rule = TSAppConfig.share.localInfo.currency_recharge_rule
                } else {
                    // 网络不可用
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_网络错误".localized)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        } else {
            self.ruleButton.isHidden = false
            self.rule = TSAppConfig.share.localInfo.currency_recharge_rule
        }
        /// 下面请求积分信息接口已经被删除,请后续确认后删除下面注释的代码
        /**
        IntegrationNetworkManager.getIntegrationConfig { [weak self] (model, message, status) in
            self?.ruleButton.isHidden = false
            guard let netModel = model else {
                let errorAlert = TSIndicatorWindowTop(state: .faild, title: "网络不稳定")
                errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            self?.rule = netModel.rule
        }
        */
    }

}

extension IntegrationRecordController: IntegrationRecordTableRefreshDelegate {

    // 下拉刷新
    func integrationRecordTable(_ view: IntegrationRecordTable, didRefreshWithIdentidier identifier: String) {
        IntegrationNetworkManager.getOrders(after: nil, action: nil) { (models, message, status) in
            var cellModels: [IntegrationRecordCellModel]?
            if let datas = models {
                cellModels = datas.map { IntegrationRecordCellModel(model: $0) }
            }
            view.processRefresh(newDatas: cellModels, errorMessage: message)
        }
    }

    // 上拉加载更多
    func integrationRecordTable(_ view: IntegrationRecordTable, didLoadMoreWithIdentidier identifier: String) {
        IntegrationNetworkManager.getOrders(after: table.datas.last?.id, action: nil) { (models, message, status) in
            var cellModels: [IntegrationRecordCellModel]?
            if let datas = models {
                cellModels = datas.map { IntegrationRecordCellModel(model: $0) }
            }
            view.processLoadMore(newDatas: cellModels, errorMessage: message)
        }
    }
}
