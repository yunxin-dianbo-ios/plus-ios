//
//  TopicListControllerModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TopicListControllerModel {
    /// 圈子 id
    var id = 0
    /// 图片 url
    var coverImage: TSNetFileModel?
    /// 圈子名称
    var name = ""
    /// 成员数
    var memberCount = 0
    /// 地址
    var location = ""
    /// 圈主
    var ownerName = ""
    /// 圈主的用户 id
    var ownerUserId: Int?
    /// 简介
    var intro = ""
    /// 帖子数量
    var postCount = 0
    /// 关注的人数
    var followCount = 0
    /// 关注状态
    var followStatus = false
    /// 成员数量
    var userCount = 0
    /// 黑名单成员数量
    var blackCount: Int = 0
    /// 是否已经加入
    var isJoin = false
    /// 圈子类型
    var mode = ""
    /// 如果是付费圈子，加入时需要支付的价格
    var joinMoney: Int = 0
    /// 当前用户在圈子中的职位
    var role = GroupManagerType.unjoined
    /// 发帖权限
    var capability = PostCapability.all
    /// 话题参与者数组
    var menbers: [TSUserInfoModel] = []

    /// 当前用户在圈子中是否有发帖权限
    var canRealsePost: Bool {
        return capability.canReleasePost(for: role)
    }

    init() {
    }

    /// 从圈子信息 model 初始化
    init(topicModel model: TopicModel) {
        id = model.id
        coverImage = model.avatar
        name = model.name
        intro = model.summary
        postCount = model.postCount
        followCount = model.followCount
        followStatus = model.followStatus
        ownerUserId = model.userId
        ownerName = model.userInfo.name
        menbers = model.menber
    }

}
