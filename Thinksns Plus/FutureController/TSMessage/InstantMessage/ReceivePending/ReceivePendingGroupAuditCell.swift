//
//  ReceivePendingGroupAuditCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子 待审核成员 Cell

import UIKit

protocol ReceivePendingGroupAuditCellProtocol: class {
    /// 申请用户 点击回调
    func didClickUserInGroupAuditCell(_ cell: ReceivePendingGroupAuditCell) -> Void
    /// 审核按钮 点击响应
    func didClickAuditInGroupAuditCell(_ cell: ReceivePendingGroupAuditCell) -> Void
//    /// 圈子 点击回调
//    func didClickGroupInGroupAuditCell(_ cell: ReceivePendingGroupAuditCell) -> Void
}

class ReceivePendingGroupAuditCell: UITableViewCell {

    // MARK: - Internal Property

    /// 回调
    weak var delegate: ReceivePendingGroupAuditCellProtocol?

    static let cellHeight: CGFloat = 75
    /// 重用标识符
    static let identifier: String = "ReceivePendingGroupAuditCellReuseIdentifier"

    var model: ReceivePendingGroupAuditModel? {
        didSet {
            self.setupWithModel(model)
        }
    }

    // MARK: - Private Property

    fileprivate weak var headerIcon: AvatarView!
    fileprivate weak var nameControl: TSLabelControl!
    fileprivate weak var timeLabel: UILabel!
    fileprivate weak var statusBtn: UIButton!
    fileprivate weak var descLabel: UILabel!

    fileprivate let avatarIconWH: CGFloat = 28
    fileprivate let lrMargin: CGFloat = 10
    fileprivate let topMargin: CGFloat = 15
    fileprivate let nameLeftMargin: CGFloat = 10

    fileprivate let contentTopMargin: CGFloat = 10
    fileprivate let bottomMargin: CGFloat = 15

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> ReceivePendingGroupAuditCell {
        let identifier = ReceivePendingGroupAuditCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = ReceivePendingGroupAuditCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! ReceivePendingGroupAuditCell
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
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        // 1. topView
        let topView = UIView()
        mainView.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(mainView)
        }
        // 2. descView
        let descLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content)
        mainView.addSubview(descLabel)
        descLabel.numberOfLines = 0
        descLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.nameControl)
            make.trailing.equalTo(self.statusBtn)
            make.top.equalTo(topView.snp.bottom).offset(contentTopMargin)
            make.bottom.equalTo(mainView).offset(-bottomMargin)
        }
        self.descLabel = descLabel
    }
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        // 1. headerIcon
        let avatarView = AvatarView(type: AvatarType.custom(avatarWidth: self.avatarIconWH, showBorderLine: false))
        topView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(lrMargin)
            make.width.height.equalTo(avatarIconWH)
            make.top.equalTo(topView).offset(topMargin)
            make.bottom.equalTo(topView)
        }
        self.headerIcon = avatarView
        // 2. nameControl
        let nameControl = TSLabelControl(font: UIFont.systemFont(ofSize: 12), textColor: TSColor.main.content)
        topView.addSubview(nameControl)
        nameControl.addTarget(self, action: #selector(nameControlClick(_:)), for: .touchUpInside)
        nameControl.snp.makeConstraints { (make) in
            make.top.equalTo(avatarView)
            make.leading.equalTo(avatarView.snp.trailing).offset(nameLeftMargin)
        }
        self.nameControl = nameControl
        // 3. timeLabel
        let timeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        topView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(avatarView)
            make.leading.equalTo(nameControl)
        }
        self.timeLabel = timeLabel
        // 4. statusBtn
        let statusBtn = UIButton(type: .custom)
        topView.addSubview(statusBtn)
        statusBtn.addTarget(self, action: #selector(statusBtnClick), for: .touchUpInside)
        statusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        statusBtn.setTitleColor(UIColor(hex: 0x4bb893), for:.normal)
        statusBtn.setTitleColor(TSColor.button.disabled, for: .disabled)
        statusBtn.snp.remakeConstraints { (mark) in
            mark.trailing.equalToSuperview().offset(-lrMargin)
            mark.centerY.equalTo(nameControl)
            mark.height.equalTo(18)
            mark.width.equalTo(42)
        }
        self.statusBtn = statusBtn
    }

    // MARK: - Private  数据加载

    func setupWithModel(_ model: ReceivePendingGroupAuditModel?) -> Void {
        guard let model = model else {
            return
        }
        if let user = model.user {
            let avatarInfo = AvatarInfo(userModel: user)
            avatarInfo.type = AvatarInfo.UserAvatarType.normal(userId: user.userIdentity)
            self.headerIcon.avatarInfo = avatarInfo
        }
        self.nameControl.label.text = model.user?.name
        self.timeLabel.text = TSDate().dateString(.normal, nsDate: model.createDate as NSDate)
        self.statusBtn.layer.borderColor = UIColor.clear.cgColor
        var title: String?
        switch model.status {
        case .wait:
            title = "审核"
            self.statusBtn.layer.cornerRadius = 9
            self.statusBtn.layer.borderColor = TSColor.small.topLogo.cgColor
            self.statusBtn.layer.borderWidth = 0.5
        case .agree:
            title = "同意"
        case .reject:
            title = "驳回"
        }
        self.statusBtn.setTitle(title, for: .normal)
        self.statusBtn.isEnabled = (model.status == .wait)
        // desc
        //self.descLabel.text = String(format: "申请加入你的圈子\"%@\"，请及时审核", )
        let headStrAtt = NSMutableAttributedString(string: "申请加入你的圈子\"")
        headStrAtt.setColor(TSColor.normal.minor, range: headStrAtt.rangeOfAll())
        let groupNameAtt = NSMutableAttributedString(string: model.group?.name ?? "")
        groupNameAtt.setColor(TSColor.main.content, range: groupNameAtt.rangeOfAll())
        let tailStrAtt = NSMutableAttributedString(string: "\"，请及时审核")
        tailStrAtt.setColor(TSColor.normal.minor, range: tailStrAtt.rangeOfAll())
        let attString = NSMutableAttributedString()
        attString.append(headStrAtt)
        attString.append(groupNameAtt)
        attString.append(tailStrAtt)
        attString.setFont(UIFont.systemFont(ofSize: 14), range: attString.rangeOfAll())
        self.descLabel.attributedText = attString
    }

    // MARK: - Private  事件响应

    @objc fileprivate func nameControlClick(_ control: UIControl) -> Void {
        self.delegate?.didClickUserInGroupAuditCell(self)
    }

    @objc fileprivate func statusBtnClick() -> Void {
        self.delegate?.didClickAuditInGroupAuditCell(self)
    }

}
