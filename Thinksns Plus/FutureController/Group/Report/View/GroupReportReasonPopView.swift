//
//  GroupReportReasonPopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报原因弹窗界面
//  应该考虑弹窗提示界面的统一、通用

import UIKit

class GroupReportReasonPopView: UIView {

    // MARK: - Internal Property
    var reason: String? {
        didSet {
            self.contentLabel.text = reason
        }
    }
    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate weak var titleLabel: UILabel!
    fileprivate weak var contentLabel: UILabel!
    fileprivate weak var doneBtn: UIButton!

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
        // 2. promptView
        let promptView = UIView()
        coverBtn.addSubview(promptView)
        self.initialPromptView(promptView)
        promptView.snp.makeConstraints { (make) in
            make.center.equalTo(coverBtn)
            make.width.equalTo(250)
        }
    }
    /// 悬赏规则视图布局
    private func initialPromptView(_ promptView: UIView) -> Void {
        let leftMargin: CGFloat = 25
        let rightMargin: CGFloat = 25
        let topH: CGFloat = 55
        let bottomH: CGFloat = 50
        let contentTopMargin: CGFloat = 10
        let contentBottomMargin: CGFloat = 10
        // 0. promptView
        promptView.backgroundColor = UIColor.white
        promptView.clipsToBounds = true
        promptView.layer.cornerRadius = 5
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        promptView.addSubview(titleLabel)
        titleLabel.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 25, margin2: 25)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(promptView)
            make.height.equalTo(topH)
            make.leading.trailing.top.equalTo(promptView)
        }
        self.titleLabel = titleLabel
        // 3. doneBtn
        let doneBtn = UIButton(type: .custom)
        promptView.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(doneBtnClick(_:)), for: .touchUpInside)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneBtn.setTitleColor(TSColor.main.theme, for: .normal)
        doneBtn.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: leftMargin, margin2: rightMargin)
        doneBtn.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(promptView)
            make.height.equalTo(bottomH)
        }
        self.doneBtn = doneBtn
        // 2. contentLabel
        let contentLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content)
        promptView.addSubview(contentLabel)
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(promptView).offset(leftMargin)
            make.trailing.equalTo(promptView).offset(-rightMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(contentTopMargin)
            make.bottom.equalTo(doneBtn.snp.top).offset(-contentBottomMargin)
        }
        self.contentLabel = contentLabel
        // 4. Localized
        titleLabel.text = "举报原因".localized
        doneBtn.setTitle("关闭".localized, for: .normal)
        contentLabel.text = "我的写作目标是内容完整、脉络清晰、通俗易懂，帮助初学者看清技术路径，快速入门。难度为入门级，不涉及深入的细节，重在理解各种技术想要解决的问题，掌握基本用法，为进一步自学打下基础。"
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
