//
//  TSLikeUserModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞用户数据模型

import UIKit
import ObjectMapper

typealias TSFavorListModel = TSLikeUserModel
class TSLikeUserModel: Mappable {
    /// 点赞列表的标识
    var id: Int!
    /// 用户标识
    var userId: Int!
    /// 目标用户标识
    var targetUserId: Int!
    /// 点赞的资源 ID,具体内容不详
    var likeableId: Int!
    /// 点赞的资源类型
    var likeableTypeValue: String!
    /// 创建时间
    var createdDate: Date!
    /// 更新时间
    var updatedDate: Date?
    /// 用户详细信息
    var userDetail: TSUserInfoModel!

    init() {
    }
    /// 自己构造点赞用户模型
    init(userId: Int, user: TSUserInfoModel, sourceId: Int, likeType: String = "") {
        self.userId = userId
        self.userDetail = user
        self.likeableId = sourceId
        // 注：点赞资源类型应该使用枚举，便于外界构造传入和别处使用
        self.likeableTypeValue = likeType
        self.createdDate = Date()
        self.updatedDate = Date()
        self.id = 0
        self.targetUserId = 0
    }

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        likeableId <- map["likeable_id"]
        likeableTypeValue <- map["likeable_type"]
        createdDate <- (map["created_at"], TSDateTransfrom())
        updatedDate <- (map["updated_at"], TSDateTransfrom())
        userDetail <- map["user"]
    }
}
