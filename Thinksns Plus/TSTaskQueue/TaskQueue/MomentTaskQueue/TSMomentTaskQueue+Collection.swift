//
//  TSMomentTaskQueue+Collection.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态收藏任务

import UIKit

extension TSMomentTaskQueue {

    /// 收藏任务队列
    func start(collect feedId: Int, isCollect: Bool) {
        let newCollect = isCollect ? 1 : 0

        // 发起网络任务
        let shouldNetwork = shouldCollectNetwork(newCollect, feedIdentity: feedId)
        if shouldNetwork {
            network(collect: newCollect, feedIdentity: feedId)
        }
//        // 更改动态数据库
//        TSDatabaseManager().moment.change(collect: oldMomentObject)
    }

    /// 继续未完成的收藏任务
    func continueCollectionTask(isOpenApp: Bool) {
        var list = TSDatabaseManager().momentTask.getFaildCollectList()
        if isOpenApp {
            list = TSDatabaseManager().momentTask.getUnFinishedCollectList()
        }
        if list.isEmpty {
            return
        }
        for task in list {
            TSDatabaseManager().momentTask.changeToStartState(collect: task)
            network(collect: task.collectState, feedIdentity: task.feedIdentity)
        }
    }

    // MARK: - Private

    /// 收藏网络请求
    private func network(collect newCollect: Int, feedIdentity: Int) {
        // 查询次数
        var count = collectNetCountArray[feedIdentity]
        if let count = count {
            collectNetCountArray.updateValue(count + 1, forKey: feedIdentity)
        } else {
            collectNetCountArray.updateValue(1, forKey: feedIdentity)
            count = 1
        }
        TSMomentNetworkManager().colloction(newCollect, feedIdentity: feedIdentity) { (isSuccess) in
            // 请求成功
            if isSuccess {
                // 获取任务
                let task = TSDatabaseManager().momentTask.getCollect(feedIdentity)!
                // 判断数据库的任务和当前网络请求的结果是否匹配
                if task.collectState == newCollect {
                    // 匹配，结束任务
                    TSDatabaseManager().momentTask.end(collect: task, success: true)
                    self.collectNetCountArray.updateValue(0, forKey: feedIdentity)
                } else {
                    // 不匹配，再进行网络其请求
                    self.network(collect: task.collectState, feedIdentity: task.feedIdentity)
                }
                return
            }
            // 请求失败
            if count! < self.networkCountMax {
                // 继续请求
                if TSCurrentUserInfo.share.accountToken != nil {
                    self.network(collect: newCollect, feedIdentity: feedIdentity)
                }
            } else {
                // 结束请求，更新任务状态
                // 获取任务
                let task = TSDatabaseManager().momentTask.getCollect(feedIdentity)!
                TSDatabaseManager().momentTask.end(collect: task, success: false)
                self.collectNetCountArray.updateValue(0, forKey: feedIdentity)
            }
        }
    }

    /// 判断是否发起收藏网络请求，并保存任务
    private func shouldCollectNetwork(_ newCollect: Int, feedIdentity: Int) -> Bool {
        var shouldCollectNetwork = false
        if TSCurrentUserInfo.share.accountToken != nil {
            let task = TSDatabaseManager().momentTask.getCollect(feedIdentity)
            if let task = task {
                if task.taskState == 1 {
                    shouldCollectNetwork = true
                } else {
                    shouldCollectNetwork = false
                }
            } else {
                shouldCollectNetwork = true
            }
        }
        TSDatabaseManager().momentTask.save(collectTask: newCollect, feedIdentity: feedIdentity)
        return shouldCollectNetwork
    }

}
