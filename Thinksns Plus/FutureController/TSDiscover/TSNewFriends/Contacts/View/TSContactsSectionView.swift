//
//  TSContactsSectionView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSContactsSectionView: UIView { // TODO: 改成 ReuseHeaderFooterView
    @IBOutlet var view: UIView!
    @IBOutlet weak var arrowsImageView: UIImageView!

    /// 标题
    @IBOutlet weak var label: UILabel!
    /// 更多按钮
    @IBOutlet weak var button: UIButton!

    var moreButtonOperation: ((String) -> Void)?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "TSContactsSectionView", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
    }
    // MARK: - IBAction

    /// 更多按钮点击事件
    @IBAction func buttonTaped(_ sender: Any) {
        let title = label.text!
        moreButtonOperation?(title)
    }
}
