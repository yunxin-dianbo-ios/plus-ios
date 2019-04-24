//
//  GroupModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 圈子网络数据模型

import UIKit
import ObjectMapper

enum GroupModeType: String {
    /// 付费圈子
    case paidGroup = "paid"
    /// 公开圈子
    case publicGroup = "public"
    /// 私有圈子
    case privateGroup = "private"
}

class GroupModel: Mappable {

    /// 圈子 id
    var id = 0
    /// 圈子名称
    var name = ""
    /// 创建者id
    var userId = 0
    /// 创建者信息
    var userInfo = TSUserInfoModel()
    /// 圈主
    var founder: TSUserInfoModel?
    /// 分类
    var categoryInfo = GroupCategoryModel()
    /// 位置
    var location = ""
    /// 经度
    var longtitude = ""
    /// 纬度
    var latitude = ""
    /// geo hash
    var geoHash = ""
    /// 是否允许同步动态，0 不允许 1允许
    var allowFeed: Bool = false
    /// 圈子类型:public: 公开，private：私有，paid：付费的
    var mode = ""
    /// 发帖权限:member,administrator,founder 所有，administrator,founder 管理员和圈主，administrator圈主
    var permissions = ""
    /// 如果 mode 为 paid 用于标示收费金额
    var money = 0
    /// 简介
    var summary = ""
    /// 公告
    var notice = ""
    /// 成员数
    var userCount = 0
    /// 黑名单成员数
    var blackCount: Int = 0
    /// 帖子数
    var postCount = 0
    /// 精华帖子数
    var excellenPostsCount = 0
    /// 审核状态:0 未审核 1 通过 2 拒绝
    var audit = 0
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()
    /// 加入时间
    var joinDate: Date?
    /// 加圈收益统计
    var joinIncomeCount = 0
    /// 置顶收益统计
    var pinnedIncomeCount = 0
    /// 头像
    var avatar: TSNetFileModel?
    /// 是否加入：null未加入
    var joined: GroupJoinModel?
    /// 标签
    var tags: [GroupTagModel] = []

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        userId <- map["user_id"]
        userInfo <- map["user"]
        categoryInfo <- map["category"]
        location <- map["location"]
        longtitude <- map["longitude"]
        latitude <- map["latitude"]
        geoHash <- map["geo_hash"]
        allowFeed <- map["allow_feed"]
        mode <- map["mode"]
        permissions <- map["permissions"]
        money <- map["money"]
        summary <- map["summary"]
        notice <- map["notice"]
        userCount <- map["users_count"]
        postCount <- map["posts_count"]
        excellenPostsCount <- map["excellen_posts_count"]
        blackCount <- map["blacklist_count"]
        audit <- map["audit"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
        joinDate <- (map["join_at"], TSDateTransfrom())
        joinIncomeCount <- map["join_income_count"]
        pinnedIncomeCount <- map["pinned_income_count"]
        joined <- map["joined"]
        avatar <- map["avatar"]
        tags <- map["tags"]
        founder <- map["founder.user"] //
    }
}

extension GroupModel {
    /// 修改圈子信息时，将修改后的圈子模型的数据与之前的模型同步更新
    func updateWithBuildGroup(_ buildGroup: BuildGroupModel) -> Void {
        self.name = buildGroup.name
        self.allowFeed = buildGroup.allowFeed
        self.summary = buildGroup.intro
        self.mode = buildGroup.mode
        self.notice = buildGroup.notice
        //self.money = buildGroup.money
        // 其他部分暂时不同步，暂时主要是同步动态属性需要
    }
}

/// 发帖权限
enum PostCapability: String {
    /// 所有成员
    case all = "所有成员"
    /// 仅圈主
    case onlyMaster = "仅圈主"
    /// 仅圈主和管理员
    case masterAndManager = "仅圈主和管理员"

    /// 判断某个圈子的角色类型是否能发帖
    func canReleasePost(for role: GroupManagerType) -> Bool {
        switch self {
        case .all:
            return role != .black
        case .onlyMaster:
            return role == .master
        case .masterAndManager:
            return role == .master || role == .manager
        }
    }
}

extension GroupModel {
    /// 获取发帖权限
    func getPostCapabilityType() -> PostCapability {
        // member,administrator,founder 所有，administrator,founder 管理员和圈主，administrator
        switch permissions {
        case "member,administrator,founder":
            return .all
        case "founder,administrator":
            return .masterAndManager
        case "founder":
            return .onlyMaster
        default:
            return .all
        }
    }

    /// 获取当前用户在圈子中的角色信息
    func getRoleInfo() -> GroupManagerType {
        guard let joinInfo = joined else {
            return .unjoined
        }
        if joinInfo.disabled == 1 {
            return .black
        }
        switch joinInfo.role {
        case "member":
            return .member
        case "administrator":
            return .manager
        case "founder":
            return .master
        default:
            return .unjoined
        }
    }
    /// 获取当前用户的审核状态
//    func getAuditState() -> GroupMemberAuditStatus {
//        guard let joinInfo = joined else {
//            return .wait
//        }
//        
//    }
}

/// 用户加入圈子的信息 model
class GroupJoinModel: Mappable {

    /// 成员唯一id
    var id = 0
    /// 所属圈子id
    var groupId = 0
    /// 用户Id
    var userId = 0
    /// 待审核 1已审核 2驳回
    var audit = 0
    /// 角色 member-普通成员 administrator - 管理者 founder - 创建者
    var role = ""
    /// 是否被拉黑禁用 1-禁用 0-正常
    var disabled = 0
    /// 创建时间
    var create = Date()
    /// 更新时间
    var update = Date()

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        groupId <- map["group_id"]
        userId <- map["user_id"]
        audit <- map["audit"]
        role <- map["role"]
        disabled <- map["disabled"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }

}

/// 圈子标签数据 model（没有看到后台文档）
class GroupTagModel: Mappable {

    var id = 0
    var name = ""
    var categoryId = 0
    var weight = 0

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        categoryId <- map["tag_category_id"]
        weight <- map["weight"]
    }
}

/// 圈子分类数据 model
class GroupCategoryModel: Mappable {

    var id = 0
    var name = ""
    var sortBy = 0
    var status = 0
    var create = Date()
    var update = Date()

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        sortBy <- map["sort_by"]
        status <- map["status"]
        create <- (map["created_at"], TSDateTransfrom())
        update <- (map["updated_at"], TSDateTransfrom())
    }
}

/// 无处安放的一些关于圈子的信息
class GroupsInfoModel: Mappable {

    /// 圈子总数
    var count = 0

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        count <- map["count"]
    }

}
