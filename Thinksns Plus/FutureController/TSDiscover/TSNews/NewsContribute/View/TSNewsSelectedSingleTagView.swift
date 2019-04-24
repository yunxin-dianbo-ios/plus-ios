//
//  TSNewsSelectedSingleTagView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 16/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯模块中选中的单个标签视图
//  之后根据需要，若能公用，则可重命名为TSSelectedSingleTagView

import UIKit

class TSNewsSelectedSingleTagView: UIControl {

    // MARK: - Internal Property
    var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }

    // MARK: - Private Property
    private weak var titleLabel: UILabel!
    static private let font = UIFont.systemFont(ofSize: 12)

    // MARK: - Internal Function
    /// 根据文字获取宽度
    class func widthWithTitle(_ title: String, lrMargin: Float = 10) -> Float {
        let size = title.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: TSNewsSelectedSingleTagView.font)
        return Float(size.width) + lrMargin * 2.0
    }

    // MARK: - Initialize Function
    init(title: String = "") {
        self.title = title
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.layer.cornerRadius = 2
        self.backgroundColor = UIColor(hex: 0xf4f5f5)
        // titleLabel
        let label = UILabel(text: self.title, font: TSNewsSelectedSingleTagView.font, textColor: UIColor(hex: 0x333333), alignment: .center)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
        self.titleLabel = label
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
