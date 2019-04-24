//
//  IntegrationCashController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  积分提现

import UIKit

class IntegrationCashController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    /// 小菊花
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var containerTop: NSLayoutConstraint!
    //积分规则按钮
    @IBOutlet weak var ruleButton: UIButton!
    var tableController: IntegrationCashTableController?

    class func vc() -> IntegrationCashController {
        let sb = UIStoryboard(name: "IntegrationCashController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! IntegrationCashController
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let table = segue.destination as? IntegrationCashTableController {
            tableController = table
        }
    }

    func loadData() {
        if TSAppConfig.share.localInfo.currencySetInfo != nil {
            self.indicator.isHidden = true
            self.tableController?.model = IntegrationCashModel(model: TSAppConfig.share.localInfo.currencySetInfo!)
        } else {
            indicator.startAnimating()
            TSRootViewController.share.updateLaunchConfigInfo { (status) in
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                if status == true {
                    if TSAppConfig.share.localInfo.currencySetInfo != nil {
                        self.tableController?.model = IntegrationCashModel(model: TSAppConfig.share.localInfo.currencySetInfo!)
                    }
                } else {
                    // 网络不可用
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_网络错误".localized)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
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
            self?.tableController?.model = IntegrationCashModel(model: netModel)
        }
        */
        titleLabel.text = String(format: "format提取".localized, TSAppConfig.share.localInfo.goldName)
        ruleButton.setTitle(String(format: "goldName提取规则".localized, TSAppConfig.share.localInfo.goldName), for: .normal)
    }

    // MARK: - Action

    /// 点击了返回按钮
    @IBAction func backButtonTaped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    /// 点击了提取记录按钮
    @IBAction func recordButtonTaped(_ sender: UIButton) {
        let recordVC = IntegrationCashRecordController(selectedIndex: 1)
        navigationController?.pushViewController(recordVC, animated: true)
    }

    /// 点击了积分提取规则按钮
    @IBAction func ruleButtonTaped(_ sender: UIButton) {
        let vc = RuleShowViewController()
        vc.ruleMarkdownStr = tableController?.model.rule ?? ""
        vc.title = "\(TSAppConfig.share.localInfo.goldName)提取规则"
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

class IntegrationCashTableController: UITableViewController {
    // 金币兑换描述
    @IBOutlet weak var goldRadioDesLabel: UILabel!
    /// 积分和 CNY 的转换比例展示板
    @IBOutlet weak var displayLabel: UILabel!
    /// 提示信息
    @IBOutlet weak var messageLabel: UILabel!
    /// 输入框
    @IBOutlet weak var textField: UITextField!
    /// 确认按钮
    @IBOutlet weak var sureButton: UIButton!

    var model = IntegrationCashModel() {
        didSet {
            loadModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // 添加点击手势，完成 "空白处点击关闭键盘效果"
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapGRProcess(_:)))
        self.tableView.backgroundView = UIView(frame: self.view.bounds)
        self.tableView.backgroundView?.addGestureRecognizer(tapGR)
        // 默认设置
        self.sureButton.isEnabled = false
        self.sureButton.layer.cornerRadius = 6
        self.sureButton.clipsToBounds = true
        self.sureButton.setBackgroundImage(UIImage(color: TSColor.button.normal), for: .normal)
        self.sureButton.setBackgroundImage(UIImage(color: TSColor.button.disabled), for: .disabled)
        goldRadioDesLabel.text = String(format: "兑换金额_比例描述".localized, TSAppConfig.share.localInfo.goldName)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        // 更新状态栏的颜色
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledValueChangedNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        // 更新状态栏的颜色
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    func setUI() {
        // 1.设置提示信息
        messageLabel.text = "输入需提取的\(TSAppConfig.share.localInfo.goldName)\n\n提取\(TSAppConfig.share.localInfo.goldName)须提交官方审核，审核反馈请关注系统消息！"
        // 2.设置输入框
        textField.layer.borderColor = UIColor(hex: 0xdedede).cgColor
        textField.layer.borderWidth = 0.5
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            let headerView = UIView(frame: CGRect(x: 0, y: -(TSLiuhaiHeight + 20), width: ScreenWidth, height: (TSLiuhaiHeight + 20)))
            headerView.backgroundColor = UIColor(hex: 0x8C8AD9)
            tableView.addSubview(headerView)
        }
    }

    func loadModel() {
        displayLabel.text = "\(model.ratio * 100)\(TSAppConfig.share.localInfo.goldName)=1元"
        textField.placeholder = "请至少提取\(model.cashMin)\(TSAppConfig.share.localInfo.goldName)"
    }

    // MARK: - Action

    /// 点击了确认按钮
    @IBAction func sureButtonTaped(_ sender: UIButton) {
        view.endEditing(true)
        guard let amount = Int(textField.text ?? "") else {
            let alert = TSIndicatorWindowTop(state: .faild, title: "请输入正确\(TSAppConfig.share.localInfo.goldName)数量")
            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            return
        }
        sender.isEnabled = false
        IntegrationNetworkManager.cash(amount: amount) { (message, status) in
            sender.isEnabled = true
            let alert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message ?? "")
            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }

    /// 点击手势处理
    @objc fileprivate func tapGRProcess(_ tapGR: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }

    // MARK: - Notification

    /// 输入框通知处理
    @objc fileprivate func textFiledValueChangedNotificationProcess(_ notification: Notification) -> Void {
        // 非titleField判断
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField != self.textField {
            return
        }
        // 根据输入框是否有值来确认按钮状态
        if textField.text == nil || textField.text == "" {
            self.sureButton.isEnabled = false
        } else {
            self.sureButton.isEnabled = true
        }
    }

}
