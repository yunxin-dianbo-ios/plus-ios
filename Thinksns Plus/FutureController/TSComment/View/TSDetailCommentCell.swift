//
//  TSDetailCommentCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论列表中的Cell
//  类似于之前的TSDetailCommentTableViewCell，并取代它

import Foundation
import UIKit

protocol TSDetailCommentCellProtocol: class {
    /// 点击用户头像
    func commentCell(_ cell: TSDetailCommentCell, didClickUserIcon userId: Int) -> Void
    /// 点击用户昵称(用户昵称和用户头像可能并不是同一人)
    func commentCell(_ cell: TSDetailCommentCell, didClickUserName userId: Int) -> Void
    /// 点击重新发送
    func didClickResendBtnInCommentCell(_ cell: TSDetailCommentCell) -> Void
}

class TSDetailCommentCell: UITableViewCell {

    // MARK: - Internal Property
    static let cellHeight: CGFloat = 75
    /// 重用标识符
    static let identifier: String = "TSDetailCommentCellReuseIdentifier"

    /// 回调
    weak var delegate: TSDetailCommentCellProtocol?
    /// 数据
    var model: TSCommentViewModel? {
        didSet {
            self.setupWithModel(model)
        }
    }
    var simpleModel: TSSimpleCommentModel? {
        didSet {
            self.setupWithModel(simpleModel)
        }
    }

    // MARK: - Private Property
    /// 主控件
    fileprivate weak var mainView: UIView!
    /// 头像
    fileprivate weak var headerIcon: AvatarView!
    /// 昵称
    fileprivate weak var nameControl: TSLabelControl!
    /// 时间
    fileprivate weak var timeLabel: UILabel!
    /// 置顶标记
    fileprivate weak var topFlag: UIImageView!
    /// 评论内容
    fileprivate weak var commentView: TSCommentContentView!

    /// 重新发送按钮(发送失败的本地评论)
    fileprivate weak var resendBtn: UIButton!

    fileprivate let avatarIconWH: CGFloat = 40
    fileprivate let lrMargin: CGFloat = 10
    fileprivate let topMargin: CGFloat = 15
    fileprivate let nameH: CGFloat = 15
    fileprivate let nameLeftMargin: CGFloat = 15
    fileprivate let timeLeftMargin: CGFloat = 8
    fileprivate let contentTopMargin: CGFloat = 10
    fileprivate let bottomMargin: CGFloat = 15

    // 需实际进行修正
    fileprivate var resendIconW: CGFloat = 16

    fileprivate var commentLeftMargin: CGFloat {
        return self.lrMargin + self.avatarIconWH + self.nameLeftMargin
    }

    // MARK: - Internal Function

    /// 便利重用构造
    class func cellInTableView(_ tableView: UITableView) -> TSDetailCommentCell {
        let identifier = TSDetailCommentCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSDetailCommentCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        cell?.selectionStyle = .none
        return cell as! TSDetailCommentCell
    }

    /// 高度计算
    class func heightWithModel(_ comment: TSCommentViewModel) -> CGFloat {
        let cell = TSDetailCommentCell(style: .default, reuseIdentifier: "")
        let fixedH: CGFloat = cell.topMargin + cell.nameH + cell.contentTopMargin + cell.bottomMargin
        // 计算评论内容的实际宽度
        let commentRightMargin: CGFloat = (comment.status == .faild) ? (cell.lrMargin * 2.0 + cell.resendIconW) : cell.lrMargin
        let commentW: CGFloat = ScreenWidth - cell.commentLeftMargin - commentRightMargin
        let commentH: CGFloat = TSCommentContentView.heightWithModel(comment, type: .detail, maxW: commentW)
        return fixedH + commentH
        return 0
    }
    class func heightWithModel(_ comment: TSSimpleCommentModel) -> CGFloat {
        let cell = TSDetailCommentCell(style: .default, reuseIdentifier: "")
        let fixedH: CGFloat = cell.topMargin + cell.nameH + cell.contentTopMargin + cell.bottomMargin
        // 计算评论内容的实际宽度
        let commentRightMargin: CGFloat = (comment.status == 1) ? (cell.lrMargin * 2.0 + cell.resendIconW) : cell.lrMargin
        let commentW: CGFloat = ScreenWidth - cell.commentLeftMargin - commentRightMargin
        let commentH: CGFloat = TSCommentContentView.heightWithModel(comment, type: .detail, maxW: commentW)
        return fixedH + commentH
        return 0
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        self.mainView = mainView
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        // 1. headerIcon
        let avatarView = AvatarView(type: .width38(showBorderLine: false))
        mainView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.leading.equalTo(mainView).offset(lrMargin)
            make.top.equalTo(mainView).offset(topMargin)
            make.width.height.equalTo(avatarIconWH)
        }
        self.headerIcon = avatarView
        // 2. nameControl
        let nameControl = TSLabelControl(font: UIFont.systemFont(ofSize: 13), textColor: TSColor.main.content)
        mainView.addSubview(nameControl)
        nameControl.addTarget(self, action: #selector(nameControlClick(_:)), for: .touchUpInside)
        nameControl.snp.makeConstraints { (make) in
            make.top.equalTo(avatarView)
            make.leading.equalTo(avatarView.snp.trailing).offset(nameLeftMargin)
            make.height.equalTo(nameH)
        }
        self.nameControl = nameControl
        // 3. timeLabel
        let timeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        mainView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarView)
            make.trailing.equalTo(mainView).offset(-lrMargin)
        }
        self.timeLabel = timeLabel
        // 4. topFlg
        let topImg = #imageLiteral(resourceName: "IMG_label_zhiding")
        let topFlag = UIImageView(cornerRadius: 0)
        mainView.addSubview(topFlag)
        topFlag.image = topImg
        topFlag.snp.makeConstraints { (make) in
            make.trailing.equalTo(timeLabel.snp.leading).offset(-timeLeftMargin)
            make.centerY.equalTo(timeLabel)
            make.width.equalTo(topImg.size.width)
            make.height.equalTo(topImg.size.height)
        }
        self.topFlag = topFlag
        // 6. resendBtn
        let resendImage = #imageLiteral(resourceName: "IMG_msg_box_remind")
        let resendBtn = UIButton(type: .custom)
        mainView.addSubview(resendBtn)
        resendBtn.setImage(resendImage, for: .normal)
        resendBtn.addTarget(self, action: #selector(resendBtnClick(_:)), for: .touchUpInside)
        resendBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(mainView).offset(-lrMargin)
            make.top.equalTo(timeLabel.snp.bottom).offset(contentTopMargin)
            make.height.equalTo(resendImage.size.width)
            make.width.equalTo(resendImage.size.height)
        }
        self.resendBtn = resendBtn
        self.resendIconW = resendImage.size.width
        // 5. commentView
        let commentView = TSCommentContentView(type: .detail)
        mainView.addSubview(commentView)
        commentView.snp.makeConstraints { (make) in
            make.top.equalTo(nameControl.snp.bottom).offset(contentTopMargin)
            make.bottom.equalTo(mainView).offset(-bottomMargin)
            make.leading.equalTo(nameControl)
            // 右侧约束根据需要再下面中进行修正
            make.trailing.equalTo(mainView).offset(-lrMargin)
            //make.trailing.equalTo(mainView).offset(-lrMargin - lrMargin - resendIconW)
            //make.trailing.equalTo(resendBtn.snp.leading).offset(-lrMargin)
        }
        self.commentView = commentView
        // 6. bottomLine
        mainView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }

    // MARK: - Private  数据加载
    /// 加载数据
    func setupWithModel(_ comment: TSCommentViewModel?) -> Void {
        guard let comment = comment else {
            return
        }
        self.topFlag.isHidden = !comment.isTop
        self.resendBtn.isHidden = (comment.status != .faild)
        // 如果cell每次重用时重置的话，则这里无需处理正常状态
        let commentRightMargin: CGFloat = (comment.status == .faild) ? (lrMargin * 2.0 + self.resendIconW) : lrMargin
        self.commentView.snp.updateConstraints { (make) in
            make.trailing.equalTo(self.mainView).offset(-commentRightMargin)
        }
        self.layoutIfNeeded()
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: comment.user?.avatar)
        avatarInfo.verifiedIcon = comment.user?.verified?.icon ?? ""
        avatarInfo.verifiedType = comment.user?.verified?.type ?? ""
        avatarInfo.type = .normal(userId: comment.userId)
        self.headerIcon.avatarInfo = avatarInfo
        self.nameControl.title = comment.user?.name
        if let date = comment.createDate {
            self.timeLabel.text = TSDate().dateString(.normal, nsDate: date as NSDate)
        } else {
            self.timeLabel.text = ""
        }
        let commentW: CGFloat = ScreenWidth - commentRightMargin - self.commentLeftMargin
        self.commentView.loadComment(comment, width: commentW)
    }
    func setupWithModel(_ comment: TSSimpleCommentModel?) -> Void {
        guard let comment = comment else {
            return
        }
        self.topFlag.isHidden = !comment.isTop
        /// 状态 0：已成功的 1：未成功的 2 : 正在发送中
        self.resendBtn.isHidden = (comment.status != 1)
        // 如果cell每次重用时重置的话，则这里无需处理正常状态
        let commentRightMargin: CGFloat = (comment.status == 1) ? (lrMargin * 2.0 + self.resendIconW) : lrMargin
        self.commentView.snp.updateConstraints { (make) in
            make.trailing.equalTo(self.mainView).offset(-commentRightMargin)
        }
        self.layoutIfNeeded()
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: comment.userInfo?.avatar)
        avatarInfo.verifiedIcon = comment.userInfo?.verified?.icon ?? ""
        avatarInfo.verifiedType = comment.userInfo?.verified?.type ?? ""
        avatarInfo.type = .normal(userId: comment.userInfo?.userIdentity)
        self.headerIcon.avatarInfo = avatarInfo
        self.nameControl.title = comment.userInfo?.name
        if let date = comment.createdAt {
            self.timeLabel.text = TSDate().dateString(.normal, nsDate: date)
        } else {
            self.timeLabel.text = ""
        }
        let commentW: CGFloat = ScreenWidth - commentRightMargin - self.commentLeftMargin
        self.commentView.loadComment(comment, width: commentW)
    }

    // MARK: - Private  事件响应

    /// 用户头像点击响应
    @objc fileprivate func headerIconClick(_ button: UIButton) -> Void {
        // Remark: - 注：ViewModel中应自带userId，待完成
        guard let model = self.model, let userId = model.user?.userIdentity else {
            return
        }
        self.delegate?.commentCell(self, didClickUserIcon: userId)
    }
    /// 用户昵称点击响应
    @objc fileprivate func nameControlClick(_ control: UIControl) -> Void {
        // Remark: - 注：ViewModel中应自带userId，待完成
        guard let model = self.model, let userId = model.user?.userIdentity else {
            return
        }
        self.delegate?.commentCell(self, didClickUserName: userId)
    }
    /// 重新发送按钮点击响应
    @objc fileprivate func resendBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickResendBtnInCommentCell(self)
    }

}
