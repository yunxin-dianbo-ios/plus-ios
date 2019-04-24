//
//  TSWebEditorToolView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 24/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  Web编辑器的工具栏
/**
 该工具栏由三部分组成：
 1、工具栏。
 2、文字样式工具栏。 - 添加再window上，位于工具栏上方

 注：该工具栏实际使用时可能需要扩展自定义的工具栏
 
 **/

typealias TSEditorToolBarProtocol = TSWebEditorToolBarProtocol
typealias TSEditorToolBar = TSWebEditorToolBar

/**
import Foundation
import UIKit


protocol TSEditorToolBarProtocol: class {
    
    /// 样式点击回调
    func richTextToolBar(toolbar: TSEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) -> Void
    /// 键盘按钮点击回调
    func didClickKeyboardBtn(in toolbar: TSEditorToolBar) -> Void
    /// 文字按钮点击回调 - 工具栏上的文字按钮
    func richTextToolBar(toolbar: TSEditorToolBar, didClickTextStyleBtnWithSelectedState state: Bool) -> Void
    
}

/// 编辑器工具栏
class TSEditorToolBar: UIView
{
    
    // MARK: - Internal Property
    
    weak var delegate: TSEditorToolBarProtocol?
    
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
    /// 当前高度(注：非视图高度、因为textStyleView添加在window上，)之后再修正为同步动态和视图一致
    var currentHeight: CGFloat {
        var height: CGFloat = self.toolViewH
        if !self.hiddenTextStyle {
            height += self.textStyleH
        }
        return height
    }
    
    /// 设置可用元素
    func setEnableItems(_ items: [TSEditorTextStyle]) -> Void {
        self.textStyleView.setEnableItems(items)
    }
    
    // MARK: - Internal Function
    
    
    // MARK: - Private Property
    
    /// 工具栏
    fileprivate weak var toolView: UIView!
    /// 文字样式视图
    fileprivate let textStyleView: TSEditorTextStyleView = TSEditorTextStyleView()

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
        // 1. toolView
        let toolView = UIView()
        self.addSubview(toolView)
        self.initialToolView(toolView)
        toolView.addLineWithSide(.inTop, color: TSColor.inconspicuous.highlight, thickness: 0.5, margin1: 0, margin2: 0)
        toolView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(self.toolViewH)
        }
        self.toolView = toolView
        // 2. textStyleView
        self.textStyleView.delegate = self
        self.textStyleView.isHidden = true
    }
    
    /// toolView - items布局
    fileprivate func initialToolView(_ toolView: UIView) -> Void {
        let lrMargin: CGFloat = 15
        let itemNames = ["IMG_ico_tools_packup", "IMG_ico_tools_link", "IMG_ico_tools_line", "IMG_ico_tools_font", "IMG_ico_tools_laststep", "IMG_ico_tools_nextstep", "IMG_ico_tools_picture"]
        let textStyles: Array<TSEditorTextStyle> = [TSEditorTextStyle.none, TSEditorTextStyle.link, TSEditorTextStyle.hr, TSEditorTextStyle.none, TSEditorTextStyle.undo, TSEditorTextStyle.redo, TSEditorTextStyle.image]
        let itemWidth: CGFloat = (UIScreen.main.bounds.size.width - lrMargin * 2.0) / CGFloat(textStyles.count)
        for (index, textStyle) in textStyles.enumerated() {
            let button = TSEditorTextStyleButton.init(textStyle: textStyle)
            self.addSubview(button)
            button.tag = 250 + index
            button.setImage(UIImage.init(named: itemNames[index]), for: .normal)
            if 3 == index {
                let selectedImageName = itemNames[index] + "_on"
                button.setImage(UIImage.init(named: selectedImageName), for: .selected)
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
    
    @objc fileprivate func itemBtnClick(_ button: TSEditorTextStyleButton) -> Void {
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
    
}

extension TSEditorToolBar: TSEditorTextStyleViewProtocol {
    func textStyleView(styleView: TSEditorTextStyleView, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) {
        self.delegate?.richTextToolBar(toolbar: self, didClickTextStyle: textStyle, withSelectedState: state)
    }
}

**/
