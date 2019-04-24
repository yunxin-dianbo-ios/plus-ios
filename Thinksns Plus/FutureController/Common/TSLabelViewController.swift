//
//  TSLabelViewController.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  分页视图控制器
//  超类
//  点击导航栏标签可切换下方 view 的视图控制器
//  例如：粉丝关注列表

import UIKit

fileprivate struct SizeDesign {
    let badgeSize: CGSize = CGSize(width: 6, height: 6)
}

class TSLabelViewController: TSViewController, UIScrollViewDelegate {

    /// 滚动视图
    var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))
    /// 标签视图
    let labelView = UIView()
    /// 标签下方的蓝线
    let blueLine = UIView()
    /// 提示用的小红点
    var badges: [UIView] = []
    /// 蓝线的 leading
    var blueLineLeading: CGFloat = 0

    /// 标签标题数组
    var titleArray: [String]? = nil

    /// 按钮基础 tag 值
    let tagBasicForButton = 200

    // MARK: - Lifecycle

    /// 自定义初始化方法
    ///
    /// - Parameter labelTitleArray: 导航栏上标签的 title 的数组
    init(labelTitleArray: [String], scrollViewFrame: CGRect?, isChat: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        if isChat {
            let frame = scrollViewFrame ?? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64)
            self.scrollView = ChatScrollView(frame: frame)
        }

        if let scrollViewFrame = scrollViewFrame {
            scrollView.frame = scrollViewFrame
        }
        titleArray = labelTitleArray
        for _ in labelTitleArray {
            let badge = UIView()
            badge.backgroundColor = TSColor.main.warn
            badge.clipsToBounds = true
            badge.layer.cornerRadius = SizeDesign().badgeSize.height * 0.5
            badge.isHidden = true
            badges.append(badge)
        }

        setSuperUX()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
    }

    func changeStatuBar() {
        if UIApplication.shared.statusBarFrame.size.height == 20 {
            scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64 - 49)
        }
    }

    // MARK: - Custom user interface

    /// 视图设置
    func setSuperUX() {
        self.automaticallyAdjustsScrollViewInsets = false
        if let titleArray = titleArray {
            if titleArray.isEmpty {
                return
            }
            // 设计已确认,该数组内字数的宽度(字符数量)是一致的,出现别的情况概不负责 :)
            let labelButtonWidth = 40 + (titleArray[0].sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.Title.headline.rawValue))).width // 单边间距，参见 TS 设计文档第二版第 7 页
            let buttonTitleSize = titleArray[0].sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.Title.headline.rawValue))
            let labelHeight: CGFloat = 44

            // blue line
            let blueLineHeight: CGFloat = 2.0
            blueLineLeading = (labelButtonWidth - buttonTitleSize.width) / 2 - 7
            blueLine.frame = CGRect(x: blueLineLeading, y: labelHeight - blueLineHeight, width: buttonTitleSize.width + 14, height: blueLineHeight)
            blueLine.backgroundColor = TSColor.main.theme
            labelView.addSubview(blueLine)

            // labelView button
            for (index, title) in titleArray.enumerated() {
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: CGFloat(index) * labelButtonWidth, y: CGFloat(0), width: labelButtonWidth, height: labelHeight)
                button.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
                button.setTitle(title, for: .normal)
                button.setTitleColor( index == 0 ? TSColor.inconspicuous.navHighlightTitle : TSColor.normal.minor, for: .normal)
                button.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
                button.tag = tagBasicForButton + index

                let badge = badges[index]
                let badgeX = CGFloat(index) * labelView.frame.width / CGFloat(titleArray.count) + labelButtonWidth - 13
                badge.frame = CGRect(x: badgeX, y: 10, width: SizeDesign().badgeSize.width, height: SizeDesign().badgeSize.height)
                button.addSubview(badge)

                labelView.addSubview(button)
            }

            // labelView
            labelView.frame = CGRect(x: CGFloat(0), y: CGFloat(-3), width: labelButtonWidth * CGFloat(titleArray.count), height: labelHeight)
            labelView.backgroundColor = UIColor.white
            navigationItem.titleView = labelView

            // scrollView
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(titleArray.count), height: scrollView.frame.size.height)
            scrollView.backgroundColor = UIColor.white
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.bounces = false
            scrollView.delegate = self
            view.addSubview(scrollView)
        }
    }

    // MARK: - Button click
    func buttonTaped(sender: UIButton) {
        let index = sender.tag - tagBasicForButton
        scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width * CGFloat(index), y: 0), animated: true)
    }

    // MARK: - Public

    /// 添加子视图
    public func add(childView: UIView, at index: Int) {
        let width = self.scrollView.frame.width
        let height = self.scrollView.frame.height
        childView.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
        self.scrollView.addSubview(childView)
    }

    /// 添加子视图控制器的方法
    ///
    /// - Parameters:
    ///   - childViewController: 子视图控制器
    ///   - index: 索引下标，从 0 开始，请与 labelTitleArray 中的下标一一对应
    public func add(childViewController: Any, At index: Int) {
        let width = self.scrollView.frame.width
        let height = self.scrollView.frame.height
        if let childVC = childViewController as? UIViewController {
            self.addChildViewController(childVC)
            childVC.view.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
            self.scrollView.addSubview(childVC.view)
        }
    }

    /// 切换选中的分页
    ///
    /// - Parameter index: 分页下标
    public func setSelectedAt(_ index: Int) {
        update(childViewsAt: index)
    }

    /// 切换了选中的页面
    func selectedPageChangedTo(index: Int) {
        /// [长期注释] 这个方法有子类实现，来获取页面切换的回调
    }

    // MARK: - Private

    /// 更新 scrollow 的偏移位置
    private func update(childViewsAt index: Int) {
        let width = self.scrollView.frame.width
        // scroll view
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * width, y: 0), animated: true)
        updateButton(index)
    }

    var oldIndex = 0
    /// 刷新按钮
    private func updateButton(_ index: Int) {
        if oldIndex == index {
            return
        }
        selectedPageChangedTo(index: index)
        let oldButton = (labelView.viewWithTag(tagBasicForButton + oldIndex) as? UIButton)!
        oldButton.setTitleColor(TSColor.normal.minor, for: .normal)
        oldIndex = index
        let button = (labelView.viewWithTag(tagBasicForButton + index) as? UIButton)!
        button.setTitleColor(TSColor.inconspicuous.navHighlightTitle, for: .normal)
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = scrollView.contentOffset.x / scrollView.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > titleArray!.count {
            index = CGFloat(titleArray!.count)
        }
        let i = round(index)
        updateButton(Int(i))
        blueLine.frame = CGRect(x: CGFloat(index) * labelView.frame.width / CGFloat(titleArray!.count) + blueLineLeading, y: blueLine.frame.origin.y, width: blueLine.frame.width, height: blueLine.frame.height)
         TSKeyboardToolbar.share.keyboarddisappear()
    }

}
