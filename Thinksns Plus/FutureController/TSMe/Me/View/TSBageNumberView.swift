//
//  TSBageNumberView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  小红点,初始化size请使用bageViewBouds

import UIKit

enum bageViewBouds: CGFloat {
    case Width = 22
    case Height = 14
}

class TSBageNumberView: UIView {

    let view = UIView()
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {

        view.backgroundColor = TSColor.main.warn
        view.layer.cornerRadius = bageViewBouds.Height.rawValue / 2.0
        view.clipsToBounds = true

        label.font = UIFont.systemFont(ofSize: TSFont.UserName.comment.rawValue)
        label.textColor = TSColor.normal.background
        label.textAlignment = .center

        self.addSubview(view)
        view.addSubview(label)

        view.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(self)
            make.right.equalTo(self).offset(-bageViewBouds.Height.rawValue)
        }

        label.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }

        view.isHidden = true
    }

    // MARK: - 设置小红点数字
    /// 改变小红点的数字，最大显示99，并且大于0的时候才显示
    public func setlabelNumbers(_ number: Int) {
        let str = "\(number)"
        if number > 0 && number < 99 {
            view.isHidden = false
            label.text = str
            if number > 9 {
                label.text = str
                view.snp.updateConstraints({ (make) in
                    make.top.left.bottom.right.equalTo(self)
                })
            } else {
                view.snp.updateConstraints({ (make) in
                    make.top.left.bottom.equalTo(self)
                    make.right.equalTo(self).offset(-7)
                })
            }
        } else {
            view.isHidden = true
        }
    }
}
