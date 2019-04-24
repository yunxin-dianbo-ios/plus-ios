//
//  TSUserInfoObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/15.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  用户信息列表

import UIKit
import RealmSwift
import SwiftyJSON

/// 用户验证的数据库模型
class TSUserVerifiedObject: Object {
    dynamic var type: String = ""
    dynamic var icon: String = ""
    /// 认证描述
    dynamic var descrip: String = ""
}

// 网络文件数据库模型，用于用户头像、背景、圈子封面等可修复文件
// 附件信息可查看 https://slimkit.github.io/docs/api-v2-core-file-storage.html
class TSNetFileObject: Object {
    /*
     
     "vendor": "local",
     "url": "https://xxxxx",
     "mize": "image/png",
     "size": 8674535,
     "dimension": {
     "width": 240,
     "height": 240,
     }
     */
    // 厂商名称
    dynamic var vendor: String = "local"
    // 文件请求地址，GET 方式
    dynamic var url: String = ""
    // 文件 MIME
    dynamic var mize: String = ""
    // 文件尺寸
    dynamic var size: Int = 0
    // 文件宽
    dynamic var width: Int = 0
    // 文件高
    dynamic var height: Int = 0

}

/// 用户附加信息的数据库模型
class TSUserExtraObject: Object {
    dynamic var userId: Int = 0
    dynamic var likesCount: Int = 0
    dynamic var commentsCount: Int = 0
    dynamic var followersCount: Int = 0
    dynamic var followingsCount: Int = 0
    dynamic var feedsCount: Int = 0
    dynamic var updateDate: String = ""
    /// 问题数
    dynamic var qustionsCount = 0
    /// 回答数
    dynamic var answersCount = 0

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["userId"]
    }
    /// 设置主键
    override static func primaryKey() -> String? {
        return "userId"
    }
}

/// 用户信息的数据库模型
class TSUserInfoObject: Object {
    /// 用户标识
    dynamic var userIdentity = -1
    /// 用户名
    dynamic var name = ""
    /// 邮箱
    dynamic var email: String? = nil
    /// 电话
    dynamic var phone: String? = nil
    /// 电话2，后台在“/user/find-by-phone”接口中返回的电话信息的 key 为 mobi，通过聚众讨论，决定增加一个字段
    dynamic var mobi: String? = nil
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
    /// 用户标签
    let tags = List<TSTagObject>()

    /// 设置索引
    override static func indexedProperties() -> [String] {
        return ["userIdentity"]
    }

    /// 设置主键
    override static func primaryKey() -> String? {
        return "userIdentity"
    }
}
