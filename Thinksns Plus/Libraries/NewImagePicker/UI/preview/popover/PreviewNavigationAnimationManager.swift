//
//  PreviewNavigationAnimationManager.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/25.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

class PreviewNavigationAnimationManager: NSObject, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {

    /// 是否为 push
    var isPush = true

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            isPush = true
        }
        if operation == .pop {
            isPush = false
        }
        return self
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPush ? showPushAnimation(transitionContext: transitionContext) : showPopAnimation(transitionContext: transitionContext)
    }

    // push 动画
    func showPushAnimation(transitionContext: UIViewControllerContextTransitioning) {
        // 1.获取 previewVC
        let toVC = transitionContext.viewController(forKey: .to) as! PHPreviewVC

        // 2.将 preview 添加在 container 上
        transitionContext.containerView.addSubview(toVC.view)

        // 3.开启 preview 过渡动画

        // 4.结束转场动画
        transitionContext.completeTransition(true)
    }

    /// pop 动画
    func showPopAnimation(transitionContext: UIViewControllerContextTransitioning) {

        // 1.获取 toVC(collection) 和 fromVC(preview)
        let toVC = transitionContext.viewController(forKey: .to)!
        let fromVC = transitionContext.viewController(forKey: .from)!

        // 2.调整 collection 和 preview 的层级结构
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        // 3.开启 preview 的过渡动画

        // 4.结束转场动画
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
}
