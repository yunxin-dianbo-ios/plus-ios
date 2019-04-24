//
//  TWRichTextToolBar.swift
//  TSRichTextEditor-Swift
//
//  Created by 小唐 on 04/12/2017.
//  Copyright © 2017 Tightwad. All rights reserved.
//
//  发帖编辑器底部键盘工具栏
/**
 该工具栏由三部分组成：
     1、同步至动态视图。 - 根据开关控制显示，并对高度进行修正
     2、工具栏。
     3、文字样式工具栏。 - 添加再window上，位于工具栏上方，会遮挡同步至动态
 **/

import UIKit

protocol TWRichTextToolBarProtocol: class {

    /// 样式点击回调
    func richTextToolBar(toolbar: TWRichTextToolBar, didClickTextStyle textStyle: TWRichTextStyle, withSelectedState state: Bool) -> Void
    /// 键盘按钮点击回调
    func didClickKeyboardBtn(in toolbar: TWRichTextToolBar) -> Void
    /// 文字按钮点击回调 - 工具栏上的文字按钮
    func richTextToolBar(toolbar: TWRichTextToolBar, didClickTextStyleBtnWithSelectedState state: Bool) -> Void

}

class TWRichTextToolBar: UIView {

    // MARK: - Internal Property

    weak var delegate: TWRichTextToolBarProtocol?

    /// 隐藏文字样式视图
    var hiddenTextStyle: Bool = true {
        didSet {
            self.hiddenTextStyleView(hidden: hiddenTextStyle)
        }
    }
    /// 输入操作是否可用
    var inputEnable: Bool = true {
        didSet {
            for index in 1...6 {
                let button: UIButton = self.viewWithTag(index + 250) as! UIButton
                button.isEnabled = inputEnable
            }
        }
    }
    /// 是否显示同步至动态
    var showSyncMoment: Bool = false {
        didSet {
            self.syncMomentView.isHidden = !showSyncMoment
            let height: CGFloat = showSyncMoment ? self.syncMomentH : 0
            self.syncMomentView.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
        }
    }
    /// 当前高度(注：非视图高度、因为textStyleView添加在window上，)之后再修正为同步动态和视图一致
    var currentHeight: CGFloat {
        var height: CGFloat = self.toolViewH
        if !self.hiddenTextStyle {
            height += self.textStyleH
        } else if self.showSyncMoment {
            height += self.syncMomentH
        }
        return height
    }
    /// 是否同步至动态
    var syncMoment: Bool {
        var syncMomentFlag: Bool = false
        if self.showSyncMoment {
            syncMomentFlag = self.syncBtn.isSelected
        }
        return syncMomentFlag
    }

    /// 设置可用元素
    func setEnableItems(_ items: [TWRichTextStyle]) -> Void {
        self.textStyleView.setEnableItems(items)
    }

    // MARK: - Internal Function

    // MARK: - Private Property

    /// 同步动态视图
    fileprivate weak var syncMomentView: UIView!
    fileprivate weak var syncBtn: UIButton!
    /// 工具栏
    fileprivate weak var toolView: UIView!
    /// 文字样式视图
    fileprivate let textStyleView: TWTextStyleView = TWTextStyleView()

    /// 同步至动态的高度
    fileprivate let syncMomentH: CGFloat = 35
    /// 工具栏高度
    fileprivate let toolViewH: CGFloat = 40
    /// 文字样式工具栏高度
    fileprivate let textStyleH: CGFloat = 40

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
        self.backgroundColor = UIColor.white
        // 1. syncMomentView
        let syncMomentView = UIView()
        self.addSubview(syncMomentView)
        self.initialSyncMomentView(syncMomentView)
        syncMomentView.isHidden = true
        syncMomentView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(0) // 高度进行动态变化
        }
        self.syncMomentView = syncMomentView
        // 2. toolView
        let toolView = UIView()
        self.addSubview(toolView)
        self.initialToolView(toolView)
        toolView.addLineWithSide(.inTop, color: TSColor.inconspicuous.highlight, thickness: 0.5, margin1: 0, margin2: 0)
        toolView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(syncMomentView.snp.bottom)
            make.height.equalTo(self.toolViewH)
        }
        self.toolView = toolView
        // 3. textStyleView
        self.textStyleView.delegate = self
        self.textStyleView.isHidden = true
    }

    /// syncMomentView布局
    fileprivate func initialSyncMomentView(_ syncMomentView: UIView) -> Void {
        // 1. checkBox
        let syncBtn = UIButton(type: .custom)
        syncMomentView.addSubview(syncBtn)
        syncBtn.setImage(#imageLiteral(resourceName: "IMG_ico_circle_check"), for: .normal)
        syncBtn.setImage(#imageLiteral(resourceName: "IMG_ico_circle_checked"), for: .selected)
        syncBtn.addTarget(self, action: #selector(syncBtnClick(_:)), for: .touchUpInside)
        syncBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        syncBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(syncMomentView)
            make.leading.equalTo(syncMomentView).offset(15)
        }
        self.syncBtn = syncBtn
        // 2. promptLabel
        let promptLabel = UILabel(text: "显示_同步至动态".localized, font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.minor)
        syncMomentView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(syncMomentView)
            make.leading.equalTo(syncBtn.snp.trailing).offset(0) // btnRightMargin
        }
    }

    /// toolView - items布局
    fileprivate func initialToolView(_ toolView: UIView) -> Void {
        let lrMargin: CGFloat = 15
        let itemNames = ["IMG_ico_tools_packup", "IMG_ico_tools_link", "IMG_ico_tools_line", "IMG_ico_tools_font", "IMG_ico_tools_laststep", "IMG_ico_tools_nextstep", "IMG_ico_tools_picture"]
        let textStyles: Array<TWRichTextStyle> = [TWRichTextStyle.none, TWRichTextStyle.link, TWRichTextStyle.hr, TWRichTextStyle.none, TWRichTextStyle.undo, TWRichTextStyle.redo, TWRichTextStyle.image]
        let itemWidth: CGFloat = (UIScreen.main.bounds.size.width - lrMargin * 2.0) / CGFloat(textStyles.count)
        for (index, textStyle) in textStyles.enumerated() {
            let button = TWRichTextButton(textStyle: textStyle)
            self.addSubview(button)
            button.tag = 250 + index
            button.setImage(UIImage(named: itemNames[index]), for: .normal)
            if 3 == index {
                let selectedImageName = itemNames[index] + "_on"
                button.setImage(UIImage(named: selectedImageName), for: .selected)
            }
            button.addTarget(self, action: #selector(itemBtnClick(_:)), for: .touchUpInside)
            let leftOffset: CGFloat = lrMargin + itemWidth * CGFloat(index)
            button.snp.makeConstraints({ (make) in
                make.width.equalTo(itemWidth)
                make.top.bottom.equalTo(toolView)
                make.leading.equalTo(toolView).offset(leftOffset)
            })
        }
    }

    // MARK: - Private  数据加载

    /// 是否显示 textStyleView
    fileprivate func hiddenTextStyleView(hidden: Bool) -> Void {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        if hidden {
            self.textStyleView.removeFromSuperview()
        } else {
            if nil != self.textStyleView.superview {
                self.textStyleView.removeFromSuperview()
            }
            window.addSubview(self.textStyleView)
            self.textStyleView.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(window)
                make.bottom.equalTo(self.toolView.snp.top)
            })
        }
        self.textStyleView.isHidden = hidden
        if let button = self.viewWithTag(250 + 3) as? UIButton {
            button.isSelected = !hidden
        }
    }

    // MARK: - Private  事件响应

    @objc fileprivate func itemBtnClick(_ button: TWRichTextButton) -> Void {
        let index = button.tag - 250
        if 0 == index {
            self.delegate?.didClickKeyboardBtn(in: self)
            return
        } else if 3 == index {
            button.isSelected = !button.isSelected
            self.hiddenTextStyleView(hidden: !button.isSelected)
            self.delegate?.richTextToolBar(toolbar: self, didClickTextStyleBtnWithSelectedState: button.isSelected)
            return
        }
        self.delegate?.richTextToolBar(toolbar: self, didClickTextStyle: button.textStyle, withSelectedState: button.isSelected)
    }

    /// 同步按钮点击响应
    @objc fileprivate func syncBtnClick(_ button: UIButton) -> Void {
        button.isSelected = !button.isSelected
    }

}

extension TWRichTextToolBar: TWTextStyleViewProtocol {
    func textStyleView(styleView: TWTextStyleView, didClickTextStyle textStyle: TWRichTextStyle, withSelectedState state: Bool) {
        self.delegate?.richTextToolBar(toolbar: self, didClickTextStyle: textStyle, withSelectedState: state)
    }
}
