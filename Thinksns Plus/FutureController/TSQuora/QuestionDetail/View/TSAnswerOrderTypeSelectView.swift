//
//  TSAnswerOrderTypeSelectView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 30/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案排序方式选择视图

import UIKit

protocol TSAnswerOrderTypeSelectViewProtocol: class {
    /// 重新选择点击响应(和默认不一样的点击时)
    func selectView(_ selectView: TSAnswerOrderTypeSelectView, didReSelectedAt type: TSAnserOrderType) -> Void
}

class TSAnswerOrderTypeSelectView: UIView {

    // MARK: - Internal Property
    /// 代理回调
    weak var delegate: TSAnswerOrderTypeSelectViewProtocol?
    /// 当前选中
    var currentType: TSAnserOrderType = .diggCount {
        didSet {
            var index: Int = 0
            switch currentType {
            case .diggCount:
                index = 0
            case .publishTime:
                index = 1
            }
            self.currentSelected?.isSelected = false
            let control = self.viewWithTag(self.orderTypeTagBase + index) as! UIControl
            control.isSelected = true
            self.currentSelected = control
        }
    }

    // type selectedType

    // MARK: - Private Property
    private let titles = ["默认排序", "按时间排序"]      // 标题数组
    private let singleTypeH: CGFloat = 35             // 单个排序方式的高度
    private let singleTypeW: CGFloat = 100            // 单个排序方式的宽度
    /// 排序方式的的tag基值
    private let orderTypeTagBase: Int = 250

    // MARK: - Internal Function

    private weak var currentSelected: UIControl?

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
        self.currentType = .diggCount
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
        self.currentType = .diggCount
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = TSColor.inconspicuous.disabled.cgColor
        // 注：这里应该获取最大的宽度(利用minWidthWithTitle获取最大的宽度)，而不是直接赋值.
        let controlW = self.singleTypeW
        let controlH = self.singleTypeH
        for (index, title) in titles.enumerated() {
            let control = TSAnswerOrderTypeSingleSelectControl()
            self.addSubview(control)
            control.title = title
            control.addTarget(self, action: #selector(answerOrderTypecontrolClick(_:)), for: .touchUpInside)
            control.tag = self.orderTypeTagBase + index
            control.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(self)
                make.height.equalTo(controlH)
                make.width.equalTo(controlW)
                make.top.equalTo(self).offset(controlH * CGFloat(index))
                // 对最后一个的底部进行处理
                if index == titles.count - 1 {
                    make.bottom.equalTo(self)
                }
            })
            // 分隔线条
            if 0 != index {
                control.addLineWithSide(.inTop, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
            }
        }
        // 默认选中
        let defaultControl = self.viewWithTag(self.orderTypeTagBase + 0) as! UIControl
        defaultControl.isSelected = true
        self.currentSelected = defaultControl
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 答案排序方式点击响应
    @objc private func answerOrderTypecontrolClick(_ control: UIControl) -> Void {
        if control.isSelected {
            return
        }
        // 回调
        let index = control.tag - self.orderTypeTagBase
        switch index {
        case 0:
            // 默认排序
            self.currentType = .diggCount   // didSet里进行显示配置
            self.delegate?.selectView(self, didReSelectedAt: .diggCount)
        case 1:
            // 时间排序
            self.currentType = .publishTime // didSet里进行显示配置
            self.delegate?.selectView(self, didReSelectedAt: .publishTime)
        default:
            break
        }
    }

}

/// 答案排序方式中单个方式的选择控件
class TSAnswerOrderTypeSingleSelectControl: UIControl {
    // MARK: - Internal Property
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }

    /// 根据title计算的最短宽度
    func minWidthWithTitle(_ title: String) -> CGFloat {
        let titleW: CGFloat = title.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: self.titleFont).width
        let imageW: CGFloat = self.iconView.image?.size.width ?? 0
        return titleW + self.leftMargin + self.rightMargin + self.centerMinMargin + imageW
    }

    // MARK: - Private Property
    /// 标题
    private weak var titleLabel: UILabel!
    /// 图标
    private weak var iconView: UIImageView!

    private var leftMargin: CGFloat = 10        // 左侧间距，title的左侧间距
    private var rightMargin: CGFloat = 10       // 右侧间距，image的右侧间距
    private var centerMinMargin: CGFloat = 10   // title和image之间的最短间距
    private let titleFont: UIFont = UIFont.systemFont(ofSize: 12)

    // 选中处理
    override var isSelected: Bool {
        didSet {
            self.iconView.isHidden = !isSelected
            self.titleLabel.textColor = isSelected ? TSColor.normal.content : TSColor.normal.minor
        }
    }

    // MARK: - Initialize Function

    init(leftMargin: CGFloat = 10, rightMargin: CGFloat = 10, centerMinMargin: CGFloat = 10) {
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.centerMinMargin = centerMinMargin
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Private  UI
    private func initialUI() -> Void {
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: titleFont, textColor: TSColor.normal.minor)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(leftMargin)
        }
        self.titleLabel = titleLabel
        // 2. iconView
        let iconView = UIImageView()
        self.addSubview(iconView)
        iconView.contentMode = .center
        iconView.image = UIImage(named: "IMG_ico_quora_question_select")
        iconView.isHidden = true        // 默认隐藏
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-rightMargin)
        }
        self.iconView = iconView
    }
}
