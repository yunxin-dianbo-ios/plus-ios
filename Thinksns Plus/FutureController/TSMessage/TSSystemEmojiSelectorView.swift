//
//  TSSystemEmojiSelectorView.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/9/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON
protocol TSSystemEmojiSelectorViewDelegate: class {
    func emojiViewDidSelected(emoji: String)
}
class TSSystemEmojiSelectorView: UIView, UIScrollViewDelegate {
    private var pageContrl = UIPageControl()
    private let scrollView = UIScrollView()
    /// 默认行数
    private let lines: Int = 3
    /// 默认单页列数
    private let columns: Int = 7
    /// 备注: emojiContentViewHeight + pageControlHeight 修改了就必须要修改 TSKeyboardToolbar 类里面 的 emojiHeight 和 toolBarHeight 两个属性里面的 145 (130+15)、以及 TSTextToolBarView 类里面 emojiViewHeight属性 和 scrollMaxHeight 属性 里面 145 (130+15) 的值
    private var emojiContentViewHeight: CGFloat = 130
    private let pageControlHeight: CGFloat = 15
    private var totalHeight: CGFloat = 0
    /// emoji数据
    var emojis: [String] = []
    /// 是否在屏幕中显示
    var isShow: Bool = false
    /// 默认开启对底部安全区域的支持
    var shouldKeepBottomSafeArea = true {
        didSet {
            // 关闭了安全区域调整高度
            if shouldKeepBottomSafeArea == false {
                if emojiContentViewHeight + pageControlHeight != self.height {
                    totalHeight = emojiContentViewHeight + pageControlHeight
                    self.height = totalHeight
                    self.updataUI()
                }
            }
        }
    }
    weak var delegate: TSSystemEmojiSelectorViewDelegate?
    var didSelectedEmojiBlock: ((String) -> Void)?
    override init(frame: CGRect) {
        totalHeight = emojiContentViewHeight + pageControlHeight + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight()
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: totalHeight))
        initData()
        creatView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initData() {
        if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "emoji", ofType: "json")!)), let d = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers), let emojiArray = d as? NSArray {
            for item in emojiArray {
                if let itemDic = item as? NSDictionary {
                    emojis.append(itemDic.allKeys[0] as! String)
                }
            }
        } else {
            TSLogCenter.log.debug("\n\n没有找到emoji.json\n\n")
        }
    }
    private func creatView() {
        let didTap = UITapGestureRecognizer(target: self, action: #selector(didTapSelf))
        self.addGestureRecognizer(didTap)
        backgroundColor = UIColor(hex: 0xECEFF3)
        pageContrl.pageIndicatorTintColor = UIColor.gray
        pageContrl.currentPageIndicatorTintColor = UIColor.white
        pageContrl.numberOfPages = emojis.count / (lines * columns) + (emojis.count % (lines * columns) > 0 ? 1 : 0)
        pageContrl.frame = CGRect(x: (self.width - 120) / 2.0, y: self.height - pageControlHeight - TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: 120, height: pageControlHeight)
        pageContrl.addTarget(self, action: #selector(pageControlDidChange), for: UIControlEvents.valueChanged)
        scrollView.isPagingEnabled = true
        scrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.emojiContentViewHeight)
        scrollView.contentSize = CGSize(width: self.width * CGFloat(pageContrl.numberOfPages), height: 0)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        let emojiLabWidth: CGFloat = 45
        let emojiLabHeight: CGFloat = 30
        let spaceX: CGFloat = (self.width - emojiLabWidth * CGFloat(columns)) / CGFloat(columns + 1)
        let spaceY: CGFloat = 11
        let offsetX: CGFloat = scrollView.width
        for (index, emoji) in emojis.enumerated() {
            let emojiLab = UILabel()
            let tap = UITapGestureRecognizer(target: self, action: #selector(emojiDidTap(tap:)))
            emojiLab.isUserInteractionEnabled = true
            emojiLab.addGestureRecognizer(tap)
            emojiLab.textAlignment = .center
            emojiLab.font = UIFont.systemFont(ofSize: 28)
            emojiLab.text = emoji
            let xx: CGFloat = offsetX * CGFloat(index / (columns * lines)) + spaceX * CGFloat(index % columns + 1) + emojiLabWidth * CGFloat(index % columns)
            let yy: CGFloat = spaceY * CGFloat(index % (columns * lines) / columns + 1) + emojiLabHeight * CGFloat(index % (columns * lines) / columns)
            emojiLab.frame = CGRect(x: xx, y: yy, width: emojiLabWidth, height: emojiLabHeight)
            scrollView.addSubview(emojiLab)
        }
        addSubview(scrollView)
        addSubview(pageContrl)
    }
    func updataUI() {
        pageContrl.frame = CGRect(x: (self.width - 120) / 2.0, y: self.height - 15, width: 120, height: 15)
    }
    func pageControlDidChange() {
        scrollView.setContentOffset(CGPoint(x: CGFloat(pageContrl.currentPage) * scrollView.width, y: 0), animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageContrl.currentPage = Int(scrollView.contentOffset.x / scrollView.width)
    }
    // 拦截自己的点击事件
    func didTapSelf() {
        TSLogCenter.log.debug("点击了emoji的背景")
    }
    func emojiDidTap(tap: UITapGestureRecognizer) {
        let emojiLab = tap.view as? UILabel
        if let tapBlock = self.didSelectedEmojiBlock {
            tapBlock((emojiLab?.text)!)
        } else {
            delegate?.emojiViewDidSelected(emoji: (emojiLab?.text)!)
        }
        TSLogCenter.log.debug(emojiLab?.text)
    }
    // MARK: - Delegate
    func showEmojiView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: (self.superview?.height)! - self.height, width: self.width, height: self.height)
        }) { (success) in
            self.isShow = true
        }
        let userInfo = ["UIKeyboardAnimationDurationUserInfoKey": 0.25, "UIKeyboardFrameEndUserInfoKey": CGRect(x: 0, y: 0, width: self.width, height: self.height)] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillShow, object: nil, userInfo: userInfo)
    }
    func hidenEmojiView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: (self.superview?.height)!, width: self.width, height: self.height)
        }) { (success) in
            self.isShow = false
        }
//        let userInfo = ["UIKeyboardAnimationDurationUserInfoKey": 0.25, "UIKeyboardFrameEndUserInfoKey": CGRect(x: 0, y: (self.superview?.height)!, width: self.width, height: self.height)] as [String : Any]
//        NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil, userInfo: userInfo)
//
    }
}
