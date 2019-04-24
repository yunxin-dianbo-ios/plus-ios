//
//  TSAccountMock.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
@testable import Thinksns_Plus
import XCTest

/// 找回密码视图控制器 Mock
class TSRetrievePasswordVCMock: TSRetrievePasswordVC {
    /// 发送验证码按钮是否被 enable 过
    var CAPTCHAButtonShouldEnable = false
    /// 发送验证码按钮是否被 disable 过
    var CAPTCHAButtonShouldDisable = false

    override func enabledCAPTCHAButton() {
        super.enabledCAPTCHAButton()
        CAPTCHAButtonShouldEnable = true
    }
    override func disabledCAPTCHAButton() {
        super.disabledCAPTCHAButton()
        CAPTCHAButtonShouldDisable = true
    }
}

/// 注册视图控制器 Mock
class TSRegisterVCMock: TSRegisterVC {
    /// 发送验证码按钮是否被 enable 过
    var CAPTCHAButtonShouldEnable = false
    /// 发送验证码按钮是否被 disable 过
    var CAPTCHAButtonShouldDisable = false

    override func enabledCAPTCHAButton() {
        super.enabledCAPTCHAButton()
        CAPTCHAButtonShouldEnable = true
    }
    override func disabledCAPTCHAButton() {
        super.disabledCAPTCHAButton()
        CAPTCHAButtonShouldDisable = true
    }
}
