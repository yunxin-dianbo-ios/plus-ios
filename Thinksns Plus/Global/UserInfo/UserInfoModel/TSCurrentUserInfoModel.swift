//
//  TSCurrentUserInfoModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  当前用户的数据模型
//  含有wallet数据模型

import Foundation
import RealmSwift
import ObjectMapper
import UIKit

class TSCurrentUserInfoModel: Mappable {
    /// 用户标识
    var userIdentity: Int = -1
    /// 用户名
    var name: String = ""
    /// 电话
    var phone: String?
    /// 邮箱
    var email: String?
    /// 是否初始化了密码(当前登录用户信息获取的接口已经添加了)
    var isInitPwd: Bool = false
    /// The user's gender, 0 - Unknown, 1 - Man, 2 - Woman.
    var sex: Int = 0
    /// 服务器返回的用户简介
    var bio: String?
    /// 地址
    var location: String?
    /// 创建时间
    var createDate: String = ""
    /// 更新时间
    var updateDate: String = ""
    /// 头像
    var avatar: TSNetFileModel?
    /// 背景
    var bg: TSNetFileModel?
    /// Whether the user is following you.
    var following: Bool = false
    /// Whether you are following this user.
    var follower: Bool = false
    /// 好友数量
    var friendsCount: Int = 0
    /// 验证信息
    var verified: TSUserVerifiedModel?
    /// 附加信息
    var extra: TSUserExtraModel?
    /// 钱包
    var wallet: TSUserInfoWalletModel?
    /// 积分
    var integration: UserIntegrationModel?

    /// 是否显示过资讯投稿的支付提示，默认为false，无需存入数据库，使用UserDefaults存储
    var isShowedNewsContributePayPrompt: Bool {
        get {
            let userDefaults = UserDefaults.standard
            let key = String(format: "%d-isShowedNewsContributePayPrompt", self.userIdentity)
            return userDefaults.bool(forKey: key)
        }
        set(newIsShowedNewsContributePayPrompt) {
            // 1.获得NSUserDefaults文件
            let userDefaults = UserDefaults.standard
            //2.向文件中写入内容
            let key = String(format: "%d-isShowedNewsContributePayPrompt", self.userIdentity)
            userDefaults.setValue(newIsShowedNewsContributePayPrompt, forKey: key)
            userDefaults.synchronize()
        }
    }

    /// 返回用户的简介信息
    func shortDesc() -> String {
        return bio == nil ? "占位符_空的简介".localized : bio!
    }

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        userIdentity <- map["id"]
        name <- map["name"]
        phone <- map["phone"]
        email <- map["email"]
        bio <- map["bio"]
        sex <- map["sex"]
        location <- map["location"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        avatar <- map["avatar"]
        bg <- map["bg"]
        follower <- map["follower"]
        following <- map["following"]
        friendsCount <- map["friends_count"]
        verified <- map["verified"]
        extra <- map["extra"]
        wallet <- map["new_wallet"]
        isInitPwd <- map["initial_password"]
        integration <- map["currency"]
    }
    init(object: TSCurrentUserInfoObject) {
        self.userIdentity = object.userIdentity
        self.name = object.name
        self.email = object.email
        self.phone = object.phone
        self.bio = object.bio
        self.sex = object.sex
        self.location = object.location
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.follower = object.follower
        self.following = object.following
        self.friendsCount = object.friendsCount
        if nil != object.avatar {
            self.avatar = TSNetFileModel(object: object.avatar!)
        }
        if nil != object.bg {
            self.bg = TSNetFileModel(object: object.bg!)
        }
        if nil != object.verified {
            self.verified = TSUserVerifiedModel(object: object.verified!)
        }
        if nil != object.extra {
            self.extra = TSUserExtraModel(object: object.extra!)
        }
        if nil != object.wallet {
            self.wallet = TSUserInfoWalletModel(object: object.wallet!)
        }
    }

    /// 转换为数据库对象
    func object() -> TSCurrentUserInfoObject {
        let object = TSCurrentUserInfoObject()
        object.userIdentity = self.userIdentity
        object.name = self.name
        object.email = self.email
        object.phone = self.phone
        object.bio = self.bio
        object.sex = self.sex
        object.location = self.location
        object.avatar = self.avatar?.object()
        object.bg = self.bg?.object()
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.follower = self.follower
        object.following = self.following
        object.friendsCount = self.friendsCount
        object.verified = self.verified?.object()
        object.extra = self.extra?.object()
        object.wallet = self.wallet?.object()
        return object
    }

    /// 可将本身转化为TSUserInfoModel
    func convert() -> TSUserInfoModel {
        let model = TSUserInfoModel()
        model.userIdentity = self.userIdentity
        model.name = self.name
        model.email = self.email
        model.phone = self.phone
        model.bio = self.bio
        model.sex = self.sex
        model.location = self.location
        model.avatar = self.avatar
        model.bg = self.bg
        model.createDate = self.createDate
        model.updateDate = self.updateDate
        model.follower = self.follower
        model.following = self.following
        model.friendsCount = self.friendsCount
        model.verified = self.verified
        model.extra = self.extra
        return model
    }
}
