//
//  GroupListCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子列表 cell model

import UIKit

/// label 尾部图片
enum TailImage: String {
    /// 置顶
    case top = "IMG_label_zhiding"
    /// 付费
    case pay = "IMG_music_pic_pay_song"
}

class GroupListCellModel {

    /// 详情信息类型
    enum DetailInfoType {
        case none
        /// (帖子数， 成员数)
        case countInfo(Int, Int)
        /// 创建时间
        case create(Date)
    }

    /// 右边控件类型
    enum RightType {
        case none
        /// 加入按钮（是否加入）
        case joinButtonAndRoleTag
        /// 审核信息
        case audit(String)
    }

    /// 圈子 id
    var id = 0
    /// 圈子名称
    var name = ""
    /// 圈子标签图片
    var tailImage: TailImage?
    /// 圈子图片
    var cover = ""
    /// 详情信息
    var detailInfo = DetailInfoType.none
    /// 当前用户在圈子中的职位信息
    var position = ""
    /// 右边视图
    var rightType = RightType.none
    /// 当前用户在圈子中的角色
    var role = GroupManagerType.unjoined
    /// 当前用户的加入的信息
    var joined: GroupJoinModel?
    /// 圈子类型:public: 公开，private：私有，paid：付费的
    var mode = ""
    /// 加入圈子的付费金额
    var joinMoney: Int = 0
    /// 是否允许同步至动态
    var allowFeed: Bool = false
    /// 是否允许进入详情页
    var shouldPushDetail: Bool = false
    init() {
    }

    /// 初始化带同时具有职位标签和加入按钮，成员数和帖子数的 cell model
    init(model: GroupModel) {
        id = model.id
        name = model.name
        cover = TSUtil.praseTSNetFileUrl(netFile: model.avatar) ?? ""
        detailInfo = .countInfo(model.postCount, model.userCount)
        mode = model.mode
        /// 如果是付费圈子，显示付费图片
        if model.mode == GroupModeType.paidGroup.rawValue {
            tailImage = .pay
        }
        role = model.getRoleInfo()
        if model.joined != nil {
            joined = model.joined
        }
        rightType = .joinButtonAndRoleTag
        joinMoney = model.money
        allowFeed = model.allowFeed
        /// 圈子类型:public: 公开，private：私有，paid：付费的
        if (role == .master || role == .manager || role == .member || role == .black) && joined?.audit == 1 {
            shouldPushDetail = true
        }
        if mode == "public" {
            shouldPushDetail = true
        }
    }

    /// 初始化带有审核信息，以及创建日期 cell model
    init(auditType model: GroupModel) {
        id = model.id
        name = model.name
        cover = TSUtil.praseTSNetFileUrl(netFile: model.avatar) ?? ""
        mode = model.mode
        // 如果是付费圈子，显示付费图片
        if model.mode == GroupModeType.paidGroup.rawValue {
            tailImage = .pay
        }

        // 设置审核信息
        var auditInfo = ""
        if model.audit == 0 {
            auditInfo = "创建待审核"
            detailInfo = .create(model.create)
        } else if model.audit == 1 {
            auditInfo = "申请加入待审核"
            if model.joinDate != nil {
                detailInfo = .create(model.joinDate!)
            }
        }
        rightType = .audit(auditInfo)
        role = model.getRoleInfo()
        joinMoney = model.money
        allowFeed = model.allowFeed
        if model.joined != nil {
            joined = model.joined
        }
        if (role == .master || role == .manager || role == .member) && joined?.audit == 1 {
            shouldPushDetail = true
        }
    }

    /// 从帖子列表的 header model 中初始化
    init(postsHeaderModel model: PostListControllerModel) {
        id = model.id
        name = model.name
        cover = model.coverImage
        detailInfo = .countInfo(model.postCount, model.memberCount)
        mode = model.mode
        /// 如果是付费圈子，显示付费图片
        if model.mode == GroupModeType.paidGroup.rawValue {
            tailImage = .pay
        }
        rightType = .joinButtonAndRoleTag
        role = model.role
        joinMoney = model.joinMoney
    }
}
