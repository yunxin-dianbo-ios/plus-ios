//
//  TSToApplicationSelectDayOrPriceView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
/// 选择天数【或者】金额

import UIKit

protocol btnTapDelegate: NSObjectProtocol {
    /// 代理，返回点击的btn
    /// - 因为感觉都是1天、5天、10天或者1元、5元、10元，所以默认点击返回Int传入就是1、5、10
    /// - 为了表示重置页面操作,返回传入Int为nil
    /// - Parameter returnedInt: 返回传入的Int.
    func btnTap(returnedInt: Int?)
}

class TSToApplicationSelectDayOrPriceView: UIView {
    var hasItemChoosed: Bool = false
    var tipsLabelStr: String = ""
    var btnName: Array<String> = []
    // 按钮
    var btnFirst: TSButton = TSButton(type: .custom)
    var btnSecond: TSButton = TSButton(type: .custom)
    var btnThird: TSButton = TSButton(type: .custom)

    weak var btnTapDelegate: btnTapDelegate? = nil

    /// 构造器，
    ///
    /// - Parameters:
    ///   - frame: 传入整个视图大小
    ///   - tipsLabelStr: 传入btn上方提示文字
    ///   - btnName: 传入想要btn显示的字符串【数组】
    init(frame: CGRect, tipsLabelStr: String, btnName: Array<String>) {
        super.init(frame: frame)
        self.tipsLabelStr = tipsLabelStr
        self.btnName = btnName
        self.backgroundColor = TSColor.main.white
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        let tipLabel = UILabel()
        tipLabel.text = tipsLabelStr
        tipLabel.textColor = TSColor.normal.minor
        tipLabel.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(14)
            make.top.equalTo(self).offset(19.5)
            make.width.equalTo(105)
            make.height.equalTo(12.5)
        }

        bntSet(bnt: btnFirst, bntReturnedInt: 1, btnName: btnName[0])
        bntSet(bnt: btnSecond, bntReturnedInt: 5, btnName: btnName[1])
        bntSet(bnt: btnThird, bntReturnedInt: 10, btnName: btnName[2])

        btnFirst.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.top.equalTo(self).offset(46.5)
            make.bottom.equalTo(self).offset(-20)
            make.right.equalTo(btnSecond.snp.left).offset(-15)
        }
        btnSecond.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(btnFirst)
            make.right.equalTo(btnThird.snp.left).offset(-15)
        }
        btnThird.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(btnFirst)
            make.right.equalTo(self).offset(-15)
        }
    }

    func bntSet(bnt: TSButton, bntReturnedInt: Int, btnName: String) {
        bnt.tag = bntReturnedInt
        bnt.addTarget(self, action: #selector(buttonTaped(_:)), for: .touchUpInside)
        bnt.setTitle(btnName, for: .normal)
        bnt.setTitleColor(TSColor.main.content, for: .normal)
        bnt.backgroundColor = TSColor.main.white
        bnt.clipsToBounds = true
        bnt.layer.cornerRadius = 6
        bnt.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
        bnt.layer.borderWidth = 1
        self.addSubview(bnt)
    }
    func buttonTaped(_ bnt: TSButton) {
        let returnedInt = bnt.tag
        self.btnTapDelegate?.btnTap(returnedInt: returnedInt)
        let bntArry: Array<TSButton> = [btnFirst, btnSecond, btnThird]
        for index in bntArry {
            if index.tag == bnt.tag {
                index.setTitleColor(TSColor.main.theme, for: .normal)
                index.layer.borderColor = TSColor.main.theme.cgColor
            } else {
                index.setTitleColor(TSColor.main.content, for: .normal)
                index.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
            }
        }
        hasItemChoosed = true
    }

    /// 重置操作
    public func resetAll() {
        let bntArry: Array<TSButton> = [btnFirst, btnSecond, btnThird]
        for index in bntArry {
            index.setTitleColor(TSColor.main.content, for: .normal)
            index.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
        }
        self.hasItemChoosed = false
        self.btnTapDelegate?.btnTap(returnedInt: nil)
    }

}
