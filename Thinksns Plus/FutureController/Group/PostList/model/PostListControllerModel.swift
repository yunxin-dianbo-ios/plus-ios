//
//  PostListControllerModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class PostListControllerModel {

    /// 圈子 id
    var id = 0
    /// 图片 url
    var coverImage = ""
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

    /// 当前用户在圈子中是否有发帖权限
    var canRealsePost: Bool {
        return capability.canReleasePost(for: role)
    }

    init() {
    }

    /// 从圈子信息 model 初始化
    init(groupModel model: GroupModel) {
        id = model.id
        coverImage = TSUtil.praseTSNetFileUrl(netFile: model.avatar) ?? ""
        name = model.name
        memberCount = model.userCount
        location = model.location
        ownerName = model.founder?.name ?? ""
        ownerUserId = model.founder?.userIdentity
        intro = model.summary
        postCount = model.postCount
        userCount = model.userCount
        blackCount = model.blackCount
        isJoin = model.joined != nil
        mode = model.mode
        role = model.getRoleInfo()
        joinMoney = model.money
        capability = model.getPostCapabilityType()
    }

}
