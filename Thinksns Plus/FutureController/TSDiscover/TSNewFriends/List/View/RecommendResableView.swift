//
//  RecommendResableView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/6/21.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class RecommendResableView: UICollectionReusableView {
    let titleLabel = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = TSColor.normal.minor
        self.titleLabel.text = "推荐好友"
        self.addSubview(self.titleLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.centerY = self.centerY
        self.titleLabel.mj_x = 15
        self.titleLabel.sizeToFit()
    }
}
