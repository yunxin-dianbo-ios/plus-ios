//
//  TWTextStyleView.swift
//  TSRichTextEditor-Swift
//
//  Created by 小唐 on 04/12/2017.
//  Copyright © 2017 Tightwad. All rights reserved.
//

import UIKit
import SnapKit

protocol TWTextStyleViewProtocol: class {

    /// 样式点击回调
    func textStyleView(styleView: TWTextStyleView, didClickTextStyle textStyle: TWRichTextStyle, withSelectedState state: Bool) -> Void

}

class TWTextStyleView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TWTextStyleViewProtocol?
    /// 设置当前打开的样式
    func setEnableItems(_ items: [TWRichTextStyle]) -> Void {
        // 取消所有选中
        for (i, _) in self.textStyles.enumerated() {
            if let button = self.viewWithTag(250 + i) as? UIButton {
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
                if let button = self.viewWithTag(250 + index) as? UIButton {
                    button.isSelected = true
                }
            }
        }
    }

    // MARK: - Internal Function

    // MARK: - Private Property

    fileprivate let viewHeight: CGFloat = 40
    fileprivate let textStyles: Array<TWRichTextStyle> = [TWRichTextStyle.bold, TWRichTextStyle.italic, TWRichTextStyle.strikethrough, TWRichTextStyle.blockquote, TWRichTextStyle.h1, TWRichTextStyle.h2, TWRichTextStyle.h3, TWRichTextStyle.h4]

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

        // 0xf5f5f4
        self.backgroundColor = UIColor.lightGray

        let lrMargin: CGFloat = 15
        let iconNames = ["IMG_ico_font_bold", "IMG_ico_font_italy", "IMG_ico_font_s", "IMG_ico_font_quota", "IMG_ico_font_h1", "IMG_ico_font_h2", "IMG_ico_font_h3", "IMG_ico_font_h4"]

        let btnW: CGFloat = (UIScreen.main.bounds.size.width - lrMargin * 2.0) / CGFloat(textStyles.count)
        for (index, textStyle) in textStyles.enumerated() {
            let button = TWRichTextButton(textStyle: textStyle)
            self.addSubview(button)
            button.setImage(UIImage(named: iconNames[index]), for: .normal)
            let selectedImageName = iconNames[index] + "_on"
            button.setImage(UIImage(named: selectedImageName), for: .selected)
            button.addTarget(self, action: #selector(textStyleBtnClick(_:)), for: .touchUpInside)
            button.tag = 250 + index
            button.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(self)
                let leftOffset = lrMargin + btnW * CGFloat(index)
                make.leading.equalTo(self).offset(leftOffset)
                make.height.equalTo(self.viewHeight)
            })
        }
    }

    // MARK: - Private  数据加载
    /// heading标签点击特殊处理
    fileprivate func headingStyleClick() -> Void {
        // 取消掉所有的heading标签的选中
        for index in 0...3 {
            if let button = self.viewWithTag(250 + 4 + index) as? UIButton {
                button.isSelected = false
            }
        }
        // 取消掉引用标签的选中
        if let button = self.viewWithTag(250 + 3) as? UIButton {
            button.isSelected = false
        }
    }
    /// blockquote标签点击特殊处理
    fileprivate func blockquoteStyleClick() -> Void {
        // 取消掉所有的heading标签的选中
        for index in 0...3 {
            if let button = self.viewWithTag(250 + 4 + index) as? UIButton {
                button.isSelected = false
            }
        }
    }

    // MARK: - Private  事件响应

    // 样式按钮点击响应
    @objc fileprivate func textStyleBtnClick(_ button: TWRichTextButton) -> Void {
        let textStyle = button.textStyle
//        if textStyle == .h1 || textStyle == .h2 || textStyle == .h3 || textStyle == .h4 {
//            self.headingStyleClick()
//        }
//        // 对引用选中时候进行处理：移除heading标签
//        if textStyle == .blockquote {
//            self.blockquoteStyleClick()
//        }

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
