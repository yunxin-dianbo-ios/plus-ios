//
//  TSDetailCommentTableViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSDetailCommentTableViewCellDelegate: NSObjectProtocol {

    /// 点击重新发送按钮
    ///
    /// - Parameter commnetModel: 数据模型
    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: TSSimpleCommentModel)

    /// 点击了名字
    ///
    /// - Parameter userId: 用户Id
    func didSelectName(userId: Int)

    /// 点击了头像
    ///
    /// - Parameter userId: 用户Id
    func didSelectHeader(userId: Int)

    /// 长按了评论
    func didLongPressComment(in cell: TSDetailCommentTableViewCell, model: TSSimpleCommentModel) -> Void
}

class TSDetailCommentTableViewCell: TSTableViewCell, TSCommentLabelDelegate, TSCustomAcionSheetDelegate {
    /// indexPath记录
    var indexPath: IndexPath?

    enum DetailCommentType {
        /// 没有数据状态
        case nothing
        /// 普通状态
        case normal
    }
    /// 置顶标签
    @IBOutlet weak var topLabel: UIImageView!

    /// 昵称和父视图顶部的偏移量
    let nickNameWithSuperViewOfTopOffset: CGFloat = 15
    /// 昵称Label的高度
    let nickNameHeight: CGFloat = 15
    /// 评论视图顶部和昵称底部的距离
    let commentTopWithNickNameOfBottomOffset: CGFloat = 10
    /// 评论视图底部和父视图底部的距离
    let commentBottomWithSuperViewOfBottmOffset: CGFloat = 10
    /// 评论内容和重返按钮之间的约束
    @IBOutlet weak var commentViewWithReSendButtonOfRight: NSLayoutConstraint!
    /// 评论内容和父视图右边的约束
    @IBOutlet weak var commentViewWithConentViewRight: NSLayoutConstraint!
    /// 重发按钮
    @IBOutlet weak var reSendButton: UIButton!
    /// 头像按钮
    @IBOutlet weak var headerButton: AvatarView!
    /// 昵称
    @IBOutlet weak var nickNameLabel: UILabel!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 评论详情
    @IBOutlet weak var commentDetailLabel: TSCommentLabel!
    /// 评论详情的高度
    @IBOutlet weak var commentDetailHeight: NSLayoutConstraint!
    /// 评论的模型
    var commnetModel: TSSimpleCommentModel?
    /// 状态
    var detailCommentcellType: DetailCommentType = .nothing
    /// 空视图
    @IBOutlet weak var nothingImageView: UIImageView!
    /// 空视图的高度
    @IBOutlet weak var nothingImageViewHeight: NSLayoutConstraint!

    /// 代理
    weak var cellDelegate: TSDetailCommentTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    // MARK: - setUI
    /// 设置界面
    func setUI() {
        nickNameLabel.textColor = TSColor.normal.blackTitle
        nickNameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.listPulse.rawValue)
        timeLabel.textColor = TSColor.normal.disabled
        timeLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        nothingImageViewHeight.constant = (UIImage(named: "IMG_img_default_nothing")?.size.height)!
        headerButton.showBoardLine = false
        headerButton.buttonForAvatar.addTarget(self, action: #selector(tapHeader), for: .touchUpInside)
        // 姓名点击响应
        let nameControl = UIControl()
        self.contentView.addSubview(nameControl)
        nameControl.addTarget(self, action: #selector(didTapName), for: .touchUpInside)
        nameControl.snp.makeConstraints { (make) in
            make.edges.equalTo(nickNameLabel)
        }
        // 评论整体添加长按举报手势
        let longGR = UILongPressGestureRecognizer(target: self, action: #selector(commentLongProcess(_:)))
        commentDetailLabel.addGestureRecognizer(longGR)
    }

    /// 给各个UI赋值
    func setDatas(width: CGFloat) {

        switch detailCommentcellType {
        case .normal:
            guard let model = self.commnetModel else {
                assert(false, "\(TSDetailCommentTableViewCell.self)没有解析到数据")
                return
            }
            self.backgroundColor = UIColor.white

            /// 判断评论是否置顶
            topLabel.isHidden = !model.isTop
            if model.status == 1 {
                commentViewWithConentViewRight.priority = UILayoutPriorityDefaultLow
                commentViewWithReSendButtonOfRight.priority = UILayoutPriorityDefaultHigh
                reSendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                reSendButton.isHidden = false
            } else {
                commentViewWithConentViewRight.priority = UILayoutPriorityDefaultHigh
                commentViewWithReSendButtonOfRight.priority = UILayoutPriorityDefaultLow
                reSendButton.isHidden = true
            }
            commentDetailLabel.linesSpacing = 0
            headerButton.isHidden = false
            commentDetailLabel.isHidden = false
            nothingImageView.isHidden = true
            nickNameLabel.text = model.userInfo?.name
            timeLabel.text = TSDate().dateString(.normal, nsDate: (model.createdAt)!)
            commentDetailLabel.showType = .detail
            commentDetailLabel.commentModel = model
            commentDetailLabel.sizeToFit()
            commentDetailLabel.labelDelegate = self
            commentDetailLabel.linesSpacing = 4.0
            let height = CGFloat(commentDetailLabel.getSizeWithWidth(width - 10 - 40 - 10 - 15).height)
            commentDetailHeight.constant = height
            let avatarInfo = AvatarInfo()
            avatarInfo.type = AvatarInfo.UserAvatarType.normal(userId: model.user?.userIdentity)
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.userInfo?.avatar)
            avatarInfo.verifiedIcon = model.userInfo?.verified?.icon ?? ""
            avatarInfo.verifiedType = model.userInfo?.verified?.type ?? ""
            headerButton.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.user?.sex)
            headerButton.avatarInfo = avatarInfo

        case .nothing:
            self.backgroundColor = TSColor.inconspicuous.disabled
            reSendButton.isHidden = true
            nickNameLabel.text = ""
            timeLabel.text = ""
            headerButton.isHidden = true
            commentDetailLabel.isHidden = true
            nothingImageView.isHidden = false
        }
    }

    /// 点击名字
    @objc fileprivate func didTapName() {
        self.cellDelegate?.didSelectHeader(userId: (self.commnetModel?.userInfo?.userIdentity)!)
    }

    /// 点击
    ///
    /// - Parameter didSelectId: 点击用户名返回相应的Id
    /// 注：这里响应的是评论中回复的名字
    func didSelect(didSelectId: Int) {
        self.cellDelegate?.didSelectName(userId: (self.commnetModel?.replyUserInfo?.userIdentity)!)
    }

    /// 重发按钮点击
    @IBAction func reSendTap(_ sender: UIButton) {
        let reTipView = TSCustomActionsheetView(titles: ["重新发送"])
        reTipView.delegate = self
        reTipView.show()
    }

    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
          self.cellDelegate?.repeatTap(cell: self, commnetModel: self.commnetModel!)
    }

    /// 点击头像
    func tapHeader () {
        self.cellDelegate?.didSelectHeader(userId: (self.commnetModel?.userInfo?.userIdentity)!)
    }

    @objc fileprivate func commentLongProcess(_ longPressGR: UILongPressGestureRecognizer) {
        guard let commnetModel = self.commnetModel else {
            return
        }
        // 避免调用2次
        if longPressGR.state == UIGestureRecognizerState.began {
            self.cellDelegate?.didLongPressComment(in: self, model: commnetModel)
        }
    }
}

extension TSDetailCommentTableViewCell {
    // MARK: - setCellHeight
    func setCommentHeight(comments: [TSSimpleCommentModel], width: CGFloat) -> [CGFloat] {
       var cellHeight: [CGFloat] = Array()
        for item in comments {
            let label = TSCommentLabel(commentModel: item, type: .detail)
            label.sizeToFit()
            label.linesSpacing = 4.0
            let yOffsetHeight: CGFloat = self.nickNameWithSuperViewOfTopOffset + self.nickNameHeight + self.commentTopWithNickNameOfBottomOffset + self.commentBottomWithSuperViewOfBottmOffset
            let labelWidth = width - 10 - 40 - 10 - 15
            let contentHeight = label.getSizeWithWidth(labelWidth).height
            cellHeight.append(contentHeight + yOffsetHeight)
        }
        return cellHeight
    }
}
