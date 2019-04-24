//
//  RankListHeaderImageView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
// 
//  实现了圆角的头像ImageView

import UIKit

class TSRankListHeaderImageView: TSImageView {

    init() {
         super.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.draw(frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
      self.layer.mask = TSRankingListTool().drawCorner(corner: self.bounds.size.width / 2, rect: self.bounds)
    }
}
