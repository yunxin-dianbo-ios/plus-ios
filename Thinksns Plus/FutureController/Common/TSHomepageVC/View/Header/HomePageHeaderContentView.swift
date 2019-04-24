//
//  HomePageHeaderContentView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

let heightRatio = UIScreen.main.bounds.height / 667 // iphone 6 是 1 然后高度减少 就 0.x 或者加大到1.x

class HomePageHeaderContentView: UIView {

    static var bgImageHeight = UIScreen.main.bounds.width / 2

    /// 数据
    var model = HomepageModel() {
        didSet {
            loadModel()
        }
    }

    /// 头像
    let avatar = ScreenHeight <= 568 ? AvatarView(origin: CGPoint(x: (UIScreen.main.bounds.width - 60) / 2, y: 48 * heightRatio), type: AvatarType.width60(showBorderLine: true)) : AvatarView(origin: CGPoint(x: (UIScreen.main.bounds.width - 70) / 2, y: 48 * heightRatio), type: AvatarType.width70(showBorderLine: true))
    /// 姓名 label
    let labelForName = UILabel()
    /// 粉丝按钮
    let buttonForFans = UIButton(type: .custom)
    /// 关注按钮
    let buttonForFollow = UIButton(type: .custom)
    /// 认证 label
    let labelForVerified = UILabel()
    /// 地址 label
    let labelForAdress = UILabel()
    /// 简介 label
    let labelForIntro = UILabel()
    /// 用户标签视图
    let tagView = ATagsVeiw()
    /// 白色视图，用 button 是为了拦截 HomePageHeaderContentView 的点击手势响应
    let whiteView = UIButton(type: .custom)
    /// 背景蒙层
    let bgImageView = UIImageView()

    init() {
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        backgroundColor = .clear
        addSubview(bgImageView)
        addSubview(avatar)
        addSubview(labelForName)
        addSubview(buttonForFans)
        addSubview(buttonForFollow)
        addSubview(whiteView)
        addSubview(labelForVerified)
        addSubview(labelForAdress)
        addSubview(labelForIntro)
        addSubview(tagView)
    }

    func loadModel() {

        // 3.粉丝按钮和关注按钮
        loadFansAndFollowButton()

        // 2.姓名 label
        loadNameLabel()

        // 1.头像
        loadAvatar()

        // 0.背景图
        loadBgImageView()
        var yRecord: CGFloat = HomePageHeaderContentView.bgImageHeight + 11
        // 4.认证 label
        loadVerifiedLabel(yRecord: &yRecord)

        // 5.地址 label
        loadAdressLabel(yRecord: &yRecord)

        // 3.简介 label
        loadIntroLabel(yRecord: &yRecord)

        // 4.用户标签视图
        loadUserTag(yRecord: &yRecord)

        // 5.加载白色视图
        loadWhiteView(yRecord: &yRecord)

        // 更新视图的 frame
        frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: yRecord))
    }

    func loadBgImageView() {
        bgImageView.image = UIImage(named: "pic_mask_zy")
        bgImageView.frame = CGRect(x: 0, y: HomePageHeaderContentView.bgImageHeight - ScreenHeight * 2 / 3.0, width: ScreenWidth, height: ScreenHeight * 2 / 3.0)
    }
    /// 加载头像
    func loadAvatar() {
        let userInfo = model.userInfo
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: userInfo.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
        avatarInfo.verifiedType = userInfo.verified?.type ?? ""
        avatarInfo.verifiedIcon = userInfo.verified?.icon ?? ""
        avatar.avatarInfo = avatarInfo
        avatar.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - 70) / 2, y: labelForName.frame.minY - 8 - 70)
        if ScreenHeight <= 568 {
            avatar.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - 60) / 2, y: labelForName.frame.minY - 8 - 60)
        }
    }

    /// 加载姓名 label
    func loadNameLabel() {
        labelForName.textColor = UIColor.white
        labelForName.font = UIFont.systemFont(ofSize: 16)
        labelForName.text = model.userInfo.name
        labelForName.sizeToFit()
        // 计算姓名 label frame
        let nameX = (UIScreen.main.bounds.width - labelForName.size.width) / 2
        let nameY = buttonForFans.frame.minY - 7 - labelForName.size.height
        labelForName.frame = CGRect(origin: CGPoint(x: nameX, y: nameY), size: labelForName.size)
    }

    /// 加载粉丝和关注按钮
    func loadFansAndFollowButton() {
        // 1.粉丝按钮
        buttonForFans.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        buttonForFans.setTitleColor(UIColor.white, for: .normal)
        let fansCount = model.userInfo.extra?.followersCount ?? 0
        buttonForFans.setTitle("粉丝 \(fansCount)", for: .normal)
        buttonForFans.sizeToFit()

        // 2.关注按钮
        buttonForFollow.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        buttonForFollow.setTitleColor(UIColor.white, for: .normal)
        let followCount = model.userInfo.extra?.followingsCount ?? 0
        buttonForFollow.setTitle("关注 \(followCount)", for: .normal)
        buttonForFollow.sizeToFit()

        // 计算粉丝按钮和关注按钮的 frame
        let fansFollowSpacing: CGFloat = 23 // 粉丝按钮和关注按钮在 x 轴上的间距
        let fansX = (UIScreen.main.bounds.width - buttonForFollow.size.width - buttonForFans.size.width - fansFollowSpacing) / 2
        let fansY = HomePageHeaderContentView.bgImageHeight - 10 - buttonForFollow.size.height
        buttonForFans.frame = CGRect(origin: CGPoint(x: fansX, y: fansY), size: buttonForFans.size)
        let followX = buttonForFans.frame.maxX + fansFollowSpacing
        let followY = fansY
        buttonForFollow.frame = CGRect(origin: CGPoint(x: followX, y: followY), size: buttonForFollow.size)
    }

    /// 加载认证 label
    func loadVerifiedLabel(yRecord: inout CGFloat) {
        // 认证描述不存在，隐藏认证 label
        guard let verifiedInfo = model.userInfo.verified?.description,
            verifiedInfo.isEmpty == false else {
                return
        }
        labelForVerified.textColor = TSColor.button.orangeGold
        labelForVerified.font = UIFont.systemFont(ofSize: 14)
        labelForVerified.numberOfLines = 0
        labelForVerified.text = "认证：\(verifiedInfo)"
        labelForVerified.frame = CGRect(x: 10, y: yRecord + 9, width: UIScreen.main.bounds.width - 15, height: 0)
        labelForVerified.sizeToFit()
        yRecord = labelForVerified.frame.maxY
    }

    /// 加载地址 label
    func loadAdressLabel(yRecord: inout CGFloat) {
        // 地址不存在，隐藏地址 label
        guard let adressInfo = model.userInfo.location, adressInfo.isEmpty == false else {
            return
        }
        labelForAdress.textColor = UIColor(hex: 0x999999)
        labelForAdress.font = UIFont.systemFont(ofSize: 14)
        labelForAdress.text = "地址：\(adressInfo)"
        labelForAdress.frame = CGRect(x: 10, y: yRecord + 9, width: UIScreen.main.bounds.width - 15, height: 0)
        labelForAdress.sizeToFit()
        yRecord = labelForAdress.frame.maxY
    }

    /// 加载简介 label
    func loadIntroLabel(yRecord: inout CGFloat) {
        let introInfo = model.userInfo.shortDesc()
        labelForIntro.textColor = UIColor(hex: 0x999999)
        labelForIntro.font = UIFont.systemFont(ofSize: 14)
        labelForIntro.numberOfLines = 0
        labelForIntro.text = "简介：\(introInfo)"
        labelForIntro.frame = CGRect(x: 10, y: yRecord + 9, width: UIScreen.main.bounds.width - 15, height: 0)
        labelForIntro.sizeToFit()
        yRecord = labelForIntro.frame.maxY
    }

    /// 加载用户标签
    func loadUserTag(yRecord: inout CGFloat) {
        if model.userTags.isEmpty {
            return
        }
        tagView.frame = CGRect(origin: CGPoint(x: 10, y: yRecord + 9), size: CGSize(width: UIScreen.main.bounds.width - 18, height: 0))
        tagView.maxWidth = UIScreen.main.bounds.width - 15
        tagView.removeAllTags()
        tagView.tagBackgroudColor = UIColor(hex: 0xefefef)
        tagView.tagRadius = 9
        tagView.add(tags: model.userTags.map { $0.name })
        yRecord = tagView.frame.maxY

        // 拦截tagView的点击响应，之后待优化：
        let tap = UITapGestureRecognizer(target: self, action: #selector(test))
        tagView.addGestureRecognizer(tap)
    }

    func test() {
        print("喵喵喵")
    }

    /// 加载白色视图
    func loadWhiteView(yRecord: inout CGFloat) {
        whiteView.backgroundColor = .white
        whiteView.frame = CGRect(x: 0, y: UIScreen.main.bounds.width / 2, width: UIScreen.main.bounds.width, height: yRecord - UIScreen.main.bounds.width / 2 + 20)
        yRecord = whiteView.frame.maxY
    }
}
