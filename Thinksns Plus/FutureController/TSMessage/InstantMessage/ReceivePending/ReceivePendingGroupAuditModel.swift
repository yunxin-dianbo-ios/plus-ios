//
//  ReceivePendingGroupAuditModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子 待审核成员 数据模型
//  圈子成员的基础上增加 圈子 属性

import Foundation
import ObjectMapper

class ReceivePendingGroupAuditModel: Mappable {

    /// 处理状态
    enum Status: Int {
        case wait = 0
        case agree
        case reject
    }

    /// 记录唯一id
    var id: Int = 0
    /// 圈子唯一id
    var groupId: Int = 0
    /// 用户id
    var userId: Int = 0
    /// 成员id
    var memberId: Int = 0
    /// 处理状态 0-待审核 1-通过 2-拒绝
    var status: Status = .wait
    /// 审核人员id，未审核时为null
    var auditerId: Int?
    /// 审核时间，未审核时为null
    var audit_at: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var auditDate: Date = Date()
    var createDate: Date = Date()
    var updateDate: Date = Date()
    /// 申请用户信息
    var user: TSUserInfoModel?
    /// 所属圈子信息
    var group: GroupModel?
    /// 审核人员
    var auditer: TSUserInfoModel?
    /// 申请人成员信息，在申请人退圈等操作后为null
    var member: GroupMemberModel?

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        groupId <- map["group_id"]
        userId <- map["user_id"]
        memberId <- map["member_id"]
        status <- (map["status"], TransformOf<ReceivePendingGroupAuditModel.Status, Int>(fromJSON: {
            ReceivePendingGroupAuditModel.Status(rawValue: $0!)
        }, toJSON: {
            $0.map { $0.rawValue }
        }))
        auditerId <- map["auditer"]
        audit_at <- map["audit_at"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        auditDate <- (map["audit_at"], TSDateTransfrom())
        createDate <- (map["created_at"], TSDateTransfrom())
        updateDate <- (map["updated_at"], TSDateTransfrom())
        user <- map["user"]
        group <- map["group"]
        auditer <- map["audit_user"]
        member <- map["member_info"]
    }
}
