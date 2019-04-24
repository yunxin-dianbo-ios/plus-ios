//
//  TSCertificatePreviewCollectionLayout.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSCertificatePreviewCollectionLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 1.定义常量
        let spacing: CGFloat = 5 // item 间隔

        // 2.计算item的宽度和高度,以及设置item的宽度和高度
        itemSize = CGSize(width: 100, height: 50)

        // 3.设置其他属性
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing
    }
}
