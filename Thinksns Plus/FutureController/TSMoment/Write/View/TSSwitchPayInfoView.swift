//
//  TSSwitchPayInfoView.swift
//  ThinkSNS +
//
//  Created by lip on 2017/7/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

protocol TSSwitchPayInfoViewDelegate: class {
    func paySwitchValueChanged(_ paySwitch: UISwitch)
    func fieldBeginEditing() -> Void
    func fieldEndEditing() -> Void
}
extension TSSwitchPayInfoViewDelegate {
    func fieldBeginEditing() -> Void {
    }
    func fieldEndEditing() -> Void {
    }
}

class TSSwitchPayInfoView: UIView {
    // MARK: - 
    /// 是否隐藏更多信息
    var isHiddenMoreInfo: Bool = false
    /// 是否开启了收费开关
    var paySwitchIsOn: Bool {
        return self.paySwitch.isOn
    }
    /// 配置后的支付价格
    var payPrice: Int = 0
    /// 代理
    weak var delegate: TSSwitchPayInfoViewDelegate?
    // MARK: - ui
    // MARK: 开关容器
    /// 开关容器视图
    private weak var switchContentView: UIView!
    // 开关容器视图的顶部线条
    private weak var topLine: UIView!
    /// 开关容器内的信息标签
    private weak var switchInfoLabel: UILabel!
    /// 开关容器内的开关
    weak var paySwitch: UISwitch!
    // 开关容器视图的低部线条
    private weak var bottomLine: UIView!
    // MARK: 支付详细配置
    /// 支付详情容器视图
    private weak var detailContentView: UIView!
    /// 支付详细配置
    private weak var settingInfoLabel: UILabel!
    /// 支付按钮组
    private var payMentBtns: Array<UIButton>!
    /// 中间的线条
    private weak var midLine: UIView!
    /// 底部的线条
    private weak var footLine: UIView!
    /// 详情内输入框提示标签
    private weak var promptLeftInfoLabel: UILabel!
    /// 详情内输入框提示标签
    private weak var promptRightInfoLabel: UILabel!
    /// 金额输入框
    private(set) weak var priceTextField: UITextField!
    /// 备注信息
    private weak var remarkLabel: UILabel!

    // MARK: - lifecycle
    init() {
        super.init(frame: CGRect.zero)
        self.createUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.createUI()
    }

    // MARK: - func
    func priceTextFieldResignFirstResponder() {
        priceTextField.resignFirstResponder()
    }

    @objc private func paySwitchValueChanged(_ paySwitch: UISwitch) {
        priceTextFieldResignFirstResponder()
        delegate?.paySwitchValueChanged(paySwitch)
        guard isHiddenMoreInfo == false else {
            return
        }
        payPrice = 0
        for btn in payMentBtns {
            btn.isEnabled = true
            btn.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
        }
        detailContentView.isHidden = !paySwitch.isOn
        bottomLine.isHidden = paySwitch.isOn
    }

    @objc private func priceBtnTaped(_ priceBtn: UIButton) {
        priceTextFieldResignFirstResponder()
        if priceTextField.text != nil {
            priceTextField.text = nil
        }
        for (index, btn) in payMentBtns.enumerated() {
            btn.isEnabled = true
            btn.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
            if priceBtn == btn {
                payPrice = TSAppConfig.share.localInfo.feedItems[index]
            }
        }
        priceBtn.isEnabled = false
        priceBtn.layer.borderColor = TSColor.main.theme.cgColor
    }

    @objc private func userInputPrice(_ priceTextField: UITextField) {
        let str: String = priceTextField.text ?? "0"
        if str.isEmpty == false {
            TSAccountRegex.checkAndUplodTextFieldText(textField: priceTextField, stringCountLimit: 8)
            payPrice = Int(str)!
            for btn in payMentBtns {
                btn.isEnabled = true
                btn.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
            }
            if str.first == "0" || !TSAccountRegex.isPayMoneyFormat(str) {
                payPrice = 0
                priceTextField.text = nil
            }
        }
    }

    // MARK: - init and layout
    override func layoutSubviews() {
        super.layoutSubviews()
        switchContentView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
        topLine.snp.makeConstraints { (line) in
            line.height.equalTo(0.5)
            line.top.equalTo(switchContentView.snp.top)
            line.left.equalTo(switchContentView.snp.left)
            line.right.equalTo(switchContentView.snp.right)
        }
        switchInfoLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(switchContentView.snp.centerY)
            make.left.equalTo(switchContentView.snp.left).offset(25)
        }
        paySwitch.snp.makeConstraints { (make) in
//            make.height.equalTo(switchContentView.snp.height)
            make.centerY.equalTo(switchContentView.snp.centerY)
            make.right.equalTo(switchContentView.snp.right).offset(-11.5)
        }
        bottomLine.snp.makeConstraints { (line) in
            line.height.equalTo(0.5)
            line.bottom.equalTo(switchContentView.snp.bottom)
            line.left.equalTo(switchContentView.snp.left)
            line.right.equalTo(switchContentView.snp.right)
        }

        detailContentView.snp.makeConstraints { (make) in
            make.top.equalTo(switchContentView.snp.bottom)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        settingInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(detailContentView.snp.top).offset(19)
            make.left.equalTo(detailContentView.snp.left).offset(15)
        }
        for (index, btn) in payMentBtns.enumerated() {
            let btnWidth = (ScreenSize.ScreenWidth - CGFloat(payMentBtns.count + 1) * 15 ) / CGFloat(payMentBtns.count)
            let btnLeftSpace = CGFloat(index) * btnWidth + 15 * CGFloat(index + 1)
            btn.snp.makeConstraints({ (make) in
                make.top.equalTo(detailContentView.snp.top).offset(46.5)
                make.size.equalTo(CGSize(width: btnWidth, height: 35))
                make.left.equalTo(detailContentView.snp.left).offset(btnLeftSpace)
            })
        }
        midLine.snp.makeConstraints { (line) in
            line.top.equalTo(detailContentView.snp.top).offset(101.5)
            line.left.equalToSuperview()
            line.right.equalToSuperview()
            line.height.equalTo(0.5)
        }
        footLine.snp.makeConstraints { (line) in
            line.top.equalTo(midLine.snp.bottom).offset(49.5)
            line.left.equalToSuperview()
            line.right.equalToSuperview()
            line.height.equalTo(0.5)
        }
        promptLeftInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(detailContentView).offset(17.5 + 102)
            make.left.equalTo(detailContentView).offset(15)
        }
        promptRightInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(promptLeftInfoLabel)
            make.height.equalTo(14)
            make.right.equalTo(detailContentView.snp.right).offset(-15.5)
        }
        priceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(promptLeftInfoLabel.snp.top).offset(-2)
            make.right.equalTo(promptRightInfoLabel.snp.left).offset(-9)
            make.left.equalTo(promptLeftInfoLabel.snp.right).offset(9)
        }
        remarkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(footLine.snp.bottom).offset(15)
            make.left.equalTo(detailContentView).offset(15)
        }
    }

    private func createUI() {
        // 开关容器视图
        let switchContentView = UIView()
        switchContentView.backgroundColor = UIColor.white
        self.switchContentView = switchContentView

        // 顶部线条
        let topLine = UIView()
        topLine.backgroundColor = TSColor.inconspicuous.disabled
        self.topLine = topLine

        // 开关信息标签
        let switchInfoLabel = UILabel()
        switchInfoLabel.text = "是否收费"
        switchInfoLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        switchInfoLabel.textColor = TSColor.normal.blackTitle
        self.switchInfoLabel = switchInfoLabel

        // 开关
        let paySwitch = UISwitch()
        paySwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        paySwitch.isOn = false
        paySwitch.addTarget(self, action: #selector(paySwitchValueChanged(_:)), for: .valueChanged)
        self.paySwitch = paySwitch

        // 顶部线条
        let bottomLine = UIView()
        bottomLine.backgroundColor = TSColor.inconspicuous.disabled
        self.bottomLine = bottomLine

        self.addSubview(switchContentView)
        switchContentView.addSubview(topLine)
        switchContentView.addSubview(switchInfoLabel)
        switchContentView.addSubview(paySwitch)
        switchContentView.addSubview(bottomLine)

        // 支付详情容器视图
        let detailContentView = UIView()
        detailContentView.isHidden = true
        switchContentView.backgroundColor = UIColor.white
        self.detailContentView = detailContentView

        // 支付详细配置标签
        let settingInfoLabel = UILabel()
        settingInfoLabel.text = "设置文字收费金额"
        settingInfoLabel.textColor = TSColor.normal.minor
        settingInfoLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.settingInfoLabel = settingInfoLabel

        // 支付按钮
        payMentBtns = [UIButton]()
        for price in TSAppConfig.share.localInfo.feedItems {
            payMentBtns.append(self.custom(pricebtn: "\(price)"))
        }

        // 中间的线条
        let midLine = UIView()
        midLine.backgroundColor = TSColor.inconspicuous.disabled
        self.midLine = midLine

        // 底部的线条
        let footLine = UIView()
        footLine.backgroundColor = TSColor.inconspicuous.disabled
        self.footLine = footLine

        // 详情内输入框提示标签
        let promptLeftInfoLabel = UILabel()
        promptLeftInfoLabel.text = "自定义金额"
        promptLeftInfoLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        promptLeftInfoLabel.textColor = TSColor.normal.blackTitle
        self.promptLeftInfoLabel = promptLeftInfoLabel

        // 详情内输入框提示标签
        let promptRightInfoLabel = UILabel()
        promptRightInfoLabel.text = TSAppConfig.share.localInfo.goldName
        promptRightInfoLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        promptRightInfoLabel.textColor = TSColor.normal.blackTitle
        self.promptRightInfoLabel = promptRightInfoLabel

        // 金额输入框
        let priceTextField = UITextField()
        priceTextField.placeholder = "输入金额"
        priceTextField.keyboardType = .numberPad
        priceTextField.textAlignment = .right
        priceTextField.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        priceTextField.textColor = TSColor.normal.blackTitle
        priceTextField.delegate = self
        priceTextField.addTarget(self, action: #selector(userInputPrice(_:)), for: .allEditingEvents)
        self.priceTextField = priceTextField

        // 备注信息
        let remarkLabel = UILabel()
        remarkLabel.textColor = TSColor.normal.minor
        remarkLabel.text = "注：超过" + "\(TSAppConfig.share.localInfo.feedLimit)" + "字部分内容收费"
        remarkLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.remarkLabel = remarkLabel

        self.addSubview(detailContentView)
        detailContentView.addSubview(settingInfoLabel)
        for btn in payMentBtns {
            detailContentView.addSubview(btn)
        }
        detailContentView.addSubview(midLine)
        detailContentView.addSubview(footLine)
        detailContentView.addSubview(promptLeftInfoLabel)
        detailContentView.addSubview(promptRightInfoLabel)
        detailContentView.addSubview(priceTextField)
        detailContentView.addSubview(remarkLabel)
    }

    private func custom(pricebtn withPrice: String) -> UIButton {
        let priceBtn = UIButton(type: .custom)
        priceBtn.addTarget(self, action: #selector(priceBtnTaped(_:)), for: .touchUpInside)
        priceBtn.setTitle(withPrice, for: .normal)
        priceBtn.setTitleColor(TSColor.normal.blackTitle, for: .normal)
        priceBtn.setTitleColor(TSColor.main.theme, for: .disabled)
        priceBtn.setTitleColor(TSColor.normal.blackTitle, for: .normal)
        priceBtn.setTitleColor(TSColor.main.theme, for: .disabled)
        priceBtn.backgroundColor = TSColor.main.white
        priceBtn.clipsToBounds = true
        priceBtn.layer.cornerRadius = 6
        priceBtn.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
        priceBtn.layer.borderWidth = 0.5
        return priceBtn
    }
}

extension TSSwitchPayInfoView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.fieldBeginEditing()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.fieldEndEditing()
    }
}
