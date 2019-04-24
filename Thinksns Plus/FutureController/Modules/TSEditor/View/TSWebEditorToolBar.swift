//
//  TSWebEditorToolBar.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  工具栏，完成后用来替换TSWebEditorToolBar

/**
 该工具栏组成：顶部栏 + 扩展栏 + 工具栏。
 顶部栏：
    1. 根据需要展示，高度限定
 扩展栏：
    1. 根据需要展示，高度限定
    2. 显示文字样式工具栏 + 设置工具栏
    3. 设置工具栏用于对外扩展(从外界进行设置，内部添加到设置工具视图，但进行高度限定)
 工具栏：
    1. 设置选项不一定存在
    2. 高度限定
 
 **/

import Foundation
import UIKit

protocol TSWebEditorToolBarProtocol: class {

    /// 样式点击回调
    func richTextToolBar(toolbar: TSWebEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) -> Void
    /// 键盘按钮点击回调
    func didClickKeyboardBtn(in toolbar: TSWebEditorToolBar) -> Void
    /// 工具栏高度变化回调: 点击文字选项按钮 或 设置按钮，导致扩展视图高度变化
    func didHeightChanged(in toolbar: TSWebEditorToolBar) -> Void
    /// 表情点击回调
    func richTextToolBarEmoji(toolbar: TSWebEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool, emojiButton: UIButton) -> Void
}

/// 编辑器工具栏
class TSWebEditorToolBar: UIView {
    /// 扩展选项
    enum ExtensionType {
        case setting
        case textStyle
    }

    // MARK: - Internal Property

    /// 回调代理
    weak var delegate: TSWebEditorToolBarProtocol?
    /// 是否显示设置选项
    let showSettingFlag: Bool

    /// 输入操作是否可用
    var inputEnable: Bool = true {
        didSet {
            for index in 1...6 {
                let button: UIButton = self.viewWithTag(index + 250) as! UIButton
                button.isEnabled = inputEnable
            }
        }
    }
    /// 当前高度
    var currentHeight: CGFloat {
        var height: CGFloat = self.toolViewH
        //height += topViewVisibility ? self.topViewH : 0
        height += showExtensionFlag ? self.extensionH : 0
        return height
    }

    /// 设置可用元素
    func setEnableItems(_ items: [TSEditorTextStyle]) -> Void {
        self.textStyleView.setEnableItems(items)
    }

    /// 显示 或 隐藏topView
    var topViewVisibility: Bool = false {
        didSet {
            self.setupTopViewVisibility(topViewVisibility)
        }
    }
    /// 设置顶部展示视图: 高宽同topView，并作为topView的子视图添加展示
    var topShowView: UIView? {
        didSet {
            guard let topShowView = topShowView else {
                self.topView.removeAllSubViews()
                return
            }
            self.topView.addSubview(topShowView)
            topShowView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.topView)
            }
        }
    }

    /// 显示extension视图
    func showExtension(_ type: ExtensionType) -> Void {
        self.setupShowExtension(type)
    }
    /// 隐藏extension视图
    func hiddenExtension() -> Void {
        self.setupHiddenExtension()
    }
    /// 设置扩展视图: 高宽同extensionView(width: ScreenWidth, height: extensionH=40)
    var settingExtensionView: UIView? {
        didSet {
            guard let settingExtensioView = settingExtensionView else {
                self.settingView.removeAllSubViews()
                return
            }
            self.settingView.addSubview(settingExtensioView)
            settingExtensioView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.settingView)
            }
        }
    }

    // MARK: - Internal Function

    // MARK: - Private Property

    /// 顶部视图
    fileprivate let topView: UIView = UIView()
    /// 顶部扩展视图
    fileprivate let extensionView: UIView = UIView()
    /// 底部工具栏
    fileprivate let toolView: UIView = UIView()

    /// 是否显示extension视图，默认不显示
    fileprivate var showExtensionFlag: Bool = false

    /// 工具栏上的左右间距
    fileprivate let lrMargin: CGFloat = 15
    /// 高度
    fileprivate let topViewH: CGFloat = 35
    fileprivate let toolViewH: CGFloat = 40
    fileprivate let extensionH: CGFloat = 40

    /// 文字样式视图
    fileprivate let textStyleView: TSEditorTextStyleView = TSEditorTextStyleView()
    /// 设置视图
    fileprivate let settingView: UIView = UIView()

    /// 工具栏选项
    fileprivate var itemIconNames: [String] = []
    fileprivate var itemTextStyles: [TSEditorTextStyle] = []

    /// 选项按钮
    fileprivate var textStyleItemBtn: UIButton? // 文字样式选项按钮
    fileprivate var settingItemBtn: UIButton?   // 设置选项按钮，可能为nil

    // MARK: - Initialize Function
    init(showSetting: Bool = false) {
        self.showSettingFlag = showSetting
        super.init(frame: CGRect.zero)
        // 注：这里的顺序，UI需要先初始化数据
        self.initialDataSource()
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        // 0. topView
        self.addSubview(self.topView)
        self.topView.isHidden = true    // 默认隐藏
        self.topView.clipsToBounds = true
        self.topView.snp.makeConstraints { (make) in
            make.height.equalTo(0)  // 默认高度为0
            make.top.equalTo(self)
            make.leading.trailing.equalTo(self)
        }
        // 1. extensionView
        self.addSubview(self.extensionView)
        self.extensionView.isHidden = true  // 默认隐藏
        self.extensionView.clipsToBounds = true
        self.extensionView.snp.makeConstraints { (make) in
            make.height.equalTo(0)  // 默认高度为0
            make.top.equalTo(self.topView.snp.bottom)
            make.leading.trailing.equalTo(self)
        }
        // 2. toolView
        self.addSubview(self.toolView)
        self.initialToolView(self.toolView)
        self.toolView.addLineWithSide(.inTop, color: TSColor.inconspicuous.highlight, thickness: 0.5, margin1: 0, margin2: 0)
        self.toolView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(self.extensionView.snp.bottom)
            make.height.equalTo(self.toolViewH)
        }
        // 3. extensionChildView
        self.textStyleView.delegate = self
    }

    /// toolView - items布局
    fileprivate func initialToolView(_ toolView: UIView) -> Void {
        let itemNames = self.itemIconNames
        let textStyles = self.itemTextStyles
        let itemWidth: CGFloat = (UIScreen.main.bounds.size.width - lrMargin * 2.0) / CGFloat(textStyles.count)
        for (index, textStyle) in textStyles.enumerated() {
            let button = TSEditorTextStyleButton(textStyle: textStyle)
            self.addSubview(button)
            button.tag = 250 + index
            button.setImage(UIImage(named: itemNames[index]), for: .normal)
            if self.showSettingFlag && index == self.itemTextStyles.count - 2 {
                button.setImage(UIImage(named: "ico_tougao_face的副本"), for: .selected)
            }
            if !self.showSettingFlag && index == self.itemTextStyles.count - 1 {
                button.setImage(UIImage(named: "ico_tougao_face的副本"), for: .selected)
            }
            if 3 == index {
                let selectedImageName = itemNames[index] + "_on"
                button.setImage(UIImage(named: selectedImageName), for: .selected)
                self.textStyleItemBtn = button
            } else if index == textStyles.count - 1 && self.showSettingFlag {
                let selectedImageName = itemNames[index] + "_on"
                button.setImage(UIImage(named: selectedImageName), for: .selected)
                self.settingItemBtn = button
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

    /// 数据选项初始化
    fileprivate func initialDataSource() -> Void {
        var itemNames = ["IMG_ico_tools_packup", "IMG_ico_tools_link", "IMG_ico_tools_line", "IMG_ico_tools_font", "IMG_ico_tools_laststep", "IMG_ico_tools_nextstep", "IMG_ico_tools_picture", "ico_tougao_face"]
        var textStyles: Array<TSEditorTextStyle> = [TSEditorTextStyle.none, TSEditorTextStyle.link, TSEditorTextStyle.hr, TSEditorTextStyle.none, TSEditorTextStyle.undo, TSEditorTextStyle.redo, TSEditorTextStyle.image, TSEditorTextStyle.image]
        // 显示设置按钮选项
        if self.showSettingFlag {
            itemNames.append("IMG_ico_tools_setting")
            textStyles.append(TSEditorTextStyle.none)
        }
        self.itemIconNames = itemNames
        self.itemTextStyles = textStyles
    }

    /// 设置topView的可见性
    fileprivate func setupTopViewVisibility(_ show: Bool) -> Void {
        self.topView.isHidden = !show
        let height: CGFloat = show ? self.topViewH : 0
        self.topView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        self.layoutIfNeeded()
    }

    /// 设置 显示extension视图
    fileprivate func setupShowExtension(_ type: ExtensionType) -> Void {
        self.extensionView.removeAllSubViews()
        self.extensionView.isHidden = false
        self.extensionView.snp.updateConstraints { (make) in
            make.height.equalTo(self.extensionH)
        }
        switch type {
        case .textStyle:
            self.extensionView.addSubview(self.textStyleView)
            self.textStyleView.snp.makeConstraints({ (make) in
                make.edges.equalTo(self.extensionView)
            })
            self.textStyleItemBtn?.isSelected = true
            self.settingItemBtn?.isSelected = false
        case .setting:
            self.extensionView.addSubview(self.settingView)
            self.settingView.snp.makeConstraints({ (make) in
                make.edges.equalTo(self.extensionView)
            })
            self.textStyleItemBtn?.isSelected = false
            self.settingItemBtn?.isSelected = true
        }
        self.layoutIfNeeded()
        self.showExtensionFlag = true
        self.delegate?.didHeightChanged(in: self)
    }
    /// 设置 隐藏extension视图
    fileprivate func setupHiddenExtension() -> Void {
        self.extensionView.removeAllSubViews()
        self.extensionView.isHidden = true
        self.extensionView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        self.layoutIfNeeded()
        self.showExtensionFlag = false
        self.delegate?.didHeightChanged(in: self)
        // textStyle选项 和 setting选项状态重置
        self.textStyleItemBtn?.isSelected = false
        self.settingItemBtn?.isSelected = false
    }

    // MARK: - Private  事件响应

    @objc fileprivate func itemBtnClick(_ button: TSEditorTextStyleButton) -> Void {
        let index = button.tag - 250
        if self.showSettingFlag && index == self.itemTextStyles.count - 2 {
            button.isSelected = !button.isSelected
            self.delegate?.richTextToolBarEmoji(toolbar: self, didClickTextStyle: button.textStyle, withSelectedState: button.isSelected, emojiButton: button)
            return
        }
        if !self.showSettingFlag && index == self.itemTextStyles.count - 1 {
            button.isSelected = !button.isSelected
            self.delegate?.richTextToolBarEmoji(toolbar: self, didClickTextStyle: button.textStyle, withSelectedState: button.isSelected, emojiButton: button)
            return
        }
        if 0 == index {
            // 键盘按钮点击
            self.delegate?.didClickKeyboardBtn(in: self)
            return
        } else if 3 == index {
            // 文字样式按钮点击
            button.isSelected = !button.isSelected
            if button.isSelected {
                self.showExtension(.textStyle)
            } else {
                self.hiddenExtension()
            }
            return
        } else if index == self.itemTextStyles.count - 1 && self.showSettingFlag {
            // 设置按钮点击
            button.isSelected = !button.isSelected
            if button.isSelected {
                self.showExtension(.setting)
            } else {
                self.hiddenExtension()
            }
            return
        }
        self.delegate?.richTextToolBar(toolbar: self, didClickTextStyle: button.textStyle, withSelectedState: button.isSelected)
    }

}

extension TSWebEditorToolBar: TSEditorTextStyleViewProtocol {
    func textStyleView(styleView: TSEditorTextStyleView, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) {
        self.delegate?.richTextToolBar(toolbar: self, didClickTextStyle: textStyle, withSelectedState: state)
    }
}
