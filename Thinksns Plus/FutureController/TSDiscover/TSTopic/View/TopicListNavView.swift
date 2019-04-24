//
//  TopicListNavView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TopicListNavViewDelegate: class {
    /// 返回按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedLeftButton: TSButton)
    /// 更多按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedRightButton: TSButton)
    /// 分享按钮点击事件
    func navView(_ navView: TopicListNavView, didSelectedShareButton: UIButton)
}

class TopicListNavView: UIView {
    /// 返回按钮
    let buttonAtLeft = TSButton(type: .custom)
    /// 更多按钮
    let buttonAtRight = TSButton(type: .custom)
    /// 分享按钮
    let shareButton = UIButton(type: .custom)
    /// 标题
    let labelForTitle = TSLabel()
    /// 小菊花
    let indicator = TSIndicatorFlowerView()
    /// 分割线
    let seperatarLine = UIView()
    var centY: CGFloat = 0
    /// 代理
    weak var delegate: TopicListNavViewDelegate?
    // 导航栏图片
    var whiteImageBack = UIImage(named: "IMG_topbar_back_white")
    var whiteImageMore = UIImage(named: "IMG_topbar_more_white")
    var whiteImageSearch = UIImage(named: "IMG_ico_search_white")
    var whiteImageShare = UIImage(named: "IMG_topbar_right_white")
    var imageBack = UIImage(named: "IMG_topbar_back")
    var imageMore = UIImage(named:
        "IMG_topbar_more_black")
    var imageSearch = UIImage(named: "IMG_ico_search")
    var imageShare = UIImage(named: "IMG_music_ico_share_black")

    /// 按钮是否需要变成白色
    var isButtonWhite = true

    // MARK: - Lifecycle
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TSNavigationBarHeight))
        addNotificatin()
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // 移除检测音乐按钮的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }

    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
        centY = (frame.height - TSStatusBarHeight) / 2 + TSStatusBarHeight
        // 1.back button
        buttonAtLeft.setImage(whiteImageBack, for: .normal)
        buttonAtLeft.frame = CGRect(x: 0, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        buttonAtLeft.addTarget(self, action: #selector(leftButtonTaped), for: .touchUpInside)
        // 2.more button
        buttonAtRight.setImage(whiteImageMore, for: .normal)
        buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        buttonAtRight.addTarget(self, action: #selector(rightButtonTaped), for: .touchUpInside)
        // 3.title label
        labelForTitle.textAlignment = .center
        labelForTitle.font = UIFont.systemFont(ofSize: TSFont.SubUserName.home.rawValue)
        labelForTitle.textColor = TSColor.main.content
        // 4.分享按钮
        // h5分享地址暂无，先隐藏分享
        shareButton.isHidden = true
        shareButton.setImage(whiteImageShare, for: .normal)
        shareButton.frame = CGRect(x: UIScreen.main.bounds.width - 44 * 2, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        shareButton.addTarget(self, action: #selector(shareButtonTaped), for: .touchUpInside)

        // 6.分割线
        seperatarLine.frame = CGRect(x: 0, y: frame.height - 1, width: UIScreen.main.bounds.width, height: 1)
        seperatarLine.backgroundColor = TSColor.inconspicuous.disabled

        // 7.小菊花
        indicator.frame = CGRect(x: 50, y: 29, width: 25, height: 25)
        indicator.centerY = shareButton.centerY

        addSubview(labelForTitle)
        addSubview(buttonAtLeft)
        addSubview(buttonAtRight)
        addSubview(shareButton)
        addSubview(indicator)
    }

    // MARK: - Button click
    /// 点击了左边按钮
    func leftButtonTaped() {
        if let delegate = delegate {
            delegate.navView(self, didSelectedLeftButton: buttonAtLeft)
        }
    }

    /// 点击了右边事件
    func rightButtonTaped() {
        if let delegate = delegate {
            delegate.navView(self, didSelectedRightButton: buttonAtRight)
        }
    }

    /// 点击了分享按钮
    func shareButtonTaped() {
        delegate?.navView(self, didSelectedShareButton: shareButton)
    }

    // MARK: - Public
    /// 根据音乐按钮是否显示，更新右边按钮的位置
    func updateRightButtonFrame() {
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        // 判断音乐按钮是否显示
        if isMusicButtonShow {
            TSMusicPlayStatusView.shareView.reSetImage(white: isButtonWhite)
            // 调整分享按钮的位置
            buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44 - 44, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        } else {
            buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        }
    }

    // 根据偏移量刷新子视图
    func updateChildView(offset: CGFloat, buttonKeepBlack: Bool) {
        let offset = offset + UIScreen.main.bounds.width / 2
        updateTitleLabel(offset)
        updateBackGroundColor(offset)
        updateButton(offset, buttonKeepBlack: buttonKeepBlack)
    }

    /// 设置标题
    func setTitle(_ title: String) {
        labelForTitle.text = title
        let newSize = title.sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.Title.headline.rawValue))
        labelForTitle.frame = CGRect(x: (UIScreen.main.bounds.width - newSize.width) / 2, y: frame.height + TSUserInterfacePrinciples.share.getTSTopAdjustsScrollViewInsets(), width: newSize.width, height: newSize.height)
    }

    // MARK: - Private
    private func updateButton(_ offset: CGFloat, buttonKeepBlack: Bool) {
        // 判断音乐按钮是否显示
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        let shouldWhite = offset - 100 > 0

        if buttonKeepBlack {
            isButtonWhite = false
            buttonAtLeft.setImage(imageBack, for: .normal)
            buttonAtRight.setImage(imageMore, for: .normal)
            shareButton.setImage(imageShare, for: .normal)
            // 更新音乐按钮的颜色
            if isMusicButtonShow {
                TSMusicPlayStatusView.shareView.reSetImage(white: false)
            }
            // 更新状态栏的颜色
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        } else {
            if shouldWhite && buttonAtLeft.imageView?.image != whiteImageBack {
                isButtonWhite = true
                buttonAtLeft.setImage(whiteImageBack, for: .normal)
                buttonAtRight.setImage(whiteImageMore, for: .normal)
                shareButton.setImage(whiteImageShare, for: .normal)
                // 更新音乐按钮的颜色
                if isMusicButtonShow {
                    TSMusicPlayStatusView.shareView.reSetImage(white: true)
                }
                // 更新状态栏的颜色
                UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
                return
            }
            if !shouldWhite && buttonAtLeft.imageView?.image != imageBack {
                isButtonWhite = false
                buttonAtLeft.setImage(imageBack, for: .normal)
                buttonAtRight.setImage(imageMore, for: .normal)
                shareButton.setImage(imageShare, for: .normal)
                // 更新音乐按钮的颜色
                if isMusicButtonShow {
                    TSMusicPlayStatusView.shareView.reSetImage(white: false)
                }
                // 更新状态栏的颜色
                UIApplication.shared.setStatusBarStyle(.default, animated: true)
            }
        }
    }

    private func updateBackGroundColor(_ offset: CGFloat) {
        let backOffset = offset - 100
        let startColor = UIColor.clear
        let finalColor = UIColor.white
        let changeColor = UIColor(white: 1, alpha: (30 - backOffset) / 30)
        let shouldChanged = backOffset > 0 && backOffset < 30
        let shouldClear = backOffset >= 30
        let shouldWhite = backOffset <= 0
        let isStartColor = backgroundColor == startColor
        let isFinalColor = backgroundColor == finalColor
        if (shouldClear && isStartColor) || (shouldWhite && isFinalColor) && !shouldChanged {
            return
        }
        if shouldWhite && !isFinalColor {
            backgroundColor = finalColor
            if seperatarLine.superview == nil {
                addSubview(seperatarLine)
            }
            return
        }
        if shouldClear && !isStartColor {
            backgroundColor = startColor
            if seperatarLine.superview != nil {
                seperatarLine.removeFromSuperview()
            }
            return
        }
        if shouldChanged {
            backgroundColor = changeColor
            seperatarLine.layer.opacity = Float((30 - backOffset) / 30)
        }
    }

    func getTitleLabelHeight() -> CGFloat {
        return  labelForTitle.frame.height - TSUserInterfacePrinciples.share.getTSTopAdjustsScrollViewInsets()
    }

    private func updateTitleLabel(_ offset: CGFloat) {
        // 当为 123.5 是姓名 label 在屏幕 y 轴上的位置
        let titleOffset = 123.5 - offset
        let finalFrame = CGRect(x: (UIScreen.main.bounds.width - labelForTitle.frame.width) / 2, y: (frame.height - 20 - getTitleLabelHeight()) / 2 + 20, width: labelForTitle.frame.width, height: labelForTitle.frame.height)
        let movingFrame = CGRect(x: (UIScreen.main.bounds.width - labelForTitle.frame.width) / 2, y: frame.height - titleOffset, width: labelForTitle.frame.width, height: labelForTitle.frame.height)
        let startFrame = CGRect(x: (UIScreen.main.bounds.width - labelForTitle.frame.width) / 2, y: frame.height, width: labelForTitle.frame.width, height: labelForTitle.frame.height)
        let finalFont = UIFont.systemFont(ofSize: 18)
        let movingFont = UIFont.systemFont(ofSize: 16 + 2 * titleOffset / frame.height)
        let startFont = UIFont.systemFont(ofSize: 16)

        let isInFinalState = labelForTitle.frame == finalFrame
        let isInStartState = labelForTitle.frame == startFrame
        let isShouldStartMove = titleOffset > 0 && titleOffset <= frame.height - centY
        let isShouldStopUpMove = titleOffset > frame.height - centY
        let isShouldStopDownMove = titleOffset <= 0
        if ((isInFinalState && isShouldStopUpMove) || (isInStartState && isShouldStopDownMove)) && !isShouldStartMove {
            return
        }
        if isShouldStopUpMove && !isInFinalState {
            labelForTitle.font = finalFont
            labelForTitle.frame = finalFrame
            return
        }
        if isShouldStopDownMove && !isInStartState {
            labelForTitle.font = startFont
            labelForTitle.frame = startFrame
            return
        }
        if isShouldStartMove {
            labelForTitle.font = movingFont
            labelForTitle.frame = movingFrame
        }
    }
    // MARK: - Notification
    func addNotificatin() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateRightButtonFrame), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
}
