//
//  QuoraStackAvatarContentCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 带头像的内容 cell

import UIKit
import ActiveLabel

class QuoraStackAvatarContentCell: UITableViewCell {

    /// 头像
    let buttonForAvatar: AvatarView = {
        let button = AvatarView(type: AvatarType.width20(showBorderLine: false))
        return button
    }()

    /// 内容
    let labelForContent: ActiveLabel = {
        let label = ActiveLabel(frame: .zero)
        label.mentionColor = TSColor.main.theme
        label.URLColor = TSColor.main.theme
        label.URLSelectedColor = TSColor.main.theme
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = TSColor.normal.content
        return label
    }()

    /// 是否已经更新了约束
    var didSetupConstraints = false

    /// 数据
    var cellModel: QuoraStackAvatarContentCellModel?

    static let identifier = "QuoraStackAvatarContentCell"

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: inout QuoraStackAvatarContentCellModel) -> QuoraStackAvatarContentCell {
        let cell = table.dequeueReusableCell(withIdentifier: QuoraStackAvatarContentCell.identifier, for: indexPath) as! QuoraStackAvatarContentCell
        cell.setInfo(model: &data)
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(labelForContent)
        contentView.addSubview(buttonForAvatar)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(labelForContent)
        contentView.addSubview(buttonForAvatar)
    }

    // MARK: - Private

    /// 设置展示内容
    private func setInfo(model: inout QuoraStackAvatarContentCellModel) {
        let screenWidth = UIScreen.main.bounds.width
        // 1.设置文本
        // 1.1 更新文本的显示设置
        labelForContent.font = UIFont.systemFont(ofSize: model.font)
        labelForContent.textColor = model.textColor
        // 1.2 更新文本显示内容，"       " 是为了把头像显示的位置空出来
        let contentString = NSAttributedString(string: "       " + model.content.ts_customMarkdownToNormal())
        // 判断是否需要隐藏文字内容
        let shouldHiddenContent = model.shouldHiddenContent
        if model.shouldHiddenContent {
            labelForContent.numberOfLines = 1
        } else {
            labelForContent.numberOfLines = 3
        }
        labelForContent.frame = CGRect(x: model.left, y: model.top, width: screenWidth - (model.left + model.right), height: 0)
        labelForContent.lineSpacing = 2
        labelForContent.shouldAddFuzzyString = shouldHiddenContent
        labelForContent.handleURLTap { [weak self] (url) in
            guard shouldHiddenContent == false else {
                return
            }
            let newUrl = url.ts_serverLinkUrlProcess()
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: newUrl, currentVC: parentVC)
            }
        }
        labelForContent.attributedText = contentString
        labelForContent.lineBreakMode = .byTruncatingTail
        // 1.3 更新文本的frame
        labelForContent.sizeToFit()

        // 2.设置头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        var avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = model.avatarURL
        if let user = model.user {
            avatarInfo = AvatarInfo(userModel: user)
        }
        buttonForAvatar.avatarInfo = avatarInfo
        if model.isAnonymity {
            buttonForAvatar.buttonForAvatar.setImage(#imageLiteral(resourceName: "ico_anonymity_2"), for: .normal)
        }
        buttonForAvatar.frame = CGRect(origin: CGPoint(x: model.left, y: model.top - 1.5), size: buttonForAvatar.frame.size)

        // 3.计算头像和 label 的总体高度
        model.avatarAndLabelHeight = max(buttonForAvatar.frame.height, labelForContent.frame.height)
    }
}
