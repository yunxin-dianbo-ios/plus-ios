//
//  TSInputView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 05/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  通用输入框
//  当前的输入框暂时不考虑最大高度
//  TSOriginalCenterOneLineInputView

//  TSMultiLineInputView

//  OriginalType: OriginalCenter/OriginalTop
//  HeightLimitType: maxLine/maxHeight
//  之后的考虑方向

import Foundation
import KMPlaceholderTextView

protocol TSInputViewProtocol: class {
    func inputView(_ inputView: TSInputView, didTextValueChanged newText: String) -> Void
    func inputView(_ inputView: TSInputView, didHeightChanged newHeight: CGFloat) -> Void
}

class TSInputView: UIView {

    // MARK: - Internal Property
    weak var delegate: TSInputViewProtocol?
    /// 输入框
    private(set) weak var textView: UITextView!
    /// 输入框占位Label
    private(set) weak var placeHolderLabel: UILabel!

//    private(set) weak var textView: KMPlaceholderTextView!
    /// 文字计数Label
    private(set) weak var textCountLabel: UILabel!
    /// 输入框最大输入数
    var maxTextCount: Int = 50
    /// 显示文字计数Label的最少文字数
    var showTextMinCount: Int = 40

    var placeHolder: String? {
        didSet {
            self.placeHolderLabel.text = placeHolder
        }
    }

    // MARK: - Internal Function

    // MARK: - Private Property
    private var minH: CGFloat = 50
//    private var width: CGFloat
    private var my_width: CGFloat
    private var lrMargin: CGFloat = 15
//    private var tbMargin: CGFloat = 15
//    private var tbMargin: CGFloat = 15
//    let lrMargin: CGFloat = 20
    let tbMargin: CGFloat = 20  // 上下间距
    let textCountTBmargin: CGFloat = 15 // 文字计数的上下间距

//    let minH: CGFloat = self.minH
//    let width: CGFloat = ScreenWidth
//    let lrMargin: CGFloat = 20
//    let tbMargin: CGFloat = 20  // 单行时的上下间距
//    let textCountTBmargin: CGFloat = 15 // 文字计数的上下间距

    private let singleLineH: CGFloat = 25

    private var currentText: String?
    /// 当前是否展示字数
    private var currentShowTextCountFlag: Bool = false
    /// 当前是否单行展示(默认是单行展示)
    private var currentSingleLineFlag: Bool = true

    // MARK: - Initialize Function
    init(minH: CGFloat, width: CGFloat) {
        self.my_width = width
        self.minH = minH
        super.init(frame: CGRect.zero)

//        self.initialUI()

        self.oldinitialUI()
        self.placeHolderLabel.isHidden = false
    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
////        self.initialUI()
//    }
    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.initialUI()
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private  UI

//    // 界面布局——使用KMPlaceholderTextView + countLabel
//    private func initialUI() -> Void {
////        NotificationCenter.default.addObserver(self,
////                                               selector: #selector(textDidChange),
////                                               name: NSNotification.Name.UITextViewTextDidChange,
////                                               object: nil)
//        
//        let minH: CGFloat = 55
//        let width: CGFloat = ScreenWidth
//        let lrMargin: CGFloat = 20
//        let tbMargin: CGFloat = 20  // 单行时的上下间距
//        let textCountTBmargin: CGFloat = 15 // 文字计数的上下间距
//        // 1. textView
//        let textView = KMPlaceholderTextView()
//        self.addSubview(textView)
//        textView.placeholderFont = UIFont.systemFont(ofSize: 15)
//        textView.font = UIFont.systemFont(ofSize: 15)
//        textView.placeholderColor = TSColor.normal.disabled
//        textView.textColor = TSColor.main.content
//        textView.textContainerInset = UIEdgeInsets.zero
//        textView.snp.makeConstraints { (make) in
//            make.leading.equalTo(self).offset(lrMargin)
//            make.trailing.equalTo(self).offset(-lrMargin)
//            make.top.equalTo(self).offset(2)
//            make.bottom.equalTo(self).offset(-2)
//        }
//        self.textView = textView
//        // 2. textCountLabel    ——  默认不展示，只有当文字超过指定字数时才展示；当前字的颜色动态设置(0xee2727, 0x333333)
//        let textCountLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.main.content, alignment: .right)
//        self.addSubview(textCountLabel)
//        textCountLabel.isHidden = true
//        textCountLabel.snp.makeConstraints { (make) in
//            make.trailing.equalTo(self).offset(-lrMargin)
//            make.bottom.equalTo(self).offset(-textCountTBmargin)
//        }
//        self.textCountLabel = textCountLabel
//    }

    // 界面布局——使用textView + placeLabel + countLabel
    private func oldinitialUI() -> Void {
        // 1. textView      ——  单行时一定是位于最小高度的中间、高度随文字而变化，有字数限制和最大高度限制
        let textView = UITextView()
        self.addSubview(textView)
        // textView中的文字默认是有内边距的
        textView.textContainerInset = UIEdgeInsets.zero
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = TSColor.main.content
        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(lrMargin)
            make.trailing.equalTo(self).offset(-lrMargin)
            // 单行约束，多行时进行修正
            make.height.equalTo(17)
            make.centerY.equalTo(self)
        }
        self.textView = textView
        // 2. placeHolder   ——  最小高度的中间
        let placeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.disabled)
        self.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(lrMargin)
            make.trailing.equalTo(self).offset(-lrMargin)
            make.centerY.equalTo(self.snp.top).offset(minH * 0.5)
        }
        self.placeHolderLabel = placeLabel
        // 3. textCountLabel    ——  默认不展示，只有当文字超过指定字数时才展示；当前字的颜色动态设置(0xee2727, 0x333333)
        let textCountLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.main.content, alignment: .right)
        self.addSubview(textCountLabel)
//        textCountLabel.isHidden = true
        textCountLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self).offset(-lrMargin)
            make.bottom.equalTo(self).offset(-15)
        }
        self.textCountLabel = textCountLabel
        // 4. 添加通知
        NotificationCenter.default.addObserver(self, selector:#selector(textViewDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    // MARK: - 通知处理

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
            self.delegate?.inputView(self, didTextValueChanged: textView.text)
            return
        }

        // 内容不为空时的处理

//        // 1. 字数限制
//        TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxLen)
//        // 2. 判断当前文字内容是否更改，避免文字内容过长时的切割导致实际没有改变
//        if self.currentText == textView.text {
//            return
//        }

        // 3.文字内容发生更改时的处理：高度、约束
        self.currentText = textView.text
        var viewH: CGFloat = self.minH
        // 高度处理
        let textSize = textView.sizeThatFits(CGSize(width: self.my_width - self.lrMargin * 2, height: CGFloat(MAXFLOAT)))
        // 判断新内容是单行还是多行(多行至少2行/2行至少30)
        let isSingleLineFlag: Bool = textSize.height < 30
        // 判断当前是否展示字数标签
        let isShowTextCountFlag: Bool = textView.text.count >= self.showTextMinCount

        // 单行状态变更判断
        if self.currentSingleLineFlag != isSingleLineFlag {
            // 单行状态变更：可能由多行变成单行，也可能由单行变成多行
            self.currentSingleLineFlag = isSingleLineFlag

            if isSingleLineFlag {
                // 单行展示
//                self.textCountLabel.isHidden = true
                self.textView.snp.remakeConstraints({ (make) in
                    make.leading.equalTo(self).offset(lrMargin)
                    make.trailing.equalTo(self).offset(-lrMargin)
                    make.height.equalTo(singleLineH)
                    make.centerY.equalTo(self)
                })
//                self.textCountLabel.snp.removeConstraints()
                self.textCountLabel.snp.remakeConstraints({ (make) in
                    make.trailing.equalTo(self).offset(-lrMargin)
                    make.bottom.equalTo(self).offset(-15)
                })
            } else {
                // 多行展示，由单行刚转变成的多行。

                // 判断当前是否展示字数标签
                self.currentShowTextCountFlag = isShowTextCountFlag
//                self.textCountLabel.isHidden = !isShowTextCountFlag
                if isShowTextCountFlag {
                    // 多行 且 展示字数标签
                    self.textView.snp.remakeConstraints({ (make) in
                        make.leading.equalTo(self).offset(lrMargin)
                        make.trailing.equalTo(self).offset(-lrMargin)
                        make.height.equalTo(textSize.height)
                        make.top.equalTo(self).offset(tbMargin)
                    })
                    self.textCountLabel.snp.remakeConstraints({ (make) in
                        make.trailing.equalTo(self).offset(-lrMargin)
                        make.top.equalTo(self.textView.snp.bottom).offset(textCountTBmargin)
                        make.bottom.equalTo(self).offset(-textCountTBmargin)
                    })
                    viewH = tbMargin + textSize.height + textCountTBmargin * 2.0
                } else {
                    // 多行 且 不展示字数标签
                    self.textView.snp.remakeConstraints({ (make) in
                        make.leading.equalTo(self).offset(lrMargin)
                        make.trailing.equalTo(self).offset(-lrMargin)
                        make.height.equalTo(textSize.height)
                        make.top.equalTo(self).offset(tbMargin)
                        make.bottom.equalTo(self).offset(-tbMargin)
                    })
                    self.textCountLabel.snp.removeConstraints()
                    viewH = tbMargin * 2.0 + textSize.height
                }
            }

        } else {
            // 单行状态没有变更，则当前可能单行，也可能多行

            if isSingleLineFlag {
                // 单行展示
//                self.textCountLabel.isHidden = true
            } else {
                // 多行展示

                // 判断当前是否需要变更字数标签的展示状态

                if self.currentShowTextCountFlag != isShowTextCountFlag {
                    // 需要变更字数标签的状态
                    self.currentShowTextCountFlag = isShowTextCountFlag
//                    self.textCountLabel.isHidden = !isShowTextCountFlag

                    if isShowTextCountFlag {
                        // 展示字数标签
                        self.textView.snp.remakeConstraints({ (make) in
                            make.leading.equalTo(self).offset(lrMargin)
                            make.trailing.equalTo(self).offset(-lrMargin)
                            make.height.equalTo(textSize.height)
                            make.top.equalTo(self).offset(tbMargin)
                        })
                        self.textCountLabel.snp.remakeConstraints({ (make) in
                            make.trailing.equalTo(self).offset(-lrMargin)
                            make.top.equalTo(self.textView.snp.bottom).offset(textCountTBmargin)
                            make.bottom.equalTo(self).offset(-textCountTBmargin)
                        })
                        viewH = tbMargin + textSize.height + textCountTBmargin * 2.0
                    } else {
                        // 隐藏字数标签
                        self.textView.snp.remakeConstraints({ (make) in
                            make.leading.equalTo(self).offset(lrMargin)
                            make.trailing.equalTo(self).offset(-lrMargin)
                            make.height.equalTo(textSize.height)
                            make.top.equalTo(self).offset(tbMargin)
                            make.bottom.equalTo(self).offset(-tbMargin)
                        })
//                        self.textCountLabel.snp.removeConstraints()
                        self.textCountLabel.snp.remakeConstraints({ (make) in
                            make.trailing.equalTo(self).offset(-lrMargin)
                            make.bottom.equalTo(self).offset(-15)
                        })
                        viewH = tbMargin * 2.0 + textSize.height
                    }
                } else {
                    // 无需变更字数标签的状态

                    // 更新textView的高度
                    self.textView.snp.updateConstraints({ (make) in
                        make.height.equalTo(textSize.height)
                    })
                    // 根据当前是否展示字数标签来进行高度计算
                    if self.currentShowTextCountFlag {
                        viewH = tbMargin + textSize.height + textCountTBmargin * 2.0
                    } else {
                        viewH = tbMargin * 2.0 + textSize.height
                    }
                }
            }
        }

        // 字数标签展示配置
        if self.currentShowTextCountFlag {
            let strCurrent: String = "\(textView.text.count)"
            let strCount: String = strCurrent + "/" + "\(self.maxTextCount)"
//            let attStr = NSMutableAttributedString(string: strCount)
//            attStr.setColor(UIColor(hex: 0xee2727), range: NSRange(location: 0, length: strCurrent.count))
//            self.textCountLabel.attributedText = attStr

            self.textCountLabel.text = strCount
        }
        // 回调处理
        self.delegate?.inputView(self, didTextValueChanged: textView.text)
        self.delegate?.inputView(self, didHeightChanged: viewH)
    }

}
