//
//  TSImageButton.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图标类型按钮
//  此类按钮多用于顶部标题栏左右两侧、列表右侧。
//  此类按钮内部只设定了 size，请使用 orignal 或者 center 设定其位置。
//  综上，其他属性按 UIButton 类型照常使用即可。

import UIKit

private struct TSImageButtonUX {
    static let ButtonWidth: CGFloat = 44
    static let ButtonHeifht: CGFloat = 44
}

class TSImageButton: TSButton {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.minX, y: frame.minY, width: TSImageButtonUX.ButtonWidth, height: TSImageButtonUX.ButtonHeifht))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        setImageButtonUX()
        super.draw(rect)
    }

    func setImageButtonUX() {
        self.frame.size = CGSize(width: TSImageButtonUX.ButtonWidth, height: TSImageButtonUX.ButtonHeifht)
    }

}
