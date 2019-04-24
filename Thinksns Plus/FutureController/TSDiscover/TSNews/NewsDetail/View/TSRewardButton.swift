//
//  TSRewardButton.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSRewardButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setBackgroundImage(UIImage.imageWithColor(TSColor.small.rewardText, cornerRadius: 4), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
