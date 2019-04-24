//
//  TSWebEditorTextStyleView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 24/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  Web编辑器文字样式工具视图

import Foundation
import SnapKit

// MARK: - TSEditorTextStyle

/// 编辑器上的样式
enum TSEditorTextStyle: String {

    /** 文字样式部分 **/

    case none
    case bold
    case italic
    case strikethrough
    case underline
    case blockquote
    case h1
    case h2
    case h3
    case h4

    /** 非文字样式部分 **/

    case link
    case hr
    case undo
    case redo
    case image
}

// MARK: - TSRichTextButton

/// 编辑器上的文字样式按钮(含有一个文字样式)
class TSEditorTextStyleButton: UIButton {

    var textStyle: TSEditorTextStyle

    init(textStyle: TSEditorTextStyle) {
        self.textStyle = textStyle
        // 注：是混编时有这个问题，还是单纯的Swift有这个问题。
        //super.init(type: .custom)
        super.init(frame: CGRect.zero)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - TSEditorTextStyleView

///
protocol TSEditorTextStyleViewProtocol: class {

    /// 样式点击回调
    func textStyleView(styleView: TSEditorTextStyleView, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) -> Void

}

/// 编辑器文字样式工具视图
class TSEditorTextStyleView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TSEditorTextStyleViewProtocol?
    /// 设置当前打开的样式
    func setEnableItems(_ items: [TSEditorTextStyle]) -> Void {
        // 取消所有选中
        for (i, _) in self.textStyles.enumerated() {
            if let button = self.viewWithTag(self.tagBase + i) as? UIButton {
                button.isSelected = false
            }
        }

        // 选中指定的样式
        for item in items {
            if self.textStyles.contains(item) {
                // 当前item高亮显示
                var index: Int = -1
                switch item {
                case .bold:
                    index = 0
                case .italic:
                    index = 1
                case .strikethrough:
                    index = 2
                case .blockquote:
                    index = 3
                case .h1:
                    index = 4
                case .h2:
                    index = 5
                case .h3:
                    index = 6
                case .h4:
                    index = 7
                default:
                    break
                }
                if let button = self.viewWithTag(self.tagBase + index) as? UIButton {
                    button.isSelected = true
                }
            }
        }
    }

    // MARK: - Internal Function

    // MARK: - Private Property

    fileprivate let tagBase: Int = 250

    fileprivate let viewHeight: CGFloat = 40
    fileprivate let textStyles: Array<TSEditorTextStyle> = [TSEditorTextStyle.bold, TSEditorTextStyle.italic, TSEditorTextStyle.strikethrough, TSEditorTextStyle.blockquote, TSEditorTextStyle.h1, TSEditorTextStyle.h2, TSEditorTextStyle.h3, TSEditorTextStyle.h4]

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
        self.backgroundColor = UIColor(hex: 0xf5f5f4)

        let lrMargin: CGFloat = 15
        let iconNames = ["IMG_ico_font_bold", "IMG_ico_font_italy", "IMG_ico_font_s", "IMG_ico_font_quota", "IMG_ico_font_h1", "IMG_ico_font_h2", "IMG_ico_font_h3", "IMG_ico_font_h4"]

        let btnW: CGFloat = (UIScreen.main.bounds.size.width - lrMargin * 2.0) / CGFloat(textStyles.count)
        for (index, textStyle) in textStyles.enumerated() {
            let button = TSEditorTextStyleButton(textStyle: textStyle)
            self.addSubview(button)
            button.setImage(UIImage(named: iconNames[index]), for: .normal)
            let selectedImageName = iconNames[index] + "_on"
            button.setImage(UIImage(named: selectedImageName), for: .selected)
            button.addTarget(self, action: #selector(textStyleBtnClick(_:)), for: .touchUpInside)
            button.tag = self.tagBase + index
            button.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(self)
                let leftOffset = lrMargin + btnW * CGFloat(index)
                make.leading.equalTo(self).offset(leftOffset)
                make.width.equalTo(btnW)
                make.height.equalTo(self.viewHeight)
            })
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    // 样式按钮点击响应
    @objc fileprivate func textStyleBtnClick(_ button: TSEditorTextStyleButton) -> Void {
        let textStyle = button.textStyle
        // 注：设置样式后，webView会进行回调显示当前应开启的状态，在那里重置相关状态
        // 引用标签特殊处理
        if textStyle == .blockquote {
            self.delegate?.textStyleView(styleView: self, didClickTextStyle: button.textStyle, withSelectedState: button.isSelected)
            button.isSelected = !button.isSelected
            return
        }

        button.isSelected = !button.isSelected
        self.delegate?.textStyleView(styleView: self, didClickTextStyle: button.textStyle, withSelectedState: button.isSelected)
    }

}
