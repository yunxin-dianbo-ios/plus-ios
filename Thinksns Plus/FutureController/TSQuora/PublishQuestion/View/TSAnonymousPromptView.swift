//
//  TSAnonymousPromptView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 06/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  匿名提示视图
//  主要是用在TSAnonymousPromptPopView中，也可单独使用
//  注1：关于响应方式，既可以使用代理，也可以使用必包回调，还可以重新给控件添加响应。
//  注2：外界使用时需宽度进行约束

import UIKit

protocol TSAnonymousPromptViewProtocol: class {
    /// 取消按钮点击响应
    func didCancelBtnClickInAnonymousPromptView(_ promptView: TSAnonymousPromptView) -> Void
    /// 确认按钮点击响应
    func didConfirmBtnClickInAnonymousPromptView(_ promptView: TSAnonymousPromptView) -> Void
}

class TSAnonymousPromptView: UIView {

    // MARK: - Internal Property
    /// 回调响应
    weak var delegate: TSAnonymousPromptViewProtocol?
    var cancelBtnClickAction: ((_ promptView: TSAnonymousPromptView) -> Void)?
    var confirmBtnClickAction: ((_ promptView: TSAnonymousPromptView) -> Void)?

    /// 取消按钮
    private(set) weak var cancelBtn: UIButton!
    /// 确认按钮
    private(set) weak var confirmBtn: UIButton!
    private(set) weak var titlelabel: UILabel!
    private(set) weak var contentLabel: UILabel!

    // MARK: - Internal Function

    // MARK: - Private Property
    private let bottomTagBase: Int = 250

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
        //fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        let topH: CGFloat = 55
        let bottomH: CGFloat = 40
        let lrMargin: CGFloat = 25
        let contentTopMargin: CGFloat = 10
        let contentBottomMargin: CGFloat = 10
        // 0. self
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.white
        // 注：关于titleLabel和contentLabel是否需要放到view中，可行也可不用，代码布局可不用，若xib布局则必须，便于扩展
        // 1. topView
        let titleLabel = UILabel(text: "启用匿名", font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(topH)
        }
        titleLabel.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: lrMargin, margin2: lrMargin)
        self.titlelabel = titleLabel
        // 3. bottomView
        let bottomView = UIView()
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(bottomH)
        }
        // 3.x separateLine + cancelBtn + confirmBtn
        let titles = ["取消", "确定"]
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            bottomView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.setTitleColor(TSColor.button.normal, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
            button.tag = self.bottomTagBase + index
            button.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(bottomView)
                make.width.equalTo(bottomView).multipliedBy(0.5)
                if 0 == index {
                    make.leading.equalTo(bottomView)
                } else {
                    make.trailing.equalTo(bottomView)
                }
            })
        }
        bottomView.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        let separateLine = UIView(bgColor: TSColor.normal.disabled)
        bottomView.addSubview(separateLine)
        separateLine.snp.makeConstraints { (make) in
            make.width.equalTo(0.5)
            make.centerX.equalTo(bottomView)
            make.top.bottom.equalTo(bottomView)
        }
        self.cancelBtn = bottomView.viewWithTag(self.bottomTagBase + 0) as! UIButton
        self.confirmBtn = bottomView.viewWithTag(self.bottomTagBase + 1) as! UIButton
        // 2. contentView
        let contentLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content)
        self.addSubview(contentLabel)
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(lrMargin)
            make.trailing.equalTo(self).offset(-lrMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(contentTopMargin)
            make.bottom.equalTo(bottomView.snp.top).offset(-contentBottomMargin)
        }
        self.contentLabel = contentLabel
        contentLabel.text = TSAppConfig.share.localInfo.quoraAnonymityRule
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 按钮点击响应
    @objc private func bottomBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - self.bottomTagBase
        switch index {
        case 0:
            self.delegate?.didCancelBtnClickInAnonymousPromptView(self)
            self.cancelBtnClickAction?(self)
        case 1:
            self.delegate?.didConfirmBtnClickInAnonymousPromptView(self)
            self.confirmBtnClickAction?(self)
        default:
            break
        }
    }
}
