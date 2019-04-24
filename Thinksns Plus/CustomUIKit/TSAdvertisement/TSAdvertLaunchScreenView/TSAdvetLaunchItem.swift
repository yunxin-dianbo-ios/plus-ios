//
//  TSAdvetLaunchItemCollectionViewCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  启动页广告 cell

import UIKit

@objc protocol TSAdvetLaunchItemDelegate: class {
    /// 点击了广告界面
    @objc optional func item(didSelectedAdert item: TSAdvetLaunchItem)
    /// 点击了跳转按钮
    func item(_ item: TSAdvetLaunchItem, didSelectedSkipButton skipButton: UIButton)
}

class TSAdvetLaunchItem: TSAdvertItemView {

    static let identifer = "TSAdvetLaunchItem"

    /// 代理
    weak var delegate: TSAdvetLaunchItemDelegate?
    /// 数据模型
    private var _model: TSAdverLaunchModel?
    /// logo到屏幕顶部的约束
    // 用于更新其至空白区域垂直居中
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    var model: TSAdverLaunchModel? {
        set(newValue) {
            _model = newValue
            itemModel = newValue?.advertModel
            // 设置底部的logo视图位于空白区域垂直居中
            // 默认的logo视图宽高比为6: 20
            self.logoTopConstraint.constant = (ScreenHeight - displayFrame.height) / 2.0 + displayFrame.height - (6 / 20.0 * ScreenWidth) / 2.0
        }
        get {
           return _model
        }
    }
    /// 跳过按钮
    @IBOutlet weak var buttonForSkip: UIButton!
    /// 当前视图是否正在显示
    var isShowing = false

    // MARK: - Lifecycle
    class func launchItem() -> TSAdvetLaunchItem {
        let item = Bundle.main.loadNibNamed("TSAdvetLaunchItem", owner: nil, options: nil)?.first as! TSAdvetLaunchItem
        return item
    }

    /// 设置视图，此方法是重写付费的方法
    override func setUI() {
        // 设置广告的展示视图
        // 广告位固定宽高比为 1080:1567
        displayFrame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 1_567.0 / 1_080.0 * ScreenWidth))
        /// 开屏广告需要将点击事件绑定在图片上，而不是整个item
        let tap = UITapGestureRecognizer(target: self, action: #selector(advertTaped))
        self.imageView.addGestureRecognizer(tap)
    }

    // MARK: - IBAction

    /// 点击了跳转按钮
    @IBAction func skipButtonTaped(_ sender: UIButton) {
        delegate?.item(self, didSelectedSkipButton: sender)
    }

    // MARK: - Public

    /// 更新跳转按钮
    public func updateSkipButton(countDown: Int) {
        guard let model = model else {
            return
        }
        if !model.canSkip { // 不可跳过
            buttonForSkip.isEnabled = false
            buttonForSkip.setTitle("\(countDown)秒", for: .normal)
        } else { // 可跳过
            buttonForSkip.isEnabled = true
            buttonForSkip.setTitle("跳过 \(countDown)秒", for: .normal)
        }
    }
}
