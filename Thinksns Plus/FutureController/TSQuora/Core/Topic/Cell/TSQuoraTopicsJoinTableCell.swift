//
//  TSQuoraTopicsJoinTableCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  话题列表 cell 
//
//  纯 UI 展示，所有交互事件由代理抛出

import UIKit

protocol TSQuoraTopicsJoinTableCellDelegate: class {
    func cell(_ cell: TSQuoraTopicsJoinTableCell, didSelectedFollowButton button: UIButton, cellModel: TSQuoraTopicsJoinTableCellModel)
}

class TSQuoraTopicsJoinTableCell: UITableViewCell {

    static let identifier = "TSQuoraTopicsJoinTableCell"

    weak var delegate: TSQuoraTopicsJoinTableCellDelegate?

    /// 分割线
    @IBOutlet weak var separatorLine: UIView!
    /// 话题图片按钮
    @IBOutlet weak var buttonForImage: UIButton!
    /// 话题标题
    @IBOutlet weak var labelForTitle: UILabel!
    /// 话题信息
    @IBOutlet weak var labelForDetail: UILabel!
    /// 关注按钮
    @IBOutlet weak var buttonForFollow: UIButton!

    var cellModel: TSQuoraTopicsJoinTableCellModel?

    /// 设置信息
    public func setInfo(model: TSQuoraTopicsJoinTableCellModel) {
        cellModel = model
        /// 设置图片
        let url = URL(string: model.imageURL ?? "")
        let placeholderImage = UIImage.colorImage(color: TSColor.inconspicuous.background)
        buttonForImage.contentHorizontalAlignment = .fill
        buttonForImage.contentVerticalAlignment = .fill
        buttonForImage.kf.setImage(with: url, for: .normal, placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
        /// 设置标题
        labelForTitle.text = model.title
        /// 话题信息
        let attributeString = QuoraStackBottomButtonsCell.getAttributeString(texts: ["\(model.followCount)", " 关注 · ", "\(model.questionCount)", " 问题"], colors: [TSColor.main.theme, TSColor.normal.content, TSColor.main.theme, TSColor.normal.content])
        labelForDetail.attributedText = attributeString
        /// 关注按钮
        updateButton(isSelected: model.isFollowed)
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

    /// 关注按钮点击事件
    @IBAction func followButtonTaped() {
        guard let model = cellModel else {
            return
        }
        delegate?.cell(self, didSelectedFollowButton: buttonForFollow, cellModel: model)
    }
}
