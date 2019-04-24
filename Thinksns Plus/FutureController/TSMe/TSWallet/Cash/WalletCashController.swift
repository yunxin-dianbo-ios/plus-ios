//
//  TSWithdrawMoneyVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  提现 视图控制器

import UIKit

class WalletCashController: UITableViewController {

    /// 选择提现方式 cell
    @IBOutlet weak var cashTypeCell: UITableViewCell!
    /// 最低提现金额提示信息
    @IBOutlet weak var labelForSuggest: UILabel!
    /// 提现账户输入框
    @IBOutlet weak var textfieldForAccount: UITextField!
    /// 确认按钮
    @IBOutlet weak var buttonForSure: TSColorLumpButton!
    /// 提现金额输入框
    @IBOutlet weak var textfieldForMoney: UITextField!
    /// 提现明细按钮
    let rightBarButton = UIButton(type: .custom)
    /// 金额名称
    @IBOutlet weak var goldNameLabel: UILabel!
    /// 充值方式
    @IBOutlet weak var rechargeTypeLabel: UILabel!
    /// 提现配置
    var config = WalletCashModel() {
        didSet {
            labelForSuggest.text = "最低提现金额：\(config.cashMin)元"
        }
    }

    /// 提现方式
    var cashType: WalletCashType? {
        didSet {
            checkSureButtonStatus()
        }
    }
    /// 提现账户
    var cashAccount: String? {
        didSet {
            checkSureButtonStatus()
        }
    }
    /// 提现金额
    var cashMoney: Double? {
        didSet {
            checkSureButtonStatus()
        }
    }

    // MARK: - Lifecycle
    class func vc() -> WalletCashController {
        let sb = UIStoryboard(name: "WalletCashController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! WalletCashController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
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

    // MAKR: - UI

    func loadData() {
        if TSAppConfig.share.localInfo.walletSetInfo != nil {
            self.endLoading()
            self.config = WalletCashModel(model: TSAppConfig.share.localInfo.walletSetInfo!)
        } else {
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                if status == true {
                    if TSAppConfig.share.localInfo.walletSetInfo != nil {
                        self.endLoading()
                        self.config = WalletCashModel(model: TSAppConfig.share.localInfo.walletSetInfo!)
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
            self?.endLoading()
            self?.config = WalletCashModel(model: model)
        }
        */
    }

    func setUI() {
        title = "显示_提现".localized
        buttonForSure.sizeType = .large

        // 导航栏右方按钮
        rightBarButton.setTitle("显示_提现明细".localized, for: .normal)
        rightBarButton.setTitleColor(TSColor.main.theme, for: .normal)
        rightBarButton.sizeToFit()
        rightBarButton.addTarget(self, action: #selector(rightBarButtonTaped), for: .touchUpInside)
        rightBarButton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.rechargeTypeLabel.textColor = TSColor.normal.minor
    }

    // MARK: - Button click

    /// 点击了确认按钮
    @IBAction func sureButtonTaped(_ sender: TSColorLumpButton) {
        // 收起键盘
        textfieldForAccount.endEditing(true)
        textfieldForMoney.endEditing(true)
        guard let cashType = cashType else {
            return
        }
        guard let cashAccount = cashAccount else {
            return
        }
        guard let cashMoney = cashMoney else {
            return
        }

        let moneyFen = Int(cashMoney * 100)
        // 显示记载中的弹窗
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "显示_提现中".localized)
        loadingAlert.show()
        // 禁用确定按钮
        sender.isUserInteractionEnabled = false
        WalletNetworkManager.createCash(value: moneyFen, type: cashType.rawValue, account: cashAccount) { [weak self] (result, message, model) in
            // 启用确定按钮
            sender.isUserInteractionEnabled = true
            // 隐藏加载中弹窗
            loadingAlert.dismiss()
            if self != nil {
                // 显示结果弹窗
                var messageString = result ? "显示_提现成功".localized : "显示_提现失败".localized
                if let message = message {
                    messageString = messageString + "，" + message
                }
                if let modelMessage = model?.getOneMessage() {
                    messageString = messageString + "，" + modelMessage
                }
                let alert = TSIndicatorWindowTop(state: result ? .success : .faild, title: messageString)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 点击了提现明细按钮
    func rightBarButtonTaped() {
        let transition = TSWithdrawMoneyTransitionVC(style: .plain)
        navigationController?.pushViewController(transition, animated: true)
    }

    // MARK: - Private

    /// 检测输入框的输入状态，判断登录按钮的点击状态
    func textFiledDidChanged(notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField == textfieldForMoney {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: 8)
            cashMoney = Double(textField.text ?? "")
        }
        if textField == textfieldForAccount {
            cashAccount = textField.text
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == cashTypeCell {
            // 点击了 "选择支付方式"
            let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
            for type in config.cashTypes {
                var title = ""
                switch type {
                case .alipay:
                    title = "支付宝提现"
                case .wechat:
                    title = "微信提现"
                }
                alert.addAction(TSAlertAction(title: title, style: .default, handler: { [weak self] (_) in
                    self?.cashType = type
                    self?.rechargeTypeLabel.text = (self?.cashType == .wechat) ? "微信提现" : "支付宝提现"
                }))
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
        if cashMoney == nil || cashMoney == 0 {
            buttonForSure.isEnabled = false
            return
        }

        if cashType == nil {
            buttonForSure.isEnabled = false
            return
        }

        if cashAccount == nil {
            buttonForSure.isEnabled = false
            return
        }
        buttonForSure.isEnabled = true
    }
}

extension WalletCashController: LoadingViewDelegate {

    func reloadingButtonTaped() {
        loadData()
    }

    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}
