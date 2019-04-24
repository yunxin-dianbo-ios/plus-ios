//
//  IntegrationRechargeController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class IntegrationRechargeController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var containerTop: NSLayoutConstraint!
    fileprivate var tableController: IntegrationRechargeTableController?

    // MARK: - Lifecycle

    class func vc() -> IntegrationRechargeController {
        let sb = UIStoryboard(name: "IntegrationRechargeController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! IntegrationRechargeController
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
        if let table = segue.destination as? IntegrationRechargeTableController {
            tableController = table
        }
    }

    // MARK: - UI

    func loadData() {
        if TSAppConfig.share.launchInfo?.currencySetInfo != nil {
            self.indicator.isHidden = true
            self.tableController?.model = IntegrationRechargeModel(model: TSAppConfig.share.launchInfo!.currencySetInfo!)
        } else {
            indicator.startAnimating()
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                if status == true {
                    if TSAppConfig.share.localInfo.currencySetInfo != nil {
                        self.tableController?.model = IntegrationRechargeModel(model: TSAppConfig.share.launchInfo!.currencySetInfo!)
                    }
                } else {
                    // 网络不可用
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_网络错误".localized)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        }
        // 下面请求积分信息接口已经被删除,请后续确认后删除下面注释的代码
        /**
        indicator.startAnimating()
        IntegrationNetworkManager.getIntegrationConfig { [weak self] (model, message, status) in
            self?.indicator.stopAnimating()
            self?.indicator.isHidden = true
            guard let netModel = model else {
                let errorAlert = TSIndicatorWindowTop(state: .faild, title: "网络不稳定")
                errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            self?.tableController?.model = IntegrationRechargeModel(model: netModel)
        }
        */
        titleLabel.text = String(format: "显示_充值fomat".localized, TSAppConfig.share.localInfo.goldName)
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

    // 用户充值协议按钮点击事件
    @IBAction func protocolButtonTaped(_ sender: UIButton) {
        let vc = RuleShowViewController()
        vc.ruleMarkdownStr = tableController?.model.rule ?? ""
        vc.title = "用户充值协议"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class IntegrationRechargeTableController: UITableViewController {

    /// 选择充值方式
    @IBOutlet weak var rechargeTypeCell: UITableViewCell!
    /// 选择金额视图高度约束
    @IBOutlet weak var chooseMoneyViewHeight: NSLayoutConstraint!

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var chooseButtonView: ChooseMoneyButtonView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sureButton: TSColorLumpButton!
    @IBOutlet weak var showChargeTypeLab: UILabel!
    var model = IntegrationRechargeModel() {
        didSet {
            loadModel()
        }
    }

    /// 充值金额
    var rechargeNumber: Double? {
        didSet {
            loadDisplayLabel()
            checkSureButtonStatus()
        }
    }

    /// 充值方式
    var rechargeType: IntegrationRechargeType? {
        didSet {
            checkSureButtonStatus()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        /// 支付回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(checkPayResultBack(noti:)), name: NSNotification.Name.Pay.checkResult, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除检测输入框状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    // MARK: - UI

    func setUI() {
        sureButton.sizeType = .large
        chooseButtonView.set { [weak self] (selectedInfo) in
            self?.textField.endEditing(true)
            self?.textField.text = ""
            self?.rechargeNumber = Double(selectedInfo)
        }
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            let headerView = UIView(frame: CGRect(x: 0, y: -(TSLiuhaiHeight + 20), width: ScreenWidth, height: (TSLiuhaiHeight + 20)))
            headerView.backgroundColor = UIColor(hex: 0x8C8AD9)
            tableView.addSubview(headerView)
        }
        self.showChargeTypeLab.textColor = TSColor.normal.minor
    }

    func loadModel() {
        chooseButtonView.array = model.moneyArray
        displayLabel.text = "1元=\(100 * model.ratio)\(TSAppConfig.share.localInfo.goldName)"

        // 刷新界面
        chooseMoneyViewHeight.constant = chooseButtonView.height
        chooseButtonView.setNeedsLayout()
        chooseButtonView.layoutIfNeeded()
        tableView.reloadData()
    }

    /// 刷新加载显示 label
    func loadDisplayLabel() {
        if let number = rechargeNumber {
            displayLabel.text = "\(number)元=\(Int(number * 100) * model.ratio)\(TSAppConfig.share.localInfo.goldName)"
        } else {
            displayLabel.text = "1元=\(100 * model.ratio)\(TSAppConfig.share.localInfo.goldName)"
        }
    }

    /// 检查确定按钮的状态
    func checkSureButtonStatus() {
        if rechargeNumber == nil || rechargeNumber == 0 {
            sureButton.isEnabled = false
            return
        }

        if rechargeType == nil {
            sureButton.isEnabled = false
            return
        }
        sureButton.isEnabled = true
    }

    // MARK: - Action

    @IBAction func sureButtonTaped() {
        guard let rechargeNumber = rechargeNumber else {
            return
        }
        guard let rechargeType = rechargeType  else {
            return
        }
        // 将元单位的金额转换成分单位
        let fenNumber = Int(rechargeNumber * 100)
        if TSAppConfig.share.localInfo.currencySetInfo != nil {
            let rechargeMax = TSAppConfig.share.localInfo.currencySetInfo!.rechargeMax
            if (fenNumber > rechargeMax) {
                let alert = TSIndicatorWindowTop(state: .faild, title: "不能高于最高充值金额\(rechargeMax/100)元")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
        }

        sureButton.isUserInteractionEnabled = false

        // 1. 如果是钱包余额充值
        if rechargeType == .wallet {
            WalletNetworkManager.transfer(amount: fenNumber, complete: { [weak self] (status, message) in
                guard let `self` = self else {
                    return
                }
                self.sureButton.isUserInteractionEnabled = true
                var msg = message
                if status {
                    msg = String(format: "共消耗%.2f元，获得%d\(TSAppConfig.share.localInfo.goldName)！", rechargeNumber, self.model.ratio * Int(rechargeNumber) * 100)
                }
                let alert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            })
            return
        }
        // 2. 如果是其他充值
        if rechargeType == .alipay {
            IntegrationNetworkManager.createAlipayCharge(amount: fenNumber) { (dataString, message, status) in
                if status == true {
                    /// 注意：
                    /// 支付结果回调Block，用于wap支付结果回调（非跳转钱包支付）
                    /// 钱包的回调在appdelegate
                    UserDefaults.standard.setValue("integration", forKey: "pay_type")
                    UserDefaults.standard.synchronize()
                    let appURLScheme = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
                    AlipaySDK.defaultService().payOrder(dataString, fromScheme: appURLScheme, callback: { (payBackInfo) in
                        let payBackInfoDic = payBackInfo! as NSDictionary
                        let appdelegate = UIApplication.shared.delegate as? AppDeleguate
                        appdelegate?.checkAlipayCharge(payBackInfoDic: payBackInfoDic as! Dictionary<String, String>)
                    })
                } else {
                    let alert = TSIndicatorWindowTop(state: .faild, title: message)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        } else if rechargeType == .wx {
            IntegrationNetworkManager.createWeChatCharge(amount: fenNumber) { (data, message, status) in
                guard let dataDic = data else {
                    // 异常情况，直接提示
                    let alert = TSIndicatorWindowTop(state: .faild, title: message)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    return
                }
                guard let appid = dataDic["appid"] as? String, let partnerid = dataDic["partnerid"] as? String, let prepayid = dataDic["prepayid"] as? String,
                    let package = dataDic["package"] as? String, let nonceStr = dataDic["noncestr"] as? String, let timestamp = dataDic["timestamp"] as? Int, let sign = dataDic["sign"]  as? String else {
                        // 异常情况，直接提示
                        let alert = TSIndicatorWindowTop(state: .faild, title: message)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                        return
                }
                WXApi.registerApp(appid)
                let request = PayReq()
                request.partnerId = partnerid
                request.prepayId = prepayid
                request.package = package
                request.nonceStr = nonceStr
                request.timeStamp = UInt32(timestamp)
                request.sign = sign
                WXApi.send(request)
            }
        }
    }

    /// 支付校验回调
    func checkPayResultBack(noti: Notification) {
        guard let infoDic = noti.userInfo as? Dictionary<String, Any> else {
            TSLogCenter.log.debug("\n\n checkPayResultBack 信息为空")
            return
        }
        self.sureButton.isUserInteractionEnabled = true
        let message = infoDic["message"] as! String
        let status = infoDic["status"] as! Bool
        let result = infoDic["result"] as! String
        self.showAlert(status: status ? .success: .faild, message: result.count > 0 ? result : message)
    }
    /// 显示顶部弹窗
    func showAlert(status: LoadingState, message: String) {
        let alert = TSIndicatorWindowTop(state: status, title: message)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    /// 处理支付回调信息，显示状态弹窗
    ///
    /// - Parameter message: 回调信息
    func processPayCallback(message: PayState) {
        var state: LoadingState
        var titelString = ""
        switch message {
        case .errorToken:
            // 0. 获取支付凭据失败
            state = .faild
            titelString = "显示_获取凭证失败".localized
        case .success:
            // 1. 支付成功
            state = .success
            titelString = "显示_支付成功".localized
        case .fail:
            // 2. 支付失败
            state = .faild
            titelString = "显示_支付失败".localized
        case .cancel:
            // 3. 取消支付
            state = .success
            titelString = "显示_取消支付".localized
        }
        // 显示状态弹窗
        let alert = TSIndicatorWindowTop(state: state, title: titelString)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    /// 检测输入框的输入状态，判断登录按钮的点击状态
    func textFiledDidChanged(notification: Notification) {
        // 输入框类型 key
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField == self.textField {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: 8)
            rechargeNumber = Double(textField.text ?? "")
            if rechargeNumber != nil {
                chooseButtonView.clearSelectedStatus()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let cell = tableView.cellForRow(at: indexPath)
        /// 选择充值方式
        if cell == rechargeTypeCell {
            let alert = TSAlertController(title: "", message: "", style: .actionsheet)
            for type in model.chargeTypeArray {
                var title = ""
                switch type {
                case .alipay:
                    title = "支付宝支付"
                    alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                        self?.rechargeType = type
                        self?.showChargeTypeLab.text = "支付宝充值"
                    }))
                case .wx:
                    if UIApplication.shared.canOpenURL(URL(string: "weixin://")!) == false {
                        title = "没有检测到微信客户端"
                        alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                            let errorAlert = TSIndicatorWindowTop(state: .faild, title: "没有检测到微信客户端")
                            errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                            self?.showChargeTypeLab.text = "没有检测到微信客户端"
                            return
                        }))
                    } else {
                        title = "微信支付"
                        alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                            self?.rechargeType = type
                            self?.showChargeTypeLab.text = "微信充值"
                        }))
                    }
                case .applepay:
                    continue
                case .wallet:
                    title = "钱包余额充值"
                    alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                        self?.rechargeType = type
                        self?.showChargeTypeLab.text = "钱包余额充值"
                    }))
                }
            }

            if alert.actionsCount > 0 {
                DispatchQueue.main.async {
                    self.present(alert, animated: false, completion: nil)
                }
            } else {
                alert.addAction(TSAlertAction(title: "当前未支持任何充值方式", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }

}
