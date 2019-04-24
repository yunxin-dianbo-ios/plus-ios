//
//  TSTableView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 缺省图类型
///
/// - weakNet: 网络错误
/// - empty: 没有数据
public enum OccupiedType {
    case network
    case empty
    case searchEmpty
}

class TSTableView: UITableView {

    /// 占位图
    var placeholderViews: [PlaceholderViewType: UIView] = [.network: NormalPlaceholderView.imageView(name: "IMG_img_default_internet"), .empty: NormalPlaceholderView.imageView(name: "IMG_img_default_nothing")]
    var placeholderContentInset = UIEdgeInsets.zero

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setSuperUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setSuperUI()
    }

    // MARK: - Custom user interface
    func setSuperUI() {
        tableFooterView = UIView()
        // 添加刷新控件
        mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }
}

// MARK: - 显示指示器
extension TSTableView {
    func show(indicatorA title: String) {
        let noti = Notification(name: Notification.Name.NavigationController.showIndicatorA, object: nil, userInfo: ["content": title])
        NotificationCenter.default.post(noti)
    }

    func show(indicatorA title: String, timeInterval: Int) {
        // 兼容旧的接口,修改的该视图显示的A指示器不能设置时间自动会消失,所有该方法的时间参数未被使用
        let noti = Notification(name: Notification.Name.NavigationController.showIndicatorA, object: nil, userInfo: ["content": title])
        NotificationCenter.default.post(noti)
    }

    func dismissIndicatorA() {
       // 兼容旧的接口,修改的该视图显示的A指示器不能设置时间自动会消失,所有该方法无效.
    }
}

// MARK: - 占位图
extension TSTableView {

    /// 设置占位图的内间距
    func set(placeholderContentInset: UIEdgeInsets) {
        self.placeholderContentInset = placeholderContentInset
    }

    /// 设置占位图
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
            // 将占位图天添加到视图上
            addSubview(occupiedView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 调整占位图的位置
        for (_, occupiedView) in placeholderViews {
            guard occupiedView.superview != nil else {
                continue
            }
            occupiedView.frame = CGRect(x: 0, y: placeholderContentInset.top, width: bounds.width - contentInset.left - contentInset.right, height: bounds.height - contentInset.top - contentInset.bottom)
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

/// 刷新逻辑
extension TSTableView {

    // MARK: - Delegete
    // MARK: GTMRefreshHeaderDelegate
    func refresh() {
       // fatalError("必须重写该方法,执行下拉刷新后的逻辑")
    }

    // MARK: GTMLoadMoreFooterDelegate
    func loadMore() {
      //  fatalError("必须重写该方法,执行上拉加载后的逻辑")
    }
}
