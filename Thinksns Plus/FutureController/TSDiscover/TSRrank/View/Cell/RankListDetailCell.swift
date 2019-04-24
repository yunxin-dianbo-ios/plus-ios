//
//  RankListDetailCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜 detail cell

import UIKit

protocol RankListDetailCellDelegate: class {
    /// 点击了关注按钮
    func rankDetailCell(_ cell: RankListDetailCell, didSelected followButtn: UIButton)
}

class RankListDetailCell: UITableViewCell {

    static let identifier = "RankListDetailCell"

    /// 代理
    weak var delegate: RankListDetailCellDelegate?

    /// 排行名词
    @IBOutlet weak var labelForRank: UILabel!
    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 姓名
    @IBOutlet weak var labelForName: UILabel!
    /// 关注按钮
    @IBOutlet weak var buttonForFollow: UIButton!
    /// 榜单相关数据
    @IBOutlet weak var labelForDetail: UILabel!

    /// 数据
    var cellModel: RankListDetailCellModel?

    // MARK: - Lifecycle
    class func cellFor(table: UITableView, at indexPath: IndexPath, with model: RankListDetailCellModel) -> RankListDetailCell {
        let cell = table.dequeueReusableCell(withIdentifier: RankListDetailCell.identifier, for: indexPath) as! RankListDetailCell
        cell.setInfo(model: model)
        return cell
    }

    // MARK: - UI

    /// 点击了关注按钮
    @IBAction func followButtonTaped(_ sender: UIButton) {
        delegate?.rankDetailCell(self, didSelected: sender)
    }

    func setInfo(model: RankListDetailCellModel) {
        cellModel = model
        // 排行名次
        labelForRank.text = "\(model.rank)"
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.userInfo.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.userInfo.avatar)
        avatarInfo.verifiedType = model.userInfo.verified?.type ?? ""
        avatarInfo.verifiedIcon = model.userInfo.verified?.icon ?? ""
        avatarInfo.type = .normal(userId: model.userInfo.userIdentity)
        buttonForAvatar.avatarInfo = avatarInfo
        // 姓名
        labelForName.text = model.userInfo.name
        // 关注按钮
        self.buttonForFollow?.layer.cornerRadius = 3
        let praiseTitle: String?
        if let praiseTitleS = model.userInfo.relationshipTextWithCurrentUser()?.rawValue {
            praiseTitle = praiseTitleS
            self.buttonForFollow?.isHidden = false
            if praiseTitleS == "已关注" || praiseTitleS == "互相关注" {
                self.buttonForFollow?.setTitleColor(TSColor.main.theme, for: .normal)
                self.buttonForFollow?.backgroundColor = UIColor.white
                self.buttonForFollow?.layer.borderColor = TSColor.main.theme.cgColor
                self.buttonForFollow?.layer.borderWidth = 0.5
            } else if praiseTitleS == "+ 关注" {
                self.buttonForFollow?.setTitleColor(UIColor.white, for: .normal)
                self.buttonForFollow?.backgroundColor = TSColor.main.theme
            } else {
                self.buttonForFollow?.isHidden = true
            }
        } else {
            praiseTitle = nil
            self.buttonForFollow?.isHidden = true
        }
        self.buttonForFollow?.setTitle(praiseTitle, for: .normal)
        // 榜单相关数据
        labelForDetail.text = model.detailInfo
    }
}
