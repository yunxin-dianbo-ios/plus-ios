//
//  rankNumberView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  显示排名的View

import UIKit
import SnapKit

class TSRankNumberView: UIView {

    /// 需要传入的名次
    var numberStr: String?
    var showNumberLabel: UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)

        showNumberLabel = TSLabel()
        showNumberLabel?.textColor = UIColor.black
        showNumberLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.addSubview(showNumberLabel!)
        showNumberLabel?.snp.makeConstraints({ make in
            make.center.equalTo(self)
        })

        let leftLabel = TSLabel()
        leftLabel.text = "-"
        leftLabel.textColor = TSColor.normal.disabled
        leftLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.right.equalTo((showNumberLabel?.snp.left)!)
            make.centerY.equalTo((showNumberLabel?.snp.centerY)!)
        }

        let rightLabel = TSLabel()
        rightLabel.text = "-"
        rightLabel.textColor = TSColor.normal.disabled
        rightLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo((showNumberLabel?.snp.right)!)
            make.centerY.equalTo((showNumberLabel?.snp.centerY)!)
        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        showNumberLabel?.text = numberStr
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
