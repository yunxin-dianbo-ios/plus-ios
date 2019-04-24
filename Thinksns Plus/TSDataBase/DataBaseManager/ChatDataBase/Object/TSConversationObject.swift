//
//  TSConversationObject.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  会话信息的数据库对象
//  该对象由服务器返回的数据信息转换

import UIKit
import RealmSwift

class TSConversationObject: Object {
    /// 接收信息的用户名
    dynamic var incomingUserName = ""
    /// 接收信息的用户唯一标识
    dynamic var incomingUserIdentity: Int = -1
    /// 会话唯一标识
    ///
    /// - Note: 用于查阅数据库
    dynamic var identity: Int = -1
    /// 最新的会话信息内容
    dynamic var latestMessage: String? = nil
    /// 最新消息的时间
    ///
    /// - Note: 由服务器提供
    dynamic var latestMessageDate: NSDate? = nil
    /// 未读消息数量
    dynamic var unreadCount: Int = 0
    /// 最新消息发送结果
    let isSendingLatestMessage = RealmOptional<Bool>()

    override class func primaryKey() -> String {
        return "identity"
    }
}
