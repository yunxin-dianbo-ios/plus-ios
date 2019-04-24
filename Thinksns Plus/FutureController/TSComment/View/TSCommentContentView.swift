//
//  TSCommentContentView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论内容视图
//  类似于之前的TSCommentLabel
//  使用UIView确实比较复杂，但便于扩展。
//  而TSCommentLabel使用TYAttributedLabel确实更简单，之后出一个TSCommentContentLabel来研究TYAttributedLabel实现。

import UIKit
import TYAttributedLabel

enum TSCommentShowType {
    case simple
    case detail
}

protocol TSCommentContentViewProtocol: class {
    /// 点击评论发布者用户的昵称
    func commentView(_ commentView: TSCommentContentView, didClickCommentUser userId: Int) -> Void
    /// 点击评论回复者用户的昵称
    func commentView(_ commentView: TSCommentContentView, didClickReplyUser userId: Int) -> Void
}
extension TSCommentContentViewProtocol {
    func commentView(_ commentView: TSCommentContentView, didClickCommentUser userId: Int) -> Void {
    }
    func commentView(_ commentView: TSCommentContentView, didClickReplyUser userId: Int) -> Void {
    }
}

class TSCommentContentView: UIView, TYAttributedLabelDelegate {

    // MARK: - Internal Property

    /// 展示类型
    let type: TSCommentShowType
    /// 数据模型
    private(set) var model: TSCommentViewModel?
    private(set) var simpleModel: TSSimpleCommentModel?

    /// 回调
    weak var delegate: TSCommentContentViewProtocol?
    var commentUserClickAction: ((_ userId: Int) -> Void)?
    var replyUserClickAction: ((_ userId: Int) -> Void)?

    // MARK: - Internal Function

    /// 高度计算
    class func heightWithModel(_ model: TSCommentViewModel, type: TSCommentShowType, maxW: CGFloat) -> CGFloat {
        let commentView = TSCommentContentView(type: type)
        commentView.loadComment(model, width: maxW)
        let height = commentView.attributedLabel.getHeightWithWidth(maxW)
        return CGFloat(height)
    }
    class func heightWithModel(_ model: TSSimpleCommentModel, type: TSCommentShowType, maxW: CGFloat) -> CGFloat {
        let commentView = TSCommentContentView(type: type)
        commentView.loadComment(model, width: maxW)
        let height = commentView.attributedLabel.getHeightWithWidth(maxW)
        return CGFloat(height)
    }

    /// 数据加载
    func loadComment(_ comment: TSCommentViewModel, width: CGFloat) -> Void {
        self.model = comment
        self.setupWithComment(comment, maxW: width)
    }
    func loadComment(_ comment: TSSimpleCommentModel, width: CGFloat) -> Void {
        self.simpleModel = comment
        self.setupWithComment(comment, maxW: width)
    }

    // MARK: - Private Property

    private(set) weak var attributedLabel: TYAttributedLabel!

    fileprivate let simpleFont: UIFont = UIFont.systemFont(ofSize: 15)
    fileprivate let detailFont: UIFont = UIFont.systemFont(ofSize: 14)
    fileprivate let commentColor: UIColor = TSColor.normal.minor
    fileprivate let userNameColor: UIColor = TSColor.main.content

    fileprivate var commentUserRange: NSRange?
    fileprivate var replyUserRange: NSRange?

    // MARK: - Initialize Function
    init(type: TSCommentShowType) {
        self.type = type
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. userName
        // 2. replyLabel
        // 3. replyUserName
        // 4. contentLabel

        // TYAttributedLabel来实现
        let label = TYAttributedLabel(frame: CGRect.zero)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        label.linesSpacing = 4
        label.numberOfLines = 0
        label.delegate = self
        self.attributedLabel = label
    }

    // MARK: - Private  数据加载

    /// 加载当前评论 - TSCommentViewModel
    fileprivate func setupWithComment(_ comment: TSCommentViewModel, maxW: CGFloat) -> Void {
        self.attributedLabel.preferredMaxLayoutWidth = maxW
        switch self.type {
        case .simple:
            self.setupSimpleTypeComment(comment)
        case .detail:
            self.setupDetailTypeComment(comment)
        }
    }
    fileprivate func setupSimpleTypeComment(_ comment: TSCommentViewModel) -> Void {
        let commentContent = comment.content
        // 判断是否有回复用户
        if let replyUser = comment.replyUser {
            // 有回复用户，展示 "xx 回复 xxx: 评论内容"
            let userName = comment.user?.name ?? "未知用户"
            let replyUserName = replyUser.name
            let prefixText = userName + " 回复 " + replyUserName + ": "
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: prefixText + commentContent, attributes: attDic)
            let userRange = (prefixText as NSString).range(of: userName)
            attText.setColor(self.userNameColor, range: userRange)
            let replyUserRange = (prefixText as NSString).range(of: replyUserName)
            attText.setColor(self.userNameColor, range: replyUserRange)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.addLink(withLinkData: userName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: userRange)
            self.attributedLabel.addLink(withLinkData: replyUserName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: replyUserRange)
            self.attributedLabel.sizeToFit()
            // range保存，只有这种情况下才需要保存，用于点击时判断到底点击的是哪个
            self.replyUserRange = replyUserRange
            self.commentUserRange = userRange
        } else {
            // 没有回复用户，展示 "xxx: 评论内容"
            let userName = comment.user?.name ?? "未知用户"
            let prefixText = userName + ": "
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: prefixText + commentContent, attributes: attDic)
            let userRange = (prefixText as NSString).range(of: userName)
            attText.setColor(self.userNameColor, range: userRange)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.addLink(withLinkData: userName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: userRange)
            self.attributedLabel.sizeToFit()
        }
    }
    fileprivate func setupDetailTypeComment(_ comment: TSCommentViewModel) -> Void {
        let commentContent = comment.content
        // 判断是否有回复用户
        if let replyUser = comment.replyUser {
            // 有回复用户，展示 "回复 xxx: 评论内容"
            let replyUserName: String = replyUser.name
            let prefixText = "回复 " + replyUserName + ": "
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: prefixText + commentContent, attributes: attDic)
            let replyUserRange = (prefixText as NSString).range(of: replyUserName)
            attText.setColor(self.userNameColor, range: replyUserRange)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.addLink(withLinkData: replyUserName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: replyUserRange)
            self.attributedLabel.sizeToFit()
        } else {
            // 没有回复用户，仅仅展示评论，效果: "评论内容"
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: commentContent, attributes: attDic)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.sizeToFit()
        }
    }

    /// 加载当前评论 - TSSimpleCommentModel
    fileprivate func setupWithComment(_ comment: TSSimpleCommentModel, maxW: CGFloat) -> Void {
        self.attributedLabel.preferredMaxLayoutWidth = maxW
        switch self.type {
        case .simple:
            self.setupSimpleTypeComment(comment)
        case .detail:
            self.setupDetailTypeComment(comment)
        }
    }
    fileprivate func setupSimpleTypeComment(_ comment: TSSimpleCommentModel) -> Void {
        let commentContent = comment.content
        // 判断是否有回复用户
        if let replyUser = comment.replyUserInfo {
            // 有回复用户，展示 "xx 回复 xxx: 评论内容"
            let userName = comment.userInfo?.name ?? "未知用户"
            let replyUserName = replyUser.name
            let prefixText = userName + " 回复 " + replyUserName + ": "
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: prefixText + commentContent, attributes: attDic)
            let userRange = (prefixText as NSString).range(of: userName)
            attText.setColor(self.userNameColor, range: userRange)
            let replyUserRange = (prefixText as NSString).range(of: replyUserName)
            attText.setColor(self.userNameColor, range: replyUserRange)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.addLink(withLinkData: userName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: userRange)
            self.attributedLabel.addLink(withLinkData: replyUserName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: replyUserRange)
            self.attributedLabel.sizeToFit()
            // range保存，只有这种情况下才需要保存，用于点击时判断到底点击的是哪个
            self.replyUserRange = replyUserRange
            self.commentUserRange = userRange
        } else {
            // 没有回复用户，展示 "xxx: 评论内容"
            let userName = comment.userInfo?.name ?? "未知用户"
            let prefixText = userName + ": "
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: prefixText + commentContent, attributes: attDic)
            let userRange = (prefixText as NSString).range(of: userName)
            attText.setColor(self.userNameColor, range: userRange)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.addLink(withLinkData: userName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: userRange)
            self.attributedLabel.sizeToFit()
        }
    }
    fileprivate func setupDetailTypeComment(_ comment: TSSimpleCommentModel) -> Void {
        let commentContent = comment.content
        // 判断是否有回复用户
        if let replyUser = comment.replyUserInfo {
            // 有回复用户，展示 "回复 xxx: 评论内容"
            let replyUserName: String = replyUser.name
            let prefixText = "回复 " + replyUserName + ": "
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: prefixText + commentContent, attributes: attDic)
            let replyUserRange = (prefixText as NSString).range(of: replyUserName)
            attText.setColor(self.userNameColor, range: replyUserRange)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.addLink(withLinkData: replyUserName, linkColor: self.userNameColor, underLineStyle: CTUnderlineStyle(rawValue: 0), range: replyUserRange)
            self.attributedLabel.sizeToFit()
        } else {
            // 没有回复用户，仅仅展示评论，效果: "评论内容"
            let attDic: [String: Any] = [NSFontAttributeName: self.detailFont, NSForegroundColorAttributeName: self.commentColor]
            let attText = NSMutableAttributedString(string: commentContent, attributes: attDic)
            self.attributedLabel.setAttributedText(attText)
            self.attributedLabel.sizeToFit()
        }
    }

    // MARK: - Private  事件响应

    // MARK: - Delegate <TYAttributedLabelDelegate>

    // 点击代理
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        // 该视图兼容两种模型，待完成。
        guard let comment = self.model else {
            return
        }
        // 更简单点，可将各种状态下的range记录下后直接根据range.location判断即可。即下面最复杂的处理方案可处理所有情况。
        switch self.type {
        case .simple:
            if let replyUser = comment.replyUser {
                // 有回复用户：既可能点击评论用户，也可能点击回复用户
                // 下面的判断，其实仅判断location就行了
                if let commentUserRange = self.commentUserRange, commentUserRange.location == textStorage.realRange.location && commentUserRange.length == textStorage.realRange.length {
                    self.delegate?.commentView(self, didClickCommentUser: comment.userId)
                }
                if let replyUserRange = self.replyUserRange, replyUserRange.location == textStorage.realRange.location && replyUserRange.length == textStorage.realRange.length {
                    self.delegate?.commentView(self, didClickReplyUser: replyUser.userIdentity)
                }
            } else {
                // 无回复用户：则点击评论用户
                self.delegate?.commentView(self, didClickCommentUser: comment.userId)
                self.commentUserClickAction?(comment.userId)
            }
        case .detail:
            // detail模式下只可能有回复用户，不会有评论用户
            if let replyUser = comment.replyUser {
                self.delegate?.commentView(self, didClickReplyUser: replyUser.userIdentity)
                self.replyUserClickAction?(replyUser.userIdentity)
            }
        }
    }

    // 长按代理 有多个状态 begin, changes, end 都会调用,所以需要判断状态
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageLongPressed textStorage: TYTextStorageProtocol!, on state: UIGestureRecognizerState, at point: CGPoint) {
    }

}
