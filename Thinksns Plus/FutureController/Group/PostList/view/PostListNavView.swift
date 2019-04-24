//
//  PostListNavView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/28.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol PostListNavViewDelegate: class {
    /// 返回按钮点击事件
    func navView(_ navView: PostListNavView, didSelectedLeftButton: TSButton)
    /// 更多按钮点击事件
    func navView(_ navView: PostListNavView, didSelectedRightButton: TSButton)
    /// 分享按钮点击事件
    func navView(_ navView: PostListNavView, didSelectedShareButton: UIButton)
    /// 搜索按钮点击事件
    func navView(_ navView: PostListNavView, didSelectedSearchButton: UIButton)
}

class PostListNavView: UIView {

    /// 返回按钮
    let buttonAtLeft = TSButton(type: .custom)
    /// 更多按钮
    let buttonAtRight = TSButton(type: .custom)
    /// 搜索按钮
    let searchButton = UIButton(type: .custom)
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
    weak var delegate: PostListNavViewDelegate?
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
//        // 3.title label
        labelForTitle.textAlignment = .center
        labelForTitle.font = UIFont.systemFont(ofSize: TSFont.SubUserName.home.rawValue)
        labelForTitle.textColor = TSColor.main.content
        // 4.分享按钮
        shareButton.setImage(whiteImageShare, for: .normal)
        shareButton.frame = CGRect(x: UIScreen.main.bounds.width - 44 * 2, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        shareButton.addTarget(self, action: #selector(shareButtonTaped), for: .touchUpInside)

        // 5.搜索按钮
        searchButton.setImage(whiteImageSearch, for: .normal)
        searchButton.frame = CGRect(x: UIScreen.main.bounds.width - 44 * 3, y:(frame.height + TSStatusBarHeight - 44) / 2.0, width: 44, height: 44)
        searchButton.addTarget(self, action: #selector(searchButtonTaped), for: .touchUpInside)

        // 6.分割线
        seperatarLine.frame = CGRect(x: 0, y: frame.height - 1, width: UIScreen.main.bounds.width, height: 1)
        seperatarLine.backgroundColor = TSColor.inconspicuous.disabled

        // 7.小菊花
        indicator.frame = CGRect(x: 50, y: 29, width: 25, height: 25)
        indicator.centerY = searchButton.centerY

        addSubview(labelForTitle)
        addSubview(buttonAtLeft)
        addSubview(buttonAtRight)
        addSubview(shareButton)
        addSubview(searchButton)
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

    /// 点击了搜索按钮
    func searchButtonTaped() {
        delegate?.navView(self, didSelectedSearchButton: searchButton)
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
    func updateChildView(offset: CGFloat) {
        let offset = offset + UIScreen.main.bounds.width / 2
        updateTitleLabel(offset)
        updateBackGroundColor(offset)
        updateButton(offset)
    }

    /// 设置标题
    func setTitle(_ title: String) {
        labelForTitle.text = title
        var newSize = title.sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.Title.headline.rawValue))
        let maxWidth = searchButton.frame.minX - buttonAtLeft.frame.maxX - 10
        if newSize.width > maxWidth {
            newSize.width = maxWidth
        }
        labelForTitle.frame = CGRect(x: buttonAtLeft.frame.maxX + 10, y: frame.height, width: newSize.width, height: newSize.height)
    }

    // MARK: - Private

    private func updateButton(_ offset: CGFloat) {
        // 判断音乐按钮是否显示
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        let shouldWhite = offset - 100 > 0
        if shouldWhite && buttonAtLeft.imageView?.image != whiteImageBack {
            isButtonWhite = true
            buttonAtLeft.setImage(whiteImageBack, for: .normal)
            buttonAtRight.setImage(whiteImageMore, for: .normal)
            shareButton.setImage(whiteImageShare, for: .normal)
            searchButton.setImage(whiteImageSearch, for: .normal)
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
            searchButton.setImage(imageSearch, for: .normal)
            // 更新音乐按钮的颜色
            if isMusicButtonShow {
                TSMusicPlayStatusView.shareView.reSetImage(white: false)
            }
            // 更新状态栏的颜色
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
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

    private func updateTitleLabel(_ offset: CGFloat) {
        // 当为 123.5 是姓名 label 在屏幕 y 轴上的位置
        let titleOffset = 123.5 - offset
        let finalFrame = CGRect(x: labelForTitle.frame.origin.x, y: (frame.height - TSUserInterfacePrinciples.share.getTSStatusBarHeight() - labelForTitle.frame.height) / 2 + TSUserInterfacePrinciples.share.getTSStatusBarHeight(), width: labelForTitle.frame.width, height: labelForTitle.frame.height)
        let movingFrame = CGRect(x: labelForTitle.frame.origin.x, y: frame.height - titleOffset, width: labelForTitle.frame.width, height: labelForTitle.frame.height)
        let startFrame = CGRect(x: labelForTitle.frame.origin.x, y: frame.height, width: labelForTitle.frame.width, height: labelForTitle.frame.height)
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
