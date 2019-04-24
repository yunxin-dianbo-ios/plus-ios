//
//  TSSectionForPW.swift
//  date
//
//  Created by Fiction on 2017/7/28.
//  Copyright © 2017年 段泽里. All rights reserved.
//

import UIKit

class TSSectionForPW: UIView {
    var labelText = ""
    var userInputPlaceholder = ""
    var lineIsHidden = false

    let backgroundView: UIView = UIView()
    let leftLabel: TSAccountLabel = TSAccountLabel()
    let userInput: TSAccountTextField = TSAccountTextField()
    let line: TSSeparatorView = TSSeparatorView()
    let eyesBtn: UIButton = UIButton(type: .custom)

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
        userInput.isSecureTextEntry = true
        eyesBtn.setImage(#imageLiteral(resourceName: "IMG_ico_closeeye.png"), for: .normal)
        eyesBtn.addTarget(self, action: #selector(clickOnEyes), for: .touchUpInside)
        eyesBtn.contentMode = .scaleAspectFit

        self.addSubview(leftLabel)
        self.addSubview(userInput)
        self.addSubview(eyesBtn)
        self.addSubview(line)
        var leftLabelWidth = labelText.sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)).width + 2
        if leftLabelWidth < TSBindingLeftLabel.Width.rawValue {
            leftLabelWidth = TSBindingLeftLabel.Width.rawValue
        }
        leftLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self).offset(-0.5)
            make.left.equalTo(self).offset(13.5)
            make.width.equalTo(leftLabelWidth)
        }
        userInput.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftLabel)
            make.right.equalTo(eyesBtn.snp.left)
            make.left.equalTo(leftLabel.snp.right).offset(15)
        }
        eyesBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftLabel)
            make.right.equalTo(self)
            make.width.equalTo(leftLabel.snp.height)
        }
        line.snp.makeConstraints { (make) in
            make.top.equalTo(leftLabel.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
        line.isHidden = lineIsHidden
    }

    func clickOnEyes() {
        userInput.isSecureTextEntry = !userInput.isSecureTextEntry
        switch userInput.isSecureTextEntry {
        case true:
            eyesBtn.setImage(#imageLiteral(resourceName: "IMG_ico_closeeye.png"), for: .normal)
        case false:
            eyesBtn.setImage(#imageLiteral(resourceName: "IMG_ico_openeye.png"), for: .normal)
        }
    }
}
