//
//  GroupListCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子列表 cell

import UIKit

protocol GroupListCellDelegate: class {
    /// 点击了加入按钮
    func groupListCellDidSelectedJoinButton(_ cell: GroupListCell)
}

class GroupListCell: UITableViewCell {

    static let identifier = "GroupListCell"

    /// 代理
    weak var delegate: GroupListCellDelegate?

    /// 圈子封面图
    let coverImageView = UIImageView()
    /// 圈子名称
    let nameLabel = UILabel()
    /// 图标
    let tailImageView = UIImageView()
    /// 详情信息
    let detailLabel = UILabel()
    /// 加入按钮
    let joinButton = UIButton(type: .custom)
    /// 职位标签
    let positionTag = UILabel()
    /// 审核信息
    let auditLabel = UILabel()
    /// 分割线
    let seperator = UIView()

    /// 数据
    var model = GroupListCellModel() {
        didSet {
            loadModel()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(joinButton)
        contentView.addSubview(positionTag)
        contentView.addSubview(auditLabel)
        contentView.addSubview(seperator)
        contentView.addSubview(tailImageView)
    }

    func loadModel() {
        // 1.封面图
        coverImageView.kf.setImage(with: URL(string: model.cover), placeholder: UIImage.create(with: TSColor.inconspicuous.disabled, size: CGSize(width: 60, height: 60)), options: nil, progressBlock: nil, completionHandler: nil)

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.frame = CGRect(x: 10, y: 15, width: 60, height: 60)

        // 2.圈子名称
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.numberOfLines = 1
        let name = NSString(string: model.name)
        nameLabel.text = name.replacingOccurrences(of: "\n", with: "")
        nameLabel.sizeToFit()
        let nameWidth = min(UIScreen.main.bounds.width - 200, nameLabel.width)
        nameLabel.frame = CGRect(x: coverImageView.frame.maxX + 10, y: 25, width: nameWidth, height: nameLabel.height)
        nameLabel.lineBreakMode = .byTruncatingTail

        // 3.圈子标签图片
        if let tailImage = model.tailImage {
            let tailImage = UIImage(named: tailImage.rawValue)!
            tailImageView.image = tailImage
            tailImageView.frame = CGRect(origin: CGPoint(x: nameLabel.frame.maxX + 5, y: nameLabel.frame.minY + 2), size: tailImage.size)
        } else {
            tailImageView.image = nil
        }

        // 4.详情信息
        loadDetailLable()

        // 5.加载右边视图
        loadRightView()

        // 6.分割线
        seperator.backgroundColor = UIColor(hex: 0xededed)
        seperator.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.width, height: 1)
    }

    /// 加载详情信息
    func loadDetailLable() {
        var detailAttributeString = NSMutableAttributedString()
        switch model.detailInfo {
        case .none:
            return
        case .countInfo(let postCount, let memberCount):
            let strings = ["帖子", " \(postCount)", "  成员", " \(memberCount)"]
            let colors = [UIColor(hex: 0x999999), TSColor.main.theme, UIColor(hex: 0x999999), TSColor.main.theme]
            detailAttributeString = NSMutableAttributedString.attributeStringWith(strings: strings, colors: colors, fonts: [14, 14, 14, 14])
        case .create(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let string = formatter.string(from: date)
            detailAttributeString = NSMutableAttributedString.attributeStringWith(strings: [string], colors: [UIColor(hex: 0x999999)], fonts: [14])
        }

        detailLabel.attributedText = detailAttributeString
        detailLabel.sizeToFit()
        detailLabel.frame = CGRect(origin: CGPoint(x: nameLabel.frame.minX, y: nameLabel.frame.maxY + 8), size: detailLabel.size)
    }

    /// 加载右边视图
    func loadRightView() {
        switch model.rightType {
        case .none:
            return
        case .joinButtonAndRoleTag:
            loadJoinButtonAndRoleTag()
        case .audit(let audit):
            loadAuditLabel(audit)
        }
    }

    /// 加载审核信息
    func loadAuditLabel(_ auditInfo: String) {
        guard !auditInfo.isEmpty else {
            auditLabel.isHidden = true
            return
        }
        auditLabel.isHidden = false
        auditLabel.textColor = UIColor(hex: 0xb3b3b3)
        auditLabel.font = UIFont.systemFont(ofSize: 14)
        auditLabel.textAlignment = .right
        auditLabel.text = auditInfo
        auditLabel.sizeToFit()
        let labelX = UIScreen.main.bounds.width - 10 - auditLabel.size.width
        var labelY = (90 - auditLabel.size.height) / 2
        auditLabel.frame = CGRect(origin: CGPoint(x: labelX, y: labelY), size: auditLabel.size)
        /// 如果有标签图片，比如付费，审核label就和时间label(detailLabel)中心对齐
        if tailImageView.image != nil {
            auditLabel.centerY = detailLabel.centerY
        }
    }

    /// 加载职位标签和加入按钮
    func loadJoinButtonAndRoleTag() {
        switch model.role {
        case .master:
            positionTag.backgroundColor = UIColor(hex: 0xfca308)
            loadPositionTag()
        case .manager:
            positionTag.backgroundColor = UIColor(hex: 0xcccccc)
            loadPositionTag()
        case .member:
            loadJoinButton()
            // 还要判断审核状态
            if model.joined?.audit == 1 {
                joinButton.isHidden = true
                positionTag.isHidden = true
            } else {
                joinButton.isHidden = false
                positionTag.isHidden = true
            }
        case .black:
            joinButton.isHidden = true
            positionTag.isHidden = true
        case .unjoined:
            loadJoinButton()
        }
    }

    /// 加载职位标签
    private func loadPositionTag() {
        joinButton.isHidden = true
        positionTag.isHidden = false
        positionTag.font = UIFont.systemFont(ofSize: 10)
        positionTag.textColor = .white
        positionTag.layer.cornerRadius = 7.5
        positionTag.textAlignment = .center
        positionTag.clipsToBounds = true
        positionTag.text = model.role.rawValue
        positionTag.sizeToFit()
        let posWidth = positionTag.size.width + 20
        let posX = UIScreen.main.bounds.width - 15 - posWidth
        let posY: CGFloat = (90 - 15) / 2
        positionTag.frame = CGRect(x: posX, y: posY, width: posWidth, height: 15)
    }

    /// 加载加入按钮
    private func loadJoinButton() {
        positionTag.isHidden = true
        joinButton.isHidden = false

        let titleColor = TSColor.main.theme
        joinButton.layer.borderColor = titleColor.cgColor
        joinButton.layer.borderWidth = 1
        joinButton.layer.cornerRadius = 4
        joinButton.clipsToBounds = true
        joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        joinButton.setTitle("加入", for: .normal)
        joinButton.setTitleColor(titleColor, for: .normal)
        joinButton.setImage(UIImage(named: "IMG_channel_ico_add_blue"), for: .normal)
        joinButton.addTarget(self, action: #selector(joinButtonTaped(_:)), for: .touchUpInside)
        joinButton.sizeToFit()
        let joinX = UIScreen.main.bounds.width - 63 - 10
        joinButton.frame = CGRect(x: joinX, y: 32, width: 63, height: 25)
    }

    // 点击了加入按钮
    func joinButtonTaped(_ sender: UIButton) {
        delegate?.groupListCellDidSelectedJoinButton(self)
    }
}
