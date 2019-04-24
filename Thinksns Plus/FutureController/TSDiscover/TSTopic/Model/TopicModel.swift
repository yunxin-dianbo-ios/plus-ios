//
//  TopicModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

/// 话题详情顶部视图model
class TopicModel: Mappable {

    /// 圈子 id
    var id = 0
    /// 圈子名称
    var name = ""
    /// 创建者id
    var userId = 0
    /// 创建者信息
    var userInfo = TSUserInfoModel()
    /// 发帖权限:member,administrator,founder 所有，administrator,founder 管理员和圈主，administrator圈主
    var permissions = ""
    /// 简介
    var summary = ""
    /// 帖子数
    var postCount = 0
    /// 关注的人数
    var followCount = 0
    /// 审核状态:0 未审核 1 通过 2 拒绝
    var audit = 0
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()
    /// 封面
    var avatar: TSNetFileModel?
    /// 关注状态
    var followStatus = false
    /// 话题参与者数据
    var menber: [TSUserInfoModel] = []
    var menberID: [Int] = []

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        userId <- map["creator_user_id"]
        userInfo <- map["user"]
        permissions <- map["permissions"]
        summary <- map["desc"]
        postCount <- map["feeds_count"]
        audit <- map["audit"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
        avatar <- map["logo"]
        followCount <- map["followers_count"]
        followStatus <- map["has_followed"]
        menberID <- map["participants"]
    }
}

extension TopicModel {
    /// 修改圈子信息时，将修改后的圈子模型的数据与之前的模型同步更新
    func updateWithTopic(_ name: String) -> Void {
        self.name = name
    }

    func setUserInfo(user: TSUserInfoModel) {
        self.userInfo = user
    }

    func setMenber(menber: [TSUserInfoModel]) {
        self.menber = menber
    }
}
