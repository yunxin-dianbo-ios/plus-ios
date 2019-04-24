//
//  TSMomentDetailNavView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

protocol TSMomentDetailNavViewDelegate: class {
    /// 返回按钮点击事件
    func navView(_ navView: TSMomentDetailNavView, didSelectedLeftButton: TSButton)
}

class TSMomentDetailNavView: UIView {

    /// 返回按钮
    let buttonAtLeft = TSButton(type: .custom)
    /// 关注
    let buttonAtRight = TSButton(type: .custom)
    /// 标题
    let labelForName = TSLabel(frame: .zero)
    /// 头像
    var buttonForAvatar = AvatarView(type: AvatarType.width70(showBorderLine: false))

    /// 数据模型
    var object: TSUserInfoModel

    /// 代理
    weak var delegate: TSMomentDetailNavViewDelegate?

    // MARK: - Lifecycle
    init(_ model: TSUserInfoModel) {
        self.object = model
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TSNavigationBarHeight))
        addNotification()
        self.buttonForAvatar = AvatarView(type: AvatarType.width26(showBorderLine: false))
        let avatarInfo = AvatarInfo(userModel: model)
        buttonForAvatar.avatarInfo = avatarInfo
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        self.object = TSUserInfoModel()
        super.init(coder: aDecoder)
        addNotification()
        setUI()
    }

    deinit {
        // 移除检测音乐按钮的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }

    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = UIColor.white
        // back button
        buttonAtLeft.setImage(UIImage(named: "IMG_topbar_back"), for: .normal)
        buttonAtLeft.addTarget(self, action: #selector(leftButtonTaped), for: .touchUpInside)

        // avatar
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: object.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: object.avatar)
        avatarInfo.verifiedIcon = object.verified?.icon ?? ""
        avatarInfo.verifiedType = object.verified?.type ?? ""
        avatarInfo.type = .normal(userId: object.userIdentity)
        buttonForAvatar.avatarInfo = avatarInfo
        // name
        labelForName.font = UIFont.systemFont(ofSize: TSFont.SubUserName.home.rawValue)
        labelForName.textColor = TSColor.normal.blackTitle
        labelForName.text = object.name
        labelForName.sizeToFit()

        buttonAtLeft.frame = CGRect(x: 5, y:(frame.height - 44 + TSStatusBarHeight) / 2.0, width: 44, height: 44)
        buttonForAvatar.frame = CGRect(x: (UIScreen.main.bounds.width - 26 - 5 - labelForName.frame.width) / 2.0, y: frame.height - 10 - 26, width: 26, height: 26)
        buttonForAvatar.layer.cornerRadius = 13
        labelForName.frame = CGRect(x: buttonForAvatar.frame.maxX + 5, y: buttonForAvatar.frame.midY - labelForName.frame.height / 2.0, width: labelForName.frame.width, height: labelForName.frame.height)
        // line
        let line = UIView(frame: CGRect(x: 0, y: TSNavigationBarHeight - 1, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.disabled

        addSubview(buttonAtLeft)
        addSubview(buttonAtRight)
        addSubview(buttonForAvatar)
        addSubview(labelForName)
        addSubview(line)

        // 判断是否为当前用户
        let isCurrentUser = (TSCurrentUserInfo.share.userInfo?.userIdentity)! == object.userIdentity
        if isCurrentUser {
            return
        }
        // follow button
        buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44, y:(frame.height - 44 + TSStatusBarHeight) / 2.0, width: 44, height: 44)
        buttonAtRight.addTarget(self, action: #selector(rightButtonTaped), for: .touchUpInside)
        // 切换视图
        update(model: object)
        // 用户名点击
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelClick(_:)))
        labelForName.addGestureRecognizer(tapGesture)
        labelForName.isUserInteractionEnabled = true
    }

    func labelClick(_ sender: Any) {
        buttonForAvatar.normalUserTaped()
    }

    // 补丁方法：更新关注按钮状态
    func update(model: TSUserInfoModel) {
        object = model
        var imageName = ""
        switch object.relationshipWithCurrentUser()! {
        case .unfollow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_follow"
        case .follow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed"
        case .eachOther:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed_eachother"
        case .oneself:
            buttonAtRight.isHidden = true
            imageName = ""
        }
        buttonAtRight.setImage(UIImage(named: imageName), for: .normal)
    }

    // MARK: - Button click
    /// 点击了返回按钮
    func leftButtonTaped() {
        if let delegate = delegate {
            delegate.navView(self, didSelectedLeftButton: buttonAtLeft)
        }
    }

    /// 点击了关注按钮
    func rightButtonTaped() {
        // 切换关注状态
        object.follower = !object.follower
        let relationship = object.relationshipWithCurrentUser()!
        let followStatus: FollowStatus = object.follower == true ? .follow : .unfollow
        // 修改用户的粉丝数
        if followStatus == .follow {
            if let userExtra = object.extra {
                userExtra.followersCount = userExtra.followersCount + 1
                object.extra = userExtra
            } else {
                let extraStr = """
                {
                "user_id": \(object.userIdentity),"followers_count": 1,
                }
                """
                let extra = Mapper<TSUserExtraModel>().map(JSONString: extraStr)
                object.extra = extra
            }
        } else if followStatus == .unfollow {
            if let userExtra = object.extra {
                userExtra.followersCount = userExtra.followersCount - 1
                object.extra = userExtra
            }
        }
        // 调用关注接口
        TSUserNetworkingManager().operate(followStatus, userID: object.userIdentity)
        // 切换视图
        var imageName = ""
        switch relationship {
        case .unfollow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_follow"
        case .follow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed"
        case .eachOther:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed_eachother"
        case .oneself:
            buttonAtRight.isHidden = true
            imageName = ""
        }
        buttonAtRight.setImage(UIImage(named: imageName), for: .normal)
        TSDatabaseUser().saveUserInfo(object)
    }

    /// 根据音乐按钮是否显示，更新右边按钮的位置
    func updateRightButtonFrame() {
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        // 判断音乐按钮是否显示
        if isMusicButtonShow {
            TSMusicPlayStatusView.shareView.reSetImage(white: false)
            // 调整分享按钮的位置
            buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44 - 44, y:(frame.height + 44 - TSStatusBarHeight) / 2.0, width: 44, height: 44)
        } else {
            buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44, y:(frame.height - 44 + TSStatusBarHeight) / 2.0, width: 44, height: 44)
        }
    }

    /// 滑动效果动画
    func scrollowAnimation(_ offset: CGFloat) {
        let topY = -frame.height + TSStatusBarHeight + 1
        let bottomY: CGFloat = 0
        let isAtTop = frame.minY == topY
        let isAtBottom = frame.minY == bottomY
        let isScrollowUp = offset > 0
        let isScrollowDown = offset < 0

        if (isAtTop && isScrollowUp) || (isAtBottom && isScrollowDown) {
            return
        }
        var frameY = frame.minY - offset
        if isScrollowUp && frameY < topY { // 上滑
            frameY = topY
        }
        if isScrollowDown && frameY > bottomY {
            frameY = bottomY
        }
        frame = CGRect(x: 0, y: frameY, width: frame.width, height: frame.height)
    }

    // MARK: - Notification
    func addNotification() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateRightButtonFrame), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updataFollowStatus(notice:)), name: NSNotification.Name(rawValue: "changeFollowSrarus"), object: nil)
    }

    func updataFollowStatus(notice: NSNotification) {
        let statusFollow: String = (notice.userInfo!["follow"] ?? "0") as! String
        // 切换关注状态
        object.follower = statusFollow == "1" ? true : false
        let relationship = object.relationshipWithCurrentUser()!
        let followStatus: FollowStatus = object.follower == true ? .follow : .unfollow
        // 修改用户的粉丝数
        if followStatus == .follow {
            if let userExtra = object.extra {
                userExtra.followersCount = userExtra.followersCount + 1
                object.extra = userExtra
            } else {
                let extraStr = """
                {
                "user_id": \(object.userIdentity),"followers_count": 1,
                }
                """
                let extra = Mapper<TSUserExtraModel>().map(JSONString: extraStr)
                object.extra = extra
            }
        } else if followStatus == .unfollow {
            if let userExtra = object.extra {
                userExtra.followersCount = userExtra.followersCount - 1
                object.extra = userExtra
            }
        }
        // 切换视图
        var imageName = ""
        switch relationship {
        case .unfollow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_follow"
        case .follow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed"
        case .eachOther:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed_eachother"
        case .oneself:
            buttonAtRight.isHidden = true
            imageName = ""
        }
        buttonAtRight.setImage(UIImage(named: imageName), for: .normal)
        TSDatabaseUser().saveUserInfo(object)
    }
}
