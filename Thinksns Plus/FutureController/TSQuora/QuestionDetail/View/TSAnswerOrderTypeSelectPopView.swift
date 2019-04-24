//
//  TSAnswerOrderTypeSelectPopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 30/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情页 - 答案排序方式选择弹窗
//  注：该页面需要代理来响应子控件的响应，顺便移除本身

import UIKit

protocol TSAnswerOrderTypeSelectPopViewProtocol: class {
    /// 遮罩点击回调
    func didClickCoverInPopView(answerOrderTypeSelectPopView: TSAnswerOrderTypeSelectPopView) -> Void
    /// 排序方式点击回调
    func popView(_ popView: TSAnswerOrderTypeSelectPopView, didSelected answerOrderType: TSAnserOrderType) -> Void
}
extension TSAnswerOrderTypeSelectPopViewProtocol {
    /// 遮罩点击回调
    func didClickCoverInPopView(answerOrderTypeSelectPopView: TSAnswerOrderTypeSelectPopView) -> Void {

    }
}

class TSAnswerOrderTypeSelectPopView: UIView, TSAnswerOrderTypeSelectViewProtocol {

    // MARK: - Internal Property
    // 代理回调
    weak var delegate: TSAnswerOrderTypeSelectPopViewProtocol?
    // MARK: - Private Property
    private let selectTopMargin: CGFloat
    private let selectRightMargin: CGFloat
    /// 选择视图
    private weak var selectView: TSAnswerOrderTypeSelectView!

    // MARK: - Internal Function

    // MARK: - Initialize Function
    /// topMargin/rightMargin指的是selectView
    init(currentType: TSAnserOrderType, topMargin: CGFloat, rightMargin: CGFloat = 15) {
        self.selectTopMargin = topMargin
        self.selectRightMargin = rightMargin
        super.init(frame: UIScreen.main.bounds)
        self.initialUI()
        self.selectView.currentType = currentType
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        // 2. answerOrderTypeSelectView
        let selectView = TSAnswerOrderTypeSelectView()
        coverBtn.addSubview(selectView)
        selectView.delegate = self
        selectView.snp.makeConstraints { (make) in
            make.trailing.equalTo(coverBtn).offset(-selectRightMargin)
            make.top.equalTo(coverBtn).offset(selectTopMargin)
        }
        self.selectView = selectView
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应
    /// 遮罩点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        button.removeFromSuperview()
        self.removeFromSuperview()
        self.delegate?.didClickCoverInPopView(answerOrderTypeSelectPopView: self)
    }

    // MARK: - Delegate Function 

    // MARK: - TSAnswerOrderTypeSelectViewProtocol

    /// 答案列表的排序方式点击响应
    func selectView(_ selectView: TSAnswerOrderTypeSelectView, didReSelectedAt type: TSAnserOrderType) {
        self.removeFromSuperview()
        self.delegate?.popView(self, didSelected: type)
    }

}
