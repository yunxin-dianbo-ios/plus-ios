//
//  TSFailedCommentModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 19/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  发送失败的评论数据模型

import Foundation
import SwiftyJSON
import ObjectMapper
import RealmSwift

/// 发送失败的评论数据模型
class TSFailedCommentModel {
    /// 评论id
    var id: Int = 0
    /// 资源标识
    var commentTableType: String = ""
    /// 资源Id
    var commentTableId: Int = 0
    /// 评论者id
    var userId: Int = 0
    /// 资源作者id
    var targetUserId: Int = 0
    /// 回复者id
    var replyUserId: Int?
    /// 创建时间
    var createDate: Date?
    /// 更新时间
    var updateDate: Date?
    /// 评论内容
    var body: String = ""

    /// 评论类型，无需存储数据库。构造传入对commentTableType进行赋值或根据commentTableType进行赋值
    var type: TSCommentType?

    /// 三个用户，从数据库中查找，但该评论对应的数据库模型中并不存在这3个用户字段
    var user: TSUserInfoModel?
    var targetUser: TSUserInfoModel?
    var replyUser: TSUserInfoModel?

    // 构造方法
    init(type: TSCommentType, sourceId: Int, content: String, targetUserId: Int, replyUserId: Int?) {
        // id的自增
        self.id = TSFailedCommentObject.incrementaID()
        self.type = type
        self.commentTableType = type.rawValue
        self.commentTableId = sourceId
        self.userId = TSCurrentUserInfo.share.userInfo?.userIdentity ?? 0
        self.targetUserId = targetUserId
        self.replyUserId = replyUserId
        self.createDate = Date()
        self.updateDate = Date()
        self.body = content
    }

    // MARK: - DB
    init(object: TSFailedCommentObject) {
        self.id = object.id
        self.commentTableType = object.commentTableType
        self.commentTableId = object.commentTableId
        self.userId = object.userId
        self.targetUserId = object.targetUserId
        self.replyUserId = object.replyUserId.value
        self.createDate = object.createDate
        self.updateDate = object.updateDate
        self.body = object.body
        self.type = TSCommentType(rawValue: object.commentTableType)
    }
    func object() -> TSFailedCommentObject {
        let object = TSFailedCommentObject()
        object.id = self.id
        object.commentTableType = self.commentTableType
        object.commentTableId = self.commentTableId
        object.userId = self.userId
        object.targetUserId = self.targetUserId
        object.replyUserId = RealmOptional<Int>(self.replyUserId)
        object.createDate = self.createDate
        object.updateDate = self.updateDate
        object.body = self.body
        return object
    }
}

// MARK: - 构建TSSimpleCommentModel

extension TSFailedCommentModel {
    func simpleModel() -> TSSimpleCommentModel {
        var simpleModel = TSSimpleCommentModel()
        simpleModel.content = self.body
        if let date = self.createDate {
            simpleModel.createdAt = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        }
        simpleModel.status = 1
        simpleModel.isTop = false
        simpleModel.id = self.id
        simpleModel.commentMark = Int64(self.id)
//        simpleModel.user = self.user
//        simpleModel.replyUser = self.replyUser
        simpleModel.userInfo = self.user?.object()
        simpleModel.replyUserInfo = self.replyUser?.object()
        return simpleModel
    }
}

// MARK: - 构建TSCommentViewModel

extension TSFailedCommentModel {
    func viewModel() -> TSCommentViewModel? {
        guard let type = self.type else {
            return nil
        }
        let viewModel = TSCommentViewModel(id: self.id, userId: self.userId, type: type, user: self.user, replyUser: self.replyUser, content: self.body, createDate: self.createDate, status: .faild, isTop: false)
        return viewModel
    }
}
