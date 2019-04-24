//
//  TSTableViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  抽象类

import UIKit
import MJRefresh

class TSTableViewController: UITableViewController {

    /// 缺省图类型
    ///
    /// - weakNet: 网络错误
    /// - empty: 没有数据
    /// - custom: 自定义占位图
    public enum OccupiedType {
        case network
        case empty
    }
    /// 占位图
    /// - warning: 该方法已废弃.查看 self.placeholderViews
    internal let occupiedView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - 49))

    /// 占位图
    var placeholderViews: [PlaceholderViewType: UIView] = [.network: NormalPlaceholderView.imageView(name: "IMG_img_default_internet"), .empty: NormalPlaceholderView.imageView(name: "IMG_img_default_nothing")]

    let edgeInsets = UIEdgeInsets.zero
    /// 导航栏右边按钮的区域
    var rightButtonCunstomView: UIView? = nil
    /// 导航栏右边的按钮
    var rightButton: UIButton? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotic()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotic()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customUISetup()
        customSeparator()
        setupRefresh()
    }

    deinit {
        removeNotic()
    }

    // MARK: - Custom user interface

    /// 显示占位图
    /// - warning: 该方法已废弃.查看 self.placeholderViews
    func showOccupiedView(_ type: OccupiedType, isDataSourceEmpty: Bool) {
        switch type {
        case .empty:
            occupiedView.image = UIImage(named: "IMG_img_default_nothing")
        case .network:
            occupiedView.image = UIImage(named: "IMG_img_default_internet")
        }
        if occupiedView.superview == nil {
            tableView.addSubview(occupiedView)
        }
        if !isDataSourceEmpty && occupiedView.superview != nil {
            occupiedView.removeFromSuperview()
        }
    }
}

// MARK: - 指示器A的处理逻辑
extension TSTableViewController {
    // 需要显示指示器A
    func show(indicatorA title: String) {
        guard let nav = self.navigationController as? TSNavigationController else {
            TSLogCenter.log.debug("\n\ndismissIndicatorA调用了显示指示器A的方法,但是该控制器的父控制器设置错误\n\n")
            return
        }
        nav.show(indicatorA: title)
    }

    func show(indicatorA title: String, timeInterval: Int) {
        guard let nav = self.navigationController as? TSNavigationController else {
            TSLogCenter.log.debug("\n\ndismissIndicatorA调用了显示指示器A的方法,但是该控制器的父控制器设置错误\n\n")
            return
        }
        nav.show(indicatorA: title, timeInterval: timeInterval)
    }

    func dismissIndicatorA() {
        guard let nav = self.navigationController as? TSNavigationController else {
            TSLogCenter.log.debug("\n\ndismissIndicatorA调用了显示指示器A的方法,但是该控制器的父控制器设置错误\n\n")
            return
        }
        nav.dismissIndicatorA()
    }

}

// MARK: - 占位图
extension TSTableViewController {

    /// 设置自定义占位图
    ///
    /// - property:
    ///   - placeholderView: 自定义占位图
    ///   - type: 设置已有的占位图类型
    /// - Note: 当配置自定义的占位图时,使用 placeholderView ,且设置 type 为 custom
    func set(placeholderView: UIView, for type: PlaceholderViewType) {
        placeholderViews[type] = placeholderView
    }

    /// 显示占位图
    func show(placeholderView type: PlaceholderViewType) {
        guard let occupiedView = placeholderViews[type] else {
            assert(false, "使用了未设置的占位图")
            return
        }
        if occupiedView.superview == nil {
            removePlaceholderViews()
            view.addSubview(occupiedView)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 调整占位图的位置
        for (_, occupiedView) in placeholderViews {
            guard occupiedView.superview != nil else {
                continue
            }
            occupiedView.frame = view.bounds
        }
    }

    /// 移除占位图
    func removePlaceholderViews() {
        for (_, occupiedView) in placeholderViews {
            guard occupiedView.superview != nil else {
                continue
            }
            occupiedView.removeFromSuperview()
        }
    }

}

extension TSTableViewController {

    /// 自定义设置
    fileprivate func customUISetup() {
        self.view.backgroundColor = TSColor.inconspicuous.background
        occupiedView.contentMode = .center
        occupiedView.backgroundColor = TSColor.inconspicuous.background
    }

    func setupRefresh() {
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }

    // MARK: - Delegete
    // MARK: GTMRefreshHeaderDelegate
    func refresh() {
        fatalError("必须重写该方法,执行下拉刷新后的逻辑")
    }

    // MARK: GTMLoadMoreFooterDelegate
    func loadMore() {
        fatalError("必须重写该方法,执行上拉加载后的逻辑")
    }
}

/// 设置分割线 布满Cell 底部
extension TSTableViewController {

    func customSeparator() {
        self.tableView.separatorColor = TSColor.inconspicuous.disabled
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorInset = edgeInsets
        tableView.layoutMargins = edgeInsets
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = edgeInsets
        cell.separatorInset = edgeInsets
    }
}

/// 添加音乐入口点击的监听
extension TSTableViewController {

    func addNotic() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
        NotificationCenter.default.addObserver(self, selector: #selector(setRightCustomViewWidthMin), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }

    func removeNotic() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
}

/// 导航栏右边按钮相关
extension TSTableViewController {

    /// 设置右边按钮
    /// 增加导航栏右边按钮
    ///
    /// - Note: 在 viewWillAppear 和 viewDidLoad 各写一次，一共写两次
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - img: 图片
    func setRightButton(title: String?, img: UIImage?) {

        if self.navigationController == nil {
            return
        }

        if rightButtonCunstomView == nil {
            initRightCustom()
        }

        rightButton?.setImage(img, for: UIControlState.normal)
        rightButton?.setTitle(title, for: UIControlState.normal)

        setRightCustomViewWidth(Max: TSMusicPlayStatusView.shareView.isShow)
    }

    /// 初始化右边的按钮区域
    func initRightCustom() {
        self.rightButtonCunstomView = UIView()
        self.rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MinWidth, height: 44))
        self.rightButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.addTarget(self, action: #selector(rightButtonClicked), for: UIControlEvents.touchUpInside)
        self.rightButton?.setTitleColor(TSColor.main.theme, for: UIControlState.normal)
        self.rightButton?.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        self.rightButtonCunstomView?.addSubview(self.rightButton!)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButtonCunstomView!)
    }

    /// 设置按钮标题颜色
    ///
    /// - Parameter color: 颜色
    func setRightButtonTextColor(color: UIColor) {
        self.rightButton?.setTitleColor(color, for: UIControlState.normal)
    }

    /// 设置按钮是否可以点击
    ///
    /// - Parameter enable: 是否可以点击
    func rightButtonEnable(enable: Bool) {
        self.rightButton?.isEnabled = enable
        self.rightButton?.setTitleColor(enable ? TSColor.main.theme : TSColor.normal.disabled, for: UIControlState.normal)
    }

    /// 设置按钮区域的宽度
    ///
    /// - Parameter Max: 是否是最大宽度
    func setRightCustomViewWidth(Max: Bool) {
        if self.rightButtonCunstomView == nil {
            return
        }

        let width = Max ? TSViewRightCustomViewUX.MaxWidth: TSViewRightCustomViewUX.MinWidth

        if self.rightButtonCunstomView?.frame.width == width {
            return
        }

        self.rightButtonCunstomView!.frame = CGRect(x: 0, y: 0, width: width, height: TSViewRightCustomViewUX.Height)
    }

    /// 设置为最小宽度 （用于音乐图标自动消失时重置宽度）
    func setRightCustomViewWidthMin() {
        setRightCustomViewWidth(Max: false)
    }

    /// 按钮点击方法
    func rightButtonClicked() {
        fatalError("请重写此方法实现右边按钮的点击事件")
    }
}
