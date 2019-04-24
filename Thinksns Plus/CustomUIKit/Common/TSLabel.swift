//
//  TSLabel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  基类

import UIKit

class TSLabel: UILabel {

    // MARK: - lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: - setup
    func setupUI() {

    }
}
