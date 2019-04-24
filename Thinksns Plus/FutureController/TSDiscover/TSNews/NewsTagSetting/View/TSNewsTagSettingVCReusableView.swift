//
//  TSNewsTagSettingVCReusableView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct TSNewsTagSettingVCReusableViewUX {
    static let textLeftSpace: CGFloat = 15
    static let textFontSize: CGFloat = 13
    static let textColor = TSColor.normal.secondary
}

class TSNewsTagSettingVCReusableView: UICollectionReusableView {

    let titleLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.titleLabel.frame = CGRect(x: TSNewsTagSettingVCReusableViewUX.textLeftSpace, y: self.frame.height / 2, width: ScreenSize.ScreenWidth - TSNewsTagSettingVCReusableViewUX.textLeftSpace, height: self.frame.height / 2)
        self.titleLabel.font = UIFont.systemFont(ofSize: TSNewsTagSettingVCReusableViewUX.textFontSize)
        self.titleLabel.textColor = TSNewsTagSettingVCReusableViewUX.textColor
        self.addSubview(self.titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(text: String) {
        self.titleLabel.text = text
    }
}
