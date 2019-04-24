//
//  PHPreviewToolbar.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/30.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

class PHPreviewToolbar: UIView {

    let img_unselect = "ico_edit_choose_32"
    let img_selected = "ico_edit_chosen_32"

    /// 选择按钮
    let buttonForChoose = UIButton(type: .custom)

    /// 完成按钮
    let buttonForFinish = UIButton(type: .custom)

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = UIColor.white

        // 1.完成按钮
        buttonForFinish.setTitleColor(UIColor.white, for: .normal)
        buttonForFinish.setBackgroundImage(UIImage.create(with: TSColor.normal.disabled, size: CGSize(width: 70, height: 30)), for: .disabled)
        buttonForFinish.setBackgroundImage(UIImage.create(with: TSColor.main.theme, size: CGSize(width: 70, height: 30)), for: .normal)
        buttonForFinish.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        buttonForFinish.layer.cornerRadius = 5
        buttonForFinish.clipsToBounds = true
        buttonForFinish.frame = CGRect(x: frame.width - 70 - 9, y: (frame.height - 30) / 2, width: 70, height: 30)

        // 2.选择按钮
        buttonForChoose.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        buttonForChoose.setTitleColor(UIColor.black, for: .normal)
        buttonForChoose.frame = CGRect(x: 7, y: (frame.height - 20) / 2, width: 61, height: 20)
        buttonForChoose.setTitle("选择", for: .normal)
        buttonForChoose.setImage(UIImage(named: img_selected), for: .selected)
        buttonForChoose.setImage(UIImage(named: img_unselect), for: .normal)
        // 初始化的时候就选中
        buttonForChoose.isSelected = true
        // 3.分割线
        let separator = UIView(frame: CGRect(origin: .zero, size: CGSize(width: frame.width, height: 0.5)))
        separator.backgroundColor = TSColor.inconspicuous.disabled

        addSubview(separator)
        addSubview(buttonForChoose)
        addSubview(buttonForFinish)
    }

}
