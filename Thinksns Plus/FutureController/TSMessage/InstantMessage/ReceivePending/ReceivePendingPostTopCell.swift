//
//  ReceivePendingPostTopCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 22/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子置顶Cell

import UIKit

protocol ReceivePendingPostTopCellProtocol: class {
    /// 申请用户 点击回调
    func didClickUserInPostTopCell(_ cell: ReceivePendingPostTopCell) -> Void
    /// 审核按钮 点击响应
    func didClickAuditInPostTopCell(_ cell: ReceivePendingPostTopCell) -> Void
    /// 帖子 点击响应
    func didClickPostInPostTopCell(_ cell: ReceivePendingPostTopCell) -> Void
//    /// 圈子 点击回调
//    func didClickGroupInGroupAuditCell(_ cell: ReceivePendingPostTopCell) -> Void
}

class ReceivePendingPostTopCell: UITableViewCell {

    // MARK: - Internal Property

    /// 回调
    weak var delegate: ReceivePendingPostTopCellProtocol?

    static let cellHeight: CGFloat = 75
    /// 重用标识符
    static let identifier: String = "ReceivePendingPostTopCellReuseIdentifier"

    var model: ReceivePendingPostTopModel? {
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
    fileprivate weak var postControl: ReceivePendingPostSourceControl!
    /// 置顶信息
    let topInfoLabel: UILabel = UILabel(frame: CGRect.zero)

    /// 置顶帖子 - 帖子可能被删除

    fileprivate let avatarIconWH: CGFloat = 28
    fileprivate let postControlH: CGFloat = 44
    fileprivate let lrMargin: CGFloat = 10
    fileprivate let topMargin: CGFloat = 15
    fileprivate let nameLeftMargin: CGFloat = 10

    fileprivate let contentTopMargin: CGFloat = 10
    fileprivate let postTopMargin: CGFloat = 10
    fileprivate let postMargin: CGFloat = 5
    fileprivate let bottomMargin: CGFloat = 15

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> ReceivePendingPostTopCell {
        let identifier = ReceivePendingPostTopCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = ReceivePendingPostTopCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! ReceivePendingPostTopCell
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

        // modelure the view for the selected state
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
        }
        self.descLabel = descLabel
        // 3. postControl
        let postControl = ReceivePendingPostSourceControl()
        mainView.addSubview(postControl)
        postControl.addTarget(self, action: #selector(postControlClick), for: .touchUpInside)
        postControl.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(descLabel)
            make.top.equalTo(descLabel.snp.bottom).offset(postTopMargin)
            make.bottom.equalTo(mainView).offset(-bottomMargin)
            make.height.equalTo(postControlH)     // 默认高度
        }
        self.postControl = postControl
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
        nameControl.label.textAlignment = .left
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
        statusBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(topView).offset(-lrMargin)
            make.centerY.equalTo(nameControl)
            make.height.equalTo(22)
        }
        self.statusBtn = statusBtn

        topView.addSubview(topInfoLabel)
        self.topInfoLabel.font = UIFont.systemFont(ofSize: 12)
        self.topInfoLabel.textColor = UIColor(red: 252.0 / 255.0, green: 163.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        self.topInfoLabel.isHidden = true
        self.topInfoLabel.textAlignment = .right

        topInfoLabel.snp.remakeConstraints { (mark) in
            mark.right.equalToSuperview().offset(-65)
            mark.centerY.equalTo(nameControl.snp.centerY)
            mark.left.equalTo(nameControl.snp.right).offset(10)
            mark.height.equalTo(12)
        }
    }

    // MARK: - Private  数据加载

    func setupWithModel(_ model: ReceivePendingPostTopModel?) -> Void {
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
        // 置顶积分/时间
        if model.day > 0 && model.post != nil {
            topInfoLabel.isHidden = false
            topInfoLabel.text = "\(model.amount)" + TSAppConfig.share.localInfo.goldName + " / " + "\(model.day)天"
        } else {
            topInfoLabel.isHidden = true
            topInfoLabel.text = ""
        }
        self.statusBtn.layer.borderColor = UIColor.clear.cgColor
        self.statusBtn.snp.remakeConstraints { (mark) in
            mark.trailing.equalToSuperview().offset(-lrMargin)
            mark.centerY.equalTo(nameControl)
            mark.height.equalTo(22)
        }
        var title: String?
        switch model.status {
        case .wait:
            title = "审核"
            self.statusBtn.layer.cornerRadius = 9
            self.statusBtn.layer.borderColor = TSColor.small.topLogo.cgColor
            self.statusBtn.layer.borderWidth = 0.5
            self.statusBtn.snp.remakeConstraints { (mark) in
                mark.trailing.equalToSuperview().offset(-lrMargin)
                mark.centerY.equalTo(nameControl)
                mark.height.equalTo(18)
                mark.width.equalTo(42)
            }
            topInfoLabel.textColor = UIColor(red: 252.0 / 255.0, green: 163.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        case .agree:
            title = "同意置顶"
            topInfoLabel.textColor = TSColor.normal.disabled
        case .reject:
            title = "拒绝置顶"
            topInfoLabel.textColor = TSColor.normal.disabled
        }
        self.statusBtn.setTitle(title, for: .normal)
        self.statusBtn.isEnabled = (model.status == .wait)
        self.statusBtn.setTitleColor(TSColor.button.disabled, for: .disabled) // 避免被删除的颜色影响
        // desc
        //self.descLabel.text = String(format: "申请加入你的圈子\"%@\"，请及时审核", )
        //let headStrAtt = NSMutableAttributedString(string: "申请将动态在你管理的圈子\"")
        let headStrAtt = NSMutableAttributedString(string: "申请将帖子在你管理的圈子")
        headStrAtt.setColor(TSColor.normal.minor, range: headStrAtt.rangeOfAll())
        //let groupNameAtt = NSMutableAttributedString(string: model.group?.name ?? "")
        //groupNameAtt.setColor(TSColor.main.content, range: groupNameAtt.rangeOfAll())
        //let tailStrAtt = NSMutableAttributedString(string: "\"置顶，请及时审核")
        let tailStrAtt = NSMutableAttributedString(string: "置顶，请及时审核")
        tailStrAtt.setColor(TSColor.normal.minor, range: tailStrAtt.rangeOfAll())
        let attString = NSMutableAttributedString()
        attString.append(headStrAtt)
        //attString.append(groupNameAtt)
        attString.append(tailStrAtt)
        attString.setFont(UIFont.systemFont(ofSize: 14), range: attString.rangeOfAll())
        self.descLabel.attributedText = attString
        // post
        if let post = model.post {
            self.postControl.model = post
            self.postControl.snp.updateConstraints({ (make) in
                make.height.equalTo(self.postControlH)
            })
        } else {
            // 帖子已删除的特殊处理
            self.statusBtn.layer.borderColor = UIColor.clear.cgColor
            self.statusBtn.setTitle("该帖子已删除", for: .normal)
            self.statusBtn.snp.remakeConstraints { (mark) in
                mark.trailing.equalToSuperview().offset(-lrMargin)
                mark.centerY.equalTo(nameControl)
                mark.height.equalTo(22)
                mark.width.equalTo(80)
            }
            self.statusBtn.isEnabled = false
            self.statusBtn.setTitleColor(UIColor(hex: 0xf4504d), for: .disabled)
            self.postControl.removeAllSubViews()
            self.postControl.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
        }
    }

    // MARK: - Private  事件响应

    /// 用户名 点击
    @objc fileprivate func nameControlClick(_ control: UIControl) -> Void {
        self.delegate?.didClickUserInPostTopCell(self)
    }
    /// 审核状态 点击
    @objc fileprivate func statusBtnClick() -> Void {
        self.delegate?.didClickAuditInPostTopCell(self)
    }
    /// 帖子 点击
    @objc fileprivate func postControlClick() -> Void {
        self.delegate?.didClickPostInPostTopCell(self)
    }

}
