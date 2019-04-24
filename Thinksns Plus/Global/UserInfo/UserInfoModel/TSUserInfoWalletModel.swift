//
//  TSUserInfoWalletModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/5/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import ObjectMapper

struct TSUserInfoWalletModel: Mappable {

    /// 钱包标识
    var id: Int?
    /// 用户标识
    var userIdentity: Int?
    /// 钱包余额，余额单位为「分」
    var balance: Int = 0
    /// 总收入
    var totleIncome = 0
    /// 总支出
    var totalExpenses = 0
    // MARK: - 这里的时间也可以考虑使用Date，在mapping中进行类型转换
    /// 创建时间
    var createDate: String?
    /// 最后交易时间
    var updateDate: String?
    /// 删除时间
    var deleteDate: String?

    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        userIdentity <- map["owner_id"]
        balance <- map["balance"]
        totleIncome <- map["total_income"]
        totalExpenses <- map["total_expenses"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        deleteDate <- map["deleted_at"]
    }
}

// MARK: - 数据库

extension TSUserInfoWalletModel {

    // 从数据库模型转换
    init(object: TSUserInfoWalletObject) {
        self.id = object.id.value
        self.userIdentity = object.userIdentity.value
        self.balance = object.balance
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.deleteDate = object.deleteDate
    }

    // MARK: - Convert
    func object() -> TSUserInfoWalletObject {
        let object = TSUserInfoWalletObject()
        object.id.value = self.id
        object.userIdentity.value = self.userIdentity
        object.balance = self.balance
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.deleteDate = self.deleteDate
        return object
    }
}
