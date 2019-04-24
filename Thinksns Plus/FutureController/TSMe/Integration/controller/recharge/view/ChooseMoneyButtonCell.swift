//
//  ChooseMoneyButtonCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2018/1/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class ChooseMoneyButtonCell: UICollectionViewCell {

    static let identifier = "ChooseMoneyButtonCell"

    let moneyButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        contentView.addSubview(moneyButton)
    }

    func set(buttonTitle title: String, isSelected: Bool) {
        let buttonWidth = (UIScreen.main.bounds.width - 15 * 4) / 3
        moneyButton.frame = CGRect(x: 7.5, y: 7.5, width: buttonWidth, height: 35)
        moneyButton.setTitle(title, for: .normal)
        moneyButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        moneyButton.setTitleColor(TSColor.main.theme, for: .selected)
        moneyButton.isSelected = isSelected
        moneyButton.layer.borderWidth = 1
        moneyButton.layer.cornerRadius = 3
        moneyButton.clipsToBounds = true
        moneyButton.isUserInteractionEnabled = false
        if isSelected {
            moneyButton.layer.borderColor = TSColor.main.theme.cgColor
        } else {
            moneyButton.layer.borderColor = UIColor(hex: 0xdedede).cgColor
        }
    }
}
