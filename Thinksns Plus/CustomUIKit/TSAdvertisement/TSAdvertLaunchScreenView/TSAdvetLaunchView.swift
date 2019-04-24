//
//  TSLaunchAdvetVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

class TSAdvetLaunchView: UIView, TSAdvetLaunchItemDelegate {

    /// UI 数据模型
    var models: [TSAdverLaunchModel]?
    /// item 集合
    var items = [TSAdvetLaunchItem.launchItem(), TSAdvetLaunchItem.launchItem()]
    /// 计时器
    var timer: Timer? = nil
    /// 广告指针
    var pointer = 0
    /// 广告页面点击事件
    var tapAdvertAction: ((_ message: Any?) -> Void)? = nil

    // MARK: - Lifecycle
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor.white
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Custom user interface

    /// 设置广告的 UI 模型
    public func setAdert(models modelDatas: [TSAdverLaunchModel]) {
        models = modelDatas
        guard let models = models else {
            return
        }
        if models.isEmpty {
            return
        }
        // 停止 timmer
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        // 设置初始显示 item 视图
        items[0].model = models[0]
        for item in items {
            item.delegate = self
            addSubview(item)
            item.snp.makeConstraints({ (make) in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            })
        }
        items[0].alpha = 1
        items[0].isShowing = true
        items[0].updateSkipButton(countDown: models[0].timeInterval) //
        items[1].alpha = 0
        // 加1 是为了解决第一张图默认展示数小1的问题(一开始就先执行了switchAdvertItem)
        var firstModel = models[0]
        firstModel.timeInterval += 1
        self.models![0] = firstModel
    }

    /// 启动计时器，切换广告图
    func switchAdvertItem() {
        guard let models = models else {
            return
        }
        if pointer > models.count {
            dismiss()
            return
        }
        var itemModel = models[pointer]
        /// 当前 item
        let currentItemIndex = items[0].isShowing ? 0 : 1
        let nextItemIndex = items[0].isShowing ? 1 : 0
        // 判断当前显示广告是否已经到时
        if itemModel.alreadyTimeInterval == itemModel.timeInterval { // 到时
            if pointer >= models.count - 1 {
                dismiss()
                return
            }
            pointer += 1
            items[nextItemIndex].model = models[pointer]
            items[nextItemIndex].itemModel = models[pointer].advertModel
            // 切换下一章图片
            // 这里设置2张图的buttonForSkip的隐藏和显示，是为了避免切换过程中 buttonForSkip之前的标题产生差异
            self.items[currentItemIndex].buttonForSkip.isHidden = true
            self.items[nextItemIndex].buttonForSkip.isHidden = true
            UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseInOut, animations: { [weak self] in
                if let weakSelf = self {
                    weakSelf.items[currentItemIndex].alpha = 0
                    weakSelf.items[nextItemIndex].alpha = 1
                }
            }) { [weak self] (_) in
                if let weakSelf = self {
                    weakSelf.items[currentItemIndex].isShowing = false
                    weakSelf.items[nextItemIndex].isShowing = true
                    weakSelf.items[currentItemIndex].buttonForSkip.isHidden = false
                    weakSelf.items[nextItemIndex].buttonForSkip.isHidden = false
                    weakSelf.items[nextItemIndex].updateSkipButton(countDown: itemModel.timeInterval)
                }
            }
        } else { // 没到时
            // 更换跳转按钮上的倒计时
            let countDownNumber = itemModel.timeInterval - itemModel.alreadyTimeInterval
            items[currentItemIndex].updateSkipButton(countDown: countDownNumber)
            itemModel.alreadyTimeInterval += 1
            self.models?[pointer] = itemModel
        }
    }

    // MARK: - Public

    /// 获取当前动画的信息
    func getCurrentAdInfo() -> TSAdverLaunchModel? {
        return models?[pointer]
    }

    /// 暂停动画
    func pauseAnimation() {
        timer?.fireDate = NSDate.distantFuture
    }

    /// 重启动画
    func resumeAnimation() {
        timer?.fireDate = Date()
    }

    /// 启动轮播动画
    func starAnimation() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(switchAdvertItem), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
            timer!.fire()
        }
    }

    /// 移除广告页
    func dismiss() {
        // 停止计时器
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        // 移除广告页
        if superview != nil {
            removeFromSuperview()
        }
    }

    /// 设置广告点击事件
    func setTapAdvertAction(block: @escaping (_ message: Any?) -> Void) {
        tapAdvertAction = block
    }

    // MARK: - Delegate

    // MARK: TSAdvetLaunchItemDelegate

    /// 点击了跳转按钮
    func item(_ item: TSAdvetLaunchItem, didSelectedSkipButton skipButton: UIButton) {
        dismiss()
    }

    /// 点击了广告界面
    func item(didSelectedAdert item: TSAdvetLaunchItem) {
        tapAdvertAction?(nil)
    }

}
