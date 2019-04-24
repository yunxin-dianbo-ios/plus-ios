//
//  TSAdvertBanners.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/5/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  列表顶部 Banner

import UIKit

class TSAdvertBanners: UIView, UIScrollViewDelegate {

    /// 数据模型数组
    var models: [TSAdvertBannerModel] = []
    /// 视图切换时间间隔
    let timerInterval: TimeInterval = 4
    /// 广告按钮的 tag
    let tagForAdvertButton = 200
    /// 动画开关
    var autoAnimaiton = false
    /// 计时器
    var timer: Timer? = nil

    /// 按钮数组
    var items: [TSAdvertItemView] = []

    /// 标题数组
    var labels: [TSLabel] = []
    /// 透明蒙版图
    let maskImage = UIImage(named: "IMG_pic_layer_advertmask")!
    /// 滚动视图
    let scrollView = UIScrollView(frame: CGRect.zero)
    /// 跑马灯
    let marquee = TSMarqueeLabel(frame: CGRect.zero)
    /// 分页指示器
    var pageControl = UIPageControl()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Custom user interface
    func setUI() {
        // scrollow view
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width / 2)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        // marquee
        marquee.isHidden = true
        pageControl.currentPage = 0

        addSubview(scrollView)
        addSubview(marquee)
        addSubview(pageControl)

        timer = Timer(timeInterval: timerInterval, target: self, selector: #selector(switchAdert), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }

    // MARK: - Button click

    /// 点击了广告
    func advertTaped(sender: TSButton) {
        let index = sender.tag - tagForAdvertButton
        print("点击了第\(index)个广告")
    }

    // MARK: - Private
    func switchAdert() {
        if models.count < 2 {
            timer?.fireDate = Date.distantFuture
            return
        }
        let nextIndex = Int(round(scrollView.contentOffset.x / frame.width)) + 1
        if nextIndex == models.count + 2 {
            scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
            scrollView.setContentOffset(CGPoint(x: 2 * frame.width, y: 0), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: CGFloat(nextIndex) * frame.width, y: 0), animated: true)
        }
    }

    // MARK: - Public

    /// 显示并设置跑马灯的内容
    public func showMarquee(model: String) {
        marquee.isHidden = false
        marquee.reSetTitle(title: model)
        scrollView.frame = CGRect(x: 0, y: marquee.frame.maxY, width: frame.width, height: frame.width / 2)
    }

    /// 隐藏跑马灯
    public func hiddenMarquee() {
        marquee.isHidden = true
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width / 2)
    }

    /// 设置广告的内容
    public func setModels(models: [TSAdvertBannerModel]) {
        self.models = models
        if models.isEmpty {
            return
        }
        scrollView.contentSize = CGSize(width: frame.width * CGFloat(models.count + 2), height: frame.height)
        // 设置 scrollow 子视图
        items = []
        for index in 0...models.count + 1 {
            // 创建广告按钮
            var item: TSAdvertItemView
            if index < items.count {
                item = items[index]
            } else {
                item = TSAdvertItemView(frame: CGRect(x: CGFloat(index) * frame.width, y: 0, width: frame.width, height: frame.height))
                items.append(item)
                // mask
                let maskView = UIImageView(frame:  CGRect(x: 0, y: scrollView.frame.height - maskImage.size.height, width: scrollView.frame.width, height: maskImage.size.height))
                maskView.image = maskImage
                item.addSubview(maskView)
            }
            // 创建标题 label
            var label: TSLabel
            if index < labels.count {
                label = labels[index]
            } else {
                label = TSLabel()
                label.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
                label.textColor = UIColor.white
                label.textAlignment = .left
                label.frame = CGRect(x: 14, y: item.frame.height - 30, width: item.frame.width - 14 - 71, height: 16)
                label.numberOfLines = 1
                labels.append(label)
            }
            // 设置广告视图和标题的内容
            var model: TSAdvertBannerModel?
            if index == 0 {
                model = models.last
            } else if index == models.count + 1 {
                model = models.first
            } else {
                model = models[index - 1]
            }
            item.set(model: model?.advertModel)
            label.text = model?.title

            if item.superview == nil {
                item.addSubview(label)
                scrollView.addSubview(item)
            }
        }
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        pageControl.numberOfPages = models.count
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let pageControlWidth: CGFloat = CGFloat(models.count) * 15
        // item.frame.height - 30
        pageControl.frame = CGRect(x: self.frame.width - pageControlWidth - 16, y: self.frame.height - 30, width: pageControlWidth, height: 16)
    }

    /// 启动动画
    public func startAnimation() {
        // 如果只有一张图片，就不滚动
        if models.count < 2 {
            scrollView.isScrollEnabled = false
            timer?.fireDate = Date.distantFuture
            return
        }
        scrollView.isScrollEnabled = true
        autoAnimaiton = true
        timer?.fireDate = Date(timeIntervalSinceNow: timerInterval)
    }

    /// 停止动画
    public func stopAnimation() {
        autoAnimaiton = false
        timer?.fireDate = Date.distantFuture
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        assert(!models.isEmpty, "没有传入 Banner 的 models")

        let maxIndex = models.count + 1
        let currentOffset = scrollView.contentOffset.x
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))

        // pageControl
        if pageControl.currentPage == currentIndex {
            return
        }
        if currentIndex == 0 {
            pageControl.currentPage = models.count - 1
        } else if currentIndex == maxIndex {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = currentIndex - 1
        }
        // scroll view
        if currentOffset > CGFloat(maxIndex) * frame.width { // 大于于倒数第二张时
            scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        }
        if currentOffset < frame.width {
            scrollView.setContentOffset(CGPoint(x: CGFloat(maxIndex) * frame.width, y: 0), animated: false)
        }
    }

    // 滚动视图被拖拽
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.fireDate = Date.distantFuture
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if autoAnimaiton {
            timer?.fireDate = Date(timeIntervalSinceNow: timerInterval)
        }
    }

}
