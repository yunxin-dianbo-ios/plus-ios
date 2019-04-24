//
//  TSLabelControl.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  本身是UIControl，但内部含有一个UILabel，且该Label的内边距与本Control对齐。
//  比较类似UIButton，
//  该控件应重新构造，将Label完全独立出来

import Foundation

class TSLabelControl: UIControl {

    // MARK: - Internal Property
    var title: String? {
        didSet {
            self.label.text = title
        }
    }

    // MARK: - Private Property
    private(set) weak var label: UILabel!
    fileprivate let font: UIFont!
    fileprivate let textColor: UIColor!

    // MARK: - Initialize Function

    init(font: UIFont, textColor: UIColor) {
        self.font = font
        self.textColor = textColor
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    // MARK: - Private  UI

    private func initialUI() -> Void {
        let label = UILabel(text: "", font: self.font, textColor: self.textColor, alignment: .center)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            //make.edges.equalTo(self)
            make.leading.equalTo(self).offset(1)
            make.trailing.equalTo(self).offset(-1)
            make.top.equalTo(self).offset(1)
            make.bottom.equalTo(self).offset(-1)
        }
        self.label = label
    }

    // MARK: - Private  数据

    // MARK: - Private  事件响应

}
