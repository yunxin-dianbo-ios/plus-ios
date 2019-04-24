//
//  GroupListCollectionCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class GroupListCollectionCell: UICollectionViewCell {

    static let identifier = "GroupListCollectionCell"
    // 圈子列表
    let table = GroupListActionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 45 - 64)), tableIdentifier: "")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        contentView.addSubview(table)
    }

    func reset(tableIdentifier: Int) {
        self.table.tableIdentifier = "\(tableIdentifier)"
    }

}
