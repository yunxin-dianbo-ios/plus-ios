//
//  IntegrationHomeController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/18.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

let alreadyEnteredIntoIntegrationHomeController = "alreadyEnteredIntoIntegrationHomeController"

class IntegrationHomeController: UIViewController {

    @IBOutlet weak var titleLab: UILabel!
    /// 小菊花
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    /// 返回按钮
    @IBOutlet weak var backButton: UIButton!
    /// 明细按钮
    @IBOutlet weak var recordButton: UIButton!
    /// 积分规则按钮
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var containerTop: NSLayoutConstraint!
    /// 积分规则
    var rule = ""

    var tableController: IntegrationHomeTableController?

    // MARK: - lifecycle

    class func vc() -> IntegrationHomeController {
        let sb = UIStoryboard(name: "IntegrationHomeController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! IntegrationHomeController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            self.containerTop.constant = 0
            self.updateViewConstraints()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        // 更新状态栏的颜色
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        indicator.startAnimating()
        indicator.isHidden = false
        // 获取用户信息
        TSUserNetworkingManager().getCurrentUserInfo { [weak self] (model, _, status) in
            self?.indicator.stopAnimating()
            self?.indicator.isHidden = true
            if status, let model = model {
                TSCurrentUserInfo.share.userInfo = model
                self?.tableController?.integrationNumber = model.integration?.sum ?? 0
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        // 更新状态栏的颜色
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let table = segue.destination as? IntegrationHomeTableController {
            tableController = table
        }
    }

    func loadData() {
        titleLab.text = String(format: "显示_我的format".localized, TSAppConfig.share.localInfo.goldName)
        ruleButton.setTitle(String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName), for: .normal)
        /// 如果等于 "" 那么就请求一次启动信息接口
        if TSAppConfig.share.localInfo.currencySetInfo?.rule == "" {
            indicator.startAnimating()
            indicator.isHidden = false
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                if status == true {
                    self.rule = (TSAppConfig.share.localInfo.currencySetInfo?.rule)!
                    // 判断用户是否是第一次进入积分主页，如果是，自动弹出积分规则
                    let isEntered = UserDefaults.standard.bool(forKey: alreadyEnteredIntoIntegrationHomeController)
                    if isEntered == false {
                        UserDefaults.standard.set(true, forKey: alreadyEnteredIntoIntegrationHomeController)
                        DispatchQueue.main.async {
                            let popView = TSAgreementPopView(title: String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName), content: (TSAppConfig.share.localInfo.currencySetInfo?.rule)!, doneTitle: "知道了")
                            popView.show()
                        }
                    }
                } else {
                    // 网络不可用
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_网络错误".localized)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        } else {
            self.rule = (TSAppConfig.share.localInfo.currencySetInfo?.rule)!
            // 判断用户是否是第一次进入积分主页，如果是，自动弹出积分规则
            let isEntered = UserDefaults.standard.bool(forKey: alreadyEnteredIntoIntegrationHomeController)
            if isEntered == false {
                UserDefaults.standard.set(true, forKey: alreadyEnteredIntoIntegrationHomeController)
                DispatchQueue.main.async {
                    let popView = TSAgreementPopView(title: String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName), content: (TSAppConfig.share.localInfo.currencySetInfo?.rule)!, doneTitle: "知道了")
                    popView.show()
                }
            }
        }
        /// 下面请求积分配置信息接口被删除了 后续请确认后删除下面代码
        /**
        IntegrationNetworkManager.getIntegrationConfig { [weak self] (model, message, status) in
            self?.indicator.stopAnimating()
            self?.indicator.isHidden = true
            guard let netModel = model else {
                let errorAlert = TSIndicatorWindowTop(state: .faild, title: "网络不稳定")
                errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            self?.rule = netModel.rule
            // 判断用户是否是第一次进入积分主页，如果是，自动弹出积分规则
            let isEntered = UserDefaults.standard.bool(forKey: alreadyEnteredIntoIntegrationHomeController)
            if isEntered == false {
                UserDefaults.standard.set(true, forKey: alreadyEnteredIntoIntegrationHomeController)
                DispatchQueue.main.async {
                    let popView = TSAgreementPopView(title: String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName), content: TSAppConfig.share.localInfo.currency_recharge_rule == "" ? netModel.rule : TSAppConfig.share.localInfo.currency_recharge_rule, doneTitle: "知道了")
                    popView.show()
                }
            }
        }
        */
    }

    // MARK: - button click

    /// 点击了返回按钮
    @IBAction func backButtonTaped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    /// 点击了明细按钮
    @IBAction func recordButtonTaped(_ sender: UIButton) {
        let vc = IntegrationRecordController()
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 点击了积分规则按钮
    @IBAction func ruleButtonTaped() {
        let vc = RuleShowViewController()
        vc.ruleMarkdownStr = TSAppConfig.share.localInfo.currencySetInfo?.rule == "" ? rule : TSAppConfig.share.localInfo.currencySetInfo?.rule
        vc.title = String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

class IntegrationHomeTableController: UITableViewController {

    var advertModels: [TSAdvertViewModel] = []
    @IBOutlet weak var advertsCell: UITableViewCell!

    // 积分数量 label
    @IBOutlet weak var integrationLabel: UILabel!
    // 广告视图
    @IBOutlet weak var advertView: TSAdvertNormal!
    // 当前积分文字label
    @IBOutlet weak var currentIntegrationDesLabel: UILabel!
    // 充值积分
    @IBOutlet weak var rechargeGoldeLabel: UILabel!
    // 提取积分
    @IBOutlet weak var withdrawGoldLabel: UILabel!
    /// 跳转 IAP 充值
    var showIAP: Bool {
        return (TSAppConfig.share.localInfo.currencySetInfo?.showOnlyIAP)!
    }
    /// 积分充值显示开关 cell
    var showRechargeCell: Bool {
        return showIAP && (TSAppConfig.share.localInfo.currencySetInfo?.showIntegration)!
    }
    ///  积分提现显示开关 cell
    var showCashCell: Bool {
        return TSAppConfig.share.localInfo.currencySetInfo!.showIntegrationRecharge && !showIAP 
    }

    /// 积分数量
    var integrationNumber = 0 {
        didSet {
            integrationLabel.text = "\(integrationNumber)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        loadAdvertView()

        tableView.backgroundColor = UIColor(hex: 0xf4f5f5)
        tableView.tableFooterView = UIView()
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            let headerView = UIView(frame: CGRect(x: 0, y: -(TSLiuhaiHeight + 20), width: ScreenWidth, height: (TSLiuhaiHeight + 20)))
            headerView.backgroundColor = UIColor(hex: 0x8C8AD9)
            tableView.addSubview(headerView)
        }
        currentIntegrationDesLabel.text = String(format: "当前format".localized, TSAppConfig.share.localInfo.goldName)
        rechargeGoldeLabel.text = String(format: "充值format".localized, TSAppConfig.share.localInfo.goldName)
        withdrawGoldLabel.text = String(format: "format提取".localized, TSAppConfig.share.localInfo.goldName)
    }

    func loadAdvertView() {
        let advertObjects = TSDatabaseManager().advert.getObjects(type: .currency)
        if advertObjects.isEmpty {
            return
        }
        advertModels = advertObjects.map { TSAdvertViewModel(object: $0) }
        advertView.set(itemCount: advertModels.count)
        advertView.set(models: advertModels)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let rowNumber = indexPath.row
        switch rowNumber {
        case 1:
            // 充值积分
            if showIAP {
                let rechargeIAPVC = IntegrationRechargeIAPController.vc()
                navigationController?.pushViewController(rechargeIAPVC, animated: true)
            } else {
                let rechargeVC = IntegrationRechargeController.vc()
                navigationController?.pushViewController(rechargeVC, animated: true)
            }
        case 2:
            // 积分提取
            let cashVC = IntegrationCashController.vc()
            navigationController?.pushViewController(cashVC, animated: true)
        case 4:
            // 积分商城
            let urlString = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + "currency/shop"
            TSUtil.pushURLDetail(url: URL(string: urlString)!, currentVC: self)

        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.cellForRow(at: indexPath)
        if advertModels.isEmpty && cell == advertsCell {
            return 0
        }
        // 1.积分提现开关
        if !showCashCell && indexPath.row == 2 {
            return 0
        }
        // 2.积分充值开关
        if !showRechargeCell && indexPath.row == 1 {
            return 0
        }
        // 积分显示页面高度需要调整
        if indexPath.row == 0 && TSUserInterfacePrinciples.share.isiphoneX() == false {
            return 220 + 44
        }
        // 广告位需要调整高度，确保不变形
        if indexPath.row == 4 {
            return TSAdvertHelper.share.getAdvertHeight(advertType: .normal, Advertwith: ScreenWidth, itemCount: advertModels.count)
        }
        return UITableViewAutomaticDimension
    }
}
