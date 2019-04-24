//
//  TSMessageObject.swift
//  Thinksns Plus
//
//  Created by lip on 2017/3/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  聊天消息数据 (聊天核心和数据库均使用该类)

import RealmSwift

/// 消息类
///
/// - Note :
///    - : 当你需要发送一条文本消息时,设置 messageContent 为文本消息内容(可以包含emoji表情),然后设置messageType = 0
///    - : 当你需要发送一条自定义消息时,建议不设置 messageContent,然后同时设置 extend,和 extendCode
class TSMessageObject: Object {
    /// 消息发送者唯一标识
    ///
    /// - Note: 该标识由对接智播云服务器的客户服务器生成
    dynamic var fromUserID: Int = -1
    /// 接收到消息时,消息所属的会话的会话编号
    dynamic var conversationID: Int = -1
    /// 消息内容
    dynamic var messageContent: String? = nil
    /// 消息类型
    dynamic var messageType: Int = -1
    /// 扩展内容
    dynamic var extend: String? = nil
    /// 消息阅读标识
    dynamic var isRead: Bool = false
    /// 消息删除标识
    dynamic var isDelete: Bool = false
    /// 消息在会话中的序列号
    let serialNumber = RealmOptional<Int>()
    /// 消息发送成功状态
    ///
    /// - Note: 消息发送初存入数据库时,该值为空
    let isOutgoing = RealmOptional<Bool>()
    /// 消息发送时间
    dynamic var timeStamp: NSDate = NSDate()
    /// 消息发送后服务器成功响应时间
    ///
    /// - Note: 发送时,该时间等于本地时间,之后替换,如果发送失败则依旧等于本地时间
    dynamic var responseTimeStamp: NSDate = NSDate()
    /// 主键
    /// 
    /// - Note: 使用发送时间`timeStamp`转换后的毫秒级时间戳记录
    dynamic var key: Int = 0

    override class func primaryKey() -> String {
        return "key"
    }
}
