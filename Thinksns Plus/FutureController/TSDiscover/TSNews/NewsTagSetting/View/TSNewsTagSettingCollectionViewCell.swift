//
//  TSNewsTagSettingCollectionViewCell.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

enum TSNewsTagCellBgType {
    /// 正常的背景
    case normal
    /// 选中的背景，注：该状态根本就没有使用
    case selected
    /// 可编辑时的背景，注：该状态根本就没有使用
    case editable
    /// 推荐 的 可编辑状态
    case recommendEditable
    /// 推荐 的 正常状态
    case recommendNormal
}

class TSNewsTagSettingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deletImg: UIImageView!
    /// 是否在移动
    var isMoveing: Bool = false
    /// 是否可以编辑
    var canEdite: Bool = false
    /// 文章标题
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    /// 背景色，根据不同状态类进行配置。发生背景色的重用异常时，请使用这里。当前页面中无需重用，可不使用。
    var bgType: TSNewsTagCellBgType = .normal {
        didSet {
            var bgColor = UIColor(hex: 0xf5f5f5)
            switch bgType {
            case .normal:
                bgColor = UIColor(hex: 0xf5f5f5)
            case .recommendEditable:
                bgColor = UIColor.clear
            case .recommendNormal:
                bgColor = TSColor.main.theme.withAlphaComponent(0.15)
            default:
                break
            }
            self.titleLabel.backgroundColor = bgColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.titleLabel.backgroundColor = TSColor.inconspicuous.background
    }

    func updateData(title: String) {
        self.titleLabel.text = title
    }

    func setMoveStatus(isMoveing: Bool) {
        self.isMoveing = isMoveing
        if self.isMoveing {
            self.backgroundColor = UIColor.clear
            self.titleLabel.backgroundColor = UIColor.clear
            self.titleLabel.textColor = UIColor.clear
            self.deletImg.isHidden = true
        } else {
            self.backgroundColor = UIColor.clear
            self.titleLabel.backgroundColor = TSColor.inconspicuous.background
            self.titleLabel.textColor = TSColor.normal.blackTitle
            self.deletImg.isHidden = false
        }
    }

    func setEditEnable(canEdite: Bool) {
        self.canEdite = canEdite
        self.canEdite ? (self.deletImg.isHidden = false) : (self.deletImg.isHidden = true)
    }

    func defaultTypeForFirstItem(isEdit: Bool) {
        self.deletImg.isHidden = true
        if isEdit {
            self.titleLabel.backgroundColor = .clear
            self.titleLabel.textColor = TSColor.normal.blackTitle
        } else {
            self.titleLabel.backgroundColor = TSColor.main.theme.withAlphaComponent(0.15)
            self.titleLabel.textColor = TSColor.normal.blackTitle
        }
    }
}
