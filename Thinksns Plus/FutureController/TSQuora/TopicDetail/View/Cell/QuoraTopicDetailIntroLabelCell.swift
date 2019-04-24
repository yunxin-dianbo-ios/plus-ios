//
//  QuoraTopicDetailIntroLabelCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  话题简介 cell

import UIKit
import YYKit

class QuoraTopicDetailIntroLabelCell: UITableViewCell {

    /// 话题简介
    let introlLabel = YYLabel()
    /// 分割线
    let separatorLine = UIView()
    var showMoreIntro = false
    /// 话题简介数据
    var model: QuoraTopicDetailIntroLabelCellModel? {
        didSet {
            setInfo()
        }
    }

    static let identifier = "QuoraTopicDetailIntroLabelCell"

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: QuoraTopicDetailIntroLabelCellModel) -> QuoraTopicDetailIntroLabelCell {
        let cell = table.dequeueReusableCell(withIdentifier: QuoraTopicDetailIntroLabelCell.identifier, for: indexPath) as! QuoraTopicDetailIntroLabelCell
        cell.model = data
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    func setUI() {
        // 分割线
        separatorLine.backgroundColor = TSColor.inconspicuous.disabled
        contentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(1)
        }
        // 简介 label
        introlLabel.font = UIFont.systemFont(ofSize: 14)
        introlLabel.textColor = TSColor.normal.content
        introlLabel.isUserInteractionEnabled = true
        introlLabel.numberOfLines = 0
        introlLabel.textVerticalAlignment = .top
        introlLabel.size = CGSize(width: UIScreen.main.bounds.width - 20, height: 1_000)
        addUnfoldButton()
        contentView.addSubview(introlLabel)
    }

    func setInfo() {
        guard let cellModel = model else {
            return
        }
        let introText = "专题简介：\(cellModel.introl)"
        introlLabel.attributedText = introText.attributonString().setTextFont(14).setlineSpacing(6)
        introlLabel.textColor = TSColor.normal.content
        // 计算 frame
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        var labelHeight: CGFloat = 0
        let heightLine = self.heightOfLines(line: 3, font: UIFont.systemFont(ofSize: 14))
        let maxHeight = self.heightOfAttributeString(contentWidth: UIScreen.main.bounds.width - 20, attributeString: introlLabel.attributedText!, font: UIFont.systemFont(ofSize: 14), paragraphstyle: paragraphStyle)
        if heightLine >= maxHeight {
            labelHeight = maxHeight
        } else {
            labelHeight = heightLine
        }
        if showMoreIntro {
            labelHeight = maxHeight
        }
        introlLabel.snp.makeConstraints { (make) in
            make.topMargin.leftMargin.equalTo(15)
            make.bottomMargin.rightMargin.equalTo(-15)
            make.height.equalTo(labelHeight)
        }
        if showMoreIntro {
            introlLabel.truncationToken = nil
        }
    }

    func addUnfoldButton() {
        // 1.配置点击事件
        let hi = YYTextHighlight()
        hi.tapAction = { [weak self] (containerView, text, range, rect) in
            self?.introlLabel.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 3
            paragraphStyle.alignment = .left
            paragraphStyle.headIndent = 0.000_1
            paragraphStyle.tailIndent = -0.000_1
            let maxHeight = self?.heightOfAttributeString(contentWidth: UIScreen.main.bounds.width - 20, attributeString: (self?.introlLabel.attributedText!)!, font: UIFont.systemFont(ofSize: 14), paragraphstyle: paragraphStyle)
            let newHeight = maxHeight
            self?.introlLabel.snp.remakeConstraints { (make) in
                make.topMargin.leftMargin.equalTo(15)
                make.bottomMargin.rightMargin.equalTo(-15)
                make.height.equalTo(newHeight!)
                NotificationCenter.default.post(name: NSNotification.Name.TopicDetailController.unfold, object: nil, userInfo: nil)
            }
        }
        // 2.配置按钮标题
        let foldTitle = QuoraStackBottomButtonsCell.getAttributeString(texts: ["...", "展开全部"], colors: [TSColor.normal.content, TSColor.main.theme])
        foldTitle.font = introlLabel.font
        foldTitle.setTextHighlight(hi, range: NSRange(location: "...".count - 1, length: "展开全部".count))
        // 3.配置按钮
        let foldButton = YYLabel()
        foldButton.attributedText = foldTitle
        foldButton.sizeToFit()
        // 4.设置 token
        let truncationToken = NSAttributedString.attachmentString(withContent: foldButton, contentMode: .center, attachmentSize: foldButton.size, alignTo: foldTitle.font!, alignment: .center)
        introlLabel.truncationToken = truncationToken
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
        let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSParagraphStyleAttributeName: paragraphStyle.copy(), NSStrokeColorAttributeName: UIColor.black]
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
}
