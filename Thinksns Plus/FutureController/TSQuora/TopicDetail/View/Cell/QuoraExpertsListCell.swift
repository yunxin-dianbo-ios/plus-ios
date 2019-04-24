//
//  QuoraExpertsListCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol QuoraExpertsListCellDelegate: class {
    /// 点击了 cell 上的关注按钮
    func cell(_ cell: QuoraExpertsListCell, didSelectedFollow button: UIButton, with cellModel: TSUserInfoModel)
}

class QuoraExpertsListCell: UITableViewCell {

    static let identifier = "QuoraExpertsListCell"

    /// 代理
    weak var delegate: QuoraExpertsListCellDelegate?

    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 姓名
    @IBOutlet weak var labelForName: UILabel!
    /// 回答/赞
    @IBOutlet weak var labelForInfo: UILabel!
    /// 关注
    @IBOutlet weak var buttonForFollow: UIButton!
    /// 标签视图
    @IBOutlet weak var tagsView: ATagsVeiw!

    /// 数据 model
    var cellModel: TSUserInfoModel?

    // MARK: - Public

    func setInfo(model: TSUserInfoModel) {
        cellModel = model
        // 1.头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:model.avatar)
        avatarInfo.verifiedType = model.verified?.type ?? ""
        avatarInfo.verifiedIcon = model.verified?.icon ?? ""
        avatarInfo.type = .normal(userId: model.userIdentity)
        buttonForAvatar.avatarInfo = avatarInfo
        // 2.姓名
        labelForName.text = model.name
        // 3.回答/赞
        let attributeString = QuoraStackBottomButtonsCell.getAttributeString(texts: ["\(model.extra?.answersCount ?? 0)", " 回答 · ", "\(model.extra?.likesCount ?? 0)", " 赞"], colors: [TSColor.main.theme, TSColor.normal.minor, TSColor.main.theme, TSColor.normal.minor])
        labelForInfo.attributedText = attributeString
        // 4.关注按钮
        buttonForFollow.isHidden = false
        switch model.getFollowStatus() {
        // 关注了对方/相互关注
        case .follow, .eachOther:
            updateButton(isSelected: true)
        /// 未关注对方
        case .unfollow:
            updateButton(isSelected: false)
        case .oneself:
            buttonForFollow.isHidden = true
        }
        // 5.标签视图
        tagsView.removeAllTags()
        tagsView.maxWidth = UIScreen.main.bounds.width - 68 - 50
        let tagInfo = model.tags ?? []
        let tags = tagInfo.map { $0.name }
        tagsView.add(tags: tags)
        tagViewHeight.constant = tagsView.frame.height
        setNeedsLayout()
        layoutIfNeeded()
    }

    /// 更新按钮的选中状态
    public func updateButton(isSelected: Bool) {
        buttonForFollow.isSelected = isSelected
        if isSelected {
            // 已关注
            buttonForFollow.layer.borderColor = TSColor.normal.disabled.cgColor
        } else {
            // 未关注
            buttonForFollow.layer.borderColor = TSColor.main.theme.cgColor
        }
    }

    // MARK: - Button click

    /// 点击了关注按钮
    @IBAction func followButtonTaped(_ sender: UIButton) {
        guard let model = cellModel else {
            return
        }
        delegate?.cell(self, didSelectedFollow: sender, with: model)
    }
}
