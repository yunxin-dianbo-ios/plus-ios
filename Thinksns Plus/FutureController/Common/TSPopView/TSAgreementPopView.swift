//
//  TSAgreementPopView.swift
//  ThinkSNSPlus
//
//  Created by 小唐 on 20/03/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  协议弹窗

import UIKit

protocol TSAgreementPopViewProtocol: class {
    /// 知道按钮点击回调
    func didClickKnownInAgreementPopView(_ popView: TSAgreementPopView) -> Void
    /// 遮罩点击回调
    func didClickCoverInAgreementPopView(_ popView: TSAgreementPopView) -> Void
}
extension TSDraftMorePopViewProtocol {
    /// 知道按钮点击回调
    func didClickKnownInAgreementPopView(_ popView: TSAgreementPopView) -> Void {
    }
    /// 遮罩点击回调
    func didClickCoverInAgreementPopView(_ popView: TSAgreementPopView) -> Void {
    }
}

class TSAgreementPopView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TSAgreementPopViewProtocol?

    // MARK: - Internal Function

    /// 展示在window上
    func show() -> Void {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalTo(window)
        }
    }

    // MARK: - Private Property

    private weak var coverBtn: UIButton!
    private weak var agreementView: UIView!
    private weak var titleLabel: UILabel!
    private weak var contentLabel: UILabel!
    private weak var doneBtn: UIButton!

    private let title: String
    private let content: String
    private let doneTitle: String

    private let agreementW: CGFloat = 250
    private let agreementMaxH: CGFloat = 300
    private let lrMargin: CGFloat = 25
    private let knownH: CGFloat = 50
    private let contentTBMargin: CGFloat = 10

    // MARK: - Initialize Function
    init(title: String, content: String, doneTitle: String = "知道了") {
        self.title = title
        self.content = content
        self.doneTitle = doneTitle
        super.init(frame: UIScreen.main.bounds)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.coverBtn = coverBtn
        // 2. 协议视图
        let agreementView = UIView(cornerRadius: 5, borderWidth: 0, borderColor: UIColor.clear)
        coverBtn.addSubview(agreementView)
        agreementView.backgroundColor = UIColor.white
        self.initialAgreementView(agreementView, width: agreementW)
        agreementView.snp.makeConstraints { (make) in
            make.center.equalTo(coverBtn)
            make.width.equalTo(agreementW)
        }
        self.agreementView = agreementView
    }

    /// 协议视图UI布局，也可将其提取成一个控件
    fileprivate func initialAgreementView(_ agreementView: UIView, width: CGFloat) -> Void {
        let contentFont: UIFont = UIFont.systemFont(ofSize: 14)
        // 1. titleView
        let titleView = UIView()
        agreementView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(agreementView)
        }
        let titleLabel = UILabel(text: self.title, font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleView).offset(20)
            make.bottom.equalTo(titleView).offset(-20)
            make.centerX.equalTo(titleView)
        }
        titleView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: lrMargin, margin2: lrMargin)
        self.titleLabel = titleLabel
        // 3. knownView
        let knownView = UIView()
        agreementView.addSubview(knownView)
        knownView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(agreementView)
            make.height.equalTo(knownH)
        }
        let doneBtn = UIButton(type: .custom)
        knownView.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(knownBtnClick(_:)), for: .touchUpInside)
        doneBtn.set(title: self.doneTitle, titleColor: TSColor.main.theme, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(knownView)
        }
        knownView.addLineWithSide(.inTop, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: lrMargin, margin2: lrMargin)
        self.doneBtn = doneBtn
        // 2. contentView
        let contentView = UIView()
        agreementView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.bottom.equalTo(knownView.snp.top)
            make.leading.equalTo(agreementView).offset(lrMargin)
            make.trailing.equalTo(agreementView).offset(-lrMargin)
        }
        // 2.1 contentScrollView
        let contentScrollView = UIScrollView()
        contentView.addSubview(contentScrollView)
        let height = self.heightForScrollView(with: self.content, font: contentFont)
        contentScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.width.equalTo(width - lrMargin - lrMargin)
            make.height.equalTo(height)
        }
        // 2.2 contentLabel
        let contentLabel = UILabel(text: self.content, font: contentFont, textColor: TSColor.normal.content)
        contentScrollView.addSubview(contentLabel)
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentScrollView).offset(contentTBMargin)
            make.bottom.equalTo(contentScrollView).offset(-contentTBMargin)
            make.leading.trailing.equalTo(contentScrollView)
            make.width.equalTo(width - lrMargin - lrMargin)
        }
        self.contentLabel = contentLabel
    }

    // MARK: - Private  数据加载

    /// 根据内容确定UIScrollView的高度
    fileprivate func heightForScrollView(with content: String, font: UIFont) -> CGFloat {
        var height: CGFloat = self.contentTBMargin * 2.0
        let contentW = self.agreementW - self.lrMargin * 2.0
        let size = content.size(maxSize: CGSize(width: contentW, height: width), font: font, lineMargin: 1)
        height += size.height
        return min(agreementMaxH - 100, height)
    }

    // MARK: - Private  事件响应

    /// 遮罩点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
        self.delegate?.didClickCoverInAgreementPopView(self)
    }
    // 知道了按钮点击响应
    @objc private func knownBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
        self.delegate?.didClickKnownInAgreementPopView(self)
    }

}
