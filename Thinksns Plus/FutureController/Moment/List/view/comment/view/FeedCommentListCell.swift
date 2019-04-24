//
//  FeedCommentListCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol FeedCommentListCellDelegate: class {
    /// 点击了评论中的名字
    func feedCommentListCell(_ cell: FeedCommentListCell, didSelectedUser userId: Int)
    /// 长按了评论
    func feedCommentListCellDidLongPress(_ cell: FeedCommentListCell)
    /// 点击了评论
    func feedCommentListCellDidPress(_ cell: FeedCommentListCell)
}

class FeedCommentListCell: UITableViewCell {

    static let identifier = "FeedCommentListCell"

    ///代理
    weak var delegate: FeedCommentListCellDelegate?

    /// 发送失败按钮
    let errorButton = UIButton(type: .custom)
    /// 评论 label
    let commentLabel = FeedCommentLabel()

    /// 数据源
    var model = FeedCommentListCellModel()

    // MARK: - 生命周期

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    internal func setUI() {
        commentLabel.feedCommentDelegate = self
        contentView.addSubview(errorButton)
        contentView.addSubview(commentLabel)
    }

    func set(model: inout FeedCommentListCellModel) {
        self.model = model
        let leading = model.contentInset.left
        let tralling = model.contentInset.right
        let top = model.contentInset.top
        let bottom = model.contentInset.bottom

        // 1.评论 label
        let labelWidth = UIScreen.main.bounds.width - leading - tralling
        commentLabel.model = model
        commentLabel.isUserInteractionEnabled = true
        let labelSize = commentLabel.getSizeWithWidth(labelWidth)
        commentLabel.frame = CGRect(origin: CGPoint(x: leading, y: top), size: labelSize)

        // 2.计算 cell 高度
        model.cellHeight = max(labelSize.height, 10) + top + bottom

        // 3.发送失败按钮
        if model.sendStatus == .faild {
            errorButton.setImage(UIImage(named: "IMG_msg_box_remind"), for: .normal)
            errorButton.sizeToFit()
            let errorButtonX = leading - errorButton.size.width - 5
            let errorButtonY = (model.cellHeight - errorButton.size.height) / 2
            errorButton.frame = CGRect(origin: CGPoint(x: errorButtonX, y: errorButtonY), size: errorButton.size)
            errorButton.isUserInteractionEnabled = false
        } else {
            errorButton.frame = .zero
        }
    }
}

extension FeedCommentListCell: FeedCommentLabelDelegate {
    /// 增加了 label 上用户名的点击事件
    func feedCommentLabel(_ label: FeedCommentLabel, didSelectedUser userId: Int) {
        delegate?.feedCommentListCell(self, didSelectedUser: userId)
    }
    /// 长按了 cell
    func feedCommentLabelDidLongpress(_ label: FeedCommentLabel) {
        delegate?.feedCommentListCellDidLongPress(self)
    }
    /// 点击了label
    func feedCommentListCellDidPress(_ cell: FeedCommentLabel) {
        delegate?.feedCommentListCellDidPress(self)
    }
}
