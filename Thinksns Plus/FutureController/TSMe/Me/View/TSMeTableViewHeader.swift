//
//  TSMeTableViewHeader.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// MeTableView头视图分离的view

import UIKit
import Kingfisher

protocol didHeaderViewDelegate: NSObjectProtocol {
    /// 点击了头视图中的那一个view
    func didHeaderIndex(index: MeHeaderView)
}

enum MeHeaderView: Int {
    /// userinfoview
    case user = 0
    /// fans view
    case fans
    /// follow view
    case follow
    /// friend view
    case friend
}

class TSMeTableViewHeader: UIView {
    /// 用户信息展示view
    let userInfoView: UIView = UIView()
    /// 头像图片
    var avatar: AvatarView!
    /// 名字
    var name: UILabel = UILabel()
    /// 简介
    var intro: TYAttributedLabel = TYAttributedLabel()
    /// >
    var accessory: UIImageView = UIImageView()
    ///  用户id
    let id = TSCurrentUserInfo.share.userInfo?.userIdentity
    weak var didHeaderViewDelegate: didHeaderViewDelegate? = nil
    /// 粉丝和关注的背景view
    let userFansAndFollowBackGround: UIView = UIView()
    /// 粉丝view
    let fansView: UIView = UIView()
    /// 关注view
    let followView: UIView = UIView()
    /// 好友view
    let friendView: UIView = UIView()
    /// 数字 - 粉丝
    let fanslabel: UILabel = UILabel()
    /// 数字 - 关注
    let followlabel: UILabel = UILabel()
    /// 数字 - 好友
    let friendlabel: UILabel = UILabel()
    /// 粉丝小红点
    let fansBage = TSBageNumberView()
    /// 关注小红点
    let followBage = TSBageNumberView()
    /// 好友小红点
    let friendBage = TSBageNumberView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        setUserInfo()
        setUserFansAndFollow()
    }

    /// load用户信息展示
    func  setUserInfo() {
        userInfoView.backgroundColor = TSColor.main.white
        /// 给用户信息展示view添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapUser))
        userInfoView.addGestureRecognizer(tap)

        // 头像
        avatar = AvatarView(type: AvatarType.width60(showBorderLine: false))
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (TSCurrentUserInfo.share.userInfo?.sex ?? 0))
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: TSCurrentUserInfo.share.userInfo?.avatar)
        avatarInfo.verifiedIcon = TSCurrentUserInfo.share.userInfo?.verified?.icon ?? ""
        avatarInfo.verifiedType = TSCurrentUserInfo.share.userInfo?.verified?.type ?? ""
        avatarInfo.type = .normal(userId: id)
        avatar.avatarInfo = avatarInfo

        // 名字
        name.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        name.textColor = TSColor.normal.blackTitle

        // 简介
        intro.numberOfLines = 2
        intro.linesSpacing = 10
        intro.verticalAlignment = .top
        intro.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        intro.textColor = TSColor.normal.minor
        intro.lineBreakMode = .byTruncatingTail

        accessory.image = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
        accessory.contentMode = .scaleAspectFill
        userInfoView.addSubview(accessory)

        self.addSubview(userInfoView)
        userInfoView.addSubview(avatar)
        userInfoView.addSubview(name)
        userInfoView.addSubview(intro)

        userInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.height.equalTo(120)
        }
        avatar.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoView).offset(30)
            make.left.equalTo(userInfoView).offset(11)
            make.width.height.equalTo(60)
        }
        name.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoView).offset(40)
            make.left.equalTo(avatar.snp.right).offset(10)
            make.right.equalTo(accessory.snp.left).offset(-14)
            make.height.equalTo(17.5)
        }
        intro.snp.makeConstraints { (make) in
            make.top.equalTo(name.snp.bottom).offset(9)
            make.left.equalTo(avatar.snp.right).offset(10)
            make.right.equalTo(accessory.snp.left).offset(-14)
            make.height.equalTo(40.5)
        }
        accessory.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoView).offset(39.5)
            make.right.equalTo(userInfoView.snp.right).offset(-16)
            make.width.equalTo(10)
            make.height.equalTo(20)
        }
    }

    /// 创建粉丝和关注BG
    func setUserFansAndFollow() {
        userFansAndFollowBackGround.backgroundColor = TSColor.main.white
        fansView.backgroundColor = UIColor.clear
        followView.backgroundColor = UIColor.clear
        friendView.backgroundColor = UIColor.clear

        self.addSubview(userFansAndFollowBackGround)
        userFansAndFollowBackGround.addSubview(fansView)
        userFansAndFollowBackGround.addSubview(followView)
        userFansAndFollowBackGround.addSubview(friendView)

        userFansAndFollowBackGround.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoView.snp.bottom)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-15)
        }
        fansView.snp.makeConstraints { (make) in
            make.top.left.height.equalTo(userFansAndFollowBackGround)
            make.right.equalTo(followView.snp.left)
        }
        followView.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(fansView)
            make.right.equalTo(friendView.snp.left)
        }
        friendView.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(fansView)
            make.right.equalTo(userFansAndFollowBackGround)
        }

        setFansView()
        setFollowView()
        setFriendView()
    }

    /// 单独加载粉丝
    func setFansView() {
        /// 给粉丝view添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFans))
        fanslabel.textColor = TSColor.main.content
        fanslabel.font = UIFont.boldSystemFont(ofSize: 20)
        let label = UILabel()
        label.text = "粉丝"
        label.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        label.textColor = TSColor.normal.minor

        fansView.addGestureRecognizer(tap)
        fansView.addSubview(fanslabel)
        fansView.addSubview(label)
        fansView.addSubview(fansBage)

        fanslabel.snp.makeConstraints { (make) in
            make.top.equalTo(fansView).offset(12)
            make.centerX.equalTo(fansView)
            make.height.equalTo(20)
        }
        fansBage.snp.makeConstraints { (make) in
            make.top.equalTo(fansView).offset(8)
            make.left.equalTo(fanslabel.snp.right).offset(8)
            make.width.equalTo(bageViewBouds.Width.rawValue)
            make.height.equalTo(bageViewBouds.Height.rawValue)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(fanslabel.snp.bottom).offset(5)
            make.centerX.equalTo(fansView)
            make.height.equalTo(13)
        }
    }

    /// 单独加载关注
    func setFollowView() {
        /// 给关注view添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFollow))
        followlabel.textColor = TSColor.main.content
        followlabel.font = UIFont.boldSystemFont(ofSize: 20)

        let label = UILabel()
        label.text = "关注"
        label.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        label.textColor = TSColor.normal.minor

        followView.addGestureRecognizer(tap)
        followView.addSubview(followlabel)
        followView.addSubview(label)
        followView.addSubview(followBage)

        followlabel.snp.makeConstraints { (make) in
            make.top.equalTo(followView).offset(12)
            make.centerX.equalTo(followView)
            make.height.equalTo(20)
        }
        followBage.snp.makeConstraints { (make) in
            make.top.equalTo(followView).offset(8)
            make.left.equalTo(followlabel.snp.right).offset(8)
            make.width.equalTo(bageViewBouds.Width.rawValue)
            make.height.equalTo(bageViewBouds.Height.rawValue)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(followlabel.snp.bottom).offset(5)
            make.centerX.equalTo(followView)
            make.height.equalTo(13)
        }

    }

    /// 单独加载好友
    func setFriendView() {
        /// 给关注view添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFriend))
        friendlabel.textColor = TSColor.main.content
        friendlabel.font = UIFont.boldSystemFont(ofSize: 20)

        let label = UILabel()
        label.text = "好友"
        label.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        label.textColor = TSColor.normal.minor

        friendView.addGestureRecognizer(tap)
        friendView.addSubview(friendlabel)
        friendView.addSubview(label)
        friendView.addSubview(friendBage)

        friendlabel.snp.makeConstraints { (make) in
            make.top.equalTo(friendView).offset(11.5)
            make.centerX.equalTo(friendView)
            make.height.equalTo(20)
        }
        friendBage.snp.makeConstraints { (make) in
            make.top.equalTo(friendView).offset(8)
            make.left.equalTo(friendlabel.snp.right).offset(8)
            make.width.equalTo(bageViewBouds.Width.rawValue)
            make.height.equalTo(bageViewBouds.Height.rawValue)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(friendlabel.snp.bottom).offset(5)
            make.centerX.equalTo(friendView)
            make.height.equalTo(13)
        }

    }

    // MARK: - 外部调用改变view展示的方法
    /// 更改用户展示view数据
    public func changeUserInfoData() {
        guard let userInfo = TSCurrentUserInfo.share.userInfo else {
            return
        }
        // 更新用户名
        name.text = userInfo.name
        // 更新用户简介
        intro.text = userInfo.shortDesc()
//        var introHeight: CGFloat = intro.text?.heightWithConstrainedWidth(width: intro.width, font: intro.font) ?? 0
//        if introHeight > 20 {
//            introHeight = 34.5
//        }
//        intro.frame = CGRect.init(x: avatar.right + 10, y: name.bottom + 7.5, width: accessory.left - 14 - avatar.right - 10, height: introHeight)
        // 关注 - following
        let follower = userInfo.extra?.followingsCount ?? 0
        followlabel.text = "\(follower)"
        // 粉丝 - follower
        let following = userInfo.extra?.followersCount ?? 0
        fanslabel.text = "\(following)"
        // 好友 - friend
        let friend = userInfo.friendsCount
        friendlabel.text = "\(friend)"

        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
        avatarInfo.verifiedType = userInfo.verified?.type ?? ""
        avatarInfo.verifiedIcon = userInfo.verified?.icon ?? ""
        avatarInfo.type = .normal(userId: userInfo.userIdentity)
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (TSCurrentUserInfo.share.userInfo?.sex ?? 0))
        avatar.avatarInfo = avatarInfo
    }

    // MARK: - Gesture的sector
    func tapUser() {
        self.didHeaderViewDelegate?.didHeaderIndex(index: .user)
    }

    func tapFans() {
        self.didHeaderViewDelegate?.didHeaderIndex(index: .fans)
    }

    func tapFollow() {
        self.didHeaderViewDelegate?.didHeaderIndex(index: .follow)
    }

    func tapFriend() {
        self.didHeaderViewDelegate?.didHeaderIndex(index: .friend)
    }
}
