//
//  TSNewsTagSelectReusableView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯投稿中标签选择中的头视图

import UIKit

class TSNewsTagSelectReusableView: UICollectionReusableView {
    // MARK: - Internal Property
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    // MARK: - Private Property
    fileprivate weak var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    func initialUI() -> Void {
        // title
        let lrMargin: Float = 15
        let label = UILabel(text: "", font: UIFont.systemFont(ofSize: 13), textColor: UIColor(hex: 0x999999))
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(lrMargin)
            make.trailing.equalTo(self).offset(-lrMargin)
        }
        self.titleLabel = label
    }
}
