//
//  TSAccountRegexTest.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

@testable import Thinksns_Plus
import Nimble

class TSAccountRegexTest: TSTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - 手机号
    func testPhoneNumberLenth() {
        // Give
        let phoneNumber = "1234"
        // When
        var result = TSAccountRegex.isPhoneNnumberFormat(phoneNumber)
        // Then
        expect(result).to(equal(false))
        result = TSAccountRegex.isPhoneNnumberFormat("18908199568")
        expect(result).to(equal(true))
    }

    func testPhoneNumberFirstCharacter() {
        // Give
        let phoneNumber = "28908199568"
        // When
        var result = TSAccountRegex.isPhoneNnumberFormat(phoneNumber)
        // Then
        expect(result).to(equal(false))
        result = TSAccountRegex.isPhoneNnumberFormat("18908199568")
        expect(result).to(equal(true))
    }

    func testPhoneNumberSecondCharacter() {
        // Give
        let phoneNumber = "11908199568"
        // When
        var result = TSAccountRegex.isPhoneNnumberFormat(phoneNumber)
        // Then
        expect(result).to(equal(false))
        result = TSAccountRegex.isPhoneNnumberFormat("18908199568")
        expect(result).to(equal(true))
    }

    // MARK: - 密码
    func testPassword() {
        // Give
        let password = "Test1"
        // When
        var result = TSAccountRegex.isPhoneNnumberFormat(password)
        // Then
        expect(result).to(equal(false))
        result = TSAccountRegex.countRigthFor(password: "Test12")
        expect(result).to(equal(true))
    }

    // MARK: - 用户名
    // 测试用户名至少为 4 个英文字符
    func testUserNameLenthInEnglish() {
        // Give
        var userNameEnglish = "thi"
        // When
        var isUserNameLenthRight = !TSAccountRegex.countShortFor(userName: userNameEnglish)
        // Then
        expect(isUserNameLenthRight).to(equal(false ))
        userNameEnglish = "thinksns"
        isUserNameLenthRight = !TSAccountRegex.countShortFor(userName: userNameEnglish)
        expect(isUserNameLenthRight).to(equal(true))
    }

    // 测试用户名至少为 2 个中文字符
    func testUserNameLenthInChinese() {
        // Give
        var userName = "呜"
        // When
        var isUserNameLenthRight = !TSAccountRegex.countShortFor(userName: userName)
        // Then
        expect(isUserNameLenthRight).to(equal(false ))
        userName = "嗷嗷"
        isUserNameLenthRight = !TSAccountRegex.countShortFor(userName: userName)
        expect(isUserNameLenthRight).to(equal(true))
    }

    // 用户名只能使用大小写字母、中文、数字和下划线
    func testUserNameFormatRight() {
        // Give
        var userName = "emoji😈"
        // When
        var isUserNameFormartRight = TSAccountRegex.isUserNameFormat(userName)
        // Then
        expect(isUserNameFormartRight).to(equal(false ))
        userName = "Think123_嗷"
        isUserNameFormartRight = TSAccountRegex.isUserNameFormat(userName)
        expect(isUserNameFormartRight).to(equal(true))
    }

    // 测试用户名是否以数字开头
    func testUserNameForStartCharacter() {
        // Give
        var userName = "123Test"
        // When
        var isUserNameStartCharacterRight = !TSAccountRegex.isUserNameStartWithNumber(userName)
        // Then
        expect(isUserNameStartCharacterRight).to(equal(false ))
        userName = "Test123"
        isUserNameStartCharacterRight = !TSAccountRegex.isUserNameStartWithNumber(userName)
        expect(isUserNameStartCharacterRight).to(equal(true))
    }

    // MARK: - 验证码
    // 验证码必须为 4 位
    func testCAPTCHACountRight() {
        // Give
        var CAPTCHA = "123"
        // When
        var isCAPTCHACountRight = TSAccountRegex.isCAPTCHAFormat(CAPTCHA)
        // Then
        expect(isCAPTCHACountRight).to(equal(false))

        // Give
        CAPTCHA = "12345"
        // When
        isCAPTCHACountRight = TSAccountRegex.isCAPTCHAFormat(CAPTCHA)
        // Then
        expect(isCAPTCHACountRight).to(equal(false))

        // Give
        CAPTCHA = "1234"
        // When
        isCAPTCHACountRight = TSAccountRegex.isCAPTCHAFormat(CAPTCHA)
        // Then
        expect(isCAPTCHACountRight).to(equal(true))
    }

    // 验证码必须全为数字
    func testCAPTCHAFormartRigth() {
        // Give
        var CAPTCHA = "test"
        // When
        var isCAPTCHACountRight = TSAccountRegex.isCAPTCHAFormat(CAPTCHA)
        // Then
        expect(isCAPTCHACountRight).to(equal(false))

        // Give
        CAPTCHA = "1234"
        // When
        isCAPTCHACountRight = TSAccountRegex.isCAPTCHAFormat(CAPTCHA)
        // Then
        expect(isCAPTCHACountRight).to(equal(true))
    }
}
