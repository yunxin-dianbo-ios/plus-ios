//
//  TSNewsNavigationVar.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  资讯详情的自定义导航栏

import UIKit

protocol TSNewsNavigationBarDelegate: class {
    func Back(navigaruionBar: TSNewsNavigationBar)
}

class TSNewsNavigationBar: UIView {

    /// 返回按钮
    let buttonAtLeft = TSButton(type: .custom)
    /// 标题
    let labelForName = TSLabel(frame: .zero)
    /// 代理
    weak var delegate: TSNewsNavigationBarDelegate? = nil

    // MARK: - lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.main.white
        self.layoutControls()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func layoutControls() {
        // back button
        buttonAtLeft.setImage(UIImage(named: "IMG_topbar_back"), for: .normal)
        buttonAtLeft.frame = CGRect(x: 0, y:(frame.height - 20) / 2, width: 44, height: 44)
        buttonAtLeft.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        addSubview(buttonAtLeft)
        /// 标题
        labelForName.frame = CGRect(x: buttonAtLeft.frame.maxX, y: buttonAtLeft.frame.midY - (buttonAtLeft.frame.height / 2), width: ScreenSize.ScreenWidth - (buttonAtLeft.frame.maxX * 2), height: buttonAtLeft.frame.height)
        labelForName.font = UIFont.boldSystemFont(ofSize: TSFont.Navigation.headline.rawValue)
        labelForName.textAlignment = NSTextAlignment.center
        labelForName.textColor = TSColor.inconspicuous.navTitle
        addSubview(labelForName)
        let onePix: CGFloat = 1.0 / UIScreen.main.scale
        let line = UIView(frame: CGRect(x: 0, y: TSNavigationBarHeight - onePix, width: UIScreen.main.bounds.width, height: onePix))
        line.backgroundColor = TSColor.inconspicuous.disabled
        addSubview(line)
    }

    // MARK: - actions
    func goBack() {
        if self.delegate != nil {
            self.delegate?.Back(navigaruionBar: self)
        }
    }
    // MARK: - public

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

    /// 设置标题
    func setTitle(title: String) {
        self.labelForName.text = title
    }
}
