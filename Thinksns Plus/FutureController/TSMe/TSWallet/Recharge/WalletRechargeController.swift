//
//  WalletRechargeController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/2/5.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  钱包充值

import UIKit

/// 支付结果
enum PayState: String {
    /// 错误的支付凭证
    case errorToken
    /// 支付成功
    case success
    /// 支付失败
    case fail
    /// 支付取消
    case cancel
}

class WalletRechargeController: UITableViewController {

    /// 金额选择按钮视图高度
    @IBOutlet weak var chooseMoneyViewHeight: NSLayoutConstraint!
    /// 金额选择按钮视图
    @IBOutlet weak var chooseMoneyView: ChooseMoneyButtonView!

    /// 选择充值方式 cell
    @IBOutlet weak var rechargeTypeCell: UITableViewCell!
    /// 确认按钮
    @IBOutlet weak var buttonForSure: TSColorLumpButton!
    /// 金额输入框
    @IBOutlet weak var textfieldForMoney: UITextField!
    /// 充值方式
    @IBOutlet weak var rechargeTypeLabel: UILabel!

    var config = TSRechargeModel() {
        didSet {
            loadConfig()
        }
    }

    /// 当前充值金额
    var rechargeMoney: Double? {
        didSet {
            checkSureButtonStatus()
        }
    }
    /// 当前充值方式
    var rechargeType: WalletRechargeType? {
        didSet {
            checkSureButtonStatus()
        }
    }

    // MARK: - Lifecycle

    class func vc() -> WalletRechargeController {
        let sb = UIStoryboard(name: "WalletRechargeController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! WalletRechargeController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loading()
        loadData()
        setUI()
        /// 支付回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(checkPayResultBack(noti:)), name: NSNotification.Name.Pay.checkResult, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(textFildDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    // MARK: - UI

    func loadData() {
        if TSAppConfig.share.localInfo.walletSetInfo != nil {
            self.endLoading()
            self.config = TSRechargeModel(model: TSAppConfig.share.localInfo.walletSetInfo!)
        } else {
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                if status == true {
                    if TSAppConfig.share.localInfo.walletSetInfo != nil {
                        self.endLoading()
                        self.config = TSRechargeModel(model: TSAppConfig.share.localInfo.walletSetInfo!)
                    } else {
                        self.loadFaild(type: .network)
                    }
                } else {
                    self.loadFaild(type: .network)
                }
            }
        }
        // 下面请求钱包配置信息接口被删除了 后续请确认后删除下面代码
        /**
        WalletNetworkManager.getConfig { [weak self] (status, message, model) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.config = TSRechargeModel(model: model)
            self?.endLoading()
        }
       */
    }

    func loadConfig() {
        chooseMoneyView.array = config.options

        chooseMoneyViewHeight.constant = chooseMoneyView.height
        chooseMoneyView.setNeedsLayout()
        chooseMoneyView.layoutIfNeeded()
        tableView.reloadData()
    }

    func setUI() {
        title = "显示_充值".localized
        buttonForSure.sizeType = .large

        chooseMoneyView.set { [weak self] (money) in
            self?.textfieldForMoney.endEditing(true)
            self?.rechargeMoney = Double(money)
            self?.textfieldForMoney.text = ""
        }
        self.rechargeTypeLabel.textColor = TSColor.normal.minor
    }

    func endEditing() {
        textfieldForMoney.endEditing(true)
    }

    func textFildDidChanged(notification: Notification) {
        // 输入框类型 key
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField == self.textfieldForMoney {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: 8)
            chooseMoneyView.clearSelectedStatus()
            if let moneyNumber = Double(textField.text ?? "") {
                rechargeMoney = moneyNumber
            }
        }
    }

    /// 点击了确认按钮
    @IBAction func sureButtonTaped(_ sender: TSColorLumpButton) {
        // 收起键盘
        endEditing()
        guard let rechargeType = rechargeType else {
            TSLogCenter.log.debug("支付方式为 nil")
            return
        }
        guard let rechargeMoney = rechargeMoney else {
            TSLogCenter.log.debug("支付金额为 nil")
            return
        }
        // 计算出 CNY 分单位的金额数
        let moneyFen = Int(rechargeMoney * 100)
        // 禁用确认按钮
        sender.isUserInteractionEnabled = false
        // 2. 向后台获取支付凭证
        WalletNetworkManager.createRecharge(type: rechargeType.rawValue, amount: moneyFen, extra: nil) { [weak self] (status, message, dataString) in
            if rechargeType == .wx {
                guard let dataDic = dataString else {
                    // 异常情况，直接提示
                    let alert = TSIndicatorWindowTop(state: .faild, title: message)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    return
                }
                guard let payDic = dataDic["data"] as? Dictionary<String, Any> else {
                    // 异常情况，直接提示
                    let alert = TSIndicatorWindowTop(state: .faild, title: (message?.isEmpty)! ? "配置获取失败" : message)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    return
                }
                guard let appid = payDic["appid"] as? String, let partnerid = payDic["partnerid"] as? String, let prepayid = payDic["prepayid"] as? String,
                    let package = payDic["package"] as? String, let nonceStr = payDic["noncestr"] as? String, let timestamp = payDic["timestamp"] as? Int, let sign = payDic["sign"]  as? String else {
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
            } else {
                if status == true {
                    /// 注意：
                    /// 支付结果回调Block，用于wap支付结果回调（非跳转钱包支付）
                    /// 钱包的回调在appdelegate
                    let appURLScheme = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
                    UserDefaults.standard.setValue("wallet", forKey: "pay_type")
                    UserDefaults.standard.synchronize()
                    AlipaySDK.defaultService().payOrder(dataString?["data"] as? String, fromScheme: appURLScheme, callback: { (payBackInfo) in
                        let payBackInfoDic = payBackInfo! as NSDictionary
                        let appdelegate = UIApplication.shared.delegate as? AppDeleguate
                        appdelegate?.checkAlipayCharge(payBackInfoDic: payBackInfoDic as! Dictionary<String, String>)
                    })
                } else {
                    let alert = TSIndicatorWindowTop(state: .faild, title: message)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
        }
    }

    /// 支付校验回调
    func checkPayResultBack(noti: Notification) {
        guard let infoDic = noti.userInfo as? Dictionary<String, Any> else {
            TSLogCenter.log.debug("\n\n checkPayResultBack 信息为空")
            return
        }
        self.buttonForSure.isUserInteractionEnabled = true
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textfieldForMoney.endEditing(true)
        let cell = tableView.cellForRow(at: indexPath)
        // 1.点击了充值方式选择 cell
        if cell == rechargeTypeCell {
            let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
            for type in config.rechargeTypes {
                var title = ""
                switch type {
                case .alipay:
                    title = "支付宝支付"
                    alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                        self?.rechargeType = type
                        self?.rechargeTypeLabel.text = "支付宝充值"
                    }))
                case .wx:
                    if UIApplication.shared.canOpenURL(URL(string: "weixin://")!) == false {
                        title = "没有检测到微信客户端"
                        alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                            let errorAlert = TSIndicatorWindowTop(state: .faild, title: "没有检测到微信客户端")
                            errorAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                            self?.rechargeTypeLabel.text = "没有检测到微信客户端"
                            return
                        }))
                    } else {
                        title = "微信支付"
                        alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                            self?.rechargeType = type
                            self?.rechargeTypeLabel.text = "微信充值"
                        }))
                    }
                }
            }
            if !alert.actions.isEmpty {
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

    /// 检查确定按钮的状态
    func checkSureButtonStatus() {
        if rechargeMoney == nil || rechargeMoney == 0 {
            buttonForSure.isEnabled = false
            return
        }

        if rechargeType == nil {
            buttonForSure.isEnabled = false
            return
        }
        buttonForSure.isEnabled = true
    }
}

extension WalletRechargeController: LoadingViewDelegate {

    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }

    func reloadingButtonTaped() {
        loadData()
    }
}
