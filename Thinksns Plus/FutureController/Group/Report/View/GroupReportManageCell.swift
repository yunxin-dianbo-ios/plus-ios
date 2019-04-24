//
//  GroupReportManageCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子举报管理列表的Cell

import UIKit
import YYKit

protocol GroupReportManageCellProtocol: class {
    /// 举报用户 点击回调
    func didClickReportUser(in reportCell: GroupReportManageCell) -> Void
    /// 被举报用户 点击回调
    func didClickReportedUser(in reportCell: GroupReportManageCell) -> Void
    /// 审核按钮 点击回调
    func didClickAuditBtn(in reportCell: GroupReportManageCell) -> Void
    /// 被举报的资源 点击回调
    func didClickReportedResource(in reportCell: GroupReportManageCell) -> Void
    /// 举报原因显示更多 点击回调
    func didClickShowMore(in reportCell: GroupReportManageCell) -> Void
}

class GroupReportManageCell: UITableViewCell {

    // MARK: - Internal Property
    weak var delegate: GroupReportManageCellProtocol?
    static let cellHeight: CGFloat = 75
    /// 重用标识符
    static let identifier: String = "GroupReportManageCellReuseIdentifier"

    var model: GroupReportModel? {
        didSet {
            self.setupWithModel(model)
        }
    }

    // MARK: - Private Property

    fileprivate let lrMargin: CGFloat = 10
    fileprivate let topMargin: CGFloat = 18
    fileprivate let bottomMargin: CGFloat = 15
    fileprivate let verMargin: CGFloat = 10
    fileprivate let viewWidth: CGFloat = ScreenWidth

    fileprivate let contentFont: UIFont = UIFont.systemFont(ofSize: 14)
    fileprivate let contentColor: UIColor = TSColor.main.content

    // topView
    //fileprivate weak var reportPromptLabel: YYLabel!
    fileprivate weak var reportUserBtn: UIButton!
    fileprivate weak var reportedUserBtn: UIButton!
    fileprivate weak var reportedPromptLabel: UILabel!

    // reportContent
    fileprivate weak var reportContentLabel: YYLabel!
    //fileprivate weak var reportContentLabel: UILabel!

    // reportedTargetControl - reportedResource
    fileprivate weak var reportResourceControl: GroupReportManageTargetControll!

    // bottomView
    fileprivate weak var timeLabel: UILabel!
    fileprivate weak var statusBtn: UIButton!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> GroupReportManageCell {
        let identifier = GroupReportManageCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = GroupReportManageCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! GroupReportManageCell
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
        let mainView = UIView(bgColor: UIColor.white)
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        // 1. topView
        let topView = UIView()
        mainView.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.leading.equalTo(mainView).offset(self.lrMargin)
            make.trailing.equalTo(mainView).offset(-self.lrMargin)
            make.top.equalTo(mainView).offset(self.topMargin)
        }
        // 2. reportContentView
        let contentLabel = YYLabel()
        mainView.addSubview(contentLabel)
        contentLabel.numberOfLines = 2
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = TSColor.main.content
        // 宽度限定
        contentLabel.preferredMaxLayoutWidth = self.viewWidth - self.lrMargin * 2.0
        contentLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(topView)
            make.top.equalTo(topView.snp.bottom).offset(self.verMargin)
        }
        self.reportContentLabel = contentLabel
        // 3. reportTargetControl
        let resourceControl = GroupReportManageTargetControll()
        mainView.addSubview(resourceControl)
        resourceControl.addTarget(self, action: #selector(reportedResourceClick), for: .touchUpInside)
        resourceControl.backgroundColor = TSColor.inconspicuous.background
        resourceControl.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(topView)
            make.top.equalTo(contentLabel.snp.bottom).offset(self.verMargin)
            // 高度根据模型来修正
            make.height.equalTo(20)
        }
        self.reportResourceControl = resourceControl
        // 4. bottomView
        // 4.2 statusBtn
        let statusBtn = UIButton(type: .custom)
        mainView.addSubview(statusBtn)
        statusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        statusBtn.contentHorizontalAlignment = .right
        statusBtn.setTitleColor(TSColor.normal.minor, for: .disabled)
        statusBtn.setTitleColor(UIColor(hex: 0x4bb893), for: .normal)
        statusBtn.addTarget(self, action: #selector(statusBtnClick(_:)), for: .touchUpInside)
        statusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(resourceControl.snp.bottom).offset(self.verMargin)
            make.bottom.equalTo(mainView).offset(-self.bottomMargin)
            make.trailing.equalTo(mainView).offset(-self.lrMargin)
        }
        self.statusBtn = statusBtn
        // 4.1 timeLabel
        let timeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled)
        mainView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(mainView).offset(self.lrMargin)
            make.centerY.equalTo(statusBtn)
        }
        self.timeLabel = timeLabel
    }
    /// topView布局
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        // 1. reportUserNameBtn
        let reportUserBtn = UIButton(type: .custom)
        topView.addSubview(reportUserBtn)
        reportUserBtn.setTitleColor(TSColor.main.theme, for: .normal)
        reportUserBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        reportUserBtn.addTarget(self, action: #selector(reportUserBtnClick(_:)), for: .touchUpInside)
        reportUserBtn.contentHorizontalAlignment = .left
        reportUserBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        reportUserBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(topView)
            make.leading.equalTo(topView)
        }
        self.reportUserBtn = reportUserBtn
        // 2. reportPromptLabel
        let reportPromtLabel = UILabel(text: "显示_举报".localized, font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)
        topView.addSubview(reportPromtLabel)
        reportPromtLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(reportUserBtn)
            make.leading.equalTo(reportUserBtn.snp.trailing)
        }
        // 3. reportedUserNameBtn
        let reportedUserBtn = UIButton(type: .custom)
        topView.addSubview(reportedUserBtn)
        reportedUserBtn.setTitleColor(TSColor.main.theme, for: .normal)
        reportedUserBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        reportedUserBtn.addTarget(self, action: #selector(reportedUserBtnClick(_:)), for: .touchUpInside)
        reportedUserBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        reportedUserBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(reportPromtLabel.snp.trailing)
            make.centerY.equalTo(reportUserBtn)
        }
        self.reportedUserBtn = reportedUserBtn
        // 4. reportedPromptLabel
        let reportedPromptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)
        topView.addSubview(reportedPromptLabel)
        reportedPromptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(reportUserBtn)
            make.leading.equalTo(reportedUserBtn.snp.trailing)
        }
        self.reportedPromptLabel = reportedPromptLabel
    }

    // MARK: - Private  数据加载

    /// 数据加载
    fileprivate func setupWithModel(_ model: GroupReportModel?) -> Void {
        guard let model = model else {
            return
        }
        self.reportUserBtn.setTitle(model.user?.name, for: .normal)
        self.reportedUserBtn.setTitle(model.targetUser?.name, for: .normal)
        //self.reportContentLabel.text = model.content
        self.setupReportContentLabel(content: model.content)
        self.timeLabel.text = TSDate().dateString(.normal, nsDate: model.createDate as NSDate)
        // reportedPromptLabel
        var promptText = ""
        if let type = model.type {
            switch type {
            case .post:
                promptText = "的帖子:"
            case .comment:
                promptText = "的评论:"
            }
        }
        self.reportedPromptLabel.text = promptText
        // statusBtn
        self.statusBtn.isEnabled = model.status == .waiting
        var statusTitle = ""
        switch model.status {
        case .waiting:
            statusTitle = "待审核"
        case .accepted:
            statusTitle = "已处理"
        case .rejected:
            statusTitle = "驳回"
        }
        // 帖子被删除时的提示文字
        if model.type == .post && model.post == nil {
            statusTitle = ""
        }
        self.statusBtn.setTitle(statusTitle, for: .normal)
        // resource
        let height = GroupReportManageTargetControll.heightWithModel(model: model)
        self.reportResourceControl.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        self.reportResourceControl.model = model
    }
    /// 举报内容加载 - 使用yyLabel，超过2行时使用更多
    fileprivate func setupReportContentLabel(content: String) -> Void {
        // 构建富文本
        let attContent = NSMutableAttributedString(string: content)
        attContent.font = self.contentFont
        attContent.color = self.contentColor
        // 段落
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0        // 行间距
        attContent.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attContent.length))
        // seeMoreBtn
        let strSeeMore: String = "显示_[查看全部]".localized
        let attMore = NSMutableAttributedString(string: strSeeMore)
        attMore.font = self.contentFont
        attMore.color = TSColor.button.normal

        let highlight = YYTextHighlight()
        highlight.setColor(TSColor.main.theme)     // UIColor(hex: 0x2495bd)
        highlight.tapAction = { [weak self](containerView, text, range, rect) in
            // 展开
            guard let weakSelf = self else {
                return
            }
            self?.delegate?.didClickShowMore(in: weakSelf)
        }

        attMore.setTextHighlight(highlight, range: attMore.rangeOfAll())
        let seeMoreLabel = YYLabel()
        seeMoreLabel.attributedText = attMore
        seeMoreLabel.sizeToFit()

        let truncationToken = NSAttributedString.attachmentString(withContent: seeMoreLabel, contentMode: UIViewContentMode.center, attachmentSize: seeMoreLabel.size, alignTo: seeMoreLabel.font!, alignment: YYTextVerticalAlignment.center)
        self.reportContentLabel.truncationToken = truncationToken
        self.reportContentLabel.attributedText = attContent
    }

    // MARK: - Private  事件响应

    /// 举报用户按钮 点击响应
    @objc fileprivate func reportUserBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickReportUser(in: self)
    }
    /// 被举报的用户按钮 点击响应
    @objc fileprivate func reportedUserBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickReportedUser(in: self)
    }
    /// 审核按钮(未审核状态下) 点击响应
    @objc fileprivate func statusBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickAuditBtn(in: self)
    }
    /// 被举报的资源 点击响应
    @objc fileprivate func reportedResourceClick() -> Void {
        self.delegate?.didClickReportedResource(in: self)
    }

}
