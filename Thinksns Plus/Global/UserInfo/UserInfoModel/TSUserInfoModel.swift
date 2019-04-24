//
//  TSUserInfoModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/15.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  用户信息数据模型
//  全局使用

import UIKit
import SwiftyJSON
import ObjectMapper

enum PraiseButtonImageName: String {
    // 我没有关注对方，不管对方有没有关注我
    case unfollow = "IMG_ico_me_follow"
    // 相互关注
    case eachother = "IMG_ico_me_followed_eachother"
    // 我关注了对方，但是对方没有关注我
    case follow = "IMG_ico_me_followed"
}

/// 当前登录用户和该用户的关系
enum FollowStatus: String {
    /// 关注了对方
    case follow = "IMG_ico_me_followed"
    /// 未关注对方
    case unfollow = "IMG_ico_me_follow"
    /// 相互关注
    case eachOther = "IMG_ico_me_followed_eachother"
    /// 该用户是当前登录用户
    case oneself = ""
}

/// 当前登录用户和该用户的关系
enum FollowStatustext: String {
    /// 关注了对方
    case follow = "已关注"
    /// 未关注对方
    case unfollow = "+ 关注"
    /// 相互关注
    case eachOther = "互相关注"
    /// 该用户是当前登录用户
    case oneself = ""
}

/// 用户验证数据模型
class TSUserVerifiedModel: Mappable {
    /// Verified type.
    var type: String = ""
    /// Verified icon.
    var icon: String = ""
    /// 认证描述
    var description: String = ""

    init?(type: String?, icon: String?) {
        guard let type = type else {
            return nil
        }
        self.type = type
        self.icon = icon ?? ""
    }

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        type <- map["type"]
        icon <- map["icon"]
        description <- map["description"]
    }

    /// 从数据库模型转换
    init(object: TSUserVerifiedObject) {
        self.type = object.type
        self.icon = object.icon
        self.description = object.descrip
    }
    /// 转换为数据库对象
    func object() -> TSUserVerifiedObject {
        let object = TSUserVerifiedObject()
        object.type = self.type
        object.icon = self.icon
        object.descrip = self.description
        return object
    }
}


/// 网络文件数据模型
class TSNetFileModel: Mappable {
     /// 厂商名称
     var vendor: String = "local"
     /// 文件请求地址，GET 方式
     var url: String = ""
     /// 文件 MIME
     var mize: String = ""
     /// 文件尺寸
     var size: Int = 0
     /// 文件宽
     var width: Int = 0
     /// 文件高
     var height: Int = 0

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        vendor <- map["vendor"]
        url <- map["url"]
        mize <- map["mize"]
        size <- map["size"]
        width <- map["dimension.width"]
        height <- map["dimension.height"]
    }

    /// 从数据库模型转换
    init(object: TSNetFileObject) {
        self.vendor = object.vendor
        self.url = object.url
        self.mize = object.mize
        self.size = object.size
        self.width = object.width
        self.height = object.height
    }
    /// 转换为数据库对象
    func object() -> TSNetFileObject {
        let object = TSNetFileObject()
        object.vendor = self.vendor
        object.url = self.url
        object.mize = self.mize
        object.size = self.size
        object.width = self.width
        object.height = self.height
        return object
    }
}

/// 用户附加信息
class TSUserExtraModel: Mappable {
    var userId: Int = 0
    /// The number of users who received the number of statistics.
    var likesCount: Int = 0
    /// The comments made by this user.
    var commentsCount: Int = 0
    /// Follow this user's statistics.
    var followersCount: Int = 0
    /// This user follows the statistics.
    var followingsCount: Int = 0
    /// This user friends the statistics.
    var feedsCount: Int = 0
    /// Secondary data update time.
    var updateDate: String = ""
    /// 当前用户签到总天数
    var checkinCount: Int = 0
    /// 当前用户连续签到天数
    var lastCheckinCount: Int = 0
    /// 问题数
    var qustionsCount = 0
    /// 回答数
    var answersCount = 0
    /// 粉丝/问答点赞/回答/动态点赞/资讯点赞数（请求哪个接口，返回的就是哪个排行的数量）
    var count = 0
    /// 粉丝/财富/收入/专家/问答达人/解答/动态/资讯排行（请求哪个接口，返回的就是哪个排行）
    var rank = 0

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        userId <- map["user_id"]
        likesCount <- map["likes_count"]
        commentsCount <- map["comments_count"]
        followersCount <- map["followers_count"]
        followingsCount <- map["followings_count"]
        feedsCount <- map["feeds_count"]
        updateDate <- map["updated_at"]
        checkinCount <- map["checkin_count"]
        lastCheckinCount <- map["last_checkin_count"]
        qustionsCount <- map["questions_count"]
        answersCount <- map["answers_count"]
        count <- map["count"]
        rank <- map["rank"]
    }

    /// 从数据库模型转换
    init(object: TSUserExtraObject) {
        self.userId = object.userId
        self.likesCount = object.likesCount
        self.commentsCount = object.commentsCount
        self.followersCount = object.followersCount
        self.followingsCount = object.followingsCount
        self.feedsCount = object.feedsCount
        self.updateDate = object.updateDate
        self.qustionsCount = object.qustionsCount
        self.answersCount = object.answersCount
    }
    /// 转换为数据库对象
    func object() -> TSUserExtraObject {
        let object = TSUserExtraObject()
        object.userId = self.userId
        object.likesCount = self.likesCount
        object.commentsCount = self.commentsCount
        object.followersCount = self.followersCount
        object.followingsCount = self.followingsCount
        object.feedsCount = self.feedsCount
        object.updateDate = self.updateDate
        object.qustionsCount = self.qustionsCount
        object.answersCount = self.answersCount
        return object
    }
}

/// 用户信息模型
class TSUserInfoModel: Mappable {

    /// 用户标识
    var userIdentity: Int = -1
    /// 用户名
    var name: String = ""
    /// 电话
    var phone: String?
    /// 电话2，后台在“/user/find-by-phone”接口中返回的电话信息的 key 为 mobi，通过聚众讨论，决定增加一个字段
    var mobi: String?
    /// 邮箱
    var email: String?
    /// The user's gender, 0 - Unknown, 1 - Man, 2 - Woman.
    var sex: Int = 0
    /// 简介
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
    /// 用户是否关注你
    var following: Bool = false
    /// 你是否关注该用户
    var follower: Bool = false
    /// 好友数量
    var friendsCount: Int = 0
    /// 验证信息
    var verified: TSUserVerifiedModel?
    /// 附加信息
    var extra: TSUserExtraModel?
    /// 用户标签
    var tags: [TSTagModel] = []
    /// 该用户是否被当前登录用户拉黑
    var isBlacked: Bool = false
    /// 返回用户的简介信息
    func shortDesc() -> String {
        return bio == nil ? "占位符_空的简介".localized : bio!
    }
    /// 返回当前登录用户和该用户的关系
    ///
    /// - warning: 未登录等情况下会返回nil
    func relationshipWithCurrentUser() -> FollowStatus? {
        if TSCurrentUserInfo.share.isLogin == false {
            return nil
        }
        guard let currentUser = TSCurrentUserInfo.share.userInfo else {
            return nil
        }
        if currentUser.userIdentity == self.userIdentity {
            return .oneself
        }
        if following == true && follower == true {
            return .eachOther
        }
        if follower == true {
            return .follow
        }
        return .unfollow
    }

    /// 返回当前登录用户和该用户的关系
    ///
    /// - warning: 未登录等情况下会返回nil
    func relationshipTextWithCurrentUser() -> FollowStatustext? {
        if TSCurrentUserInfo.share.isLogin == false {
            return nil
        }
        guard let currentUser = TSCurrentUserInfo.share.userInfo else {
            return nil
        }
        if currentUser.userIdentity == self.userIdentity {
            return .oneself
        }
        if following == true && follower == true {
            return .eachOther
        }
        if follower == true {
            return .follow
        }
        return .unfollow
    }

    /// 判断改用户是不是TS助手
    ///
    /// 是的情况返回TS助手的链接,或者返回 nil
    func isTSHelper() -> NSURL? {
        /// 新版本删除了小助手的连接，暂时保留该接口，兼容旧的逻辑
        return nil
    }

    // 性别 - lazy property
    var sexTitle: String {
        var title = "未知"
        if 1 == self.sex {
            title = "男"
        } else if 2 == self.sex {
            title = "女"
        }
        return title
    }

    init() {

    }
    required init?(map: Map) {

    }
    func mapping(map: Map) {
        userIdentity <- map["id"]
        name <- map["name"]
        phone <- map["phone"]
        mobi <- map["mobi"]
        email <- map["email"]
        bio <- map["bio"]
        sex <- map["sex"]
        location <- map["location"]
        createDate <- map["created_at"]
        updateDate <- map["updated_at"]
        avatar <- (map["avatar"], TSNetFileModelTransfrom())
        bg <- (map["bg"], TSNetFileModelTransfrom())
        follower <- map["follower"]
        following <- map["following"]
        friendsCount <- map["friends_count"]
        verified <- map["verified"]
        extra <- map["extra"]
        tags <- map["tags"]
        isBlacked <- map["blacked"]
    }

    /// 从数据库模型转换
    init(object: TSUserInfoObject) {
        self.userIdentity = object.userIdentity
        self.name = object.name
        self.email = object.email
        self.phone = object.phone
        self.mobi = object.mobi
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
        } else {
            let extraStr = """
            {
            "user_id": \(self.userIdentity), "likes_count": 0, "comments_count": 0, "followers_count": 0,
            "followings_count": 0, "feeds_count": 0, "updated_at": 0,
            "checkin_count": 0, "last_checkin_count": 0, "questions_count": 0,
            "answers_count": 0, "count": 0, "rank": 0
            }
            """
            self.extra = Mapper<TSUserExtraModel>().map(JSONString: extraStr)
        }
        if object.tags.isEmpty == false {
            self.tags = []
            for tag in object.tags {
                self.tags.append(TSTagModel(object: tag))
            }
        }
    }

    /// 转换为数据库对象
    func object() -> TSUserInfoObject {
        let object = TSUserInfoObject()
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
        for tag in tags {
            let tagObject = tag.object()
            object.tags.append(tagObject)
        }
        return object
    }
    /// TSNetFileModel 兼容处理
    class TSNetFileModelTransfrom: TransformType {
        typealias Object = TSNetFileModel
        typealias JSON = String
        
        func transformFromJSON(_ value: Any?) -> Object? {
            if let string = value as? String {
                /// 构建一个TSNetFileModel
                let model = TSNetFileModel(JSON: ["vendor": "local", "url": string, "mime": ""])
                return model
            }
            if let string = value as? Dictionary<String, Any> {
                return TSNetFileModel(JSON: string)
            }
            return nil
        }
        
        func transformToJSON(_ value: Object?) -> JSON? {
            if let model = value {
                return TSUtil.praseTSNetFileUrl(netFile: model)
            }
            return nil
        }
    }
}

extension TSUserInfoModel {
    /// 获取关注状态
    func getFollowStatus() -> FollowStatus {
        guard userIdentity != TSCurrentUserInfo.share.userInfo?.userIdentity else {
            return .oneself
        }
        if follower {
            return following ? .eachOther : .follow
        } else {
            return .unfollow
        }
    }
}
