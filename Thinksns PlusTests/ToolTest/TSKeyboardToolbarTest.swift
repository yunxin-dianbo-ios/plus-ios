//
//  TSKeyboardToolbarTest.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

@testable import Thinksns_Plus
import Nimble
import UIKit
class TSKeyboardToolbarTest: TSTestCase, UITextFieldDelegate {

    override func setUp() {
        super.setUp()
        TSKeyboardToolbar.share.configureKeyboard()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKeyboardToolbar() {
        let textField = UITextField()
        textField.delegate = self
        // Give 假设 Text上有子
        textField.text = "实际上就是假按揭"
        self.textFieldDidBeginEditing(textField)
        let testString = TSKeyboardToolbar.share.keyboardTestText()
        // Then 获得结果
        expect(testString).to(equal("实际上就是假按揭"))
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // When 把各个参数传入其中
        TSKeyboardToolbar.share.keyboardGetInputbox(inputbox: textField, maximumWordLimit: 10, placeholderText: "aaa")
    }
}
