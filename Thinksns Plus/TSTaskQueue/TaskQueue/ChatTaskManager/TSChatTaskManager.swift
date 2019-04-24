//
//  TSChatTaskManager.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  聊天任务管理

import UIKit
import RealmSwift

class TSChatTaskManager: NSObject {
    /// 开始私信聊天
    ///
    /// - Parameters:
    ///   - userIdentity: 聊天对象的用户ID
    ///   - complete: 开始聊天的结果
    /// - Note: 该接口会等待服务器鉴权,可能会等待较长时间
    class func startChat(with userIdentity: Int, complete: @escaping ((_ error: NSError?) -> Swift.Void)) {
//        let currentUserId = TSCurrentUserInfo.share.accountToken?.userIdentity
//        guard let userInfoObject = TSDatabaseManager().user.get(userIdentity) else {
//            fatalError("创建会话时,该用户信息数据库检索不到")
//        }
//
//        // 数据库没有的情况下,申请服务器创建
//        TSIMNetworkManager.createConversation(with: .privately, users: [userIdentity, currentUserId!]) { (conversationModel, error) in
//            if error != nil {
//                complete(error)
//                return
//            }
//            // 更新聊天会话数据库
//            TSDatabaseManager().chat.processAndWrite([conversationModel!], [userIdentity: userInfoObject], complete: { (error) in
//                complete(error)
//            })
//        }
    }

    /// 处理陌生人发送的消息
    ///
    /// - Parameters:
    ///   - conversationID: 会话ID
    ///   - userId: 发消息人的ID
    ///   - complete: 处理结果
    /// - Note: 从服务器查询会话信息,再查询用户信息,再获取缺失的消息,再存储
    class func processStrangerMessage(conversationID: Int, complete: @escaping ((_ error: NSError?) -> Swift.Void)) {
//        if TSCurrentUserInfo.share.isLogin == false {
//            complete(TSErrorCenter.create(With: .Uninitialized))
//            return
//        }
//        TSIMNetworkManager.getConversationInfo(conversationID) { (model, error) in
//            if error != nil {
//                complete(error)
//                return
//            }
//            guard let realModel = model else {
//                return
//            }
//            // 获取用户信息
//            var userIds: Array<Int> = []
//            for index in 0..<realModel.member.count {
//                let uid = realModel.member[index]
//                if uid != TSCurrentUserInfo.share.accountToken!.userIdentity {
//                    userIds = [uid]
//                    continue
//                }
//            }
//            assert(userIds.count == 1, "过滤后的用户信息是错误的")
//            TSDataQueueManager.share.userInfoQueue.getData(userIds: userIds, isQueryDB: false, isMust: true, complete: { (userInfoObjectArray, error) in
//                if error != nil {
//                    complete(error)
//                    return
//                }
//                // 更新聊天会话数据库
//                TSDatabaseManager().chat.processAndWrite([realModel], [userIds.first!: userInfoObjectArray!.first!], complete: { (error) in
//                    complete(error)
//                })
//            })
//        }
    }

    /// 刷新聊天清单
    class func refreshConversationList(complete: @escaping (_ result: Bool) -> Swift.Void) {
//        TSIMNetworkManager.getConversationInfoList { (chatConversationModels, error) in
//            if error != nil {
//                complete(false)
//                return
//            }
//            var conversationUserIds = [Int]()
//            for conversationModel in chatConversationModels! {
//                conversationUserIds.append(conversationModel.getIncomingUserId())
//            }
//            if conversationUserIds.isEmpty {
//                complete(true)
//                return
//            }
//            complete(true)
//            // 获取并且写入用户数据
//            TSTaskQueueTool.getAndSave(userInfo: conversationUserIds, complete: { (_, userInfoObjectlDic, error) in
//                // 更新聊天会话数据库
//                TSDatabaseManager().chat.processAndWrite(chatConversationModels!, userInfoObjectlDic!, complete: { (error) in
//                    if error != nil {
//                        complete(false)
//                        return
//                    }
//                    complete(true)
//                })
//            })
//        }
    }

    /// 排除相同的userId
    ///
    /// - Parameters:
    ///   - userId: 需要保存的用户id
    ///   - userIds: 用来保存的用户id
    fileprivate class func checkUserId(userId: Int, userIds: inout [Int] ) {
        if !userIds.contains(userId) {
            userIds.append(userId)
        }
    }
}
