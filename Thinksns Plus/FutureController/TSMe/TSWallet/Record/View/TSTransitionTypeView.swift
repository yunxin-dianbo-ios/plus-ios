//
//  TSTransitionTypeView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  交易类型 标题菜单栏
//  ReceivePendingTypeView 使用了该类的做法

import UIKit

class TSTransitionTypeView: UIView {

    /// 动画时间
    let animationTime = TimeInterval(0.3)
    /// 按钮视图
    @IBOutlet weak var buttonView: UIView!
    /// 按钮基础 tag 值
    internal let tagForButton = 200
    /// row 点击事件 block
    internal var tapOperationBlock: ((_ index: Int) -> Void)?
    /// 视图消失事件 block
    internal var dismissOperationBlock: (() -> Void)?

    // MARK: - Lifecycle

    /// 初始化方法
    class func makeTransitionTypeView() -> TSTransitionTypeView {
        let typeView = (Bundle.main.loadNibNamed("TSTransitionTypeView", owner: self, options: nil)?[0] as?TSTransitionTypeView)!
        return typeView
    }

    // MAKR: - Button click

    @IBAction func rowTaped(_ sender: UIButton) {
        dismiss()
        let index = sender.tag - tagForButton
        if let operation = tapOperationBlock {
            operation(index)
        }
    }

    /// 点击了背景视图
    @IBAction func backButtonTaped(_ sender: UIButton) {
        dismiss()
    }

    // MARK: - Public

    /// 设置 row 点击事件
    func setTap(operation: @escaping (_ index: Int) -> Void) {
        tapOperationBlock = operation
    }

    /// 设置消失响应事件
    func setDismiss(operation: @escaping () -> Void) {
        dismissOperationBlock = operation
    }

    /// 出场动画
    func show() {
        buttonView.frame.origin.y = -buttonView.frame.height
        superview?.isHidden = false
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.buttonView.frame.origin.y = 0
            }
        }, completion: nil)
    }

    /// 退场动画
    func dismiss() {
        buttonView.frame.origin.y = 0
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.buttonView.frame.origin.y = -weakSelf.buttonView.frame.height
            }
        }, completion: { [weak self] (_) in
            guard let weakSelf = self else {
                    return
            }
            weakSelf.superview?.isHidden = true
            if let block = weakSelf.dismissOperationBlock {
                block()
            }
        })
    }
}
