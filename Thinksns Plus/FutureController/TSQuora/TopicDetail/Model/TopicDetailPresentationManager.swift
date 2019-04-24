//
//  TopicDetailPresentationManager.swift
//  RealmTest
//
//  Created by GorCat on 2017/8/31.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

class TopicDetailPresentationManager: NSObject {

    var isPresent = true
    let animationTime = TimeInterval(0.2)
    /// 推送前，被推送视图控制器 Y 方向上的偏移量
    var presentOffsetY: CGFloat = 100

    func willPresentedController(_ transitionContext: UIViewControllerContextTransitioning) {
        // 1.获取需要弹出视图
        // 通过ToViewKey取出的就是toVC对应的view
        guard let toView = transitionContext.view(forKey: .to), let fromView = transitionContext.view(forKey: .from) else {
            return
        }

        // 2.将需要弹出的视图添加到containerView上
        toView.frame = CGRect(origin: CGPoint(x: 0, y: presentOffsetY), size: toView.frame.size)
        fromView.frame.origin = .zero
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)

        // 3.执行动画
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveLinear, animations: {
            toView.frame.origin.y = 0
            fromView.frame.origin.y = -self.presentOffsetY
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }

    func willDismissedController(_ transitionContext: UIViewControllerContextTransitioning) {

        // 1.获取需要弹出视图
        // 通过ToViewKey取出的就是toVC对应的view
        guard let toView = transitionContext.view(forKey: .to), let fromView = transitionContext.view(forKey: .from) else {
            return
        }

        // 2.将需要弹出的视图添加到containerView上
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.addSubview(fromView)

        // 3.执行动画
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveLinear, animations: {
            fromView.frame.origin.y = self.presentOffsetY
            toView.frame.origin.y = 0
        }) { (_) in
            transitionContext.completeTransition(true)
            NotificationCenter.default.post(name: NSNotification.Name.TopicDetailController.dismiss, object: nil)
        }
    }
}

extension TopicDetailPresentationManager: UIViewControllerAnimatedTransitioning {

    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationTime
    }

    /// 动画效果
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            // 展现
            willPresentedController(transitionContext)
        } else {
            // 消失
            willDismissedController(transitionContext)
        }
    }
}

extension TopicDetailPresentationManager: UIViewControllerTransitioningDelegate {

    // 该方法用于返回一个负责转场如何出现的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }

    // 该方法用于返回一个负责转场如何消失的对象
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
}
