//
//  TSPhonographView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/16.
//  Copyright © 2017年 LeonFa. All rights reserved.
//  唱片视图

import UIKit

class TSPhonographView: UIView, CAAnimationDelegate {

    /// 唱片视图位于唱片滑动视图（TSMusicPlayVC.phonograpphScrollview）的位置
    ///
    /// - left: 左边 >> 屏幕左边【左滑可见】
    /// - center: 中间 >> 屏幕中间 【可见】
    /// - right: 右边 >> 屏幕右边 【右滑可见】
    public enum phonographViewDirection {
        case left
        case center
        case right
    }
    /// 黑色碟片
    let RotationPhonograph = UIImageView()
    /// 歌曲封面
    let songCoverView = UIImageView()

    init(scorllViewHeight: CGFloat, viewDirection: phonographViewDirection) {
        super.init(frame: CGRect())
        if viewDirection == phonographViewDirection.left {
            self.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: scorllViewHeight)
        }
        if viewDirection == phonographViewDirection.center {
            self.frame = CGRect(x: ScreenSize.ScreenWidth, y: 0, width: ScreenSize.ScreenWidth, height: scorllViewHeight)
        }
        if viewDirection == phonographViewDirection.right {
            self.frame = CGRect(x: ScreenSize.ScreenWidth * 2, y: 0, width: ScreenSize.ScreenWidth, height: scorllViewHeight)
        }
        self.creatViews(frame: self.frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    func creatViews(frame: CGRect) {
        let rotationViewHeight = frame.height * 0.6
        let rotationViewWidth = rotationViewHeight

        self.songCoverView.frame = CGRect(x: (ScreenSize.ScreenWidth - (rotationViewWidth * 0.5)) / 2, y: (frame.height * 0.2) + (rotationViewHeight / 4), width: rotationViewWidth / 2, height: rotationViewHeight / 2)
        self.songCoverView.backgroundColor = .black
        self.songCoverView.layer.masksToBounds = true
        self.songCoverView.contentMode = UIViewContentMode.scaleAspectFill
        self.addSubview(self.songCoverView)

        self.RotationPhonograph.frame = CGRect(x: 0, y: 0, width: rotationViewWidth, height: rotationViewHeight)
        self.RotationPhonograph.center = self.songCoverView.center
        self.RotationPhonograph.image = UIImage(named: "IMG_music_pic_phonograph_ring_01")
        self.addSubview(self.RotationPhonograph)
    }

    /// 共外部调用的接口
    ///
    /// - Parameter songInfo: 歌曲的数据，包括歌曲信息等
    public func updateViewData(songInfo: TSSongObject) {
        self.songCoverView.kf.setImage(with: TSURLPath.imageURLPath(storageIdentity: songInfo.singer?.cover?.id, compressionRatio: 10))
    }

    // MARK: - animation

    /// 添加动画
    public func addRotate() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.delegate = self
        rotateAnimation.toValue = 2 * Double.pi
        rotateAnimation.duration = 20
        rotateAnimation.repeatDuration = CFTimeInterval(MAXFLOAT)
        rotateAnimation.isRemovedOnCompletion = false
        self.songCoverView.layer.add(rotateAnimation, forKey: nil)
    }

    /// 移除动画
    public func removeRotate() {
        self.songCoverView.layer.removeAllAnimations()
    }

    /// 暂停动画
    public func pauseAnimation() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    /// 恢复动画
    public func resumeAnimation() {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

    /// 动画重头开始
    public func reStarAnimation() {
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
    }
}
