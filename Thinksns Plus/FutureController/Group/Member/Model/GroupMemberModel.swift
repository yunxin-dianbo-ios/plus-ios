//
//  GroupMemberModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子成员的数据模型

import Foundation
import ObjectMapper

/// 圈子成员审核状态
enum GroupMemberAuditStatus: Int {
    /// 待审核
    case wait = 0
    /// 已审核 - 通过
    case agree
    /// 已拒绝 - 驳回
    case reject
}

/// 圈子成员角色
enum GroupMemberRole: String {
    /// 成员
    case member = "member"
    /// 管理者
    case administrator = "administrator"
    /// 创建者 - 群主
    case founder = "founder"
}

/// 成员角色类型 - 用于展示/根据别的参数获取
enum GroupMemberRoleType {
    /// 圈主 - 圈子所有者
    case owner
    /// 管理员
    case administrator
    /// 成员
    case member
    /// 黑名单
    case black
}

class GroupMemberModel: Mappable {

    /// 成员唯一id
    var id: Int = 0
    /// 圈子唯一id
    var groupId: Int = 0
    /// 用户id
    var userId: Int = 0
    /// 0 待审核 1 已审核 2已驳回
    var audit: GroupMemberAuditStatus = .wait
    /// 角色，member - 成员 administrator - 管理者、founder - 创建者
    var role: GroupMemberRole = .member
    /// 是否拉黑 1拉黑
    var disabled: Bool = false
    var created_at: String = ""
    var updated_at: String = ""
    var createDate: Date = Date()
    var updateDate: Date = Date()
    var user: TSUserInfoModel?

    /// 计算属性：角色类型
    var roleType: GroupMemberRoleType {
        var roleType: GroupMemberRoleType
        if self.disabled {
            roleType = .black
        } else {
            switch self.role {
            case .member:
                roleType = .member
            case .founder:
                roleType = .owner
            case .administrator:
                roleType = .administrator
            }
        }
        return roleType
    }

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        groupId <- map["group_id"]
        userId <- map["user_id"]
        audit <- (map["audit"], TransformOf<GroupMemberAuditStatus, Int>(fromJSON: {
            GroupMemberAuditStatus(rawValue: $0!)
        }, toJSON: {
            $0.map { $0.rawValue }
        }))
        role <- (map["role"], TransformOf<GroupMemberRole, String>(fromJSON: {
            GroupMemberRole(rawValue: $0!)
        }, toJSON: {
            $0.map { $0.rawValue }
        }))
        disabled <- map["disabled"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        user <- map["user"]
    }
}

extension GroupMemberModel {
    class func memberRoleTypeWithMemberType(_ memberType: GroupManagerType) -> GroupMemberRoleType? {
        var roleType: GroupMemberRoleType?
        switch memberType {
        case .master:
            roleType = .owner
        case .manager:
            roleType = .administrator
        case .member:
            roleType = .member
        case .black:
            roleType = .black
        case .unjoined:
            roleType = nil
        }
        return roleType
    }
}
