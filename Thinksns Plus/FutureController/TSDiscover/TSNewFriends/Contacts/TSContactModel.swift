//
//  TSContactModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Contacts

struct TSContactModel {

    /// 姓名
    var name: String
    /// 电话
    var phone: String
    /// 头像
    var avatar: UIImage?
    /// 是否已经邀请过
    var isInvite = false
    
    init?(contact: CNContact) {
        let nameInfo = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName) ?? "无名氏"
        let phoneInfo = contact.phoneNumbers
        guard let phoneNumber = TSContactModel.filter(phone: phoneInfo), nameInfo != "" else {
            return nil
        }
        name = nameInfo
        phone = phoneNumber
        let imageData = contact.thumbnailImageData ?? NSData.init() as Data
        avatar = UIImage(data: imageData)
    }
    
    /// 过滤手机号的格式
    static func filter(phone: [CNLabeledValue<CNPhoneNumber>]?) -> String? {
        guard var phone = phone else {
            return nil
        }
        var phoneNum = ""
        var phoneNumArr: [String] = []
        for phoneInfo in phone {
            phoneNumArr.append(phoneInfo.value.stringValue)
        }
        if phoneNumArr.contains(TSCurrentUserInfo.share.userInfo?.phone ?? "") {
            return nil
        }
        // 获取整个数组中符合要求的第一个手机号码
        for phoneInfo in phone {
            var phoneNums = phoneInfo.value.stringValue
            phoneNums = phoneNums.replacingOccurrences(of: "-", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: "+86", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: " ", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: " ", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: " ", with: "")
            if phoneNums.count >= 11 {
                phoneNums = phoneNums.substring(from: phoneNums.index(phoneNums.endIndex, offsetBy: -11))
                if TSAccountRegex.isPhoneNnumberFormat(phoneNums) {
                    phoneNum = phoneNums
                    break
                }
            }
        }
        return phoneNum == "" ? nil : phoneNum
    }
}
