//
//  TSSectionNormal.swift
//  date
//
//  Created by Fiction on 2017/7/28.
//  Copyright © 2017年 段泽里. All rights reserved.
//
// 默认的样子，左边是这行的功能名字，右边是用户输入框

import UIKit

enum TSBindingLeftLabel: CGFloat {
    case Width = 47
}

class TSSectionNormal: UIView {
    var labelText = ""
    var userInputPlaceholder = ""
    var lineIsHidden = false

    let leftLabel: TSAccountLabel = TSAccountLabel()
    let userInput: TSAccountTextField = TSAccountTextField()
    let line: TSSeparatorView = TSSeparatorView()

    init(frame: CGRect, labelText: String!, userInputPlaceholder: String!, lineIsHidden: Bool?) {
        super.init(frame: frame)
        self.labelText = labelText
        self.userInputPlaceholder = userInputPlaceholder
        self.lineIsHidden = lineIsHidden ?? false
        self.backgroundColor = TSColor.main.white
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        leftLabel.text = labelText
        userInput.placeholder = userInputPlaceholder
        userInput.clearButtonMode = .whileEditing

        self.addSubview(leftLabel)
        self.addSubview(userInput)
        self.addSubview(line)

        leftLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self).offset(-0.5)
            make.left.equalTo(self).offset(13.5)
            make.width.equalTo(TSBindingLeftLabel.Width.rawValue)
        }
        userInput.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftLabel)
            make.right.equalTo(self).offset(-13.5)
            make.left.equalTo(leftLabel.snp.right).offset(15)
        }
        line.snp.makeConstraints { (make) in
            make.top.equalTo(leftLabel.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
        line.isHidden = lineIsHidden
    }
}
