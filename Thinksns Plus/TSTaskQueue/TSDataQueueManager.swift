//
//  TSMessageQueueManager.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  队列管理类
//  TODO: 逐步废弃该类和 TSTaskQueue,使用 TSRealmManager

import UIKit

class TSDataQueueManager: NSObject {
    static let share = TSDataQueueManager()

    enum FollowAndFansKey: String {
        case fans = "followeds"
        case follow = "follows"
    }

    private override init() {
        super.init()
        continueTask()
        addNotificationObserver()
    }

    // 用户
    let userInfoQueue = TSUserInfoQueue()

    // 动态
    let moment = TSMomentTaskQueue()

    // 评论
    let comment = TSCommentTaskQueue()

    // 资讯
    let nows = TSNewsTaskManager()

    // 钱包
    let wallet = TSWalletTaskQueue()

    // 广告
    let advert = TSAdvertTaskQueue()

    // 找人
    let findFriends = FindFriendTaskQueue()
    // 上传
    var uploadManager: TSUploadNetworkManager = TSUploadNetworkManager()

    /// 是否第一次启动 app
    private var isOpenApp = true

    // MARK: - Private

    /// 继续未完成的任务
    private func continueTask() {
        // 动态点赞任务
        moment.continueDiggTask(isOpenApp: isOpenApp)
        // 动态收藏任务
        moment.continueCollectionTask(isOpenApp: isOpenApp)
        // 动态删除任务
        moment.continueDeleteTask(isOpenApp: isOpenApp)
        // 修改未发布成功的动态，并改变状态
        moment.checkReleaseFailTask(isOpenApp: isOpenApp)
        // 评论的任务
        comment.checkFailCommentsTask(isOpenApp: isOpenApp)
        // 广告任务
        advert.continueTask()

        isOpenApp = false
    }

    // MARK: - Notification
    /// 添加观察者检测网络变动
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: Notification.Name.Reachability.Changed, object: nil)
    }

    /// 网络变动响应时间
    func networkChanged(_ notification: Notification) {
        switch TSReachability.share.reachabilityStatus {
        case .WIFI, .Cellular:
//            if TSCurrentUserInfo.share.accountToken != nil {
                continueTask()
//            }
        case .NotReachable:
            break
        }
    }
}
