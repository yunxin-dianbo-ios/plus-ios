//
//  TSOfferRewardRulePopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  悬赏规则弹窗

import UIKit

class TSOfferRewardRulePopView: UIView {

    // MARK: - Internal Property
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
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        // 2. offerRewardRuleView
        let ruleView = UIView()
        coverBtn.addSubview(ruleView)
        self.initialRuleView(ruleView)
        ruleView.snp.makeConstraints { (make) in
            make.center.equalTo(coverBtn)
            make.width.equalTo(250)
        }
    }
    /// 悬赏规则视图布局
    private func initialRuleView(_ ruleView: UIView) -> Void {
        let leftMargin: CGFloat = 25
        let rightMargin: CGFloat = 25
        let topH: CGFloat = 55
        let bottomH: CGFloat = 50
        let contentTopMargin: CGFloat = 10
        let contentBottomMargin: CGFloat = 10
        // 0. ruleView
        ruleView.backgroundColor = UIColor.white
        ruleView.clipsToBounds = true
        ruleView.layer.cornerRadius = 5
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        ruleView.addSubview(titleLabel)
        titleLabel.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 25, margin2: 25)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(ruleView)
            make.height.equalTo(topH)
            make.leading.trailing.top.equalTo(ruleView)
        }
        // 3. doneBtn
        let doneBtn = UIButton(type: .custom)
        ruleView.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(doneBtnClick(_:)), for: .touchUpInside)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneBtn.setTitleColor(TSColor.main.theme, for: .normal)
        doneBtn.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: leftMargin, margin2: rightMargin)
        doneBtn.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(ruleView)
            make.height.equalTo(bottomH)
        }
        // 2. contentLabel
        let contentLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content)
        ruleView.addSubview(contentLabel)
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(ruleView).offset(leftMargin)
            make.trailing.equalTo(ruleView).offset(-rightMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(contentTopMargin)
            make.bottom.equalTo(doneBtn.snp.top).offset(-contentBottomMargin)
        }
        // 4. Localized        
        titleLabel.text = "显示_悬赏规则".localized
        doneBtn.setTitle("显示_知道了".localized, for: .normal)
        contentLabel.text = "\(TSAppConfig.share.localInfo.reward_rule)"
    }

    // MARK: - Private  事件响应

    /// 遮罩点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
    }
    /// 确定按钮点击响应
    @objc private func doneBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
    }
}
