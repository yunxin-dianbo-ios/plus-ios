//
//  TSOriginalCenterOneInputView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 21/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  自定义输入框 - 
//      1. 默认中间展示单行，随着输入内容的增多而自动换行；
//      2. 可设置最大字数限制；
//      3. 可设置多大字数时显示当前字数和最大字数；
//      4. 最大高度限制(必须)：通过最大显示行数限制；通过最大显示高度限制；
//      5. 最小高度限制(非必须)：外界可约束最小高度，但注意代理中回调的初始高度，约束的最小高度不可低于该高度

/***

 
 注：该视图的适用范围：默认单行输入，即使有最小高度且最小高度能实现多行输入，有最大输入限制(最大字数、最大显示行数或最大显示高度)
            最大区别：中间输入，
 
 另，还可封装别的多行输入框：动态发布的那种，默认多行输入，底部有计数标签，根据字数进行显示和隐藏。
            最大区别：顶部输入，输入框的高度可能一定，也可能同上面一样进行动态改变。
 
 
 可考虑增加一个当前高度的属性

 */

/**
 
 * Bug1: 使用sizeToFits而不是使用行数方式的高度，目前，可避免：修改高度变化导致文字移动，而需要使用scrollToTop()来解决；
        注：Bug1不能算bug，因为那种方式已能完美解决，现在关键是bug2，而bug2无论是行数还是高度方式都不方便修复。
   Bug2: 长度超出时的截取导致输入框内容上下移动，待解决
 
 
 
 为了解决一些问题，可考虑在通知处理中适当使用下面的方式，处理一些异常情况，而且可能涉及输入法
 // 注：未达到字数限制但一次输入多个后导致超过限制会截取 或 达到限制但一次选中多个输入，截取能正确处理，但输入框却换行了。
 // 为了解决上述的问题，使用下面的scrollToTop()
 // 这样做的目的是为了避免多个输入截断时导致显示换行但实际内容不变的问题的解决。
 //        textView.scrollToTop()
 // 使用是为了解决搜狗输入法下的问题
 //            self.textView.scrollToTop()
 //            self.textView.sizeToFit()
 //            self.textView.scrollToBottom()
 
 
 **/

import UIKit
import Foundation

import KMPlaceholderTextView

protocol TSOriginalCenterOneInputViewProtocol: class {
    /// 文字更改回调
    func inputView(_ inputView: TSOriginalCenterOneInputView, didTextValueChanged newText: String) -> Void
    /// 高度更改回调
    func inputView(_ inputView: TSOriginalCenterOneInputView, didHeightChanged newHeight: CGFloat) -> Void

    // 注：初始高度回调有问题，待解决
    /// 初始高度回调
    func inputView(_ inputView: TSOriginalCenterOneInputView, didLoadedWith minHeight: CGFloat) -> Void

    /// 开始编辑回调 - 成为第一响应者时
    func beiginEditing(in inputView: TSOriginalCenterOneInputView) -> Void
    /// 结束编辑 - 失去第一响应者时
    func endEditing(in inputView: TSOriginalCenterOneInputView) -> Void
}

extension TSOriginalCenterOneInputViewProtocol {
    /// 开始编辑回调 - 成为第一响应者时
    func beiginEditing(in inputView: TSOriginalCenterOneInputView) -> Void {
    }
    /// 结束编辑 - 失去第一响应者时
    func endEditing(in inputView: TSOriginalCenterOneInputView) -> Void {
    }
}

/// 最大高度限制的类型
enum TSInputMaxHeightLimitType {
    /// 最大行数限制
    case maxLine
    /// 最大高度值限制
    case maxHeight
}

class TSOriginalCenterOneInputView: UIView {

    // MARK: - Internal Property
    weak var delegate: TSOriginalCenterOneInputViewProtocol?

    /// 当前文字
    var text: String? {
        set {
            self.textView.text = newValue
            self.placeHolderLabel.isHidden = !(newValue == nil || newValue!.isEmpty)
        }
        get {
            return self.textView.text
        }
    }
    fileprivate var currentText: String?

    /// 当前高度
    private(set) var currentHeight: CGFloat = 0
    /// 当前的最小高度
    private(set) var currentMinH: CGFloat = 0
    fileprivate var minHeight: CGFloat = 0

    /// 输入框最大输入数
    var maxTextCount: Int = 250
    /// 显示文字计数Label的最少文字数
    var showTextMinCount: Int = 15

    /// 默认的占位符
    var placeHolder: String? {
        didSet {
            self.placeHolderLabel.text = placeHolder
        }
    }

    // MARK: - Internal Function

    // MARK: - Private Property

    /// inputCountView - textView + textCountView 的封装
    fileprivate weak var inputCountView: UIView!
    /// 输入框
    private(set) weak var textView: UITextView!
    /// 输入框占位Label
    private(set) weak var placeHolderLabel: UILabel!
    /// 文字计数视图所在行，用于包装文字计数Label，并开关。
    private(set) weak var textCountView: UIView!
    /// 文字计数Label
    private(set) weak var textCountLabel: UILabel!

    /// 上一次是否显示计数
    private var lastShowCount: Bool = false
    /// 上一次的行数
    private var lastLines: Int = 1
    /// 上一次显示的高度
    private var lastShowHeight: CGFloat = 0

    /// 文字输入框的字体
    private let textFont: UIFont

    /// 最大高度显示
    /// 最大高度限制类型
    private let maxHeightType: TSInputMaxHeightLimitType
    /// 最大行数显示限制
    /// Reamrk: - 应考虑当其为赋值为0时表示不限制行数展示。
    private let maxShowLine: Int
    /// 最大高度显示限制
    private let maxShowHeight: CGFloat
    /// 左右间距
    var lrMargin: CGFloat = 15

    let tbMargin: CGFloat
    /// 控件宽度
    let viewWidth: CGFloat

    /// 文字计数的高度
    private var textCountH: CGFloat {
        return 15.0 + self.tbMargin
    }

//    /// 当前是否展示字数
//    private var currentShowTextCountFlag: Bool = false
//    /// 当前是否单行展示(默认是单行展示)
//    private var currentSingleLineFlag: Bool = true
//    /// 最大宽度
//    private let maxWidth: CGFloat

    // MARK: - Initialize Function

    ///
    init(viewWidth: CGFloat, font: UIFont, maxLine: Int, showTextMinCount: Int, maxTextCount: Int, lrMargin: CGFloat, tbMargin: CGFloat) {
        self.viewWidth = viewWidth
        self.textFont = font
        self.maxShowLine = maxLine
        self.showTextMinCount = showTextMinCount
        self.maxTextCount = maxTextCount
        self.lrMargin = lrMargin
        self.tbMargin = tbMargin
        self.maxShowHeight = 0
        self.maxHeightType = .maxLine
        super.init(frame: CGRect.zero)
        self.initialUI()
    }

    init(viewWidth: CGFloat, font: UIFont, maxHeight: CGFloat, showTextMinCount: Int, maxTextCount: Int, lrMargin: CGFloat, tbMargin: CGFloat) {
        self.viewWidth = viewWidth
        self.textFont = font
        self.maxShowHeight = maxHeight
        self.showTextMinCount = showTextMinCount
        self.maxTextCount = maxTextCount
        self.lrMargin = lrMargin
        self.tbMargin = tbMargin
        self.maxShowLine = 0
        self.maxHeightType = .maxHeight
        super.init(frame: CGRect.zero)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private  UI

    // 界面布局——使用textView + placeLabel + countLabel
    private func initialUI() -> Void {
        // 0. inputCountView
        let inputCountView = UIView()
        self.addSubview(inputCountView)
        inputCountView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.centerY.equalTo(self)

            // 注意：顶部与底部的高度约束，保证没有最小高度限制时能自适应，有最小高度限制时能居中
            make.top.greaterThanOrEqualTo(self).offset(tbMargin)
            make.bottom.lessThanOrEqualTo(self).offset(-tbMargin)
        }
        // 1. inputView
        // 1.1 textView 单行时一定是位于最小高度的中间、高度随文字而变化，有字数限制和最大高度限制
        let textView = UITextView()
        inputCountView.addSubview(textView)
        // textView中的文字默认是有内边距的
        textView.textContainerInset = UIEdgeInsets.zero
        textView.font = self.textFont
        textView.textColor = TSColor.main.content
        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(inputCountView).offset(lrMargin)
            make.trailing.equalTo(inputCountView).offset(-lrMargin)
            make.top.equalTo(inputCountView)
            // 单行约束，多行时进行修正
            make.height.equalTo(self.textFont.lineHeight)
        }
        self.textView = textView
        // 1.2 placeHolder
        let placeLabel = UILabel(text: "", font: self.textFont, textColor: TSColor.normal.disabled)
        inputCountView.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(inputCountView).offset(lrMargin + 5)
            make.trailing.equalTo(inputCountView).offset(-lrMargin - 5)
            make.centerY.equalTo(textView)
        }
        self.placeHolderLabel = placeLabel
        // 2. textCountView
        let textCountView = UIView()
        inputCountView.addSubview(textCountView)
        textCountView.isHidden = true   // 默认隐藏，且高度为0
        textCountView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(inputCountView)
            make.top.equalTo(textView.snp.bottom)
            make.bottom.equalTo(inputCountView)
            make.height.equalTo(0)
        }
        self.textCountView = textCountView
        // 2.x textCountLabel
        // 默认不展示，只有当文字超过指定字数时才展示；当前字的颜色动态设置(0xee2727, 0x333333)
        let textCountLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.main.content, alignment: .right)
        textCountView.addSubview(textCountLabel)
        textCountLabel.text = String(format: "%d/%d", 0, self.maxTextCount)
        textCountLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(inputCountView).offset(-lrMargin)
            //make.centerY.equalTo(textCountView)
            make.bottom.equalTo(textCountView)
        }
        self.textCountLabel = textCountLabel
        // 4. 添加通知
        NotificationCenter.default.addObserver(self, selector:#selector(textViewDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        // Reamrk: - 这里的回调一定不会走，因此需要另外一个地方来放置回调，待解决
        // 5. 最小高度回调
        // TODO: - 待解决
        textCountView.isHidden = self.showTextMinCount >= 1
        let textCountH: CGFloat = self.showTextMinCount >= 1 ? 0 : self.textCountH
        textCountView.snp.updateConstraints { (make) in
            make.height.equalTo(textCountH)
        }
        let minHeight: CGFloat = self.textFont.lineHeight + textCountH + tbMargin * 2
        self.delegate?.inputView(self, didLoadedWith: minHeight)

        self.currentMinH = minHeight
        self.minHeight = minHeight
        self.currentHeight = minHeight
    }

    // MARK: - 通知处理

    /// UITextView输入框开始编辑时的通知
    @objc fileprivate func textViewBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.textView {
            return
        }
        self.delegate?.beiginEditing(in: self)
    }
    /// UITextView输入框结束编辑时的通知
    @objc fileprivate func textViewEndEditingNotificationProcess(_ notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.textView {
            return
        }
        self.delegate?.endEditing(in: self)
    }
    /// UITextView输入的通知处理
    @objc private func textViewDidChanged(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.textView {
            return
        }
        // 输入内容处理
        let maxLen = self.maxTextCount
        let text = textView.text
        // 占位处理
        self.placeHolderLabel.isHidden = !(nil == text || text!.isEmpty)
        // 内容为空时的处理
        if nil == text || text!.isEmpty {
            self.currentText = text
            self.currentMinH = self.minHeight
            // 限制显示计数的字数为1时，进行特殊处理
            if self.showTextMinCount == 1 {
                self.textCountView.isHidden = true
                self.textCountView.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
                self.lastShowCount = false
                let height = self.textFont.lineHeight + self.tbMargin * 2
                self.currentHeight = height
                self.delegate?.inputView(self, didHeightChanged: height)
                self.layoutIfNeeded()
            }
            // 文字计数更新
            self.setupTextCount(currentNum: 0)
            self.delegate?.inputView(self, didTextValueChanged: textView.text)
            return
        }
        // 内容不为空时的处理
        // 1. 字数限制 - 注：使用下面方式而不使用封装，是为了解决搜狗输入法时的输入异常。
        //TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxLen)
        if textView.markedTextRange == nil && text!.count > maxLen { // 判断是否处于拼音输入状态
            textView.text = text!.substring(to: text!.index(text!.startIndex, offsetBy: maxLen))
            textView.scrollToBottom()
        }
        // 2. 判断当前文字内容是否更改，避免文字内容过长时的切割导致实际没有改变
        if self.currentText == textView.text {
            return
        }
        // 3.文字内容发生更改时的处理：高度、约束
        self.currentText = textView.text
        self.delegate?.inputView(self, didTextValueChanged: self.currentText!)

        /// 高度改变的标记：字数统计的显示与隐藏、行数改变
        var heightChangeFlag: Bool = false
        /// 文字输入框展示高度
        var showTextViewH: CGFloat = self.textFont.lineHeight
        // 4. 字数显示判断处理
        let currentShowCount: Bool = (self.currentText!.count >= self.showTextMinCount) ? true : false

        let showTextCountH: CGFloat = currentShowCount ? self.textCountH : 0

        self.textCountView.isHidden = !currentShowCount
        if currentShowCount != lastShowCount {
            lastShowCount = currentShowCount
            // 计数显示状态修正
            self.textCountView.snp.updateConstraints({ (make) in
                make.height.equalTo(showTextCountH)
            })
            self.layoutIfNeeded()
            heightChangeFlag = true
        }

        if currentShowCount {
            // 显示计数更新 - 颜色标记待完成
            self.setupTextCount(currentNum: self.currentText!.count)
        }
        // 5. 高度修正
        // 1. 使用 textView.contentSize.height 和 font.lineHeight 来计算行数处理
        let numLines: Int = Int(textView.contentSize.height / self.textFont.lineHeight)
        switch self.maxHeightType {
        case .maxLine:
            // 最大行数展示判断
            let showLine: Int = (numLines > self.maxShowLine) ? self.maxShowLine : numLines
            if showLine != lastLines {
                self.lastLines = numLines
                self.textView.snp.updateConstraints({ (make) in
                    make.height.equalTo(textView.contentSize.height)
                })
                self.layoutIfNeeded()
                heightChangeFlag = true
                showTextViewH = textView.contentSize.height
            } else {
                showTextViewH = CGFloat(showLine) * self.textFont.lineHeight
            }
        case .maxHeight:
            // 最大高度展示判断
            let showHeight: CGFloat = (textView.contentSize.height > self.maxShowHeight) ? self.maxShowHeight : textView.contentSize.height
            if lastShowHeight != showHeight {
                self.lastShowHeight = showHeight
                self.textView.snp.updateConstraints({ (make) in
                    make.height.equalTo(showHeight)
                })
                self.layoutIfNeeded()
                heightChangeFlag = true
                showTextViewH = textView.contentSize.height
            } else {
                // 注：该方式下的计算不准确，需更正  - 因目前并没有使用该方式，并没有具体测试过
                showTextViewH = self.maxShowHeight
            }
        }
        // 高度更改的回调
        if heightChangeFlag {
            let height: CGFloat = showTextViewH + showTextCountH + tbMargin * 2.0
            self.currentMinH = height
            self.currentHeight = height
            self.delegate?.inputView(self, didHeightChanged: height)
            textView.scrollToTop()
        }

        // 2. 使用sizeThatFits
//        let constraintSize = CGSize(width: self.maxWidth - lrMargin * 2.0, height: CGFloat(MAXFLOAT))
//        let size = self.textView.sizeThatFits(constraintSize)
//        self.textView.snp.updateConstraints { (make) in
//            make.height.equalTo(size.height)
//        }
//        self.layoutIfNeeded()
//        self.textView.scrollToTop()
//        let height: CGFloat = self.textCountH + size.height
//        self.delegate?.newInputView(self, didHeightChanged: height)

    }

    /// 文字计数统计
    fileprivate func setupTextCount(currentNum: Int) -> Void {
        let currentCount: String = String(format: "%d", currentNum)
        let countText: String = String(format: "%d/%d", currentNum, self.maxTextCount)
        let attText = NSMutableAttributedString(string: countText)
        attText.addAttribute(NSForegroundColorAttributeName, value: TSColor.normal.disabled, range: attText.rangeOfAll())
        attText.addAttribute(NSForegroundColorAttributeName, value: TSColor.normal.disabled, range: NSRange(location: 0, length: currentCount.count))
        self.textCountLabel.attributedText = attText
    }

}
