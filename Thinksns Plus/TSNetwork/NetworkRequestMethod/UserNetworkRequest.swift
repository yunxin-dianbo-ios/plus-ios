//
//  UserNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/28.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户相关网络请求

import UIKit
import ObjectMapper

struct UserNetworkRequest {
    // MARK: - 赞
    /// 意见反馈
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - content: string. 反馈内容
    ///    - system_mark: Int. 移动端标记，非必填 ，格式为uid+毫秒时间戳
    let ideaFeedback = Request<Empty>(method: .post, path: "user/feedback", replacers: [])

    /// 用户收到的评论
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 整数.获取的条数，默认 20。
    ///    - after: 整数.传递上次获取的最后一条 id
    let receiveComment = Request<ReceiveCommentModel>(method: .get, path: "user/notifications", replacers: [])
    /// 用户收到的喜欢
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: 整数.获取的条数，默认 20。
    ///    - after: 整数.传递上次获取的最后一条 id
    let receiveLike = Request<ReceiveLikeModel>(method: .get, path: "user/notifications", replacers: [])
    /// 收到的at
    let receiveAt = Request<ReceiveCommentModel>(method: .get, path: "user/comments", replacers: [])
    /// 关注指定用户
    static let follow = Request<Empty>(method: .put, path: "user/followings/:user", replacers: [":user"])
    /// 取消关注指定用户
    static let unfollow = Request<Empty>(method: .delete, path: "user/followings/:user", replacers: [":user"])

    /// 修改用户认证
    static let updateVerified = Request<Empty>(method: .patch, path: "user/certification", replacers: [])
    /// 获取一个用户的标签
    let userTags = Request<TSTagModel>(method: .get, path: "users/:user/tags", replacers: [":user"])
    // MARK: - 黑名单
    let addBlackList = Request<Empty>(method: .post, path: "user/black/{target}", replacers: ["{target}"])
    let deleteBlackList = Request<Empty>(method: .delete, path: "user/black/{target}", replacers: ["{target}"])
    let blackList = Request<TSUserInfoModel>(method: .get, path: "user/blacks", replacers: [])
    // MARK: 新增数据
    let counts = Request<UserCounts>(method: .get, path: "user/notification-statistics", replacers: [])
    /// 已读的数据使用 ["type": 已读数据] 传递
    let readCounts = Request<Empty>(method: .patch, path: "user/notifications", replacers: [])
}

struct UserCounts: Mappable {
    var at: At!
    var comment: At!
    var like: At!
    var system: System!
    var follow: Follow!

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        at <- map["at"]
        comment <- map["comment"]
        like <- map["like"]
        system <- map["system"]
        follow <- map["follow"]
    }
    
    struct At: Mappable {
        var badge: Int = 0
        var last_created_at: Date = Date()
        var preview_users_names: [String] = []
        
        init?(map: Map) { }
        
        mutating func mapping(map: Map) {
            badge <- map["badge"]
            last_created_at <- (map["last_created_at"], TSDateTransform)
            preview_users_names <- map["preview_users_names"]
        }
    }
    
    struct System: Mappable {
        var badge: Int = 0
        var first: First!
        
        init?(map: Map) { }
        
        mutating func mapping(map: Map) {
            badge <- map["badge"]
            first <- map["first"]
        }
        
        struct First: Mappable {
            var id: String = ""
            var created_at: Date = Date()
            var data: [String:Any] = [:]
            
            init?(map: Map) { }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                created_at <- (map["created_at"], TSDateTransform)
                data <- map["data"]
            }
        }
    }
    
    struct Follow: Mappable {
        var badge: Int = 0
        
        init?(map: Map) { }
        
        mutating func mapping(map: Map) {
            badge <- map["badge"]
        }
    }
}
