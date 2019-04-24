//
//  TSTransationTitleButton.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSTransationTitleButton: TSButton {

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame.origin.x = (titleLabel?.frame.width)! + 6
        titleLabel?.frame.origin.x = 2
    }

    // MARK: - Custom user interface

    func setUI() {
        setImage(UIImage(named: "IMG_ico_detail_arrowup"), for: .selected)
        setImage(UIImage(named: "IMG_ico_detail_arrowdown"), for: .normal)
        setTitleColor(TSColor.main.content, for: .normal)
        setTitle("显示_明细".localized, for: .normal)
    }
}
