//
//  GroupListRightNavView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class GroupListRightNavView: UIView {

    /// 搜索按钮
    let searchButton = UIButton(type: .custom)
    /// 创建圈子按钮
    let buildButton = UIButton(type: .custom)

    init() {
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    func setUI() {
        // 1.搜索按钮
        searchButton.setImage(UIImage(named: "IMG_ico_search"), for: .normal)
        searchButton.sizeToFit()

        // 2.创建圈子按钮
        buildButton.setImage(UIImage(named: "IMG_ico_createcircle"), for: .normal)
        buildButton.sizeToFit()

        // 3.计算 frame
        addSubview(searchButton)
        addSubview(buildButton)
        searchButton.frame = CGRect(origin: .zero, size: searchButton.size)
        buildButton.frame = CGRect(origin: CGPoint(x: searchButton.frame.maxX + 12, y: 0), size: buildButton.size)
        frame = CGRect(origin: .zero, size: CGSize(width: buildButton.frame.maxX, height: buildButton.frame.height))
    }
}
