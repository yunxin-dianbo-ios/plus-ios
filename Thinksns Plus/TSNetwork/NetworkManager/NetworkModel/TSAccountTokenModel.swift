//
//  TSAccountTokenModel.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  账户口令数据模型

import UIKit
import SwiftyJSON
import ObjectMapper

class TSAccountTokenModel: Mappable {

    static let TSAccountTokenKey = "TSAccountTokenSaveKey"
    static let TSAccountExpireIntervalKey = "TSAccountExpireIntervalKey"
    static let TSAccountCreateDateKey = "TSAccountCreateDateKey"

    var token: String = ""
    /// Authorization code expiration interval(TTL time in minutes)
    var expireInterval: Int = 0
    /// Use the authorization code to refresh the interval of the authorization code.
    var refreshTTL: Int = 0

    /// 创建日期，使用请求之前的
    var createInterval: Int = Int(Date().timeIntervalSince1970)

    /// 持久化相关信息
    func save() {
        UserDefaults.standard.setValue(self.token, forKey: TSAccountTokenModel.TSAccountTokenKey)
        UserDefaults.standard.setValue(self.expireInterval, forKey: TSAccountTokenModel.TSAccountExpireIntervalKey)
        UserDefaults.standard.setValue(self.createInterval, forKey: TSAccountTokenModel.TSAccountCreateDateKey)
        UserDefaults.standard.synchronize()
    }

    /// 重置相关信息
    static func reset() {
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountTokenKey)
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountExpireIntervalKey)
        UserDefaults.standard.removeObject(forKey: TSAccountTokenModel.TSAccountCreateDateKey)
    }

    /// 通过沙盒内数据初始化
    // invalid redeclaration of init
    init?() {
        let token = UserDefaults.standard.string(forKey: TSAccountTokenModel.TSAccountTokenKey)
        if nil == token || token!.isEmpty {
            return nil
        }
        self.token = token!
        self.expireInterval = UserDefaults.standard.integer(forKey: TSAccountTokenModel.TSAccountExpireIntervalKey)
        self.createInterval = UserDefaults.standard.integer(forKey: TSAccountTokenModel.TSAccountCreateDateKey)
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        token <- map["access_token"]
        if token.count <= 0 {
            token <- map["token"]
        }
        expireInterval <- map["expires_in"]
        if expireInterval <= 0 {
            expireInterval <- map["ttl"]
        }
        refreshTTL <- map["refresh_ttl"]
    }
}
