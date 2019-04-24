//
//  FeedCommentLabel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态评论 label

import UIKit
import TYAttributedLabel

protocol FeedCommentLabelDelegate: class {
    /// 点击了评论内容中的用户名
    func feedCommentLabel(_ label: FeedCommentLabel, didSelectedUser userId: Int)
    /// 长按了评论
    func feedCommentLabelDidLongpress(_ label: FeedCommentLabel)
    /// 点击了评论
    func feedCommentListCellDidPress(_ cell: FeedCommentLabel)
}

class FeedCommentLabel: TYAttributedLabel {

    /// 代理
    weak var feedCommentDelegate: FeedCommentLabelDelegate?

    /// 当前评论的数据模型
    var model = FeedCommentLabelModel() {
        didSet {
            loadModel()
        }
    }

    init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - setDatas

    /// 加载 model 的数据
    func loadModel() {
        self.delegate = self
        // 1.设置文字内容
        switch model.type {
        case .text:
            /// 评论了动态
            commentText()
        case .user(let replyName, _):
            /// 评论了某个用户的评论
            comment(user: replyName)
        }
        // 2.添加置顶标签图片
        if model.showTopIcon {
            appendText("  ")
            append(UIImage(named: "IMG_label_zhiding"))
        }
    }

    /// 评论了动态时，需要显示的内容
    func commentText() {
        // 1.设置文本对用的颜色字号
        let texts = [model.name, ": \(model.content)"]
        let colors = [UIColor(hex: 0x333333), UIColor(hex: 0x999999)]
        let contentString = NSMutableAttributedString.attributeStringWith(strings: texts, colors: colors, fonts: [13, 13])
        // 2.显示处理后的文字内容
        setAttributedText(contentString.setlineSpacing(3))
        // 3.添加点击事件
        // 匹配相关的at
        let matchs = TSUtil.findAllTSAt(inputStr: model.content)
        for match in matchs {
            /// 按照上边的texts的拼接方式进行增加content前边的偏移量
            let matchContent = model.content.subString(with: match.range)
            addLink(withLinkData: matchContent, linkColor: TSColor.main.theme, underLineStyle: .init(rawValue: 0), range: NSRange(location: model.name.count + 2 + match.range.location, length: match.range.length))
        }
    }

    /// 评论了某个用户的评论，需要显示的内容
    func comment(user replyName: String) {
        // 1.设置文本对用的颜色字号
        let texts = [model.name, " 回复 ", replyName, ": \(model.content)"]
        let colors = [UIColor(hex: 0x333333), UIColor(hex: 0x999999), UIColor(hex: 0x333333), UIColor(hex: 0x999999)]
        let contentString = NSMutableAttributedString.attributeStringWith(strings: texts, colors: colors, fonts: [13, 13, 13, 13])
        // 2.显示处理后的文字内容
        setAttributedText(contentString)
        // 3.添加点击事件
        let range = (contentString.string as NSString).range(of: model.name)
        addLink(withLinkData: model.name, linkColor: UIColor(hex: 0x333333), underLineStyle: .init(rawValue: 0), range: range)
        let replyNameRange = (contentString.string as NSString).range(of: replyName)
        addLink(withLinkData: replyName, linkColor: UIColor(hex: 0x333333), underLineStyle: .init(rawValue: 0), range: replyNameRange)
        // 匹配相关的at
        let matchs = TSUtil.findAllTSAt(inputStr: model.content)
        for match in matchs {
            let matchContent = model.content.subString(with: match.range)
            /// 按照上边的texts的拼接方式进行增加content前边的偏移量
            addLink(withLinkData: matchContent, linkColor: TSColor.main.theme, underLineStyle: .init(rawValue: 0), range: NSRange(location: model.name.count + 4 + replyName.count + 2 + match.range.location, length: match.range.length))
        }
    }
}

extension FeedCommentLabel: TYAttributedLabelDelegate {

    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageLongPressed textStorage: TYTextStorageProtocol!, on state: UIGestureRecognizerState, at point: CGPoint) {
        // 避免多次响应
        if state == .began {
            feedCommentDelegate?.feedCommentLabelDidLongpress(self)
        }
    }
    // 长按了非文字响应区域
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, lableLongPressOn state: UIGestureRecognizerState, at point: CGPoint) {
        if state == .began {
            feedCommentDelegate?.feedCommentLabelDidLongpress(self)
        }
    }

    /// 处理点击动作的代理
    ///
    /// - Parameters:
    ///   - attributedLabel: 当前的Label
    ///   - textStorage: textStorage description
    ///   - point: 位置
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        // 1.获取点击文字内容
        let range = textStorage.realRange
        let selectedString = (attributedLabel.attributedText().string as NSString).substring(with: range)
        // 2.根据评论类型判断对应的点击事件
        switch model.type {
        // 2.1 评论文字内容
        case .text:
            // 如果和评论者用户名的名字相同
            if model.name == selectedString {
                feedCommentDelegate?.feedCommentLabel(self, didSelectedUser: model.userId)
            } else {
                var uname = selectedString.substring(to: selectedString.index(selectedString.startIndex, offsetBy: selectedString.count - 1))
                uname = uname.substring(from: uname.index(after: uname.index(uname.startIndex, offsetBy: 1)))
                TSUtil.pushUserHomeName(name: uname)
            }
        // 2.2 评论了某个用户
        case .user(let replyName, let replyUserId):
            // 如果和评论者用户名的名字相同
            if model.name == selectedString {
                feedCommentDelegate?.feedCommentLabel(self, didSelectedUser: model.userId)
            } else if replyName == selectedString { ///< 如果和 replyName 的相同
                feedCommentDelegate?.feedCommentLabel(self, didSelectedUser: replyUserId)
            } else {
                var uname = selectedString.substring(to: selectedString.index(selectedString.startIndex, offsetBy: selectedString.count - 1))
                uname = uname.substring(from: uname.index(after: uname.index(uname.startIndex, offsetBy: 1)))
                TSUtil.pushUserHomeName(name: uname)
            }
            break
        }
    }
}

extension NSMutableAttributedString {

    /// 创建自定义的 NSMutableAttributedString
    ///
    /// - Notes: strings, colors, fonts 数组的 count 数要相同
    ///
    /// - Parameters:
    ///   - strings: 文字内容数组
    ///   - colors: 颜色数组
    ///   - fonts: 字体数组
    /// - Returns: NSMutableAttributedString
    class func attributeStringWith(strings: [String], colors: [UIColor], fonts: [CGFloat]) -> NSMutableAttributedString {
        // 1.过滤 count 不相同的情况
        guard strings.count == colors.count, colors.count == fonts.count else {
            return NSMutableAttributedString()
        }
        let attributeString = NSMutableAttributedString(string: "")
        // 2.遍历数组，给文字设置对用的颜色和字体大小
        for (index, text) in strings.enumerated() {
            guard !text.isEmpty else {
                continue
            }
            let color = colors[index]
            let font = UIFont.systemFont(ofSize: fonts[index])
            let attributeStr = NSMutableAttributedString(string: text)
            attributeStr.addAttributes([NSForegroundColorAttributeName: color, NSFontAttributeName: font], range: NSRange(location: 0, length: (text as NSString).length))
            // 3.将文字内容拼接起来
            attributeString.append(attributeStr)
        }
        return attributeString
    }
}
