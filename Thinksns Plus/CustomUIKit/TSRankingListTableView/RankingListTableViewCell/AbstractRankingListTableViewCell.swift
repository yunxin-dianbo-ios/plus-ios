//
//  AbstractRankingListTableViewCell.swift
//  Thinksns Plus
//
//  Created by Lip on 2017/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞列表公共cell的抽象基类

import UIKit
import SnapKit

protocol AbstractRankingListTableViewCellDelegate: NSObjectProtocol {
    func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger)
}

class AbstractRankingListTableViewCell: TSTableViewCell {

    /// 头像尺寸
    let headerImageSize: CGFloat = 40.0
    /// 头像对于上面的距离
    let headerImageTop: CGFloat = 15.0
    /// 头像对于左边的距离
    let headerImageLeft: CGFloat = 10.0
    /// 名次对于上面的距离
    let rankNumberTop: CGFloat = 10.0
    /// 名次的尺寸
    let rankNumberSize: CGSize = CGSize(width: 27.0, height: 11.0)
    /// 昵称相对于上面和左边的距离
    let nickNameLabelLeftAndTop: CGFloat = 15
    /// 昵称的高度
    let nickNameHeight: CGFloat = 16
    /// 内容相对于上面的距离
    let contentLabelTop: CGFloat = 9.0
    /// 内容相对于右边的距离
    let contentLabelRight: CGFloat = -44.0
    /// 内容的高度
    let contentLabelHeight: CGFloat = 14.0
    /// 点赞数量文本相对于上面的距离
    let praiseLabelTop: CGFloat = 10.0
    /// 点赞数量本文高度
    let praiseLabelHeight: CGFloat = 13.0
    /// 按钮尺寸已适当放大!减少误操作!!
    let praiseButtonSize: CGFloat = 40.0
    /// 最新关注按钮宽度
    let praiseButtonWidthNew: CGFloat = 60.0
    /// 最新关注按钮高度
    let praiseButtonHeightNew: CGFloat = 25.0
    /// 按钮图片的偏移量
    let praiseButtonContentImageOffset: CGFloat = 6

    /// 主要数据
    var userInfo: TSUserInfoModel! {
        didSet {
            guard let userModel = userInfo else {
                return
            }
            self.setupWithModel(userModel)
        }
    }
    /// 索引
    var indexPathRow: NSInteger = 0
    /// 头像
    var headerImageButton: AvatarView?
    /// 排名
    var rankNumberLable: UILabel?
    /// 昵称
    var nickNameLabel: TSLabel?
    /// 内容
    var contentLabel: TSLabel?
    /// 点赞多少
    var praiseLabel: TSLabel?
    /// 关注按钮
    var praiseButton: TSButton?
    /// 代理
    weak var delegate: AbstractRankingListTableViewCellDelegate?

    private init() {
        super.init(style: .default, reuseIdentifier: nil)
    }

    func isEnabledHeaderButton(isEnabled: Bool) {
        headerImageButton?.buttonForAvatar.isUserInteractionEnabled = isEnabled
    }

    init(style: UITableViewCellStyle, reuseIdentifier: String?, userInfo: TSUserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.userInfo = userInfo
        self.headerImageButton = AvatarView(type: AvatarType.width38(showBorderLine: false))
        let avatarInfo = AvatarInfo(userModel: userInfo)
        self.headerImageButton?.avatarInfo = avatarInfo
        self.contentView.addSubview(self.headerImageButton!)
        self.headerImageButton?.snp.makeConstraints({ make in
            make.left.equalTo(self.contentView.snp.left).offset(headerImageLeft)
            make.top.equalTo(self.contentView.snp.top).offset(headerImageTop)
            make.size.equalTo(CGSize(width: headerImageSize, height: headerImageSize))
        })
        self.rankNumberLable = UILabel()
        rankNumberLable?.textColor = TSColor.normal.blackTitle
        rankNumberLable?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        rankNumberLable?.textAlignment = .center
        self.contentView.addSubview(self.rankNumberLable!)
        self.rankNumberLable?.snp.makeConstraints({ make in
            make.top.equalTo(self.headerImageButton!.snp.bottom).offset(rankNumberTop)
            make.centerX.equalTo(self.headerImageButton!.snp.centerX)
            make.size.equalTo((CGSize(width: rankNumberSize.width, height: rankNumberSize.height)))
        })

        self.nickNameLabel = TSLabel()
        self.contentView.addSubview(self.nickNameLabel!)
        self.nickNameLabel?.textColor = TSColor.normal.blackTitle
        self.nickNameLabel?.font = UIFont.systemFont(ofSize: TSFont.SubUserName.home.rawValue)
        self.nickNameLabel?.snp.makeConstraints({ make in
            make.left.equalTo(self.headerImageButton!.snp.right).offset(nickNameLabelLeftAndTop)
            make.top.equalTo(self.contentView.snp.top).offset(nickNameLabelLeftAndTop)
            make.height.equalTo(nickNameHeight)
            make.width.equalTo(UIScreen.main.bounds.width-65-10-60-10)
        })

        self.praiseButton = TSButton()
        self.praiseButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.praiseButton?.layer.cornerRadius = 3
        self.praiseButton?.addTarget(self, action: #selector(followTouch(_:)), for: .touchUpInside)
        self.contentView.addSubview(self.praiseButton!)
//        self.praiseButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: praiseButtonContentImageOffset)
        self.praiseButton?.snp.makeConstraints({ make in
            make.right.equalTo(self.contentView.snp.right).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: praiseButtonWidthNew, height: praiseButtonHeightNew))
        })

        self.contentLabel = TSLabel()
        self.contentView.addSubview(self.contentLabel!)
        self.contentLabel?.textColor = TSColor.normal.minor
        self.contentLabel?.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue)
        self.contentLabel?.snp.makeConstraints({ make in
            make.leftMargin.equalTo(self.nickNameLabel!.snp.leftMargin)
            make.top.equalTo(self.nickNameLabel!.snp.bottom).offset(contentLabelTop)
            if self.praiseButton != nil {
                make.right.equalTo(self.praiseButton!.snp.left).offset(-20)
            } else {
                make.right.equalTo(self.contentView.snp.right).offset(contentLabelRight)
            }
            make.height.equalTo(contentLabelHeight)
        })

        self.praiseLabel = TSLabel()
        self.contentView.addSubview(self.praiseLabel!)
        self.praiseLabel?.snp.makeConstraints({ make in
            make.leftMargin.equalTo(self.contentLabel!.snp.leftMargin)
            make.top.equalTo(contentLabel!.snp.bottom).offset(praiseLabelTop)
            make.height.equalTo(praiseLabelHeight)
        })
    }

    /// 关注按钮方法
    ///
    /// - Parameter btn: 按钮
    func followTouch(_ btn: TSButton) {
        self.delegate?.cell(self, operateBtn: btn, indexPathRow: indexPathRow)
    }

    // 数据加载
    fileprivate func setupWithModel(_ userModel: TSUserInfoModel) -> Void {
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: userModel.avatar)
        avatarInfo.verifiedType = userModel.verified?.type ?? ""
        avatarInfo.verifiedIcon = userModel.verified?.icon ?? ""
        self.headerImageButton?.avatarInfo = avatarInfo
        self.nickNameLabel?.text = userModel.name
        self.contentLabel?.text = userModel.shortDesc()
        // 右侧按钮
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
