//
//  GroupReportModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子举报数据模型
//      用于圈子举报管理，而不是用于举报。

import Foundation
import ObjectMapper

/// 圈子举报模型状态
enum GroupReportStatus: Int {
    /// 待审核
    case waiting = 0
    /// 已审核 - 已同意
    case accepted
    /// 已驳回
    case rejected
}

/// 圈子举报类型
enum GroupReportType: String {
    /// 帖子
    case post
    /// 评论
    case comment
}

/// 圈子举报列表模型
class GroupReportModel: Mappable {
    /// 举报唯一id
    var id: Int = 0
    /// 举报人id
    var userId: Int = 0
    /// 被举报人 id
    var targetUserId: Int = 0
    /// 圈子id
    var groupId: Int = 0
    /// type： post-帖子id comment-评论id
    var resourceId: Int = 0
    /// 举报类型 post 帖子举报 comment 评论举报
    //var type: String = ""
    var type: GroupReportType?
    // 举报内容
    var content: String = ""
    // 举报状态 0 待审核 1 已审核 2 已驳回
    //var status: Int = 0
    var status: GroupReportStatus = .waiting
    /// 驳回原因
    var cause: String?
    // 审核处理人 id
    var handlerUserId: Int = 0

    var created_at: String = ""
    var updated_at: String = ""
    var createDate: Date = Date()
    var updateDate: Date = Date()

    /// resource
    var comment: TSCommentModel?
    //var post: PostListModel?
    var post: PostDetailModel?

    /// 举报人信息
    var user: TSUserInfoModel?
    /// 被举报人信息
    var targetUser: TSUserInfoModel?

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_id"]
        groupId <- map["group_id"]
        resourceId <- map["resource_id"]
        //type <- map["type"]
        type <- (map["type"], groupReportTypeTransform)
        content <- map["content"]
        //status <- map["status"]
        status <- (map["status"], groupReportStatusTransform)
        cause <- map["cause"]
        handlerUserId <- map["handler"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        createDate <- (map["created_at"], TSDateTransform)
        updateDate <- (map["updated_at"], TSDateTransform)
        user <- map["user"]
        targetUser <- map["target"]

        // 资源，根据类型
        if type == .post {
            post <- map["resource"]
        } else if type == .comment {
            comment <- map["resource"]
        }
    }

    fileprivate let groupReportStatusTransform = TransformOf<GroupReportStatus, Int>(fromJSON: { (value: Int?) -> GroupReportStatus? in
        var reportStatus: GroupReportStatus?
        if let intValue = value {
            //return GroupReportStatus.init(rawValue: intValue)
            switch intValue {
            case 0:
                reportStatus = GroupReportStatus.waiting
            case 1:
                reportStatus = GroupReportStatus.accepted
            case 2:
                reportStatus = GroupReportStatus.rejected
            default:
                break
            }
        }
        return reportStatus
    }) { (status: GroupReportStatus?) -> Int? in
        return status?.rawValue
    }

    fileprivate let groupReportTypeTransform = TransformOf<GroupReportType, String>(fromJSON: { (value: String?) -> GroupReportType? in
        var reportType: GroupReportType?
        if let stringValue = value {
            //return GroupReportType.init(rawValue: stringValue)
            switch stringValue {
            case "post":
                reportType = .post
            case "comment":
                reportType = .comment
            default:
                break
            }
        }
        return reportType
    }) { (type: GroupReportType?) -> String? in
        return type?.rawValue
    }

}
