//
//  TSHomeBarView.swift
//  ThinkSNS +
//
//  Created by LeonFa on 2017/5/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  首页 tabBar

import UIKit

protocol TSHomeBarViewDelegate: NSObjectProtocol {

    /// 点击首页bar
    func touchHomeButton(index: Int)

    // MARK: - 发布动态
    func releaseMoment()

    // 发布纯文字动态
    func centerButtonTaped()
}

class TSHomeBarView: UIView {

    /// 当前按钮
    var cuttentButton: UIButton?
    /// tabBar高度
    let tabBarHeight: CGFloat = 49
    /// 代理
    weak var delegate: TSHomeBarViewDelegate?
    /// tag偏移量
    let buttonTagOffset = 200
    /// 图片
    let images = [("IMG_common_ico_bottom_home_high", "IMG_common_ico_bottom_home_normal"), ("IMG_common_ico_bottom_discover_high", "IMG_common_ico_bottom_discover_normal"), ("IMG_common_ico_bottom_message_high", "IMG_common_ico_bottom_message_normal"), ("IMG_common_ico_bottom_me_high", "IMG_common_ico_bottom_me_normal")]
    /// 文字
    let titles = ["首页", "发现", "消息", "我"]

    /// life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.inconspicuous.tabBar
        var buttonArr: [UIButton] = Array()
        for (index, title) in titles.enumerated() {
            let button = TSHomeButton(selectedImage: UIImage(named: images[index].0)!, normalImage: UIImage(named: images[index].1)!, title: title)
            button.tag = index + buttonTagOffset
            button.addTarget(self, action: #selector(touchHomeButton(_:)), for: .touchUpInside)
            buttonArr.append(button)
        }

        let releaseButton = TSButton(type: .custom)
        releaseButton.setImage(UIImage(named: "IMG_common_ico_bottom_add"), for: .normal)
        releaseButton.addTarget(self, action: #selector(releaseMoment), for: .touchUpInside)
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(centerButtonTaped))
        longTouch.minimumPressDuration = 1
        releaseButton.addGestureRecognizer(longTouch)
        buttonArr.insert(releaseButton, at: 2)

        for (index, item) in buttonArr.enumerated() {
            let width = UIScreen.main.bounds.size.width / CGFloat(buttonArr.count)
            item.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: tabBarHeight)
            self.addSubview(item)
        }
    }

    // MARK: - 发布动态
    func releaseMoment() {
        self.delegate?.releaseMoment()
    }

    // 发布纯文字动态
    func centerButtonTaped() {
        self.delegate?.centerButtonTaped()
    }

    // MARK: - 选择
    func touchHomeButton(_ button: UIButton) {
        cuttentButton?.isSelected = false
        button.isSelected = true
        cuttentButton = button
        self.delegate?.touchHomeButton(index: button.tag - buttonTagOffset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
