//
//  TSIndicatorA.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  指示器 a 悬浮上导航栏下方
//  样式参见《TS+视觉规范 2.0》31 页 "G 指示器/a.第一种"

import UIKit

protocol TSIndicatorAProrocol {
    /// 根据字符串显示指示器 a,默认显示1.8秒后消失
    ///
    /// - Parameter title: 指示器内容
    func show(indicatorA title: String)
    /// 显示指示器 a
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - timeInterval: 显示时间
    func show(indicatorA title: String, timeInterval: Int?)
    /// 隐藏指示器 a
    func dismissIndicatorA()
}

extension TSIndicatorAProrocol where Self: TSNavigationController {
    /// 显示指示器 a
    ///
    /// - Parameter title: 标题
    func show(indicatorA title: String) {
        show(indicatorA: title, timeInterval: nil)
    }

    /// 显示指示器 a
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - timeInterval: 显示时间
    func show(indicatorA title: String, timeInterval: Int?) {
        var indicatorA: TSIndicatorA
        if let view = self.view.viewWithTag(TSIndicatorA.tagForIndicatorA) as? TSIndicatorA {
            indicatorA = view
            indicatorA.labelForTitle.text = title
        } else {
            indicatorA = TSIndicatorA(title: title)
            indicatorA.tag = TSIndicatorA.tagForIndicatorA
        }
        guard indicatorA.superview == nil else {
            return
        }
        let maxY = self.navigationBar.frame.maxY
        indicatorA.frame = CGRect(x: 0, y: maxY, width: UIScreen.main.bounds.width, height: 30)
        self.view.insertSubview(indicatorA, at: self.view.subviews.count)
        var deadLine: DispatchTime
        if let time = timeInterval {
            deadLine = DispatchTime.now() + DispatchTimeInterval.seconds(time)
        } else {
            deadLine = DispatchTime.now() + DispatchTimeInterval.milliseconds(1_800)
        }
        DispatchQueue.main.asyncAfter(deadline: deadLine) { [weak self] () -> Void in
            guard let `self` = self else {
                return
            }
            self.dismissIndicatorA()
          }
    }

    /// 隐藏指示器 a
    func dismissIndicatorA() {
        guard let indicatorA = self.view.viewWithTag(TSIndicatorA.tagForIndicatorA) as? TSIndicatorA else {
            return
        }
        indicatorA.removeFromSuperview()
    }
}

class TSIndicatorA: UIView {
    /// A 类型活动指示器的 tag 值
    static let tagForIndicatorA = 400
    /// 标题 label
    let labelForTitle = TSLabel()
    /// 计时器
    var timer: Timer?
    /// 标题
    var title = ""
    // MAKR: - Lifecycle

    /// 自定义构造器
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - timeInterval: 显示时间
    init(title: String) {
        super.init(frame: CGRect(x: 0, y: -30, width: UIScreen.main.bounds.width, height: 30))
        self.title = title
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Custom user interface 
    private func setUI() {
        backgroundColor = UIColor.white
        // mask view
        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        maskView.backgroundColor = TSColor.main.theme
        maskView.alpha = 0.7
        // title
        labelForTitle.textColor = UIColor.white
        labelForTitle.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        labelForTitle.textAlignment = .center
        labelForTitle.text = title
        labelForTitle.sizeToFit()
        labelForTitle.frame = CGRect(origin: CGPoint(x: (frame.width - labelForTitle.frame.width) / 2, y: (frame.height - labelForTitle.frame.height) / 2), size: labelForTitle.frame.size)

        addSubview(maskView)
        addSubview(labelForTitle)
    }
}
