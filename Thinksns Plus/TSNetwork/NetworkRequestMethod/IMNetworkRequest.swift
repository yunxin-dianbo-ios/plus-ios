//
//  IMNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  即时聊天网络请求

import UIKit
import ObjectMapper

struct IMNetworkRequest {
    // MARK: - 口令
    /// 获取口令
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let token = Request<IMTokenModel>(method: .get, path: "im/users", replacers: [])
    /// 刷新口令
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - password: string, **必传** 旧的授权码(im_password)
    let refreshToken = Request<IMTokenModel>(method: .patch, path: "im/users", replacers: [])
    // MARK: - 会话
    /// 创建会话
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - type: int,yes.会话类型 0 私有会话 1 群组会话 2聊天室会话
    ///    - name: string,no.会话名称
    ///    - pwd: string,no.会话加入密码,type=0时该参数无效
    ///    - uids: (array string),no.会话初始成员，数组集合或字符串列表``"1,2,3,4"type=0`时需要两个uid、type=`1`时需要至少一个、type=`2`时此参数将忽略;注意：如果不合法的uid或uid未注册到IM,将直接忽略
    let createConversation = Request<TSConversationModel>(method: .post, path: "im/conversations", replacers: [])
    /// 获取会话信息
    ///
    /// - RouteParameter:
    ///    - cid: 会话标识
    /// - RequestParameter: None
    let conversationInfo = Request<TSConversationModel>(method: .get, path: "im/conversations/{cid}", replacers: ["{cid}"])
    /// 当前登录用户的会话列表
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let conversationList = Request<TSConversationModel>(method: .get, path: "im/conversations/list/all", replacers: [])
}

struct TSConversationModel: Mappable {
    /// 会话创建者唯一标识
    var createUserId: Int!
    /// 会话唯一标识
    var identity: Int!
    /// 会话名称
    var name: String?
    /// 会话密码
    var password: String!
    /// 会话类型
    var type: TSConversationType = .privately
    /// 会话成员
    var member: Array<Int> = []
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        createUserId <- map["user_id"]
        identity <- map["cid"]
        name <- map["name"]
        password <- map["pwd"]
        member <- (map["uids"], StringArrayTransfrom())
    }
    /// 获取单一会话的接收消息对象
    func getIncomingUserId() -> Int {
        guard let userIdentity = TSCurrentUserInfo.share.userInfo?.userIdentity else {
            fatalError("获取聊天信息失败")
        }
        assert(self.member.count == 2, "只能获取私聊时,接收消息对象的 id")
        for value in member {
            if value != userIdentity {
                return value
            }
        }
        fatalError("无法查询到发送用户的ID")
    }
}

struct IMTokenModel: Mappable {
    static let TSIMAccountTokenModelSaveKey = "IMTokenModelSaveKey"
    /// 即时聊天登录口令
    var imToken: String!
    /// 用户标识
    var userIdentity: Int?

    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        imToken <- map["im_password"]
        userIdentity <- map["user_id"]
    }
    /// 快速构造器
    init(token imToken: String) {
        self.imToken = imToken
    }
    /// 通过沙盒内数据初始化
    init?() {
        guard let imToken = UserDefaults.standard.string(forKey: IMTokenModel.TSIMAccountTokenModelSaveKey) else {
            return nil
        }
        self.imToken = imToken
    }

    /// 持久化相关信息
    func save() {
        UserDefaults.standard.set(self.imToken, forKey: IMTokenModel.TSIMAccountTokenModelSaveKey)
        UserDefaults.standard.synchronize()
    }

    /// 重置相关信息
    static func reset() {
        UserDefaults.standard.removeObject(forKey: IMTokenModel.TSIMAccountTokenModelSaveKey)
        UserDefaults.standard.synchronize()
    }
}
