//
//  NoticeNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  通知网络请求

import UIKit
import ObjectMapper

import SwiftDate

struct NoticeNetworkRequest {
    /// 通知列表
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - limit: Integer, 获取条数，默认 20
    ///    - offset: Integer, 数据偏移量，默认 0
    ///    - type: String, 获取通知类型，可选 all,read,unread 默认 all
    ///    - notification: String|Array, 检索具体通知，可以是由 , 拼接的 IDs 组，也可以是 Array
    let notiList = Request<NoticeModel>(method: .get, path: "user/notifications", replacers: [])
    /// 获取消息详情
    ///
    /// - RouteParameter:
    ///    - notification: 通知标识
    /// - RequestParameter: None
    /// - Warning: 服务器标记该条通知已读
    let notiInfo = Request<NoticeModel>(method: .get, path: "user/notifications/{notification}", replacers: ["{notification}"])
    /// 标记所有消息已读
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let readAllNoti = Request<Empty>(method: .patch, path: "user/notifications", replacers: [])
    /// 获取用户未读**消息**详情,未读数,未读人等
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let unreadDetailInfo = Request<UnreadDetailInfoModel>(method: .get, path: "user/unread-count", replacers: [])
}

///
struct UnreadPinnedsModel: Mappable {
    /// 资讯数
    var newsCount: Int = 0
    /// 资讯申请时间
    var newsDate: Date?
    /// 动态数
    var feedsCount: Int = 0
    /// 动态申请时间
    var feedsDate: Date?
    /// 圈子帖子 申请置顶
    var postCount: Int = 0
    var postDate: Date?
    /// 圈子帖子评论 申请置顶
    var postCommentCount: Int = 0
    var postCommentDate: Date?

    init() {
    }
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        newsCount <- map["news.count"]
        newsDate <- (map["news.time"], TSDateTransfrom())
        feedsCount <- map["feeds.count"]
        feedsDate <- (map["feeds.time"], TSDateTransfrom())
        postCount <- map["group-posts.count"]
        postDate <- (map["group-posts.time"], TSDateTransfrom())
        postCommentCount <- map["group-comments.count"]
        postCommentDate <- (map["group-comments.time"], TSDateTransfrom())
    }
}

struct UnreadDetailInfoUserModel: Mappable {
    /// 操作时间
    var time: Date = Date()
    /// 用户
    var user: TSUserInfoModel = TSUserInfoModel()

    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        time <- (map["time"], TSDateTransfrom())
        user <- map["user"]
    }
}

struct UnreadAtMeInfoModel: Mappable {
    /// 操作时间
    var time: Date = Date()
    /// 用户
    var userNames: [String] = []
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        time <- (map["latest_at"], TSDateTransfrom())
        userNames <- map["users"]
    }
}
struct UnreadSystemInfoModel: Mappable {
    /// 系统消息时间
    var time: Date = Date()
    /// 消息内容
    var content: String = ""
    init?(map: Map) { }

    mutating func mapping(map: Map) {
        time <- (map["created_at"], TSDateTransfrom())
        content <- map["data.content"]
    }
}

struct UnreadDetailInfoModel: Mappable {
    /// 评论未读数
    var commentsCount: Int = 0
    /// 点赞未读数
    var likesCount: Int = 0
    /// 加入圈子未读数
    var groupJoinCount: Int = 0
    /// 系统消息未读数
    var system: Int = 0
    /// 未操作数
    var unreadPinneds: UnreadPinnedsModel = UnreadPinnedsModel()
    /// 评论产生者
    var commentsUsers: [UnreadDetailInfoUserModel] = []
    /// 点赞产生者
    var likesUsers: [UnreadDetailInfoUserModel] = []
    /// 系统消息内容
    var systemInfo: UnreadSystemInfoModel?
    /// at我的
    var atUsers: UnreadAtMeInfoModel?

    /// 待操作时间
    var pinnedsDate: Date? {
        guard let feedsDate = unreadPinneds.feedsDate, let newsDate = unreadPinneds.newsDate else {
            if unreadPinneds.feedsDate == nil && unreadPinneds.newsDate != nil {
                return unreadPinneds.newsDate
            }
            if unreadPinneds.feedsDate != nil && unreadPinneds.newsDate == nil {
                return unreadPinneds.feedsDate
            }
            return nil
        }
        return feedsDate > newsDate ? feedsDate : newsDate
    }
    /// 审核通知类型(有未读审核操作时，直接显示该类型；没有则显示默认的动态评论置顶；有多个时则先来后到)
    var pinnedType: ReceivePendingController.ShowType {
        var pinnedType: ReceivePendingController.ShowType = .momentCommentTop
        if unreadPinneds.feedsCount > 0 {
            pinnedType = .momentCommentTop
        } else if unreadPinneds.newsCount > 0 {
            pinnedType = .newsCommentTop
        } else if unreadPinneds.postCommentCount > 0 {
            pinnedType = .postCommentTop
        } else if unreadPinneds.postCount > 0 {
            pinnedType = .postTop
        } else if self.groupJoinCount > 0 {
            pinnedType = .groupAudit
        }
        return pinnedType
    }

    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        commentsCount <- map["counts.unread_comments_count"]
        likesCount <- map["counts.unread_likes_count"]
        groupJoinCount <- map["counts.unread_group_join_count"]
        system <- map["counts.system"]
        unreadPinneds <- map["pinneds"]
        commentsUsers <- map["comments"]
        likesUsers <- map["likes"]
        systemInfo <- map["system"]
        atUsers <- map["atme"]
    }
}

/// 通知类型,用户接口查询参数中
///
/// - all: 所有通知
/// - read: 已读通知
/// - unread: 未读通知
enum NoticeType: String {
    case all
    case read
    case unread
}

struct NoticeModel: Mappable {
//    /// 标识
//    var id: String!
//    /// 已读时间
//    var readDate: Date?
//    /// 详细数据
//    var detail: NoticeDetailModel!
//    /// 创建时间
//    var createdDate: Date!
    var data:[NoticeDetailModel] = []
    var links:[String:Any] = [:]
    var meta:[String:Any] = [:]

    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
//        id <- map["id"]
//        readDate <- (map["read_at"], TSDateTransfrom())
//        detail <- map["data"]
//        createdDate <- (map["created_at"], TSDateTransfrom())
        data <- map["data"]
        links <- map["links"]
        data <- map["data"]
    }
}

struct NoticeDetailModel: Mappable {
//    /// 类型关键字
//    var channel: String!
//    /// 目标 (抽象概念)
//    var target: Int!
//    /// 通知内容
//    var content: String!
//    /// 扩展内容
//    var extra: Any?
//    /// 用户信息
//    var userInfo: TSUserInfoModel?
    var id: String = ""
    var created_at: Date = Date()
    var data: [String:Any] = [:]

    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
//        channel <- map["channel"]
//        target <- map["target"]
//        content <- map["content"]
//        extra <- map["extra"]
//        userInfo <- map["extra.user"]
        id <- map["id"]
        created_at <- (map["created_at"], TSDateTransfrom())
        data <- map["data"]
    }
}
