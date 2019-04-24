//
//  TSUnreadCount.swift
//  ThinkSNS +
//
//  Created by lip on 2017/5/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  应该相关的未读数
//  TODO: 这个类的属性越来越多,持久化建议改为模型加上数据库

import UIKit

/// 未读数类型
///
/// - imMessage: 即时消息
/// - follows: 关注
/// - comments: 评论
/// - like: 点赞
/// - pending: 待审核
/// - mutual: 好友
enum UnreadCountType: String {
    case imMessage
    case follows
    case comments
    case like
    case pending
    case system
    case mutual
    case feedCommentPinned
    case groupJoinPinned
    case postCommentPinned
    case postPinned
    case newsCommentPinned
    case at
}

class TSUnreadCount: NSObject {
    /// 点赞用户信息
    var likedUsers: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "UnreadCountType.likedUsers")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "UnreadCountType.likedUsers")
        }
    }
    /// 点赞用户时间
    var likeUsersDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: "likeUsersDate")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: "likeUsersDate") as? Date
        }
    }
    /// 评论用户信息
    var commentsUsers: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "UnreadCountType.commentsUsers")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "UnreadCountType.commentsUsers")
        }
    }
    /// 评论用户时间
    var commentsUsersDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: "commentsUsersDate")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: "commentsUsersDate") as? Date
        }
    }
    /// 待处理用户信息
    var pendingUsers: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "UnreadCountType.pendingUsers")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "UnreadCountType.pendingUsers")
        }
    }
    /// 待处理用户时间
    var pendingUsersDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: "pendingUsersDate")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: "pendingUsersDate") as? Date
        }
    }
    /// 消息未读数
    var imMessage: Int = 0
    /// 通知是否有未读
    var isHiddenNoticeBadge: Bool = true
    /// 系统消息未读数
    var system: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.system.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.system.rawValue)
        }
    }
    /// 系统消息最近未读信息
    var systemInfo: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.system.rawValue + "info")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: UnreadCountType.system.rawValue + "info")
        }
    }
    /// 系统消息未读时间
    var systemTime: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.system.rawValue + "time")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: UnreadCountType.system.rawValue + "time") as? Date
        }
    }
    /// 未读粉丝数
    var follows: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.follows.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.follows.rawValue)
        }
    }
    /// 未读好友数量
    var mutual: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.mutual.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.mutual.rawValue)
        }
    }
    /// 评论未读数
    var comments: Int {
        get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.comments.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.comments.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    /// 赞未读数
    var like: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.like.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.like.rawValue)
        }
    }
    var allPinned: Int {
        get {
            return self.pending + self.newsCommentPinned + self.feedCommentPinned + self.groupJoinPinned + self.postCommentPinned + self.postPinned
        }
    }
    /// 评论置顶未读数
    var pending: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.pending.rawValue)
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.pending.rawValue)
        }
    }
    /// 资讯评论审核
    var newsCommentPinned: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.newsCommentPinned.rawValue)
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.newsCommentPinned.rawValue)
        }
    }
    /// 动态评论审核
    var feedCommentPinned: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.feedCommentPinned.rawValue)
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.feedCommentPinned.rawValue)
        }
    }
    /// 圈子加入申请
    var groupJoinPinned: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.groupJoinPinned.rawValue)
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.groupJoinPinned.rawValue)
        }
    }
    /// 发布评论审核
    var postCommentPinned: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.postCommentPinned.rawValue)
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.postCommentPinned.rawValue)
        }
    }
    /// 帖子申请置顶审核
    var postPinned: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UnreadCountType.postPinned.rawValue)
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.integer(forKey: UnreadCountType.postPinned.rawValue)
        }
    }

    /// 审核通知类型
    var pendingType: ReceivePendingController.ShowType {
        get {
            // 默认的审核类型为最多未审核内容的一类
            let pendingCounts = [feedCommentPinned, groupJoinPinned, postCommentPinned, postPinned, newsCommentPinned]
            let pendingTypes = [UnreadCountType.feedCommentPinned, UnreadCountType.groupJoinPinned, UnreadCountType.postCommentPinned, UnreadCountType.postPinned, UnreadCountType.newsCommentPinned]
            var mostPendingType = UnreadCountType.feedCommentPinned
            var mostPendingCount = feedCommentPinned
            for (index, item) in pendingCounts.enumerated() {
                if mostPendingCount < item {
                    mostPendingCount = item
                    mostPendingType = pendingTypes[index]
                }
            }
            var showType = ReceivePendingController.ShowType.momentCommentTop
            switch mostPendingType {
            case .feedCommentPinned:
                showType = .momentCommentTop
            case .groupJoinPinned:
                showType = .groupAudit
            case .postCommentPinned:
                showType = .postCommentTop
            case .postPinned:
                showType = .postTop
            case .newsCommentPinned:
                showType = .newsCommentTop
            default:
                showType = .momentCommentTop
            }
            return showType
        }
    }
    /// at我的
    var at: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "UnreadCountType.at")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: "UnreadCountType.at")
        }
    }
    /// 待处理用户信息
    var atUsers: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "UnreadCountType.atUsers")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "UnreadCountType.atUsers")
        }
    }
    /// 评论用户时间
    var atUsersDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: "atUsersDate")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: "atUsersDate") as? Date
        }
    }
    override init() {
        super.init()
        self.comments = UserDefaults.standard.integer(forKey: UnreadCountType.comments.rawValue)
        self.follows = UserDefaults.standard.integer(forKey: UnreadCountType.follows.rawValue)
        self.like = UserDefaults.standard.integer(forKey: UnreadCountType.like.rawValue)
        self.pending = UserDefaults.standard.integer(forKey: UnreadCountType.pending.rawValue)
        self.mutual = UserDefaults.standard.integer(forKey: UnreadCountType.mutual.rawValue)
        self.at = UserDefaults.standard.integer(forKey: "UnreadCountType.at")
    }

    func clearAllUnreadCount() {
        imMessage = 0
        follows = 0
        comments = 0
        like = 0
        pending = 0
        /// 资讯评论审核
        newsCommentPinned = 0
        /// 动态评论审核
        feedCommentPinned = 0
        /// 圈子加入申请
        groupJoinPinned = 0
        /// 发布评论审核
        postCommentPinned = 0
        /// 帖子申请置顶审核
        postPinned = 0

        system = 0
        mutual = 0
        isHiddenNoticeBadge = true
        JPUSHService.setBadge(0)
        UIApplication.shared.applicationIconBadgeNumber = 0
        likedUsers = nil
        commentsUsers = nil
        pendingUsers = nil
        systemInfo = nil
    }

    // 聊天信息\新增好友 不包括在内
    func allNoticeUnreadCount() -> Int {
        return follows + comments + like + pending + system + at + mutual
    }

    // 聊天信息\新增好友 不包括在内
    func onlyNoticeUnreadCount() -> Int {
        return comments + like + pending + system + at
    }
}
