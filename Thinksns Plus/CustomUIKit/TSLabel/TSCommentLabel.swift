//
//  TSCommentLabel.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态页面评论富文本

import UIKit
import TYAttributedLabel

protocol TSCommentLabelDelegate: NSObjectProtocol {

    /// 点击
    ///
    /// - Parameter didSelectId: 点击用户名返回相应的Id
    func didSelect(didSelectId: Int)
}

class TSCommentLabel: TYAttributedLabel, TYAttributedLabelDelegate {

    enum ShowType {
        case detail
        case simple
    }

    /// 回复固定字符串
    var replyTemplates = " 回复 "
    /// 固定的冒号
    var normalTemplates = ": "
    /// 显示类型
    var showType: ShowType = .simple
    /// 发表评论的名称
    var commentName = ""
    /// 回复发表评论的名称
    var replyCommentName: String?
    /// 评论内容
    var content = ""
    /// 当前评论的数据模型
    var commentModel: TSSimpleCommentModel? {
        didSet {
            if isXib {
                guard let model = commentModel else {
                    return
                }
                setSourceData(commentModel: model)
            }
        }
    }

    /// 点击名称的代理
    weak var labelDelegate: TSCommentLabelDelegate?

    var isXib = false
    /// Lifecycle
    ///
    /// - Parameter commentModel: 数据模型
    init(commentModel: TSSimpleCommentModel, type: ShowType) {
        super.init(frame: CGRect.zero)
        self.commentModel = commentModel
        self.showType = type
        setSourceData(commentModel: commentModel)
    }

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isXib = true
    }
    // MARK: - setDatas 
    func setSourceData (commentModel: TSSimpleCommentModel) {
        self.delegate = self
        commentName = self.showType == .simple ? (commentModel.userInfo?.name ?? "") : ""
        replyTemplates = self.showType == .simple ? " 回复 " : "回复 "
        content = commentModel.content
        replyCommentName = commentModel.replyUserInfo?.name
        switch self.showType {
        case .detail:
            setDetailAttributedString(commentModel: commentModel)
        case .simple:
            setAttributedString(commentModel: commentModel)
        }
    }

    /// 设置文本颜色字体以及可点击区域
    ///
    /// - Parameter commentModel: 数据模型
    private func setAttributedString(commentModel: TSSimpleCommentModel) {
        if replyCommentName == nil {
            let attributedName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: commentName as NSString, firstColor: TSColor.main.content, firstSize: TSFont.ContentText.sectionTitle.rawValue), second: (secondString:  "\(normalTemplates)\(content)" as NSString, secondColor: TSColor.normal.minor, secondSize: TSFont.ContentText.sectionTitle.rawValue))
            self.setAttributedText(attributedName)
            let range = (attributedName.string as NSString).range(of: commentName)
            self.addLink(withLinkData: commentName, linkColor: TSColor.main.content, underLineStyle: .init(rawValue: 0), range: range)
            return
        }

        let replyName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: commentName as NSString, firstColor: TSColor.main.content, firstSize: TSFont.ContentText.sectionTitle.rawValue), second: (secondString:  replyTemplates as NSString, secondColor: TSColor.normal.minor, secondSize: TSFont.ContentText.sectionTitle.rawValue))
        let beReplyName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: replyCommentName! as NSString, firstColor: TSColor.main.content, firstSize: TSFont.ContentText.sectionTitle.rawValue), second: (secondString: "\(normalTemplates)\(content)" as NSString, secondColor: TSColor.normal.minor, secondSize: TSFont.ContentText.sectionTitle.rawValue))
        replyName.append( beReplyName)
        self.setAttributedText(replyName)
        let commentNameRange = (replyName.string as NSString).range(of: commentName)
        let replyNameRange = (replyName.string as NSString).range(of: replyCommentName!)
        self.addLink(withLinkData: commentName, linkColor: TSColor.main.content, underLineStyle: .init(rawValue: 0), range: commentNameRange)
        self.addLink(withLinkData: replyCommentName!, linkColor: TSColor.main.content, underLineStyle: .init(rawValue: 0), range: replyNameRange)
    }

    /// 设置动态详情里的评论
    ///
    /// - Parameter commentModel: 数据模型
    private func setDetailAttributedString(commentModel: TSSimpleCommentModel) {
        if replyCommentName == nil {
            self.setAttributedText(NSAttributedString(string: content, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue), NSForegroundColorAttributeName: TSColor.normal.minor]))
        // 匹配相关的at
        let matchs = TSUtil.findAllTSAt(inputStr: commentModel.content)
        for match in matchs {
            let matchContent = commentModel.content.subString(with: match.range)
            /// 按照上边的texts的拼接方式进行增加content前边的偏移量
            addLink(withLinkData: matchContent, linkColor: TSColor.main.theme, underLineStyle: .init(rawValue: 0), range: NSRange(location: match.range.location, length: match.range.length))
        }
            return
        }

        let reply = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: replyTemplates as NSString, firstColor: TSColor.normal.minor, firstSize: TSFont.SubInfo.footnote.rawValue), second: (secondString: "" as NSString, secondColor: TSColor.normal.minor, secondSize: TSFont.SubInfo.footnote.rawValue))

        let beReplyName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: (replyCommentName!) as NSString, firstColor: TSColor.main.content, firstSize: TSFont.SubInfo.footnote.rawValue), second: (secondString: (normalTemplates + content) as NSString, secondColor: TSColor.normal.minor, secondSize: TSFont.SubInfo.footnote.rawValue))
        reply.append(beReplyName)
        self.setAttributedText(reply)
        let commentNameRange = (reply.string as NSString).range(of: replyCommentName!)
        self.addLink(withLinkData: replyCommentName!, linkColor: TSColor.main.content, underLineStyle: .init(rawValue: 0), range: commentNameRange)
        // 匹配相关的at
        let matchs = TSUtil.findAllTSAt(inputStr: commentModel.content)
        for match in matchs {
            let matchContent = commentModel.content.subString(with: match.range)
            /// 按照上边的texts的拼接方式进行增加content前边的偏移量
            addLink(withLinkData: matchContent, linkColor: TSColor.main.theme, underLineStyle: .init(rawValue: 0), range: NSRange(location: 3 + (replyCommentName?.count)! + 2 + match.range.location, length: match.range.length))
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
        // 如果和评论者用户名的名字相同
        if commentName == selectedString {
            self.labelDelegate?.didSelect(didSelectId: (self.commentModel?.userInfo?.userIdentity)!)
        } else if replyCommentName == selectedString {
            self.labelDelegate?.didSelect(didSelectId: (self.commentModel?.replyUserInfo?.userIdentity)!)
        } else {
            var uname = selectedString.substring(to: selectedString.index(selectedString.startIndex, offsetBy: selectedString.count - 1))
            uname = uname.substring(from: uname.index(after: uname.index(uname.startIndex, offsetBy: 1)))
            TSUtil.pushUserHomeName(name: uname)
        }
    }
}
