//
//  CropOverLayer.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/28.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

enum ImagePickerCropType {
    /// 正方形
    case squart
    /// 长方形
    case rectangle
}

class CropOverView: UIView {

    let cropTop = UIView()
    let cropBottom = UIView()
    let cropLeft = UIView()
    let cropRight = UIView()

    var cropRect: CGRect?

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
    private func setUI() {
        let color = UIColor(white: 1, alpha: 0.3)
        [cropTop, cropBottom, cropLeft, cropRight].forEach {
            $0.backgroundColor = color
            addSubview($0)
        }
    }

    /// 正方形布局
    private func squartLayout() {
        let space: CGFloat = 42
        let squartWidth = frame.width - space * 2

        cropLeft.frame = CGRect(x: 0, y: 0, width: space, height: frame.height)
        cropRight.frame = CGRect(x: frame.width - space, y: 0, width: space, height: frame.height)
        cropTop.frame = CGRect(x: space, y: 0, width: squartWidth, height: (frame.height - squartWidth) / 2)
        cropBottom.frame = CGRect(x: space, y: (frame.height - (frame.height - squartWidth) / 2), width: squartWidth, height: (frame.height - squartWidth) / 2)

        cropRect = CGRect(x: space, y: (frame.height - squartWidth) / 2, width: squartWidth, height: squartWidth)
    }

    /// 长方形布局
    private func rectangleLayout() {
        let height: CGFloat = frame.width / 2

        cropLeft.frame = CGRect.zero
        cropRight.frame = CGRect.zero
        cropTop.frame = CGRect(x: 0, y: 0, width: frame.width, height: (frame.height - height) / 2)
        cropBottom.frame = CGRect(x: 0, y: frame.height - (frame.height - height) / 2, width: frame.width, height: (frame.height - height) / 2)

        cropRect = CGRect(x: 0, y: (frame.height - height) / 2, width: frame.width, height: height)
    }

    // MARK: - Public

    /// 设置裁切类型
    func setCrop(type: ImagePickerCropType) {
        switch type {
        case .squart:
            squartLayout()
        case .rectangle:
            rectangleLayout()
        }
    }
}
