//
//  TSAccountRegex.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/27.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  用户账号处理类
//  根据 [TS 用户管理模块](https://github.com/zhiyicx/thinksns-plus-document/blob/master/document/%E7%94%A8%E6%88%B7%E7%AE%A1%E7%90%86%E6%B5%8B%E8%AF%95%E7%94%A8%E4%BE%8B.md) 中对注册、登录、找回密码等页面的账号输入的要求，TSAccountRegex 中将处理账号的方法分为 3 个类型 ：
//
//  * 检查账号信息是否含有非法字符.
//
//  * 判断账号信息字数是否过短.
//
//  * 当账号过长时，截取账号至规定的最大长度.
//
//  以上判断方法的判断规则依据 2016 年 12 月 29 日前的 TS 用户管理模块中对账号判断的描述，关于密码的规则和后台确认后依照后台提出的规则来判断，故与 TS 用户管理模块文档有一定的偏差.
//

import UIKit

class TSAccountRegex: NSObject {

    /// 检索字段是否符合规则
    ///
    /// - Parameters:
    ///   - string: 被检索的字段
    ///   - rule: 检索规则
    /// - Returns: 是否检索到合法字段
    class func regex(string: String!, rule: String!) -> Bool {
        let regex = try! NSRegularExpression(pattern: rule, options: [])
        let matchs = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        if matchs.isEmpty {
            return false // 未检索到合法字段
        } else {
            return true // 检索到合法字段
        }
    }

    // MAKR: - 身份证号
    class func isIdcardFormart(_ string: String!) -> Bool {
        let countRight = string.count == 18
        let phoneFomart = TSAccountRegex.regex(string: string, rule: "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9Xx])$")
        switch (countRight, phoneFomart) {
        case (true, true):
            return true
        default:
            return false
        }
    }

    // MARK: - 钱包

    /// 充值金额格式是否正确
    class func isPayMoneyFormat(_ string: String!) -> Bool {
        return TSAccountRegex.regex(string: string, rule: "[0-9]")
    }

    // MARK: - 手机号
    /// 手机号格式是否正确
    class func isPhoneNnumberFormat(_ string: String!) -> Bool {
        let countRight = string.count == 11
        let phoneFomart = TSAccountRegex.regex(string: string, rule: "^[1][34578][0-9]*")
        switch (countRight, phoneFomart) {
        case (true, true):
            return true
        default:
            return false
        }
    }

    // MARK: - email
    /// email格式是否正确
    class func isEmailFormat(_ string: String!) -> Bool {
        let emailFomart = TSAccountRegex.regex(string: string, rule: "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$")
        return emailFomart
    }
    class func isContentAllwhitespaces(_ string: String!) -> Bool {
        let whitespace = NSCharacterSet.whitespaces
        let temp: String? = string.trimmingCharacters(in: whitespace)
        if temp == "" {
            return false
        }
        return true
    }

    // MARK: - 密码
    /// 判断密码长度是否符合规范
    ///
    /// - Parameters:
    ///   - password: 密码
    ///   - rightOperation: 密码长度正确时候的操作
    ///   - falseOperation: 密码长度错误时候的操作
    class func countRigthFor(password: String!) -> Bool {
        let passwordCount = password.count
        switch passwordCount {
        case 0...5:
            return false
        default:
            return true
        }
    }

    // MARK: - 用户名
    /// 用户名格式是否正确
    class func isUserNameFormat(_ string: String!) -> Bool {
        return TSAccountRegex.regex(string: string, rule: "^[a-zA-Z_\\u4e00-\\u9fa5][a-zA-Z0-9_\\u4e00-\\u9fa5]*$")
    }

    /// 检查用户名格式是否正确
    class func chanageUserName(_ string: String!) -> Bool {
        let number = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]+$"
        let numberPre = NSPredicate(format: "SELF MATCHES %@", number)
        if numberPre.evaluate(with: string) {
            return false
        }
        return true
    }

    /// 用户名是否以数字开头
    class func isUserNameStartWithNumber(_ string: String!) -> Bool {
        return TSAccountRegex.regex(string: string, rule: "^[0-9]")
    }

    /// 计算长度
    class func lenthOf(userName: String!) -> Int {
        var userNameLenth = 0
        for character in userName {
            if regex(string: String(character), rule: "[a-zA-Z0-9_]") {
                userNameLenth += 1
            } else {
                userNameLenth += 2
            }
        }
        return userNameLenth
    }

    /// 判断用户名是否过短，英文字母至少4个长度，中文最少两个长度
    class func countShortFor(userName: String!) -> Bool {
        let userNameLenth = TSAccountRegex.lenthOf(userName: userName)
        if userNameLenth < 4 {
            return true
        } else {
            return false
        }
    }

    /// 判断用户名是否过长，英文最大16个长度，中文最大8个长度，中英文混合按照上述规则转换，数字占用长度同英文
    /// - paramater:
    ///   - count: 英文字符长度
    class func countTooLongFor(userName: String!, count: Int) -> Bool {
        let userNameLenth = TSAccountRegex.lenthOf(userName: userName)
        if userNameLenth > count {
            return true
        } else {
            return false
        }
    }

    // MARK: - 验证码
    /// 验证码格式是否正确
    class func isCAPTCHAFormat(_ string: String!) -> Bool {
        //判断string是否满足条件，得出一个bool
        let countRight = (string.count == 6 || string.count > 3)
        let CAPTCHAFormat = TSAccountRegex.regex(string: string, rule: "[0-9][0-9]*")
        switch (countRight, CAPTCHAFormat) {
        case (true, true):
            return true
        default:
            return false
        }
    }

    // MARK: - 处理 account 数据
    /// 截取 account 字段
    /// - 检查输入框的内容然后截取其至字数的上限，并将处理后的字段显示在传入的 textField 上
    /// - 上限计算：字母数字字符算 1 个字符，中文和 emoji 也算 1 个字符
    ///
    /// - Parameters:
    ///   - textField: 被检查的输入框
    ///   - stringCountLimit: 输入框可以输入的字符上限
    class func checkAndUplodTextFieldText<T>(textField: T, stringCountLimit: Int) {

        if textField is UITextField {
            let textField = textField as? UITextField
            let string = textField?.text!
            if textField?.markedTextRange == nil && (string?.count)! > stringCountLimit { // 判断是否处于拼音输入状态
                textField?.text = string?.substring(to: (string?.index((string?.startIndex)!, offsetBy: stringCountLimit))!)
            }
        } else {
            let textView = textField as? UITextView
            let string = textView?.text!
            if textView?.markedTextRange == nil && (string?.count)! > stringCountLimit { // 判断是否处于拼音输入状态
                textView?.text = string?.substring(to: (string?.index((string?.startIndex)!, offsetBy: stringCountLimit))!)
            }
        }
    }

    // MARK: - textview处理 account 数据
    /// 截取 account 字段
    /// - 检查输入框的内容然后截取其至字数的上限，并将处理后的字段显示在传入的 textview 上
    /// - 上限计算：字母数字字符算 1 个字符，中文和 emoji 也算 1 个字符
    ///
    /// - Parameters:
    ///   - textField: 被检查的输入框
    ///   - stringCountLimit: 输入框可以输入的字符上限
    /// tips: 主要是给OC那边调用的
    class func checkAndUplodTextView(textView: UITextView, stringCountLimit: Int) {
        let string = textView.text!
        if textView.markedTextRange == nil && (string.count) > stringCountLimit { // 判断是否处于拼音输入状态
            textView.text = string.substring(to: (string.index((string.startIndex), offsetBy: stringCountLimit)))
        }
    }
    // MARK : - 按照字节截取输入框内容长度
    // 该方式比较消耗运算性能，不能用于较长文字输入框的文字截取
    // 适用于短文本输入:比如用于昵称修改
    // 长文本字节截取方案待优化
    class func checkAndUplodTextField(textField: UITextField, byteLimit: Int) {
        // 判断是否处于拼音输入状态
        if textField.markedTextRange != nil {
            return
        }
        let stringCount = textField.text?.count
        let inputStr = textField.text
        let maxCount = byteLimit
        var inputCount = 0
        // 单个字符的数组，后边直接依次取
        var singleStringArray: [String] = Array()
        for index in 0 ..< stringCount! {
            let range = NSRange(location: index, length: 1)
            let subStr = inputStr?.subString(with: range)
            let cString = subStr?.utf8
            if (cString?.count)! / 3 >= 1 {
                inputCount = inputCount + 2
            } else {
                inputCount = inputCount + 1
            }
            singleStringArray.append(subStr!)
        }
        if inputCount > maxCount {
            // 超出了才裁剪，拼接
            var tempStr = ""
            var tempCount = 0
            for item in singleStringArray {
                if tempCount >= maxCount {
                    break
                }
                let tempSingelStr = item.utf8
                if tempSingelStr.count / 3 >= 1 {
                    // 汉字
                    tempCount = tempCount + 2
                } else {
                    // 非汉字
                    tempCount = tempCount + 1
                }
                if tempCount > maxCount {
                    break
                } else {
                    tempStr = tempStr + item
                }
            }
            textField.text = tempStr
        }
    }
    /// 目的是用于聊天部分
    // MARK: - 获取当前显示的VC
    class func getCurrentVC() -> UIViewController {
        let rootVC: UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!
        return self.findCurrentVC(vc: rootVC)
    }

    // MARK: - 处理获取当前VC逻辑
    class func findCurrentVC(vc: UIViewController) -> UIViewController {
        if vc.presentedViewController != nil {
            return self.findCurrentVC(vc: vc.presentedViewController!)
        } else if vc.isKind(of: UINavigationController.self) {
            let currentNav: UINavigationController = vc as! UINavigationController
            if currentNav.viewControllers.count > 0 {
                return self.findCurrentVC(vc: currentNav.topViewController!)
            } else {
                return vc
            }
        } else if vc.isKind(of: TSHomeTabBarController.self) {
            let currentTab: TSHomeTabBarController = vc as! TSHomeTabBarController
            if (currentTab.viewControllers?.count) != nil {
                return self.findCurrentVC(vc: currentTab.selectedViewController!)
            } else {
                return vc
            }
        } else if vc.isKind(of: TSRootViewController.self) {
            let currentTab: TSRootViewController = vc as! TSRootViewController
            if currentTab.childViewControllers.count > 0 {
                return self.findCurrentVC(vc: currentTab.currentShowViewcontroller!)
            } else {
                return vc
            }
        } else {
            return vc
        }
    }
}
