//
//  TSNewFriendsLabelView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  标签按钮视图
/*
 使用实例可参见 TSNewFriendsVC.setUI()
 */

import UIKit

@objc protocol TSTopLabelViewDelegate: class {
    @objc optional func topLabel(view: TSTopLabelView, didSelectedLabelAt index: Int, with title: String)
    @objc optional func topLabel(view: TSTopLabelView, animatedScrollViewDidScroll scrollowView: UIScrollView)
}

class TSTopLabelView: UIView, UIScrollViewDelegate {

    @IBOutlet var view: UIView!
    /// 蓝色短线的宽度
    @IBOutlet weak var blueLineWidth: NSLayoutConstraint!
    /// 蓝色短线的 x 坐标
    @IBOutlet weak var blueLineX: NSLayoutConstraint!
    /// 按钮数组
    var buttons: [UIButton] = []
    // 标签按钮之间的间隙
    var space: CGFloat {
        return (frame.width - CGFloat(titleArray.count) * blueLineWidth.constant) / CGFloat(titleArray.count + 1)
    }

    public weak var delegate: TSTopLabelViewDelegate?
    /// 标签点击事件
    public var tapOperation: ((Int, String) -> Void)?
    /// 标签 title 数组
    public var titleArray: [String] = [] {
        didSet {
            updateChildViews()
        }
    }
    /// 动画捆绑的 scrollView
    var animatedScrollView: UIScrollView? {
        didSet {
            animatedScrollView?.delegate = self
        }
    }

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "TSTopLabelView", bundle: nil).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }

    // MARK: - Custom user interface
    /// 更新子视图
    func updateChildViews() {
        // 1.移除旧的按钮
        let _ = buttons.map { $0.removeFromSuperview() }
        // 2.增加新的按钮
        for title in titleArray {
            let index = Int(titleArray.index(of: title)!)
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(TSColor.main.content, for: .selected)
            button.setTitleColor(TSColor.normal.minor, for: .normal)
            button.addTarget(self, action: #selector(buttonTaped(_:)), for: .touchUpInside)
            button.frame = CGRect(x: space + CGFloat(index) * (space + blueLineWidth.constant), y: 0, width: blueLineWidth.constant, height: frame.height)
            addSubview(button)
            buttons.append(button)
        }
        // 3.默认选中第一个
        buttons[0].isSelected = true
        blueLineX.constant = space
        setNeedsLayout()
        layoutIfNeeded()
    }

    /// 更新按钮
    func updateButton(at index: Int) {
        let _ = buttons.map { $0.isSelected = false }
        buttons[index].isSelected = true
    }

    // MARK: - Button click
    func buttonTaped(_ sender: UIButton) {
        let index = Int(buttons.index(of: sender)!)
        let title = (sender.titleLabel?.text)!
        // 更新界面
        setSelected(index: index)
        // 启动 block 和代理
        tapOperation?(index, title)
        delegate?.topLabel?(view: self, didSelectedLabelAt: index, with: title)
    }

    // MARK: - Public

    /// 设置代理事件
    public func setTape(operation: ((Int, String) -> Void)?) {
        tapOperation = operation
    }

    /// 设置选中某个标签
    public func setSelected(index: Int) {
        // 滚动 scrollView
        if animatedScrollView != nil {
            animatedScrollView?.setContentOffset(CGPoint(x: CGFloat(index) * (animatedScrollView?.frame.width)!, y: 0), animated: true)
        }
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = scrollView.contentOffset.x / scrollView.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > titleArray.count {
            index = CGFloat(titleArray.count)
        }
        let i = round(index)
        updateButton(at: Int(i))
        blueLineX.constant = CGFloat(index) * (blueLineWidth.constant + space) + space
        setNeedsLayout()
        layoutIfNeeded()
        // 收起键盘
        TSKeyboardToolbar.share.keyboarddisappear()
        // 代理调用
        delegate?.topLabel?(view: self, animatedScrollViewDidScroll: scrollView)
    }
}
