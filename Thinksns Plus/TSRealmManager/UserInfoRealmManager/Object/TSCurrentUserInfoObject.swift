//
//  TSCurrentUserInfoObject.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  当前用户的数据库模型

import Foundation
import RealmSwift

class TSCurrentUserInfoObject: Object {
    /// 用户标识
    dynamic var userIdentity = -1
    /// 用户名
    dynamic var name = ""
    /// 邮箱
    dynamic var email: String? = nil
    /// 电话
    dynamic var phone: String? = nil
    /// 性别
    dynamic var sex: Int = 0
    /// 简介
    dynamic var bio: String? = nil
    /// 地址
    dynamic var location: String? = nil
    /// 创建时间
    dynamic var createDate: String = ""
    /// 更新时间
    dynamic var updateDate: String = ""
    /// 头像
    dynamic var avatar: TSNetFileObject?
    /// 背景
    dynamic var bg: TSNetFileObject?
    /// Whether the user is following you.
    dynamic var following: Bool = false
    /// Whether you are following this user.
    dynamic var follower: Bool = false
    /// 好友数量
    dynamic var friendsCount: Int = 0
    /// 验证信息
    dynamic var verified: TSUserVerifiedObject?
    /// 附加信息
    dynamic var extra: TSUserExtraObject?
    /// 钱包
    dynamic var wallet: TSUserInfoWalletObject?

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["userIdentity"]
    }

    /// 设置主键
    override static func primaryKey() -> String? {
        return "userIdentity"
    }
}
