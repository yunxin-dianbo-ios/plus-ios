//
//  TSAccountUX.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  账号正则规范类

import UIKit

/// 输入框
class TSAccountTextField: TSTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: TSFont.TextField.account.rawValue)
        self.textColor = TSColor.normal.blackTitle
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont.systemFont(ofSize: TSFont.TextField.account.rawValue)
        self.textColor = TSColor.normal.blackTitle
    }

}

/// 标题 Label
class TSAccountLabel: TSLabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.textColor = TSColor.normal.blackTitle
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.textColor = TSColor.normal.blackTitle
    }

}

/// 红字提示的 Label
class TSAccountMessagelabel: TSLabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        self.textColor = TSColor.main.warn
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        self.textColor = TSColor.main.warn
    }
}

/// 倒计时 Label 和 Button
// 倒计时按钮
class TSCutDownLabel: TSLabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.textColor = TSColor.main.theme
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.textColor = TSColor.main.theme
    }
}

/// 发送验证码按钮
class TSSendCAPTCHAButton: TSButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.setTitleColor(TSColor.main.theme, for: .normal)
        self.setTitleColor(TSColor.normal.disabled, for: .disabled)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.setTitleColor(TSColor.main.theme, for: .normal)
        self.setTitleColor(TSColor.normal.disabled, for: .disabled)
    }

}

/// 虚线
class TSSeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.inconspicuous.disabled
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = TSColor.inconspicuous.disabled
    }
}
