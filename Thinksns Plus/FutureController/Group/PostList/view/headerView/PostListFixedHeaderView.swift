//
//  PostListHeaderView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  帖子列表视图 header 上在拉伸时是固定住的有内容的视图

import UIKit
import YYKit

extension Notification.Name {

    /// 话题详情相关
    public struct PostListController {
        /// 问题话题详情页点击了展开按钮
        public static let unfold = NSNotification.Name(rawValue: "com.ts-plus.notification.quora.topicDetail.unfold")
    }
}

protocol PostListFixedHeaderViewDelegate: class {
    /// 点击了简介 label 上的查看更多按钮
    func postListFixedHeaderView(_ view: PostListFixedHeaderView, didSelectedIntroLabelButtonWithNewFrame newFixedViewFrame: CGRect)
    /// 点击了加入按钮
    func postListFixedHeaderViewDidSelectedJoinButton(_ view: PostListFixedHeaderView)
    /// 点击了私聊按钮
    func postListFixedHeaderViewDidSelectedChatButtonWith(_ view: PostListFixedHeaderView)
}

class PostListFixedHeaderView: UIView {

    /// 代理
    weak var delegate: PostListFixedHeaderViewDelegate?

    /// 封面图
    let coverImageView = UIImageView()
    /// 圈名
    let nameLabel = UILabel()
    /// 成员
    let memberLabel = UILabel()
    /// 地址
    let locationLabel = UILabel()
    /// 圈主
    let ownerLabel = UILabel()
    /// 简介
    let introLabel = YYLabel()
    /// 简介标题
    let introlTitleLabel = UILabel()
    /// 加入按钮
    let joinButton = UIButton(type: .custom)
    /// 私聊按钮
    let chatButton = UIButton(type: .custom)

    /// 白色背景图
    let whiteView = UIView()
    /// 圈主和简介的分割线
    let seperatorLine = UIView()
    /// 灰色背景图

    // 数据
    var model = PostListControllerModel() {
        didSet {
            loadModel()
        }
    }

    init() {
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    func setUI() {
        backgroundColor = UIColor.clear
        addSubview(whiteView)
        addSubview(coverImageView)
        addSubview(nameLabel)
        addSubview(memberLabel)
        addSubview(locationLabel)
        addSubview(ownerLabel)
        addSubview(introlTitleLabel)
        addSubview(introLabel)
        addSubview(seperatorLine)
        addSubview(joinButton)
        addSubview(chatButton)
    }

    func loadModel() {
        var yRecord: CGFloat = 0
        // 1.封面图
        loadCoverImage(yRecord: &yRecord)

        // 2.圈名
        loadNameLabel()

        // 3.成员
        loadMemberCountLabel()

        // 4.地址
        loadLocationLabel()

        // 5.加入按钮
        loadJoinButton()

        // 5.圈主
        loadChatButton(yRecord: yRecord)
        loadOwnerLabel(yRecord: &yRecord)

        if !model.intro.isEmpty {
            // 6.分割线
            loadSeperatorLine(yRecord: &yRecord)

            // 7.简介
            loadIntroLabel(yRecord: &yRecord)
        }

        // 8.白色背景图
        loadWhiteView(yRecord: &yRecord)

        // 更新 frame
        frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: yRecord))
    }

    /// 加载封面图
    func loadCoverImage(yRecord: inout CGFloat) {
        let coverUrl = URL(string: model.coverImage)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.borderColor = UIColor.white.cgColor
        coverImageView.layer.borderWidth = 1
        coverImageView.kf.setImage(with: coverUrl, placeholder: UIImage.imageWithColor(TSColor.inconspicuous.disabled, cornerRadius: 0), options: nil, progressBlock: nil, completionHandler: nil)
        coverImageView.frame = CGRect(x: 10, y: 83, width: 63, height: 63)
        // 更新高度设置
        yRecord = coverImageView.frame.maxY
    }

    /// 加载圈名
    func loadNameLabel() {
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = UIColor(hex: 0xf4f5f5)
        let  name = NSString(string: model.name)
        nameLabel.text = name.replacingOccurrences(of: "\n", with: "")
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 85, y: 82, width: UIScreen.main.bounds.width - 85 - 100, height: nameLabel.size.height)
        if model.isJoin {
            //已经加入就没有加入按钮，圈名可以多显示一点
            nameLabel.width = UIScreen.main.bounds.width - 85 - 20
        }
        /// 设置阴影颜色
        nameLabel.shadowColor = UIColor.black
        ///设置阴影大小
        nameLabel.shadowOffset = CGSize(width: 0.4, height: 0.4)
    }

    /// 加载成员数
    func loadMemberCountLabel() {
        memberLabel.font = UIFont.systemFont(ofSize: 12)
        memberLabel.textColor = UIColor(hex: 0xf4f5f5)
        memberLabel.text =  "成员 \(model.memberCount) 帖子 \(model.postCount)"
        memberLabel.sizeToFit()
        memberLabel.frame = CGRect(origin: CGPoint(x: 85, y: nameLabel.frame.maxY + 10), size: memberLabel.size)
        /// 设置阴影颜色
        memberLabel.shadowColor = UIColor.black
        ///设置阴影大小
        memberLabel.shadowOffset = CGSize(width: 0.4, height: 0.4)
    }

    /// 加载地址
    func loadLocationLabel() {
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textColor = UIColor(hex: 0xf4f5f5)
        var locationStr: String
        if model.location.isEmpty {
           let defautLocations = ["金星", "水星", "火星", "土星", "地球"]
           let romandIndex = Int(arc4random_uniform(5))
           locationStr = "位置: \(defautLocations[romandIndex])"
        } else {
           locationStr = "位置: \(model.location)"
        }
        locationLabel.text = locationStr
        let localWidth = UIScreen.main.bounds.width - 85 - 95
        locationLabel.frame = CGRect(x: 85, y: memberLabel.frame.maxY + 5, width: localWidth, height: 15)
        /// 设置阴影颜色
        locationLabel.shadowColor = UIColor.black
        ///设置阴影大小
        locationLabel.shadowOffset = CGSize(width: 0.4, height: 0.4)
    }

    /// 加载加入按钮
    func loadJoinButton() {
        let isJoin = model.isJoin
        let title = isJoin ? "已加入" : "加入"
        let image =  "IMG_channel_ico_added_wihte"
        joinButton.layer.cornerRadius = 4
        joinButton.layer.borderColor = UIColor(red: 244.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0).cgColor
        joinButton.layer.borderWidth = 1
        joinButton.clipsToBounds = true
        joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        joinButton.setTitle(title, for: .normal)
        joinButton.setTitleColor(UIColor.white, for: .normal)
        joinButton.setImage(UIImage(named: image), for: .normal)
        joinButton.addTarget(self, action: #selector(joinButtonTaped(_:)), for: .touchUpInside)
        joinButton.sizeToFit()
        let joinX = UIScreen.main.bounds.width - 63 - 13
        joinButton.frame = CGRect(x: joinX, y: 97, width: 63, height: 25)
        joinButton.isHidden = isJoin
    }

    /// 加载圈主
    func loadOwnerLabel(yRecord: inout CGFloat) {
        ownerLabel.font = UIFont.systemFont(ofSize: 14)
        ownerLabel.textColor = UIColor(hex: 0x333333)
        let ownerStrings = ["圈主   ", model.ownerName]
        let ownerColors = [UIColor(hex: 0x999999), UIColor(hex: 0x333333)]
        ownerLabel.attributedText = NSMutableAttributedString.attributeStringWith(strings: ownerStrings, colors: ownerColors, fonts: [14, 14])
        ownerLabel.sizeToFit()
        ownerLabel.frame = CGRect(origin: CGPoint(x: 10, y: yRecord + 33), size: ownerLabel.size)
        // 更新 yRecord
        yRecord = ownerLabel.frame.maxY
    }

    /// 加载私聊按钮
    func loadChatButton(yRecord: CGFloat) {
        // 如果私聊对象是自己的话，就隐藏私聊按钮
        guard let ownerId = model.ownerUserId, ownerId != TSCurrentUserInfo.share.userInfo?.userIdentity  else {
            chatButton.isHidden = true
            return
        }
        chatButton.isHidden = false

        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        chatButton.setTitleColor(UIColor(hex: 0xf4f5f5), for: .normal)
        chatButton.setTitle("私聊", for: .normal)
        chatButton.addTarget(self, action: #selector(chatButtonTaped), for: .touchUpInside)
        chatButton.backgroundColor = UIColor(hex: 0xfca308)
        chatButton.clipsToBounds = true
        chatButton.layer.cornerRadius = 11
        chatButton.frame = CGRect(x: UIScreen.main.bounds.width - 47 - 15, y: yRecord + 29, width: 47, height: 22)
    }

    /// 加载分割线
    func loadSeperatorLine(yRecord: inout CGFloat) {
        seperatorLine.backgroundColor = UIColor(hex: 0xededed)
        seperatorLine.frame = CGRect(x: 50, y: yRecord + 12, width: UIScreen.main.bounds.width - 50, height: 0.5)
        /// 更新 yRecord
        yRecord = seperatorLine.frame.maxY
    }

    /// 加载简介
    func loadIntroLabel(yRecord: inout CGFloat) {
        // 1.设置简介标题
        introlTitleLabel.text = "简介"
        introlTitleLabel.font = UIFont.systemFont(ofSize: 14)
        introlTitleLabel.textColor = UIColor(hex: 0x999999)
        introlTitleLabel.sizeToFit()
        introlTitleLabel.frame = CGRect(origin: CGPoint(x: 10, y: seperatorLine.frame.maxY + 11), size: introlTitleLabel.size)

        // 2.设置简介内容
        introLabel.font = UIFont.systemFont(ofSize: 14)
        introLabel.textColor = UIColor(hex: 0x333333)
        introLabel.isUserInteractionEnabled = true
        introLabel.numberOfLines = 2
        introLabel.textVerticalAlignment = .top
        introLabel.size = CGSize(width: UIScreen.main.bounds.width - 65, height: 1_000)
        introLabel.attributedText = model.intro.attributonString().setTextFont(15).setlineSpacing(6)
        introLabel.textColor = UIColor(hex: 0x333333)

        // 计算 frame
        let contentWidth = UIScreen.main.bounds.width - 65
        introLabel.frame = CGRect(origin: CGPoint(x: 50, y: seperatorLine.frame.maxY + 12), size: CGSize(width: contentWidth, height: 0))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        var labelHeight: CGFloat = 0
        let heightLine = self.heightOfLines(line: 2, font: UIFont.systemFont(ofSize: 15))
        let maxHeight = self.heightOfAttributeString(contentWidth: introLabel.width, attributeString: introLabel.attributedText!, font: UIFont.systemFont(ofSize: 15), paragraphstyle: paragraphStyle)
        if heightLine >= maxHeight {
            labelHeight = maxHeight
        } else {
            labelHeight = heightLine
        }
        introLabel.frame = CGRect(x: 50, y: seperatorLine.frame.maxY + 12, width: introLabel.width, height: labelHeight)
        addUnfoldButton()

        // 更新 yRecord
        yRecord = introLabel.frame.maxY
    }
    // 展开按钮
    func addUnfoldButton() {
        // 2.1 配置点击事件
        let hi = YYTextHighlight()
        hi.tapAction = { [weak self] (containerView, text, range, rect) in
            guard let weakself = self else {
                return
            }

            // 更新简介 label 的 frame
            self?.introLabel.numberOfLines = 0
            // 代理回调
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 3
            paragraphStyle.alignment = .left
            paragraphStyle.headIndent = 0.000_1
            paragraphStyle.tailIndent = -0.000_1
            let maxHeight = weakself.heightOfAttributeString(contentWidth: weakself.introLabel.width, attributeString: weakself.introLabel.attributedText!, font: UIFont.systemFont(ofSize: 15), paragraphstyle: paragraphStyle)
            weakself.introLabel.frame = CGRect(x: 50, y: weakself.seperatorLine.frame.maxY + 12, width: weakself.introLabel.width, height: maxHeight)
            weakself.addClosseBtn()
            // 更新整个视图和白色视图的 frame
            var yRecord = self?.introLabel.frame.maxY ?? 0
            weakself.loadWhiteView(yRecord: &yRecord)
            weakself.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: yRecord))
            weakself.delegate?.postListFixedHeaderView(weakself, didSelectedIntroLabelButtonWithNewFrame: weakself.frame)
        }
        // 2.2 配置按钮标题
        let foldTitle = self.getAttributeString(texts: ["...", "查看更多"], colors: [TSColor.normal.content, TSColor.main.theme])
        foldTitle.font = introLabel.font
        foldTitle.setTextHighlight(hi, range: NSRange(location: ("..." as NSString).length - 1, length: ("查看更多" as NSString).length))
        // 2.3 配置按钮
        let foldButton = YYLabel()
        foldButton.attributedText = foldTitle
        foldButton.sizeToFit()
        // 2.4 设置 token
        let truncationToken = NSAttributedString.attachmentString(withContent: foldButton, contentMode: .bottomRight, attachmentSize: foldButton.size, alignTo: foldTitle.font!, alignment: .center)
        introLabel.truncationToken = truncationToken
    }
    // 收起按钮
    func addClosseBtn() {
        let highlight = YYTextHighlight()
        highlight.tapAction = {[weak self] (containerView, text, range, rect) in
            guard let weakself = self else {
                return
            }
            weakself.introLabel.numberOfLines = 5
            let heightLine = weakself.heightOfLines(line: 2, font: UIFont.systemFont(ofSize: 15))
            weakself.introLabel.frame = CGRect(x: 50, y: weakself.seperatorLine.frame.maxY + 12, width: weakself.introLabel.width, height: heightLine)
            weakself.addUnfoldButton()
            // 更新 yRecord
            var yRecord = weakself.introLabel.frame.maxY
            weakself.loadWhiteView(yRecord: &yRecord)
            weakself.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: yRecord))
            weakself.delegate?.postListFixedHeaderView(weakself, didSelectedIntroLabelButtonWithNewFrame: weakself.frame)
        }
        let foldTitle = self.getAttributeString(texts: [self.model.intro, "收起"], colors: [TSColor.normal.blackTitle, TSColor.main.theme])
        foldTitle.font = self.introLabel.font
        foldTitle.setTextHighlight(highlight, range: NSRange(location: self.model.intro.count, length: "收起".count))
        self.introLabel.attributedText = foldTitle
    }

    func loadWhiteView(yRecord: inout CGFloat) {
        whiteView.backgroundColor = UIColor.white
        whiteView.frame = CGRect(x: 0, y: 160, width: UIScreen.main.bounds.width, height: yRecord - 160 + 13)
        // 更新 yRecord
        yRecord = whiteView.frame.maxY
    }

    // MARK: - Action

    func chatButtonTaped() {
        delegate?.postListFixedHeaderViewDidSelectedChatButtonWith(self)
    }

    /// 点击了加入按钮
    func joinButtonTaped(_ sender: UIButton) {
        delegate?.postListFixedHeaderViewDidSelectedJoinButton(self)
    }

    func heightOfLines(line: Int, font: UIFont) -> CGFloat {
        if line <= 0 {
            return 0
        }

        var mutStr = "*"
        for _ in 0..<line - 1 {
            mutStr = mutStr + "\n*"
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSParagraphStyleAttributeName: paragraphStyle.copy(), NSStrokeColorAttributeName: UIColor.black]
        let tSize = mutStr.size(attributes: attribute)
        return tSize.height
    }

    func heightOfAttributeString(contentWidth: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.height
    }

    func getAttributeString(texts: [String], colors: [UIColor]) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: "")
        for index in 0..<texts.count {
            let text = texts[index]
            let color = colors[index]
            let attributeString = NSMutableAttributedString(string: text)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 3
            paragraphStyle.alignment = .left
            paragraphStyle.headIndent = 0.000_1
            paragraphStyle.tailIndent = -0.000_1
            attributeString.addAttributes([NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle.copy()], range: NSRange(location: 0, length: attributeString.length))
            string.append(attributeString)
        }
        return string
    }
}
