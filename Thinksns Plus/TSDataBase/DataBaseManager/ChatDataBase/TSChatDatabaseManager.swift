//
//  TSChatDatabaseManager.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import RealmSwift

class TSChatDatabaseManager {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    convenience init() {
        let realm = try! Realm()
        self.init(realm)
    }

    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init(_ realm: Realm) {
        self.realm = realm
    }

    func deleteAll() {
        let conversations = realm.objects(TSConversationObject.self)
        let messages = realm.objects(TSMessageObject.self)
        let conversationUtils = realm.objects(TSConversationUtilDataObject.self)
        realm.beginWrite()
        realm.delete(conversations)
        realm.delete(messages)
        realm.delete(conversationUtils)
        try! realm.commitWrite()
        self.deleteAllConversationUtilData()
    }

    // MARK: - message
    func allMessages() -> Results<TSMessageObject> {
        return realm.objects(TSMessageObject.self).sorted(byKeyPath: "responseTimeStamp")
    }

    func getMessageObject(with time: NSDate) -> TSMessageObject? {
        let predicate = NSPredicate(format: "timeStamp == %@", time)
        let messageObjects = realm.objects(TSMessageObject.self).filter(predicate)
        if messageObjects.isEmpty {
            return nil
        }
        return messageObjects.first
    }

    func getMaxSerialNumber(with cid: Int) -> Int? {
        let messageObjects = realm.objects(TSMessageObject.self).filter("conversationID == \(cid) AND serialNumber != nil").sorted(byKeyPath: "serialNumber", ascending: false)
        if messageObjects.isEmpty {
            return nil
        }
        return messageObjects.first?.serialNumber.value
    }

    func getUnreadCount(with conversationId: Int) -> Int {
        let predicate = NSPredicate(format: "conversationID = \(conversationId) AND isRead = false")
        return realm.objects(TSMessageObject.self).filter(predicate).count
    }

    /// 标记该消息为已读
    func readMessage(time: NSDate) {
        guard let messageObject = getMessageObject(with: time) else {
            fatalError("数据库无该数据")
        }
        realm.beginWrite()
        messageObject.isRead = true
        try! realm.commitWrite()
    }

    /// 标记该会话所有消息为已读
    func read(messages conversationId: Int) {
        let messages = getUnreadMessages(with: conversationId)
        if messages.isEmpty {
            return
        }
        realm.beginWrite()
        for message in messages {
            message.isRead = true
        }
        try! realm.commitWrite()
    }

    func delete(message: TSMessageObject) {
        realm.beginWrite()
        realm.delete(message)
        try! realm.commitWrite()
    }

    /// 获取会话所有消息
    ///
    /// - Parameters:
    ///   - conversationID: 会话标识,必须为正整数
    ///   - messageID: 消息标识,当传入该值后,获取比该值更小(也就是发送时间更早)的消息,没有传入该值时,获取所有消息
    /// - Returns: 查询后的数据
    func getMessages(with conversationID: Int!, messageDate: NSDate?) -> Results<TSMessageObject> {
        let predicate: NSPredicate
        if let realMessageDate = messageDate {
            predicate = NSPredicate(format: "conversationID = \(conversationID!) AND responseTimeStamp < %@", realMessageDate)
        } else {
            predicate = NSPredicate(format: "conversationID = \(conversationID!)")
        }
        return realm.objects(TSMessageObject.self).filter(predicate).sorted(byKeyPath: "responseTimeStamp", ascending: false)
    }

    /// 获取会话所有未读消息
    func getUnreadMessages(with conversationID: Int!) -> Results<TSMessageObject> {
        let predicate = NSPredicate(format: "conversationID = \(conversationID!) AND isRead = false")
        return realm.objects(TSMessageObject.self).filter(predicate).sorted(byKeyPath: "responseTimeStamp", ascending: false)
    }

    func save(message: TSMessageObject!) {
        try! realm.write {
            realm.add(message)
            try! realm.commitWrite()
        }
    }

    // MARK: - conversation
    /// 返回根据最新消息时间排序的会话对象
    func getLatestConversationinfo() -> Results<TSConversationObject> {
        return realm.objects(TSConversationObject.self).filter("latestMessage != nil").sorted(byKeyPath: "latestMessageDate", ascending: false)
    }

    func getConversationInfo(with identity: Int) -> TSConversationObject? {
        let conversationObjects = realm.objects(TSConversationObject.self).filter("identity == \(identity)")
        if conversationObjects.isEmpty {
            return nil
        }
        return conversationObjects.first
    }

    func getConversationInfo(withUserInfoId: Int) -> TSConversationObject? {
        let currentUserInfoId = TSCurrentUserInfo.share.userInfo?.userIdentity
        assert(currentUserInfoId != withUserInfoId, "只能查询他人的会话ID")
        let conversationObjects = realm.objects(TSConversationObject.self).filter("incomingUserIdentity == \(withUserInfoId)")
        if conversationObjects.isEmpty {
            return nil
        }
        return conversationObjects.first
    }

    func update(conversation: TSConversationObject, latestMessage: TSMessageObject) {
        realm.beginWrite()
        conversation.latestMessage = latestMessage.messageContent
        conversation.latestMessageDate = latestMessage.responseTimeStamp
        if let sendResult = latestMessage.isOutgoing.value {
            conversation.isSendingLatestMessage.value = sendResult
        }
        try! realm.commitWrite()
    }

    func save(chatConversation: TSConversationObject) {
        try! realm.write {
            realm.add(chatConversation, update: true)
            try! realm.commitWrite()
        }
    }

    /// 会话未读数加1
    func addOneUnreadCount(_ conversationId: Int) {
        let conversation = getConversationInfo(with: conversationId)
        realm.beginWrite()
        conversation?.unreadCount += 1
        try! realm.commitWrite()
    }

    /// 删除会话,同时删除会话对应的所有消息数据
    func delete(conversation: TSConversationObject) {
        realm.beginWrite()
        let results = getMessages(with: conversation.identity, messageDate: nil)
        realm.delete(results)
        realm.delete(conversation)
        try! realm.commitWrite()
    }

    func countAllConversationUnreadCount() {
        let results = getLatestConversationinfo()
        if results.isEmpty {
            return
        }
        DispatchQueue.main.async(execute: {
            for conversationObject in results {
                let unreadCount = self.getUnreadCount(with: conversationObject
                        .identity)
                self.realm.beginWrite()
                conversationObject.unreadCount = unreadCount
                self.realm.add(conversationObject, update: true)
                try! self.realm.commitWrite()
            }
        })
    }

    // 写入数据
    func processAndWrite(_ conversationModels: [TSConversationModel], _ userInfoObjectlDic: [Int: TSUserInfoObject], complete: @escaping ((_ error: NSError?) -> Void)) {
        for conversationModel in conversationModels {
            let oldConversationObjects = realm.objects(TSConversationObject.self).filter("identity = %d", conversationModel.identity)
            var newConversationObject = TSConversationObject()
            guard let userInfoObject = userInfoObjectlDic[conversationModel.getIncomingUserId()] else {
                fatalError("返回的会话信息和用户信息无法对应")
            }
            if oldConversationObjects.isEmpty {
                newConversationObject.identity = conversationModel.identity
                newConversationObject.incomingUserIdentity = conversationModel.getIncomingUserId()
                newConversationObject.incomingUserName = userInfoObject.name

                self.realm.beginWrite()
                self.realm.add(newConversationObject, update: true)
                try! self.realm.commitWrite()
            } else {
                // 更新所有的值
                self.realm.beginWrite()
                newConversationObject = oldConversationObjects.first!
                newConversationObject.incomingUserIdentity = conversationModel.getIncomingUserId()
                newConversationObject.incomingUserName = userInfoObject.name
                self.realm.add(newConversationObject, update: true)
                try! self.realm.commitWrite()
            }
        }
        complete(nil)
    }

}

// MARK: - 消息列表页section0的杂项数据
extension TSChatDatabaseManager {
    /// 删除所有的杂项数据
    func deleteAllConversationUtilData() -> Void {
        try! realm.write {
            let objects = realm.objects(TSConversationUtilDataObject.self)
            realm.delete(objects)
        }
    }

    /// id数组元素去重
    fileprivate func removeRepetedUserId(usersId: [Int]) -> [Int] {
        var newUsersId = [Int]()
        for id in usersId {
            if !newUsersId.contains(id) {
                newUsersId.append(id)
            }
        }
        return newUsersId
    }

}
