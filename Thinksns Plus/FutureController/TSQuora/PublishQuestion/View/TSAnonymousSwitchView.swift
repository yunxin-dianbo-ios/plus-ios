//
//  TSanonymousSwitchView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 05/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  匿名开关视图，用于：问题详情页底部 + 问题详情页中的键盘部分

import UIKit

class TSAnonymousSwitchView: UIView {

    // MARK: - Internal Property
    static let defaultH: CGFloat = 50
    private(set) weak var promptLabel: UILabel!
    private(set) weak var switchView: UISwitch!

    // MARK: - Internal Function

    // MARK: - Private Property

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        let leftMargin: CGFloat = 20
        let rightMargin: CGFloat = 10

        // 1. promptLabel
        let promptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        self.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(leftMargin)
        }
        self.promptLabel = promptLabel
        // 2. switch
        let switchView = UISwitch()
        self.addSubview(switchView)
        switchView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-rightMargin)
        }
        self.switchView = switchView
        // 3. line
        self.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        self.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        // 4. Localized
        promptLabel.text = "启用匿名"//"显示_匿名提问".localized
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
