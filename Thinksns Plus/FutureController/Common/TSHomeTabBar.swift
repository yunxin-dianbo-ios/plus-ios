//
//  TSHomeTabBar.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  首页 tabBar

import UIKit

/// 主页子页面标识
///
/// - feed: 动态
/// - discover: 发现
/// - centerBtn: 中心按钮
/// - message: 消息
/// - myCenter: 个人中心
enum HomeChildPage: Int {
    case feed = 0
    case discover
    case centerBtn
    case message
    case myCenter
}

protocol HomeTabBarCenterButtonDelegate: class {
    func tabbarCenterButtonTap(_ tabbar: TSHomeTabBar)
}

class TSHomeTabBar: UITabBar {
    /// 中心按钮
    let centerView = UIView()
    /// 所有的小红点
    lazy var badgeViews = [UIView]()
    /// 小红点的尺寸
    let badgeSize = CGSize(width: 6, height: 6)
    /// 代理
    weak var centerButtonDelegate: HomeTabBarCenterButtonDelegate?
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.insertSubview(centerView, at: 3) // 3 是测试出插入第三位置,方便排序等
        var itemCount = 0

        itemWidth = UIScreen.main.bounds.size.width / CGFloat(5)
        for subView in subviews {
            // tabbarItem固定48.0标准高度
            if subView.isKind(of: NSClassFromString("UITabBarButton")!) || subView.isEqual(centerView) {
                itemCount += 1
                subView.frame = CGRect(x: CGFloat(itemCount - 1) * itemWidth, y: 0, width: itemWidth, height: 48.0)
            }
        }

        let badgeLeftDistance = itemWidth / 2 + 4 // UI尺寸
        for index in 0..<badgeViews.count {
            let badge = badgeViews[index]
            badge.frame = CGRect(x: badgeLeftDistance + itemWidth * CGFloat(index), y: 9, width: badgeSize.width, height: badgeSize.height)
            insertSubview(badge, at: self.subviews.count)
        }
    }

    // MARK: - Custom user interface
    func initialize() {
        centerButtonDelegate = nil
        setBar()
        setCenterButton()
        setupBadge()
    }

   
    func setBar() {
         // 首页底部导航栏背景颜色
        self.barTintColor = InconspicuousColor().tabBar
    }

    func setCenterButton() {
        let image = UIImage(named: "IMG_common_ico_bottom_add")
        centerView.layer.contents = image?.cgImage
        centerView.layer.contentsGravity = kCAGravityResizeAspect
        centerView.bounds.size = CGSize.zero
        let tap = UITapGestureRecognizer(target: self, action: #selector(centerButtonTaped(_:)))
        centerView.addGestureRecognizer(tap)
    }

    func setupBadge() {
        for _ in 0...4 {
            let badge = UIView(frame: CGRect.zero)
            badge.backgroundColor = TSColor.main.warn
            badge.clipsToBounds = true
            badge.layer.cornerRadius = badgeSize.height * 0.5
            badge.isHidden = true
            badgeViews.append(badge)
        }
    }

    // MARK: - Button click
    func centerButtonTaped(_ sender: UIGestureRecognizer) {
        if self.centerButtonDelegate == nil {
            return
        }
        self.centerButtonDelegate?.tabbarCenterButtonTap(self)
    }

    // MARK: - badge show/hidden
    /// 显示小红点
    func showBadge(_ page: HomeChildPage) {
        let index = page.rawValue
        badgeViews[index].isHidden = false
    }

    /// 隐藏小红点
    func hiddenBadge(_ page: HomeChildPage) {
        let index = page.rawValue
        badgeViews[index].isHidden = true
    }
}
