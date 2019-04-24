//
//  IntegrationRechargeController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire

class IntegrationRechargeIAPController: UIViewController, SKProductsRequestDelegate {

    // 积分充值页面title
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var containerTop: NSLayoutConstraint!
    fileprivate var tableController: IntegrationRechargeIAPTableController?
    var skRequest: SKProductsRequest!
    var iapModels = [IAPProductModel]()

    // MARK: - Lifecycle
    class func vc() -> IntegrationRechargeIAPController {
        let sb = UIStoryboard(name: "IntegrationRechargeIAPController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! IntegrationRechargeIAPController
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        // 更新状态栏的颜色
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let table = segue.destination as? IntegrationRechargeIAPTableController {
            tableController = table
        }
    }

    // MARK: - UI
    func loadData() {
        titleLabel.text = String(format: "显示_充值fomat".localized, TSAppConfig.share.localInfo.goldName)
        indicator.startAnimating()

        IntegrationNetworkManager.getIAPIntegrationConfig { [weak self] (iapModels, message, result) in
            guard let `self` = self else {
                return
            }
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            guard iapModels.isEmpty == true else {
                self.tableController?.sureButton.backgroundColor = TSColor.inconspicuous.disabled
                self.tableController?.sureButton.isUserInteractionEnabled = false
                self.validate(iapModels)
                self.tableController?.dataLoadError()
                return
            }
            self.tableController?.models = []
            if result == false {
                let errorAlert = TSIndicatorWindowTop(state: .faild, title: "网络不稳定")
                errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            } else {
                let errorAlert = TSIndicatorWindowTop(state: .faild, title: "充值暂不可用")
                errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.tableController?.sureButton.backgroundColor = TSColor.inconspicuous.disabled
                self.tableController?.sureButton.isUserInteractionEnabled = false
            }
        }
    }

    func validate(_ models: [IAPProductModel]) {
        var ids = Set<String>()
        for model in models {
            ids.insert(model.id)
        }
        self.skRequest = SKProductsRequest(productIdentifiers: ids)
        self.skRequest.delegate = self
        self.skRequest.start()
        self.iapModels = models
    }
    /// IAP配置信息信息获取成功
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.indicator.stopAnimating()
        self.indicator.isHidden = true
        for invalidId in response.invalidProductIdentifiers {
            // 如果有无效产品,就从数组里面删除不显示
            self.iapModels = self.iapModels.filter({ (model) -> Bool in
                return model.id != invalidId
            })
        }
        //显示界面
        self.tableController?.models = self.iapModels
        self.tableController?.skResponse = response
    }
    /// IAP配置信息信息获取失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.indicator.stopAnimating()
        let errorAlert = TSIndicatorWindowTop(state: .faild, title: "支付信息获取失败,请稍后重试")
        errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    // MARK: - Action
    // 充值记录按钮点击事件
    @IBAction func recordButtonTaped(_ sender: UIButton) {
        let recordVC = IntegrationCashRecordController(selectedIndex: 0)
        navigationController?.pushViewController(recordVC, animated: true)
    }

    // 返回按钮点击事件
    @IBAction func backButtonTaped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

class IntegrationRechargeIAPTableController: UITableViewController, SKPaymentTransactionObserver {
    /// 选择金额视图高度约束
    @IBOutlet weak var chooseMoneyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showRuleDetailLabel: UILabel!
    @IBOutlet weak var showRuleDetailLabel2: UILabel!
    @IBOutlet weak var showRuleDetailLabel3: UILabel!
    @IBOutlet weak var showRuleBtn: UIButton!
    @IBOutlet weak var showHelpBtn: UIButton!

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var chooseButtonView: ChooseMoneyButtonView!
    @IBOutlet weak var sureButton: UIButton!
    var skResponse: SKProductsResponse = SKProductsResponse()
    // 交易票据存根信息
    var integrationModle: IntegrationModel?
    // TSIndicatorWindowTop
    var indicatorView: TSIndicatorWindowTop?

    var models = [IAPProductModel]() {
        didSet {
            loadModel()
        }
    }

    /// 充值金额
    var rechargeNumber: Int? {
        didSet {
            loadDisplayLabel()
        }
    }

    /// 充值方式
    var rechargeType: IntegrationRechargeType?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SKPaymentQueue.default().add(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - UI

    func setUI() {
        showRuleBtn.addTarget(self, action: #selector(showRuleBtnDidClick), for: .touchUpInside)
        showHelpBtn.addTarget(self, action: #selector(showHelpBtnDidClick), for: .touchUpInside)
        chooseButtonView.set { [weak self] (selectedInfo) in
            if let double = Double(selectedInfo) {
                self?.rechargeNumber = Int(double)
                self?.sureButton.isUserInteractionEnabled = true
                self?.sureButton.backgroundColor = TSColor.main.theme
            } else {
                self?.rechargeNumber = nil
            }
        }
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            let headerView = UIView(frame: CGRect(x: 0, y: -(TSLiuhaiHeight + 20), width: ScreenWidth, height: (TSLiuhaiHeight + 20)))
            headerView.backgroundColor = UIColor(hex: 0x8C8AD9)
            tableView.addSubview(headerView)
        }
    }

    func loadModel() {
        if models.isEmpty {
            return
        }
        let prices = models.map { (model) -> String in
            let cnyOption = Double(model.amount) / 100
            return cnyOption.tostring()
        }
        chooseButtonView.array = prices
        displayLabel.text = "1元=\(100 * models[0].ratio)\(TSAppConfig.share.localInfo.goldName)"
        showRuleDetailLabel.text = "1.\(TSAppConfig.share.localInfo.goldName)充值兑换比例为: 1.00元=\(100 * models[0].ratio)\(TSAppConfig.share.localInfo.goldName);"
        showRuleDetailLabel2.text = String(format: "iap_说明2".localized, TSAppConfig.share.localInfo.goldName)
         showRuleDetailLabel3.text = String(format: "iap_说明3".localized, TSAppConfig.share.localInfo.goldName)
        // 刷新界面
        chooseMoneyViewHeight.constant = chooseButtonView.height
        chooseButtonView.setNeedsLayout()
        chooseButtonView.layoutIfNeeded()
        tableView.reloadData()
    }
    func dataLoadError() {
        displayLabel.text = "1元= -- \(TSAppConfig.share.localInfo.goldName)"
        showRuleDetailLabel.text = "1.\(TSAppConfig.share.localInfo.goldName)充值兑换比例为: 1.00元= -- \(TSAppConfig.share.localInfo.goldName);"
        showRuleDetailLabel2.text = String(format: "iap_说明2".localized, TSAppConfig.share.localInfo.goldName)
        showRuleDetailLabel3.text = String(format: "iap_说明3".localized, TSAppConfig.share.localInfo.goldName)
        // 刷新界面
        chooseMoneyViewHeight.constant = chooseButtonView.height
        chooseButtonView.setNeedsLayout()
        chooseButtonView.layoutIfNeeded()
        tableView.reloadData()
    }

    /// 刷新加载显示 label
    func loadDisplayLabel() {
        if let number = rechargeNumber {
            displayLabel.text = "\(number)元=\(number * 100 * models[0].ratio)\(TSAppConfig.share.localInfo.goldName)"
        } else {
            displayLabel.text = "1元=\(100 * models[0].ratio)\(TSAppConfig.share.localInfo.goldName)"
        }
    }

    // MARK: - Action

    func showRuleBtnDidClick() {
        guard let rule = models.first?.rule else {
            let errorAlert = TSIndicatorWindowTop(state: .faild, title: "未设置充值协议")
            errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            return
        }
        let vc = RuleShowViewController()
        vc.ruleMarkdownStr = rule
        vc.title = "用户充值协议"
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func showHelpBtnDidClick() {
        let url = TSAppConfig.share.rootServerAddress + "api/v2/currency/apple-iap/help"
        TSUtil.pushURLDetail(url:  URL(string: url)!, currentVC: self)
    }

    @IBAction func sureButtonTaped(_ sender: UIButton) {
        guard let rechargeNumber = rechargeNumber else {
            showAlert(status: .faild, message: "请输入或选择充值金额")
            return
        }

        // 将元单位的金额转换成分单位
        let fenNumber = rechargeNumber * 100
        // 遍历我们服务器的id表,通过价格amount找到对应的产品id
        // [坑] 这种遍历方式,如果出现多个产品价格一样就会出现错误的id
        let productId = self.models.filter { (iapModel) -> Bool in
            return iapModel.amount == fenNumber
        }

        let products = self.skResponse.products.filter { (product) -> Bool in
            return product.productIdentifier == productId[0].id
        }
        let payment = SKMutablePayment(product: products[0])
        payment.quantity = 1

        sender.isUserInteractionEnabled = false
        let alert = TSIndicatorWindowTop(state: .loading, title: "支付中")
        alert.show()
        self.indicatorView = alert
        var request = IntegrationIAPNetworkRequest().recharge
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["amount": fenNumber]
        RequestNetworkData.share.text(request: request) { [weak self] (result) in
            guard let `self` = self else {
                return
            }
            switch result {
            case .failure(let response):
                sender.isUserInteractionEnabled = true
                if let indicatorView = self.indicatorView {
                    indicatorView.dismiss()
                }
                self.showAlert(status: .faild, message: response.message ?? "发起交易失败")
            case .error(_):
                sender.isUserInteractionEnabled = true
                if let indicatorView = self.indicatorView {
                    indicatorView.dismiss()
                }
                self.showAlert(status: .faild, message: "网络错误")
            case .success(let response):
                guard let model = response.model else {
                    if let indicatorView = self.indicatorView {
                        indicatorView.dismiss()
                    }
                    self.showAlert(status: .faild, message: "网络错误")
                    return
                }
                self.integrationModle = model
                SKPaymentQueue.default().add(payment)
            }
        }
    }

    /// 显示顶部弹窗
    func showAlert(status: LoadingState, message: String) {
        let alert = TSIndicatorWindowTop(state: status, title: message)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased: // 购买成功,标记购买结束
                queue.finishTransaction(transaction)
                // 告知服务器
                guard let orderId = self.integrationModle?.id else {
                    return
                }
                // 载入支付凭据
                uploadReceiptWith(order: orderId)
                break
            case .failed:
                sureButton.isUserInteractionEnabled = true
                if let indicatorView = self.indicatorView {
                    indicatorView.dismiss()
                }
                let alert = TSIndicatorWindowTop(state: .faild, title: "显示_支付失败".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                queue.finishTransaction(transaction)
                break
            case .purchasing, .restored, .deferred:
                break
            }
        }
    }

    func uploadReceiptWith(order: Int) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receipt = try? Data(contentsOf: receiptURL) else {
            return
        }
        var request = IntegrationIAPNetworkRequest().order
        request.urlPath = request.fullPathWith(replacers: ["\(order)"])

        request.parameter = ["receipt": receipt.base64EncodedString()]
        RequestNetworkData.share.text(request: request) { [weak self] (result) in
            if let indicatorView = self?.indicatorView {
                indicatorView.dismiss()
            }
            self?.sureButton.isUserInteractionEnabled = true
            switch result {
            case .error(_):
                let alert = TSIndicatorWindowTop(state: .faild, title: "网络错误")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(_):
                let alert = TSIndicatorWindowTop(state: .faild, title: "显示_支付失败".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(_):
                let alert = TSIndicatorWindowTop(state: .success, title: "显示_支付成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
}
