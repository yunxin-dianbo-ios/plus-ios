//
//  TSAnonymousPromptPopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 06/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  匿名提示弹窗

import UIKit

protocol TSAnonymousPromptPopViewProtocol: class {

    // 确定按钮点击回调
    func didConfirmBtnClick() -> Void

    // optional 

    /// 遮罩点击回调
    func didCoverClick() -> Void
    /// 取消按钮点击回调
    func didCancelBtnClick() -> Void
}
extension TSAnonymousPromptPopViewProtocol {
    func didCoverClick() -> Void {

    }
    func didCancelBtnClick() -> Void {

    }
}

class TSAnonymousPromptPopView: UIView {

    // MARK: - Internal Property

    weak var delegate: TSAnonymousPromptPopViewProtocol?

    private(set) weak  var anonymousView: TSAnonymousPromptView!
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
        // 2. anonymousPromptView
        let promptView = TSAnonymousPromptView()
        coverBtn.addSubview(promptView)
        promptView.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        promptView.confirmBtn.addTarget(self, action: #selector(confirmBtnClick), for: .touchUpInside)
        promptView.snp.makeConstraints { (make) in
            make.center.equalTo(coverBtn)
            make.width.equalTo(250)
        }
        self.anonymousView = promptView
    }

    // MARK: - Private  事件响应

    /// 遮罩点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
        self.delegate?.didCoverClick()
    }

    /// 取消按钮点击回调
    @objc private func cancelBtnClick() -> Void {
        self.removeFromSuperview()
        self.delegate?.didCancelBtnClick()
    }
    /// 确认按钮点击回调
    @objc private func confirmBtnClick() -> Void {
        self.removeFromSuperview()
        self.delegate?.didConfirmBtnClick()
    }
}
