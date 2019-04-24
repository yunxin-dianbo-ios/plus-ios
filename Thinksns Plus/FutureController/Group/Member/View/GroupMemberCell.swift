//
//  GroupMemberCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子成员Cell

import UIKit

protocol GroupMemberCellProtocol: class {
    /// 更多按钮点击回调
    func didMoreBtnClickInMemberCell(_ cell: GroupMemberCell) -> Void
}

class GroupMemberCell: UITableViewCell {

    // MARK: - Internal Property
    // 回调
    weak var delegate: GroupMemberCellProtocol?
    var moreBtnClickAction: ((_ cell: GroupMemberCell) -> Void)?
    var indexPath: IndexPath?

    static let cellHeight: CGFloat = 68 // 15 + 38 + 15
    /// 重用标识符
    static let identifier: String = "GroupMemberCellReuseIdentifier"
    /// 更多响应时距离右侧的间距
    static let moreShowRightMargin: CGFloat = 45 // 15 + 15 + 16

    /// 数据模型
    var model: GroupMemberModel? {
        didSet {
            self.setupWithMember(model)
        }
    }
    /// 显示/隐藏更多选项
    var showMoreFlag: Bool = true {
        didSet {
            self.moreBtn.isHidden = !showMoreFlag
        }
    }
    /// 显示/隐藏底部线条
    var showBottomLine: Bool = true {
        didSet {
            self.bottomLine.isHidden = !showBottomLine
        }
    }

    // MARK: - Private Property

    /// 头像
    fileprivate weak var iconView: AvatarView!
    /// 名称
    fileprivate weak var namelabel: UILabel!
    /// 角色标记(不同角色颜色不一样，有的角色不予展示)
    fileprivate weak var roleBtn: UIButton!     // 不可响应
    /// 右侧更多按钮
    weak var moreBtn: UIButton!
    /// 底部线条
    fileprivate weak var bottomLine: UIView!

    fileprivate let lrMargin: CGFloat = 15
    fileprivate let tbMargin: CGFloat = 15
    fileprivate let horMargin: CGFloat = 15
    fileprivate let iconWH: CGFloat = 38

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> GroupMemberCell {
        let identifier = GroupMemberCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = GroupMemberCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! GroupMemberCell
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
        // line
        self.bottomLine = mainView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        // 1. 头像
        let iconView = AvatarView(type: AvatarType.custom(avatarWidth: self.iconWH, showBorderLine: false))
        mainView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(self.iconWH)
            make.centerY.equalTo(mainView)
            make.leading.equalTo(mainView).offset(lrMargin)
        }
        self.iconView = iconView
        // 2. 名字
        let nameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 17), textColor: TSColor.main.content)
        mainView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView)
            make.leading.equalTo(iconView.snp.trailing).offset(horMargin)
        }
        self.namelabel = nameLabel
        // 3. 角色标识 不可响应，便于控制内边距
        let roleBtn = UIButton(cornerRadius: 9)
        mainView.addSubview(roleBtn)
        roleBtn.isUserInteractionEnabled = false
        roleBtn.setTitleColor(UIColor.white, for: .normal)
        roleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        roleBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        roleBtn.backgroundColor = TSColor.button.disabled
        roleBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView)
            make.leading.equalTo(nameLabel.snp.trailing).offset(horMargin)
        }
        self.roleBtn = roleBtn
        // 4. 更多按钮
        let moreBtn = UIButton(type: .custom)
        mainView.addSubview(moreBtn)
        moreBtn.contentEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        moreBtn.setImage(#imageLiteral(resourceName: "IMG_home_ico_more"), for: .normal)
        moreBtn.addTarget(self, action: #selector(moreBtnClick(_:)), for: .touchUpInside)
        moreBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(mainView)
            make.trailing.equalTo(mainView).offset(-5)
        }
        self.moreBtn = moreBtn
    }

    // MARK: - Private  数据加载

    /// 根据模型加载数据
    func setupWithMember(_ member: GroupMemberModel?) -> Void {
        guard let member = member, let user = member.user else {
            return
        }
        self.iconView.avatarInfo = AvatarInfo(userModel: user)
        self.namelabel.text = member.user?.name
        self.moreBtn.isHidden = member.role == .founder     // 群主 没有更多选项
        switch member.role {
        case .founder:
            self.roleBtn.isHidden = false
            self.roleBtn.setTitle("圈主", for: .normal)
            self.roleBtn.backgroundColor = UIColor(hex: 0xfca308)

        case .administrator:
            self.roleBtn.isHidden = false
            self.roleBtn.setTitle("管理员", for: .normal)
            self.roleBtn.backgroundColor = TSColor.button.disabled

        default:
            self.roleBtn.isHidden = true
        }
    }

    // MARK: - Private  事件响应

    /// 更多按钮点击响应
    @objc fileprivate func moreBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didMoreBtnClickInMemberCell(self)
        self.moreBtnClickAction?(self)
    }

}
