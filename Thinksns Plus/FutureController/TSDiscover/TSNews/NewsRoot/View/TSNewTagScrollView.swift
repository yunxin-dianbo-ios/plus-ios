//
//  TSNewTagScrollView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSNewTagScrollViewDelegate: class {
    func selectedTag(WithTagIndex index: Int)
}

class TSNewTagScrollView: UIView {
    /// 代理
    weak var delegate: TSNewTagScrollViewDelegate? = nil
    /// 保存添加在scrollview上的按钮控件
    var buttonArr: [TSNewsTagButton] = []
    /// 当前选中的按钮
    var selectedButton: TSNewsTagButton? = nil
    /// 滑动视图
    var tagScrollView: UIScrollView? = nil

// MARK: - lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.createScrollView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - UI
    func createScrollView() {
        self.tagScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.tagScrollView?.backgroundColor = .white
        self.tagScrollView?.showsVerticalScrollIndicator = false
        self.tagScrollView?.showsHorizontalScrollIndicator = false
        self.addSubview(self.tagScrollView!)
    }

    func updateTags(WithTags tags: [TSNewsTagObject]) {

        for view in (self.tagScrollView?.subviews)! {
            if view.tag >= 100 {
                view.removeFromSuperview()
            }
        }
        self.buttonArr.removeAll()

        var lastButtonMaxX: CGFloat = 0
        var tag: Int = 0
        for object in tags {
            let buttonWidth = TSNewsTagButton.caculateButtonWidth(WithTitle: object.name)
            let titleButton = TSNewsTagButton(frame: CGRect(x: lastButtonMaxX, y: 0, width: buttonWidth, height: 1), title: object.name)
            titleButton.tag = tag + 100
            if tag == 0 {
                /// 默认选中第一个按钮 【“推荐”】
                titleButton.setTitleColor(TSNewsTagButtonUX.selectedTitleColor, for: UIControlState.normal)
                titleButton.titleLabel?.font = TSNewsTagButtonUX.selectedTitleFont
                self.selectedButton = titleButton
            }
            titleButton.addTarget(self, action: #selector(buttonClicked(button:)), for: UIControlEvents.touchUpInside)
            lastButtonMaxX += buttonWidth
            tag += 1
            self.tagScrollView!.addSubview(titleButton)
            self.buttonArr.append(titleButton)
        }
        self.tagScrollView?.contentSize = CGSize(width: lastButtonMaxX, height: 0)
        /// 重新布局后  重置偏移量
        self.tagScrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

// MARK: - actions 
    func buttonClicked(button: TSNewsTagButton) {
        if self.delegate != nil {
            self.delegate?.selectedTag(WithTagIndex: button.tag - 100)
        }
        self.recordSelectedButton(button: button)
    }
// MARK: - public

    /// 根据传入的scrollview偏移量来设置标题按钮的样式
    ///
    /// - Parameter xPoint: 列表底部滑动Scrollview的偏移量
    func setTitleButtonStyle(WithContentOffSetXPoint xPoint: CGFloat) {
        /**
         *  注意： 下文中的nextButton统一代指当前选中按钮右边的按钮
         **/

        /// ※ scrollview的水平偏移量与屏幕宽度的比值
        let ScaleValue = xPoint / ScreenSize.ScreenWidth
        /// 当前选中的按钮角标 （去掉了ScaleValue小数点后的数值）
        let currentIndex = Int(ScaleValue)
        /// 位于当前选中的按钮右边的按钮的角标
        let nextIndex = currentIndex + 1

        /// 当前选中的按钮
        let currentButton = self.buttonArr[currentIndex]
        /// 右边的按钮 (可能为空)
        var nextButton: TSNewsTagButton? = nil
        if nextIndex < self.buttonArr.count {
            nextButton = self.buttonArr[nextIndex]
        }

        let currentStyleScale = ScaleValue - CGFloat(currentIndex)
        let nextStyleScale = 1 - currentStyleScale

        let currentFontSize = TSNewsTagButtonUX.normalTitleFont.pointSize + ((TSNewsTagButtonUX.selectedTitleFont.pointSize - TSNewsTagButtonUX.normalTitleFont.pointSize) * nextStyleScale)
        let titleColor = UIColor(red: (51 + ((178 - 51) * currentStyleScale)) / 255, green: (51 + ((178 - 51) * currentStyleScale)) / 255, blue: (51 + ((178 - 51) * currentStyleScale)) / 255, alpha: 1.0)
        currentButton.titleLabel?.font = UIFont.systemFont(ofSize: currentFontSize)
        currentButton.setTitleColor(titleColor, for: UIControlState.normal)

        let nextFontSize = TSNewsTagButtonUX.normalTitleFont.pointSize + ((TSNewsTagButtonUX.selectedTitleFont.pointSize - TSNewsTagButtonUX.normalTitleFont.pointSize) * currentStyleScale)
        let titleColorNext = UIColor(red: (51 + ((178 - 51) * nextStyleScale)) / 255, green: (51 + ((178 - 51) * nextStyleScale)) / 255, blue: (51 + ((178 - 51) * nextStyleScale)) / 255, alpha: 1.0)
        nextButton?.titleLabel?.font = UIFont.systemFont(ofSize: nextFontSize)
        nextButton?.setTitleColor(titleColorNext, for: UIControlState.normal)
    }

    /// 根据传入的scrollview的偏移量来确定选中标题的位置
    ///
    /// - Parameter xPoint: 水平偏移量
    func setButtonOffSet(scrollViewContentOffSetX xPoint: CGFloat) {
        /// ※ scrollview的水平偏移量与屏幕宽度的比值
        let ScaleValue = xPoint / ScreenSize.ScreenWidth
        /// 当前选中的按钮角标 （去掉了ScaleValue小数点后的数值）
        let currentIndex = Int(ScaleValue)

        /// 当前选中的按钮
        let currentButton = self.buttonArr[currentIndex]
        self.selectedButton = currentButton
        self.moveSelectedButtonToCenter(currentButton: currentButton)
    }
// MARK: - private
    func recordSelectedButton(button: TSNewsTagButton) {
        if self.selectedButton == nil {
            button.setTitleColor(TSNewsTagButtonUX.selectedTitleColor, for: UIControlState.normal)
            button.titleLabel?.font = TSNewsTagButtonUX.selectedTitleFont
            self.selectedButton = button
        } else if self.selectedButton != nil && self.selectedButton == button {
            button.setTitleColor(TSNewsTagButtonUX.selectedTitleColor, for: UIControlState.normal)
            button.titleLabel?.font = TSNewsTagButtonUX.selectedTitleFont
        } else if self.selectedButton != nil && self.selectedButton != button {
            self.selectedButton?.setTitleColor(TSNewsTagButtonUX.normalTitleColor, for: UIControlState.normal)
            self.selectedButton?.titleLabel?.font = TSNewsTagButtonUX.normalTitleFont
            button.setTitleColor(TSNewsTagButtonUX.selectedTitleColor, for: UIControlState.normal)
            button.titleLabel?.font = TSNewsTagButtonUX.selectedTitleFont
            self.selectedButton = button
        }
        self.moveSelectedButtonToCenter(currentButton: button)
    }
    /// 将选中的按钮居中
    func moveSelectedButtonToCenter(currentButton: TSNewsTagButton) {
        if (self.tagScrollView?.contentSize.width)! <= self.frame.width {
            return
        }
        var offsetX = currentButton.center.x - ((self.tagScrollView?.frame.width)! / 2)

        if offsetX < 0 {
            offsetX = 0
        }
        let maxOffsetX = (self.tagScrollView?.contentSize.width)! - (self.tagScrollView?.frame.width)!
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        self.tagScrollView?.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}
