//
//  AlbumCollectionToolbar.swift
//  ImagePicker
//
//  Created by GorCat on 2017/7/3.
//  Copyright © 2017年 GorCat. All rights reserved.
//
//  collection 的工具栏

import UIKit

class AlbumCollectionToolbar: UIView {

    /// 预览按钮
    var buttonForPreview = UIButton(type: .custom)
    /// 完成按钮
    var buttonForFinish = UIButton(type: .custom)
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

        // 2.预览按钮
        buttonForPreview.frame = CGRect(x: 0, y: 0, width: 50, height: frame.height)
        buttonForPreview.setTitle("预览", for: .normal)
        buttonForPreview.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        buttonForPreview.setTitleColor(UIColor.black, for: .normal)

        // 3.分割线
        let separator = UIView(frame: CGRect(origin: .zero, size: CGSize(width: frame.width, height: 1)))
        separator.backgroundColor = UIColor.gray

        addSubview(separator)
        addSubview(buttonForFinish)
        addSubview(buttonForPreview)
    }

}
