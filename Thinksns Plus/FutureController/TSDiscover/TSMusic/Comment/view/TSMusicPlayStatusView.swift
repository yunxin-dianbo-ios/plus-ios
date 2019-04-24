//
//  TSMusicPlayStatusView.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct TSMusicPlayStatusViewUX {
    /// 视图宽度
    static let ViewWidth: CGFloat = 34
    /// 视图高度
    static let ViewHeight: CGFloat = 34
    /// 距右距离
    static let rightSpce: CGFloat = 5
    /// 距上距离
    static let topSpace: CGFloat = (TSNavigationBarHeight - 34 + TSStatusBarHeight) / 2.0
}

let TSMusicPushToMusicPlayVCName = "TSMusicPushToMusicPlayVCName"

let TSMusicStatusViewAutoHidenName = "TSMusicStatusViewAutoHidenName"

class TSMusicPlayStatusView: UIView {

    /// 单例对象
    static let shareView = TSMusicPlayStatusView()
    /// 动画视图
    private let AnimationView: UIButton = UIButton()
    /// 是否在动画中
    private var isAnimation: Bool = false
    /// 定时器
    private var timer: Timer? = nil
    /// 歌曲暂停后视图消失的时间
    private let dismissTime: Double = 4

    /// 入口视图是否在显示
    var isShow: Bool {
        return false//self.superview != nil
    }

    private init() {
        super.init(frame: CGRect(x: TSMusicPlayStatusViewUX.ViewWidth + 5, y: TSMusicPlayStatusViewUX.topSpace, width: TSMusicPlayStatusViewUX.ViewWidth, height: TSMusicPlayStatusViewUX.ViewWidth))
        self.alpha = 0.1
        self.layer.cornerRadius = TSMusicPlayStatusViewUX.ViewWidth / 2.0
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        self.addGestureRecognizer(panGesture)
        layoutAnimationView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutAnimationView() {
        self.AnimationView.frame = self.bounds
        self.AnimationView.setImage(UIImage(named: "IMG_music_ico_suspension_black"), for: UIControlState.normal)
        self.AnimationView.addTarget(self, action: #selector(pushToPlayVC), for: UIControlEvents.touchUpInside)
        self.addSubview(self.AnimationView)
    }

    // MARK: - 动画
    /// 添加动画
    private func addAnimation() {
        cancelTimer()
        if isAnimation {
            return
        }
        isAnimation = true

        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.toValue = 2 * Double.pi
        rotateAnimation.duration = 4
        rotateAnimation.repeatDuration = CFTimeInterval(MAXFLOAT)
        rotateAnimation.isRemovedOnCompletion = false
        self.AnimationView.layer.add(rotateAnimation, forKey: nil)
    }

    /// 移除动画
    private func removeRotate() {
        starTimer()
        if !isAnimation {
            return
        }
        isAnimation = false
        self.AnimationView.layer.removeAllAnimations()
    }

    /// 启动定时器 5秒后自动隐藏视图
    private func starTimer() {
        if self.timer == nil {
            timer = Timer(timeInterval: dismissTime, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        }
        RunLoop.main.add(timer!, forMode:RunLoopMode.commonModes)
    }

    /// 取消定时器
    private func cancelTimer() {
        if timer == nil {
            return
        }
        timer?.invalidate()
        timer = nil
    }

    @objc private func timerAction() {
        self.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
        }
        cancelTimer()
    }
    // MARK: - 通知

    /// 添加通知监听
    private func addNotice() {
        NotificationCenter.default.addObserver(self, selector: Selector(extendedGraphemeClusterLiteral: "bigenAnimaition"), name: NSNotification.Name(rawValue: TSMusicPlayBeginName), object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector(extendedGraphemeClusterLiteral: "stopAnimation"), name: NSNotification.Name(rawValue: TSMusicPlayPausedName), object: nil)
    }

    /// 注销监听
    private func removeNotice() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - action
    @objc private func pushToPlayVC() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicPushToMusicPlayVCName), object: nil)
    }

    private func bigenAnimaition() {
        addAnimation()
        cancelTimer()
    }

    private func stopAnimation() {
        removeRotate()
        starTimer()
    }

    // MARK: - Public Method
    public func showView() {
        if self.superview == nil {
            UIApplication.topViewController()?.view.addSubview(self)
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = CGRect(x: TSMusicPlayStatusViewUX.ViewWidth + 5, y: TSMusicPlayStatusViewUX.topSpace, width: TSMusicPlayStatusViewUX.ViewWidth, height: TSMusicPlayStatusViewUX.ViewWidth)
                self.AnimationView.setImage(UIImage(named: "IMG_music_ico_suspension_black"), for: UIControlState.normal)
                self.alpha = 1.0
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            })
        }
    }

    public func dismiss() {
        if self.superview != nil {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.1
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }
    }

    /// 用于播放界面消失时设置视图动画
    public func setAnimation() {
        if TSMusicPlayerHelper.sharePlayerHelper.player.status == .Playing {
            addAnimation()
        } else if TSMusicPlayerHelper.sharePlayerHelper.player.status == .Paused {
            removeRotate()
        }
    }

    public func reSetImage(white: Bool) {
        self.AnimationView.setImage(UIImage(named: white ? "IMG_music_ico_suspension_white" : "IMG_music_ico_suspension_black"), for: UIControlState.normal)
    }

    public func panAction(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.AnimationView.setImage(UIImage(named: "IMG_music_ico_suspension_white"), for: UIControlState.normal)
        }
        if recognizer.state == .ended {
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            self.AnimationView.setImage(UIImage(named: "IMG_music_ico_suspension_black"), for: UIControlState.normal)
        }
        let translationPoint: CGPoint = recognizer.translation(in: self.superview)
        let centerP: CGPoint = (recognizer.view?.center)!
        var pointX = centerP.x + translationPoint.x
        var pointY = centerP.y + translationPoint.y
        if pointY < TSStatusBarHeight + TSMusicPlayStatusViewUX.ViewHeight / 2.0 {
            pointY = TSStatusBarHeight + TSMusicPlayStatusViewUX.ViewHeight / 2.0
        }
        if pointY > ScreenHeight - TSTabbarHeight - TSMusicPlayStatusViewUX.ViewHeight / 2.0 {
            pointY = ScreenHeight - TSTabbarHeight - TSMusicPlayStatusViewUX.ViewHeight / 2.0
        }
        if pointX < TSMusicPlayStatusViewUX.ViewWidth / 2.0 {
            pointX = TSMusicPlayStatusViewUX.ViewWidth / 2.0
        }
        if pointX > ScreenWidth - TSMusicPlayStatusViewUX.ViewWidth / 2.0 {
            pointX = ScreenWidth - TSMusicPlayStatusViewUX.ViewWidth / 2.0
        }
        recognizer.view?.center = CGPoint(x: pointX, y: pointY)
        recognizer.setTranslation(CGPoint.zero, in: self.superview)
    }
}
