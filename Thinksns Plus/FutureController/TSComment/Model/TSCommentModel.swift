//
//  TSCommentModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论模型，通用

import Foundation
import ObjectMapper
import RealmSwift

/// 评论应用场景/评论类型
typealias TSCommentSituation = TSCommentType
enum TSCommentType: String {
    /// 动态(动态列表、动态详情、收藏动态)
    case momment = "feeds"
    /// 资讯
    case news = "news"
    /// 音乐 - 专辑
    case album = "music_specials"
    /// 音乐 - 歌曲
    case song = "musics"
    /// 问答 - 问题
    case question = "questions"
    /// 问答 - 答案
    case answer = "question-answers"
    /// 圈子帖子
    case post = "group-posts"

    init(type: ReceiveInfoSourceType) {
        self.init(rawValue: type.rawValue)!
    }
}

/// 评论通用模型
typealias TSCommonCommentModel = TSCommentModel
class TSCommentModel: Mappable {

    // json模型下的数据

    /// 评论id
    var id: Int = 0
    /// 评论者id
    var userId: Int = 0
    /// 评论对象的发布者id
    var targetUserId: Int = 0
    /// 被回复者id，可能不存在
    var replyUserId: Int?
    /// 评论内容
    var body: String = ""
    /// 资源id
    var commentTableId: Int = 0
    /// 资源标识
    var commentTableType: String = ""
    /// 更新时间
    var updateDate: Date?
    /// 创建时间
    var createDate: Date?

    // 其他数据，需输入数据库

    /// 是否置顶
    var isTop: Bool = false

    // 其他数据，无需存入数据库

    /// 评论类型
    var type: TSCommentType? {
        return TSCommentType(rawValue: self.commentTableType)
    }
    /// 三个用户，从数据库中查找，或网络请求用户列表时赋值
    /// 该评论对应的数据库模型中并不存在这3个用户字段
    /// Remark：这里get方法中使用数据库查找的方式获值，若只有get方法，则每次都要查询数据库; 若getset方式，则可能因为nil陷入死循环
    var user: TSUserInfoModel?
    var targetUser: TSUserInfoModel?
    var replyUser: TSUserInfoModel?

    // MARK: - Mappable

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        replyUserId <- map["reply_user"]
        body <- map["body"]
        commentTableId <- map["commentable_id"]
        commentTableType <- map["commentable_type"]
        updateDate <- (map["updated_at"], TSDateTransfrom())
        createDate <- (map["updated_at"], TSDateTransfrom())
    }

    // MARK: - DB

    /// 从数据库模型中加载
    init(object: TSCommentObject) {
        self.id = object.id
        self.userId = object.userId
        self.targetUserId = object.targetUserId
        self.replyUserId = object.replyUserId.value
        self.body = object.body
        self.commentTableId = object.commentTableId
        self.commentTableType = object.commentTableType
        self.updateDate = object.updateDate
        self.createDate = object.createDate
        self.isTop = object.isTop
    }
    /// 转换为对应的数据库模型
    func object() -> TSCommentObject {
        let object = TSCommentObject()
        object.id = self.id
        object.userId = self.userId
        object.targetUserId = self.targetUserId
        object.replyUserId = RealmOptional<Int>(self.replyUserId)
        object.body = self.body
        object.commentTableId = self.commentTableId
        object.commentTableType = self.commentTableType
        object.updateDate = self.updateDate
        object.createDate = self.createDate
        object.isTop = self.isTop
        return object
    }

}

// MARK: - 构建TSSimpleCommentModel

extension TSCommentModel {
    func simpleModel() -> TSSimpleCommentModel {
        var simpleModel = TSSimpleCommentModel()
        simpleModel.content = self.body
        if let date = self.createDate {
            simpleModel.createdAt = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        }
        simpleModel.status = 0
        simpleModel.isTop = false
        simpleModel.id = self.id
        simpleModel.commentMark = Int64(self.id)
//        simpleModel.user = self.user
//        simpleModel.replyUser = self.replyUser
        simpleModel.userInfo = self.user?.object()
        simpleModel.replyUserInfo = self.replyUser?.object()
        simpleModel.isTop = self.isTop
        return simpleModel
    }
}

// MARK: - 构建TSCommentViewModel

extension TSCommentModel {
    func viewModel() -> TSCommentViewModel? {
        guard let type = self.type else {
            return nil
        }
        let viewModel = TSCommentViewModel(id: self.id, userId: self.userId, type: type, user: self.user, replyUser: self.replyUser, content: self.body, createDate: self.createDate, status: .normal, isTop: self.isTop)
        return viewModel
    }
}
