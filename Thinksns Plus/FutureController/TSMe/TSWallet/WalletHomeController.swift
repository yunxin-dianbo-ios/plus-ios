//
//  WalletHomepageController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/2/5.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

let alreadyEnteredIntoWalletHomeController = "alreadyEnteredIntoWalletHomeController"

class WalletHomeController: UIViewController {

    /// 小菊花
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    /// 返回按钮
    @IBOutlet weak var backButton: UIButton!
    /// 明细按钮
    @IBOutlet weak var recordButton: UIButton!
    /// 充值提现规则按钮
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var containerTop: NSLayoutConstraint!
    /// 积分规则
    var rule = ""

    var tableController: WalletHomeTableController?

    // MARK: - lifecycle

    class func vc() -> WalletHomeController {
        let sb = UIStoryboard(name: "WalletHomeController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! WalletHomeController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.view.backgroundColor = UIColor(hex: 0xf4f5f5)
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
                self?.tableController?.moneyNumber = model.wallet?.balance ?? 0
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
        if let table = segue.destination as? WalletHomeTableController {
            tableController = table
        }
    }

    func loadData() {
        if TSAppConfig.share.localInfo.walletSetInfo?.rule == "" {
            indicator.startAnimating()
            indicator.isHidden = false
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                if status == true {
                    self.rule = (TSAppConfig.share.localInfo.walletSetInfo?.rule)!
                    // 判断用户是否是第一次进入积分主页，如果是，自动弹出积分规则
                    let isEntered = UserDefaults.standard.bool(forKey: alreadyEnteredIntoIntegrationHomeController)
                    if isEntered == false {
                        UserDefaults.standard.set(true, forKey: alreadyEnteredIntoIntegrationHomeController)
                        DispatchQueue.main.async {
                            let popView = TSAgreementPopView(title: String(format: "显示_积分规则".localized, TSAppConfig.share.localInfo.goldName), content: (TSAppConfig.share.localInfo.walletSetInfo?.rule)!, doneTitle: "知道了")
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
            self.rule = (TSAppConfig.share.localInfo.walletSetInfo?.rule)!
            // 判断用户是否是第一次进入积分主页，如果是，自动弹出积分规则
            let isEntered = UserDefaults.standard.bool(forKey: alreadyEnteredIntoWalletHomeController)
            if isEntered == false {
                UserDefaults.standard.set(true, forKey: alreadyEnteredIntoWalletHomeController)
                DispatchQueue.main.async {
                    let popView = TSAgreementPopView(title: "充值提现规则", content: (TSAppConfig.share.localInfo.walletSetInfo?.rule)!, doneTitle: "知道了")
                    popView.show()
                }
            }
        }
        // 下面请求钱包配置信息接口被删除了 后续请确认后删除下面代码
        /**
        WalletNetworkManager.getConfig { [weak self] (status, message, model) in
            self?.indicator.stopAnimating()
            self?.indicator.isHidden = true
            guard let netModel = model else {
                let errorAlert = TSIndicatorWindowTop(state: .faild, title: "网络不稳定")
                errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            self?.rule = netModel.rule
            // 判断用户是否是第一次进入积分主页，如果是，自动弹出积分规则
            let isEntered = UserDefaults.standard.bool(forKey: alreadyEnteredIntoWalletHomeController)
            if isEntered == false {
                UserDefaults.standard.set(true, forKey: alreadyEnteredIntoWalletHomeController)
                DispatchQueue.main.async {
                    let popView = TSAgreementPopView(title: "充值提现规则", content: TSAppConfig.share.localInfo.cash_rule == "" ? netModel.rule : TSAppConfig.share.localInfo.cash_rule, doneTitle: "知道了")
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
        let transtionVC = TSWalletTransitionVC(style: .plain)
        navigationController?.pushViewController(transtionVC, animated: true)
    }

    /// 点击了积分规则按钮
    @IBAction func ruleButtonTaped() {
        let vc = RuleShowViewController()
        vc.ruleMarkdownStr = TSAppConfig.share.localInfo.walletSetInfo?.rule == "" ? rule : TSAppConfig.share.localInfo.walletSetInfo?.rule
        vc.title = "充值提现规则"
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

class WalletHomeTableController: UITableViewController {

    /// 金额数 (分单位)
    var moneyNumber = 0 {
        didSet {
            moneyLabel.text = (Double(moneyNumber) / 100).tostring()
        }
    }

    /// 是否显示充值 cell
    var shouRechargeCell: Bool {
        return TSAppConfig.share.localInfo.walletSetInfo!.showRecharge
    }
    /// 是否显示提现 cell
    var showCashCell: Bool {
        return TSAppConfig.share.localInfo.walletSetInfo!.showCash
    }
    /// 是否显示积分充值 cell
    var showIntegrationRechargeCell: Bool {
        return showIAP || TSAppConfig.share.localInfo.currencySetInfo!.showIntegrationRecharge
    }

    /// 是否开启 IAP 充值
    var showIAP: Bool {
        return (TSAppConfig.share.localInfo.currencySetInfo?.showOnlyIAP)!
    }

    /// 金额 label
    @IBOutlet weak var moneyLabel: UILabel!
    /// 充值 cell
    @IBOutlet weak var rechargeCell: UITableViewCell!
    /// 提现 cell
    @IBOutlet weak var cashCell: UITableViewCell!
    /// 积分充值 cell
    @IBOutlet weak var integrationRechargeCell: UITableViewCell!
    // 积分充值label
    @IBOutlet weak var rechargeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        tableView.backgroundColor = UIColor(hex: 0xf4f5f5)
        rechargeLabel.text = String(format: "format充值".localized, TSAppConfig.share.localInfo.goldName)
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            let headerView = UIView(frame: CGRect(x: 0, y: -(TSLiuhaiHeight + 20), width: ScreenWidth, height: (TSLiuhaiHeight + 20)))
            headerView.backgroundColor = TSColor.main.theme
            tableView.addSubview(headerView)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.cellForRow(at: indexPath)
        // 1.判断是否显示充值 cell
        if !shouRechargeCell && cell == rechargeCell {
            return 0
        }
        // 2.判断是否显示提现 cell
        if !showCashCell && cell == cashCell {
            return 0
        }
        // 3.判断是否显示积分提现 cell
        if !showIntegrationRechargeCell && cell == integrationRechargeCell {
            return 0
        }
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath)
        if cell == rechargeCell {
            // 1.点击了充值 cell
            let rechargeVC = WalletRechargeController.vc()
            navigationController?.pushViewController(rechargeVC, animated: true)
        } else if cell == cashCell {
            // 2.点击了提现 cell
            let cashVC = WalletCashController.vc()
            navigationController?.pushViewController(cashVC, animated: true)
        } else if cell == integrationRechargeCell {
            // 3.点击了积分充值 cell
            if showIAP {
                let rechargeIAPVC = IntegrationRechargeIAPController.vc()
                navigationController?.pushViewController(rechargeIAPVC, animated: true)
            } else {
                let rechargeVC = IntegrationRechargeController.vc()
                navigationController?.pushViewController(rechargeVC, animated: true)
            }
        }
    }
}
