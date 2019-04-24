//
//  TSUserCustomizeTheAmountView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户自定义金额,带显示总结金额(bool)

import UIKit

protocol userInputDelegate: NSObjectProtocol {
    /// 返回用户输入字符串
    /// - 返回的字符串会过滤一次。见textFieldChange方法
    /// - Parameter input: 输入的字符串
    func userInput(input: String?)
}

class TSUserCustomizeTheAmountView: UIView {
    var lumpSumBool = false
    var moneyTitleStr = ""
    // 屏幕宽度
    let mainwidth = UIScreen.main.bounds.width
    /// 输入金额textfield
    public var userInputMoney: UITextField!
    /// 总金额label
    var lumpSumLabel: TSLabel = TSLabel()
    /// 金额单位Label
    var unitLabel: UILabel = UILabel()
    fileprivate let moneyUnit: String

    weak var userInputDelegate: userInputDelegate? = nil
    init(frame: CGRect, moneyTitle: String, lumpSum: Bool, moneyUnit: String = TSAppConfig.share.localInfo.goldName) {
        self.moneyUnit = moneyUnit
        super.init(frame: frame)
        self.moneyTitleStr = moneyTitle
        self.lumpSumBool = lumpSum
        self.backgroundColor = TSColor.main.white
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        let userCustomizeMoneyView = UIView()
        userCustomizeMoneyView.backgroundColor = UIColor.clear
        self.addSubview(userCustomizeMoneyView)
        userCustomizeMoneyView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.height.equalTo(50)
        }
        let userCustomizeMoneytitle = UILabel()
        userCustomizeMoneytitle.text = moneyTitleStr
        userCustomizeMoneytitle.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        userCustomizeMoneyView.addSubview(userCustomizeMoneytitle)
        userCustomizeMoneytitle.snp.makeConstraints { (make) in
            make.centerY.equalTo(userCustomizeMoneyView)
            make.left.equalTo(userCustomizeMoneyView).offset(14)
            make.width.equalTo(100)
        }

        let yuan = self.unitLabel
        yuan.text = self.moneyUnit
        yuan.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        let yuanSize = self.moneyUnit.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue))
        userCustomizeMoneyView.addSubview(yuan)
        yuan.snp.makeConstraints { (make) in
            make.centerY.equalTo(userCustomizeMoneyView)
            make.width.equalTo(yuanSize.width + 5)              // width 多给5，则右侧间距少5
            make.right.equalTo(userCustomizeMoneyView.snp.right).offset(-10)
        }

        userInputMoney = UITextField()
        userInputMoney.placeholder = "占位符_请输入数量".localized
        userInputMoney.text = "0"
        userInputMoney.keyboardType = .numberPad
        userInputMoney.textAlignment = .right
        userInputMoney.textColor = TSColor.normal.blackTitle
        userInputMoney.font = UIFont.systemFont(ofSize: 15)
        userInputMoney.addTarget(self, action: #selector(textFieldChange(_:)), for: .allEditingEvents)
        userCustomizeMoneyView.addSubview(userInputMoney)
        userInputMoney.snp.makeConstraints { (make) in
            make.right.equalTo(yuan.snp.left).offset(-10)
            make.left.equalTo(userCustomizeMoneytitle.snp.right).offset(9)
            make.centerY.equalTo(userCustomizeMoneytitle.snp.centerY)
        }
        if lumpSumBool {
            let lumpSumView = UIView()
            lumpSumView.backgroundColor = TSColor.main.white
            self.addSubview(lumpSumView)
            lumpSumView.snp.makeConstraints { (make) in
                make.top.equalTo(userCustomizeMoneyView.snp.bottom)
                make.width.height.left.equalTo(userCustomizeMoneyView)
            }
            let lumpSumTitle = UILabel()
            lumpSumTitle.text = "显示_共需积分".localized
            lumpSumTitle.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
            lumpSumView.addSubview(lumpSumTitle)
            lumpSumTitle.snp.makeConstraints { (make) in
                make.top.equalTo(lumpSumView).offset(17.5)
                make.left.equalTo(lumpSumView).offset(14)
                make.width.equalTo(90)
                make.height.equalTo(14)
            }
            let lumpSumYuan = UILabel()
            lumpSumYuan.text = TSAppConfig.share.localInfo.goldName
            lumpSumYuan.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
            lumpSumView.addSubview(lumpSumYuan)
            lumpSumYuan.snp.makeConstraints { (make) in
                make.centerY.equalTo(lumpSumView)
                make.width.height.equalTo( yuanSize.width + 5)   // width 多给5，则右侧间距少5
                make.right.equalTo(lumpSumView.snp.right).offset(-10)
            }
            lumpSumLabel = TSLabel()
            lumpSumLabel.text = ""
            lumpSumLabel.textAlignment = .right
            lumpSumLabel.textColor = TSColor.normal.disabled
            lumpSumLabel.font = UIFont.systemFont(ofSize: 15)
            lumpSumLabel.lineBreakMode = .byTruncatingMiddle
            lumpSumView.addSubview(lumpSumLabel)
            lumpSumLabel.snp.makeConstraints { (make) in
                make.top.height.equalTo(lumpSumTitle)
                make.right.equalTo(lumpSumYuan.snp.left).offset(-9)
                make.left.equalTo(lumpSumTitle.snp.right).offset(9)
            }
            let lineview = UIView(frame: CGRect(x: 15, y: 0, width: mainwidth - 30, height: 0.5))
            lineview.backgroundColor = TSColor.normal.disabled
            lumpSumView.addSubview(lineview)
        }
    }

    /// 过滤textField输入字符串，做返回处理
    /// - 字符串首字符为0，点击textfield第一次获得的""，以及非数字字符，代理返回为nil
    /// - 满足👆条件情况下，字符数大于8删除首字符（因为是做金额计算，不做限制会出bug）
    /// - Parameter changetext: 变动的textfield
    func textFieldChange(_ changetext: UITextField) {
        var str = changetext.text!
        if str.first != "0" && str != "" && TSAccountRegex.isPayMoneyFormat(str) {
            if (changetext.text?.count)! > 8 {
                str = str.substring(to: str.index(before: str.endIndex))
                changetext.text = str
            }
            self.userInputDelegate?.userInput(input: changetext.text)
        } else if str == "0" {
            // 需求：可以输入0积分
            self.userInputDelegate?.userInput(input: changetext.text)
        } else {
            changetext.text = nil
            self.userInputDelegate?.userInput(input: nil)
        }
    }
}
