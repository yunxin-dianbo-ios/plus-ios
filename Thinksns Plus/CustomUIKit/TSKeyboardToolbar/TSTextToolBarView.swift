//
//  TSTextToolBarView.swift
//  KeyboardToolbar
//
//  Created by LeonFa on 2017/2/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 键盘工具栏布局视图

import UIKit
import SnapKit
import KMPlaceholderTextView

 @objc protocol TSTextToolBarViewDelegate: NSObjectProtocol {
    func sendTextMessage(message: String, inputBox: AnyObject?)
    func removeToolBar()
    func emojiClick(emoji: String)
    @objc optional func changeFrame(currentHeight: CGFloat)
}

class TSTextToolBarView: UIView, UITextViewDelegate, TSSystemEmojiSelectorViewDelegate {

    typealias ChangeHeightClosure = (CGFloat) -> Void

    private var emojiViewHeight: CGFloat = 145
    var scrollMaxHeight: CGFloat = 120 + 145 + TSBottomSafeAreaHeight
    // 按钮圆角
    private let buttonCorner: CGFloat = 3.0
    // 按钮右边距
    private let buttonRightmargin: CGFloat = 10.0
    // 按钮下边距
    private let buttonButtommargin: CGFloat = 9.0
    // 按钮尺寸
    private let buttonSize: CGSize = CGSize(width: 45.0, height: 26.0)
    // 下分割线左边距
    private let bottomLineLeftmargin: CGFloat = 10.0 + 10 + 18
    // 下分割线右边距
    private let bottomLineRightmargin: CGFloat = 8.0
    // 下分割线的下边距
    private let bottomLineBottommargin: CGFloat = 8.0
    // 下分割线的高度
    private let bottomLineHeight: CGFloat = 0.5
    // 显示字数下边距
    private let showTextNumberButtommargin: CGFloat = 10.0
    // 在多少字数后显示字数提示(不要低于50)
    public var maximumWord: Int = 200
    // 最大字数限制
    public var maximumWordLimit: Int = 255
    // 获取当前的高度以便改变父类高度
    public var changeHeightClosure: ChangeHeightClosure? = nil
    // 父类的初始高度
    public var superViewSourceHeight: CGFloat = 0
    // 传过来的文本输入框
    public var inputBox: AnyObject?

    // 发送按钮
    private var sendButton: UIButton
    // 显示字数
    private var showTextNumber: UILabel
    // 录入文本
    var sendTextView: KMPlaceholderTextView
    // 下分割线
    private var bottomLine: UIView
    // 上分割线
    private var topLine: UIView
    /// 表情按钮
    var smileButton = UIButton(type: .custom)
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!

    weak var toolBarViewDelegate: TSTextToolBarViewDelegate?
    // MARK -  Lifecycle
    ///
    /// - Parameter frame: 尺寸
    /// - Parameter initType: true TSKeyboardToolbar 创建而来 false TSMusicCommentToolView 创建而来(本项目有两个地方用到此类)
    init(frame: CGRect, superViewSourceHeight: CGFloat) {
        sendButton = UIButton(type: .custom)
        sendTextView = KMPlaceholderTextView()
        bottomLine = UIView()
        topLine = UIView()
        showTextNumber = UILabel()
        super.init(frame: frame)
        self.superViewSourceHeight = superViewSourceHeight
        setUI()
    }

    private func setUI() {
        self.addSubview(topLine)
        topLine.backgroundColor = TSColor.normal.keyboardTopCutLine
        topLine.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(bottomLineHeight)
        }

        /// 设置按钮
        self.addSubview(sendButton)
        sendButton.setTitle("显示_发送".localized, for: .normal)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)
        sendButton.backgroundColor = UIColor.lightGray
        sendButton.layer.cornerRadius = 3.0
        sendButton.layer.masksToBounds = true
        sendButton.addTarget(self, action: #selector(sendText(_:)), for: .touchUpInside)
        sendButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-buttonRightmargin)
            make.bottom.equalTo(self.snp.bottom).offset(-buttonButtommargin - emojiViewHeight - TSBottomSafeAreaHeight)
            make.size.equalTo(buttonSize)
        }

        self.addSubview(smileButton)
        smileButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(10)
            make.centerY.equalTo(sendButton.snp.centerY)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        smileButton.setImage(#imageLiteral(resourceName: "ico_chat_keyboard_expression"), for: .normal)
        smileButton.setImage(UIImage(named: "ico_comment_keyboard"), for: .selected)
        smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControlEvents.touchUpInside)

        // 设置字数文本框
        self.addSubview(showTextNumber)
        showTextNumber.snp.makeConstraints { (make) in
            make.bottom.equalTo(sendButton.snp.bottom)
            make.centerX.equalTo(sendButton.snp.centerX)
        }
        showTextNumber.alpha = 0.2
        showTextNumber.isHidden = true

        /// 设置下划线
        self.addSubview(bottomLine)
        bottomLine.backgroundColor = TSColor.main.theme
        bottomLine.snp.makeConstraints({ (make) in
            make.left.equalTo(self.snp.left).offset(bottomLineLeftmargin)
            make.right.equalTo(sendButton.snp.left).offset(-bottomLineRightmargin)
            make.bottom.equalTo(self.snp.bottom).offset(-bottomLineBottommargin - emojiViewHeight - TSBottomSafeAreaHeight)
            make.height.equalTo(bottomLineHeight)
        })

        /// 限制输入文本框字数
        NotificationCenter.default.addObserver(self, selector:  #selector(self.textViewDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)

        // 设置文本框
        self.addSubview(sendTextView)
        sendTextView.placeholder = "随便说说~~"
        sendTextView.backgroundColor = UIColor.clear
        sendTextView.delegate = self
        sendTextView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.comment.rawValue)
        sendTextView.placeholderColor = TSColor.normal.disabled
        sendTextView.textColor = TSColor.main.content
        sendTextView.font = UIFont.systemFont(ofSize: TSFont.ContentText.comment.rawValue)
        sendTextView.isScrollEnabled = false
        sendTextView.layoutManager.allowsNonContiguousLayout = false
        sendTextView.returnKeyType = .send
        sendTextView.snp.makeConstraints { (make) in
            make.leftMargin.equalTo(bottomLine.snp.leftMargin)
            make.right.equalTo(bottomLine.snp.rightMargin)
            make.bottom.equalTo(bottomLine.snp.top)
            let newSize = sendTextView.sizeThatFits(CGSize(width: sendTextView.frame.size.width, height: CGFloat(MAXFLOAT)))
            make.height.equalTo(newSize.height)
        }

        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 44, width: ScreenWidth, height: 0))
        emojiView.delegate = self
        self.addSubview(emojiView)
        emojiView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(emojiViewHeight + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight())
            make.width.equalTo(ScreenWidth)
            make.centerX.equalTo(ScreenWidth / 2.0)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        sendButton.backgroundColor = textView.text.isEmpty ? TSColor.normal.disabled : TSColor.main.theme
        // 免得搞忘，，这步是设置如果在粘贴的情况下超过字数如何处理
        if textView.text.count > maximumWordLimit {
            let str = textView.text
            if let str = str {
                let aaa = str.substring(to: str.index(str.startIndex, offsetBy: maximumWordLimit))
                textView.text = aaa
                textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 300, height: 300), animated: true)
                setAllComponenSize(textView: textView)
                return
            }
        }
       self.setAllComponenSize(textView: textView)
        /// 匹配at人的情况
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            let range = textView.selectedRange
            let attString = NSMutableAttributedString(string: textView.text)
            attString.addAttributes([NSForegroundColorAttributeName: textView.textColor, NSFontAttributeName: textView.font], range: NSRange(location: 0, length: attString.length))
            let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
            for item in matchs {
                attString.addAttributes([NSForegroundColorAttributeName: TSColor.main.theme], range: NSRange(location: item.range.location, length: item.range.length - 1))
            }
            textView.attributedText = attString
            textView.selectedRange = range
            return
        }
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        /// 整体不可编辑
        // 联想文字则不修改
        let range = textView.selectedRange
        if range.length > 0 {
            return
        }
        let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
        for match in matchs {
            let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            if NSLocationInRange(range.location, newRange) {
                textView.selectedRange = NSRange(location: match.range.location + match.range.length, length: 0)
                break
            }
        }
    }
    func setAllComponenSize(textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))

        let currentComponentHeight = bottomLineBottommargin + bottomLineHeight + newSize.height + emojiViewHeight + TSBottomSafeAreaHeight

        if textView.text.count >= maximumWord {
            self.showTextNumber.isHidden = false
            showTextNumber.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(sendButton.snp.top).offset(-showTextNumberButtommargin)
                make.centerX.equalTo(sendButton.snp.centerX)
            })

            UIView.animate(withDuration: 0.2, animations: {
                self.showTextNumber.layoutIfNeeded()
                self.showTextNumber.alpha = 1
            })

            let strCount = textView.text.count > maximumWordLimit ? maximumWordLimit : textView.text.count
            showTextNumber.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: "\(strCount)" as NSString, firstColor: TSColor.normal.statisticsNumberOfWords, firstSize: TSFont.SubInfo.statisticsNumberOfWords.rawValue), second: (secondString: "/\(maximumWordLimit)" as NSString, secondColor: TSColor.normal.blackTitle, TSFont.SubInfo.statisticsNumberOfWords.rawValue))
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.showTextNumber.alpha = 0.2
            }, completion: { (_) in
                self.showTextNumber.isHidden = true
            })
        }

        if currentComponentHeight >= scrollMaxHeight {
            textView.isScrollEnabled = true
            sendTextView.snp.updateConstraints { (make) in
                make.height.equalTo(80)
                make.bottom.equalTo(bottomLine.snp.top).offset(-3)
            }

            if let changeHeightClosure = self.changeHeightClosure {
                changeHeightClosure(scrollMaxHeight - 20)
            }

            self.snp.remakeConstraints { (make) in
                make.bottom.right.left.equalTo(self.superview!)
                make.height.equalTo(scrollMaxHeight - 20)
            }
        } else {
            textView.isScrollEnabled = false
            sendTextView.snp.updateConstraints { (make) in
                make.height.equalTo(newSize.height)
                make.bottom.equalTo(bottomLine.snp.top)
            }
            self.snp.remakeConstraints { (make) in
                make.bottom.right.left.equalTo(self.superview!)
                make.height.equalTo(currentComponentHeight)
            }

            if let changeHeightClosure = self.changeHeightClosure {
                changeHeightClosure(currentComponentHeight)
            }
        }
    }

    func setSendViewParameter(placeholderText: String, inputbox: AnyObject?, maximumWordLimit: Int) {
        self.maximumWordLimit = maximumWordLimit
        self.inputBox = inputbox
        sendTextView.placeholder = placeholderText
        sendTextView.becomeFirstResponder()
        if self.inputBox is UITextField {
            let inputTextField = self.inputBox as? UITextField
              sendTextView.text = inputTextField?.text
        } else if self.inputBox is UITextView {
            let inputTextField = self.inputBox as? UITextView
              sendTextView.text = inputTextField?.text
        } else {
            TSLogCenter.log.verbose("TSKeyboardToolbar没有传入对象")
        }

        self.setAllComponenSize(textView: sendTextView)

    }

    @objc private func textViewDidChanged(notification: Notification) {

        TSAccountRegex.checkAndUplodTextFieldText(textField: sendTextView, stringCountLimit: maximumWordLimit)
    }
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.sendMessage()
            return false
        }
        if text == "" {
            let selectRange = textView.selectedRange
            if selectRange.length > 0 {
                return true
            }
            // 整体删除at的关键词，修改为整体选中
            var isEditAt = false
            var atRange = selectRange
            let mutString = NSMutableString(string: textView.text)
            let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
            for match in matchs {
                let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
                if NSLocationInRange(range.location, newRange) {
                    isEditAt = true
                    atRange = match.range
                    break
                }
            }
            if isEditAt {
                textView.text = String(mutString)
                textView.selectedRange = atRange
                return false
            }
        } else if text == "@" {
            // 跳转到at列表
            // 手动输入的at在选择了用户的block中会先移除掉,如果跳转后不选择用户就不做处理
            TSKeyboardToolbar.share.isAtActionPush = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tsnotiNamepushAtSelectedList"), object: ["textView": textView])
            toolBarViewDelegate?.removeToolBar()
            return true
        }
        return true
    }

    @objc private func sendText(_ btn: UIButton) {
        self.sendMessage()
    }

    private func sendMessage() {

        if self.inputBox is UITextField {
            let inputTextField = self.inputBox as? UITextField
            inputTextField?.text = sendTextView.text
        } else if self.inputBox is UITextView {
            let inputTextView = self.inputBox as? UITextView
            inputTextView?.text = sendTextView.text
        }
        sendTextView.text = sendTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sendTextView.text = sendTextView.text.replacingOccurrences(of: "\r", with: "")
        sendTextView.text = sendTextView.text.replacingOccurrences(of: "\n", with: "")

        let number = "^\\s*|\\s*$"
        let numberPre = NSPredicate(format: "SELF MATCHES %@", number)
        if numberPre.evaluate(with: sendTextView.text) {
         return
        }
        /// 转换手动输入的at为TS+的at规则
        sendTextView.text = TSUtil.replaceEditAtString(inputStr: sendTextView.text)
        self.toolBarViewDelegate?.sendTextMessage(message: sendTextView.text, inputBox: self.inputBox)
        sendTextView.text = ""
        self.textViewDidChange(sendTextView)
        toolBarViewDelegate?.removeToolBar()
    }

    func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            sendTextView.resignFirstResponder()
        } else {
            sendTextView.becomeFirstResponder()
        }
    }

    func emojiViewDidSelected(emoji: String) {
        toolBarViewDelegate?.emojiClick(emoji: emoji)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
