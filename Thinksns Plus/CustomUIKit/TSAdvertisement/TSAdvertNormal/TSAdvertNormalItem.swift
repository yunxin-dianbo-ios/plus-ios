//
//  TSAdvertNormalItem.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSAdvertNormalItem: UICollectionViewCell {

    /// 重用 id
    static let identifier = "TSAdvertNormalItem"
    /// 广告视图
    @IBOutlet weak var advertView: TSAdvertItemView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(info: TSAdvertViewModel) {
        advertView.displayFrame = bounds
        advertView.set(model: info)
    }
}
