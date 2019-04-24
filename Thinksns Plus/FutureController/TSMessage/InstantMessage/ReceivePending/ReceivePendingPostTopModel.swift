//
//  ReceivePendingPostTopModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 22/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子置顶数据模型
//  该数据模型还需要添加圈子部分

import Foundation
import ObjectMapper

class ReceivePendingPostTopModel: Mappable {

    /// 处理状态
    enum Status: Int {
        /// 待审核
        case wait = 0
        /// 已通过
        case agree
        /// 已拒绝
        case reject
    }

    /// 数据id
    var id: Int = 0
    /// 置顶类型 有comment 评论置顶和post帖子置顶两种，该接口中始终为post
    var channel: String = "post"
    /// 当channel 为comment时为帖子id，该接口中始终为0
    var raw: Int = 0
    /// 帖子id
    var target: Int = 0
    /// 申请人id
    var userId: Int = 0
    /// 申请对方id，该接口中始终等于当前认证用户id
    var targetUserId: Int = 0
    /// 置顶金额，分单位
    var amount: Int = 0
    /// 置顶天数
    var day: Int = 0
    /// 置顶过期时间 （被拒绝时为拒绝处理的操作时间）
    var expires_at: String = ""
    /// 处理状态 0-待审核 1-已通过 2-已拒绝
    //var status: Int = 0
    var status: Status = ReceivePendingPostTopModel.Status.wait
    /// 数据创建时间，可视为用户申请时间
    var created_at: String = ""
    /// 申请者用户信息，参考对应用户数据
    var user: TSUserInfoModel?
    /// 申请的帖子信息，参考帖子数据
    var post: PostDetailModel?
    var createDate: Date = Date()
    var expireDate: Date?

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        id <- map["id"]
        channel <- map["channel"]
        raw <- map["raw"]
        target <- map["target"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        amount <- map["amount"]
        day <- map["day"]
        expires_at <- map["expires_at"]
        //status <- map["status"]
        status <- (map["status"], TransformOf<ReceivePendingPostTopModel.Status, Int>(fromJSON: {
            if $0 != nil {
                return ReceivePendingPostTopModel.Status(rawValue: $0!)
            }
            return nil
        }, toJSON: {
            $0.map { $0.rawValue }
        }))
        created_at <- map["created_at"]
        user <- map["user"]
        post <- map["post"]
        createDate <- (map["id"], TSDateTransfrom())
        expireDate <- (map["id"], TSDateTransfrom())
    }

}
