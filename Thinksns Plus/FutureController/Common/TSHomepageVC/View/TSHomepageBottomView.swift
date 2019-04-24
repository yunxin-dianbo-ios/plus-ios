//
//  TSHomepageBottomView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人主页 底部视图

import UIKit
import RealmSwift

protocol TSHomepageBottomViewDelegate: class {
    /// 底部按钮点击回调，增加title，是因为index可能因为是否有打赏而不一致
    func bottomView(_ bottomView: TSHomepageBottomView, didSelectedButtonAt index: Int, title: String?)
}

class TSHomepageBottomView: UIView {
    let tagForButton = 200
    /// 用户关系
    var followStatus: FollowStatus = .follow
    /// 代理
    weak var delegate: TSHomepageBottomViewDelegate?

    // MARK: - Lifecycle
    init() {
        super.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 47 - TSBottomSafeAreaHeight, width:  UIScreen.main.bounds.width, height: 47 + TSBottomSafeAreaHeight))
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface
    /// 更新视图
    func setUI() {
        backgroundColor = UIColor.white
        // separate line
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        lineView.backgroundColor = TSColor.inconspicuous.disabled
        addSubview(lineView)
        // button
        var imageArray = [String]()
        var titileArray = [String]()
        // 检查是否开启了打赏配置
        if TSAppConfig.share.localInfo.isOpenReward == true {
            titileArray = ["显示_打赏".localized, "显示_关注".localized, "显示_聊天".localized]
            imageArray = ["IMG_ico_me_reward", "IMG_ico_me_follow_small", "IMG_ico_me_chat"]
        } else {
            imageArray = ["IMG_ico_me_follow_small", "IMG_ico_me_chat"]
            titileArray = ["显示_关注".localized, "显示_聊天".localized]
        }

        for index in 0..<titileArray.count {
            let button = TSButton(type: .custom)
            let width: CGFloat = frame.width / CGFloat(titileArray.count)
            var buttonHeight: CGFloat = 0
            if TSUserInterfacePrinciples.share.isiphoneX() == true {
                buttonHeight = 47.0
            } else {
                buttonHeight = frame.height
            }
            button.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: buttonHeight)
            button.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
            button.setImage(UIImage(named: imageArray[index]), for: .normal)
            button.setTitle(titileArray[index], for: .normal)
            button.tag = tagForButton + index
            button.setTitleColor(TSColor.normal.blackTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonTaped(_:)), for: .touchUpInside)
            addSubview(button)

            if index > 0 {
                let line = UIView(frame: CGRect(x: (frame.width - CGFloat(titileArray.count) * 1) / CGFloat(titileArray.count) * CGFloat(index) + (CGFloat(index) - 1) * 1, y: 0, width: 1, height: buttonHeight))
                line.backgroundColor = TSColor.inconspicuous.disabled
                addSubview(line)
            }
        }
    }

    // MARK: - Button click
    /// 按钮点击事件
    func buttonTaped(_ sender: UIButton) {
        let index = sender.tag - tagForButton
        self.delegate?.bottomView(self, didSelectedButtonAt: index, title: sender.currentTitle)
    }

    // MARK: - Public 
    /// 加载用户关系数据
    func setFollowStatus(_ followStatus: FollowStatus) {
        self.followStatus = followStatus
        let tag: Int = TSAppConfig.share.localInfo.isOpenReward ? tagForButton + 1 : tagForButton
        let followButton = (viewWithTag(tag) as? TSButton)!
        var imageName = ""
        var title = ""
        var color = UIColor.clear
        switch followStatus {
        case .unfollow:
            followButton.isHidden = false
            imageName = "IMG_ico_me_follow_small"
            title = "显示_关注".localized
            color = TSColor.normal.blackTitle
        case .follow:
            followButton.isHidden = false
            imageName = "IMG_ico_me_followed_small"
            title = "显示_已关注".localized
            color = TSColor.main.theme
        case .eachOther:
            followButton.isHidden = false
            imageName = "IMG_ico_me_followed_eachother_small"
            title = "显示_互相关注".localized
            color = TSColor.main.theme
        case .oneself:
            followButton.isHidden = true
        }
        followButton.setImage(UIImage(named: imageName), for: .normal)
        followButton.setTitle(title, for: .normal)
        followButton.setTitleColor(color, for: .normal)
    }
}
