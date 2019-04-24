//
//  TSBeforeReleaseView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  发布视图
//  主要用于主页tabbar中"+"号的响应

import UIKit

protocol TSBeforeReleaseViewDelegate: class {
    /// 回调一个index，可能为空（为空表示退出操作）
    func indexOfBtnArray(_ releaseView: TSBeforeReleaseView, _ index: Int?, _ title: String?)
}

class TSBeforeReleaseView: UIView, UIGestureRecognizerDelegate {
    // MARK: - property
    /// 模糊视图
    var visualView: UIVisualEffectView!
    /// 模拟tabbar
    var exitView: UIView = UIView()
    /// 退出图标
    var exitImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "IMG_common_ico_close"))
    /// Logo图片
    var logoImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "logo_thinksns+"))
    /// 页面高度
    let viewHeight = UIScreen.main.bounds.height
    /// 页面宽度
    let viewWidth = UIScreen.main.bounds.width
    /// Y点相对于iPhone6屏幕比例
    var proportionY: CGFloat = CGFloat(344.5 / 667.0)
    /// 默认btn宽度
    let btnWidth: CGFloat = 55
    /// 默认btn高度
    let btnHieght: CGFloat = 80
    /// 单行展示的最大数
    let onelineMax: Int = 4

    /// 发布按钮数组
    var relesaeBtnArray: Array<TSShareButton> = []
    /// 发布按钮数组动画初始点
    var relesaeBtnInitialPointArray: Array<CGPoint> = []
    /// 发布按钮数组结束动画点
    var relesaeBtnEndPointArray: Array<CGPoint> = []
    /// 代理
    weak var TSBeforeReleaseViewDelegate: TSBeforeReleaseViewDelegate? = nil

    // MARK: - Lifecycle
    /// 发布视图构造方法，images和titles数据一致时创建该页面btn
    ///
    /// - Parameters:
    ///   - frame: 该页面的大小（建议屏幕大小）
    ///   - images: 传入的images数组
    ///   - titles: 传入的titles数组
    init(frame: CGRect, images: Array<UIImage>, titles: Array<String>) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.clear
        if images.count <= 4 {
            proportionY = CGFloat((344.5 + btnWidth + viewHeight * CGFloat(25.0 / 667.0)) / 667.0)
        }
        self.getBtnArray(images: images, titles: titles)
        setupSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - layout ui
    func setupSubViews() {
        // 模糊视图以及点击事件
        let blur = UIBlurEffect(style: .extraLight)
        visualView = UIVisualEffectView(effect:blur)
        visualView.frame = self.frame
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(exitMethod))

        // 底部❌layout
        exitView.frame = CGRect(x: 0, y: (super.bounds.height) - 50 - TSBottomSafeAreaHeight, width: (super.bounds.width), height: 50)
        if TSUserInterfacePrinciples.share.isiphoneX() == true {
            exitView.backgroundColor = UIColor.clear
        } else {
            exitView.backgroundColor = UIColor.white
        }
        exitView.layer.shadowOpacity = 0.6
        exitView.layer.shadowColor = UIColor.darkGray.cgColor
        exitView.layer.shadowOffset = CGSize(width: 1, height: 1)
        exitView.layer.shadowRadius = 1
        exitImage.frame = CGRect(x: (exitView.bounds.width) / 2 - 10, y: (exitView.bounds.height) / 2 - 10, width: 20, height: 20)
        exitImage.contentMode = .scaleAspectFit
        exitImage.isUserInteractionEnabled = true
        

        logoImage.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        logoImage.centerX = self.centerX
        visualView.contentView.addSubview(logoImage)

        self.addSubview(visualView)
        visualView.addGestureRecognizer(tap)
        // UIVisualEffectView 添加子视图使用contentView，否则这里会崩溃
        visualView.contentView.addSubview(exitView)
        exitView.addSubview(exitImage)

        self.layoutForBtnArray()
    }

    /// 根据btnArray布局
    /// - btn间隔等分视图（已问过设计）
    ///     - 需要获得一个初始的point（方便动画设置- 开始）
    ///     - 需要获得一个结束的point（方便动画设置- 结束）
    ///     - 开始动画效果
    func layoutForBtnArray() {
        let count = relesaeBtnArray.count
        relesaeBtnEndPointArray = self.animateEndPoint(count: count)
        relesaeBtnInitialPointArray = self.animateStartPoint(endPoints: relesaeBtnEndPointArray)
        guard !relesaeBtnEndPointArray.isEmpty && !relesaeBtnInitialPointArray.isEmpty else {
            assert(false, "炸了，动画效果需要的数据不足")
            return
        }
        self.anmieShow()
    }

    // MARK: - Custom function
    func tapBtnOfArrayIndex(_ btn: TSShareButton) {
        for index in 0..<relesaeBtnArray.count {
            if relesaeBtnArray[index] == btn {
                let title = btn.currentTitle
                // 投稿时的特殊处理: 需请求用户认证状态，再进行响应回调
                if title == "显示_投稿".localized {
                    // 投稿的特殊处理
                    self.isUserInteractionEnabled = false
                    TSNewsHelper.share.updateVerified(complete: { (verified) in
                        self.isUserInteractionEnabled = true
                        if nil == verified {
                            // 网络请求失败，则不处理
                            return
                        } else {
                            self.didItemTap(tapBtn: btn, index: index, title: title)
                        }
                    })
                } else {
                    self.didItemTap(tapBtn: btn, index: index, title: title)
                }
            }
        }
    }
    /// item的具体响应
    func didItemTap(tapBtn: TSShareButton, index: Int, title: String?) -> Void {
        self.tapToEnlarge(tapBtn)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.removeFromSuperview()
            self.TSBeforeReleaseViewDelegate?.indexOfBtnArray(self, index, title)
        }
    }

    /// 点击后变大动画效果
    ///
    /// - Parameter tap: 传入点击btn
    func tapToEnlarge(_ tap: TSShareButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveLinear, animations: {
            tap.transform = CGAffineTransform(scaleX: 2, y: 2)
        }, completion:nil)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            tap.alpha = 0.0
        }, completion:nil)
    }
    /// 动画开始的位置
    ///
    /// - Parameter endPoints: 动画结束的位置
    /// - Returns: 偏移后得出动画开始的位置
    func animateStartPoint(endPoints: Array<CGPoint>) -> Array<CGPoint> {
        let offsetY: CGFloat = 90
        var array: Array<CGPoint> = []
        for point in endPoints {
            let temp = CGPoint(x: point.x, y: point.y + offsetY)
            array.append(temp)
        }
        return array
    }

    /// 动画结束的位置
    ///
    /// - Parameter count: 多少个按钮
    /// - Returns: 根据count得出设计图按钮位置（数组）
    func animateEndPoint(count: Int) -> Array<CGPoint> {
        let oneLineNum = count >= self.onelineMax ? self.onelineMax : count
        let oneLineBtnWidth = count >= self.onelineMax ? CGFloat(self.onelineMax) * btnWidth : CGFloat(count) * btnWidth
        var spacing = (viewWidth - oneLineBtnWidth) / CGFloat(oneLineNum + 1)
        if 4 == count {
            spacing = (viewWidth - btnWidth * 2.0) / (2.0 + 1.0)
        }
        var array: Array<CGPoint> = []
        let startX: CGFloat = spacing
        let startY: CGFloat = viewHeight * proportionY
        let spacingY: CGFloat = viewHeight * CGFloat(25.0 / 667.0)
        for index in 0..<count {
            var row = index / self.onelineMax
            var col = index % self.onelineMax
            if 4 == count {
                row = index / 2
                col = index % 2
            }
            let temp = CGPoint(x: startX + (btnWidth + spacing) * CGFloat(col), y: startY + (btnHieght + spacingY) * CGFloat(row))
            array.append(temp)
        }
        return array
    }

    /// 行动代号：动画展示
    /// - 1. 设置按钮的初始化位置
    /// - 2. 设置数组按钮动画效果
    func anmieShow() {
        for index in 0..<self.relesaeBtnArray.count {
            let btn = self.relesaeBtnArray[index]
            // UIVisualEffectView 添加子视图使用contentView，否则这里会崩溃
            visualView.contentView.addSubview(btn)
            let startPoint = self.relesaeBtnInitialPointArray[index]
            btn.frame = CGRect(x: startPoint.x, y: startPoint.y, width: btnWidth, height: btnHieght)
        }
        for index in 0..<self.relesaeBtnArray.count {
            UIView.animate(withDuration: 0.3, animations: {
                let btn = self.relesaeBtnArray[index]
                let endPoint = self.relesaeBtnEndPointArray[index]
                btn.frame = CGRect(x: endPoint.x, y: endPoint.y, width: self.btnWidth, height: self.btnHieght)
            }, completion: nil)
        }
    }

    /// 获取有多少个btn
    /// - 如果图片、文字数不相等则不创建
    /// - Parameters:
    ///   - images: btn的图片数
    ///   - titles: btn的文字数
    func getBtnArray(images: Array<UIImage>, titles: Array<String>) {
        guard images.count == titles.count else {
            return
        }
        for index in 0..<images.count {
            let tempBtn: TSShareButton = TSShareButton(normalImage: images[index], title: titles[index], titleFont: TSFont.Button.keyboardRight.rawValue, titleColor: TSColor.small.releaseBtnTitle)
            tempBtn.setTitleWithImageSpaceAndTitleHeight(space: 11.5, height: 13)
            tempBtn.addTarget(self, action: #selector(tapBtnOfArrayIndex(_:)), for: .touchUpInside)
            relesaeBtnArray.append(tempBtn)
        }
    }

    /// 退出方法
    func exitMethod() {
        self.alpha = 1
        UIView.animate(withDuration: 0.7, animations: {
            self.alpha = 0
        }) { (bool) in
            self.alpha = 1
            self.removeFromSuperview()
            self.TSBeforeReleaseViewDelegate?.indexOfBtnArray(self, nil, nil)
        }
    }
}
